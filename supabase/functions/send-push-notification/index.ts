import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
const firebasePrivateKey = Deno.env
  .get("FIREBASE_PRIVATE_KEY")!
  .replace(/\\n/g, "\n");

type RequestBody = {
  profileIds: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
};

const adminClient = createClient(supabaseUrl, serviceRoleKey);

function base64Url(value: string | Uint8Array): string {
  const bytes = typeof value === "string"
    ? new TextEncoder().encode(value)
    : value;
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/, "");
}

async function createAccessToken(): Promise<string> {
  const header = base64Url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const now = Math.floor(Date.now() / 1000);
  const claim = base64Url(JSON.stringify({
    iss: firebaseClientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const unsignedToken = `${header}.${claim}`;
  const pem = firebasePrivateKey
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(pem), (char) => char.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken),
  );
  const jwt = `${unsignedToken}.${base64Url(new Uint8Array(signature))}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!response.ok) throw new Error(`Google OAuth failed: ${await response.text()}`);
  const result = await response.json();
  return result.access_token as string;
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authorization = request.headers.get("Authorization");
    if (!authorization) throw new Error("Missing authorization header");
    const userClient = createClient(
      supabaseUrl,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authorization } } },
    );
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) throw new Error("Unauthorized");
    const { data: isAdmin, error: roleError } = await userClient.rpc(
      "has_role",
      { role_code: "admin" },
    );
    if (roleError || isAdmin !== true) throw new Error("Forbidden");

    const { profileIds, title, body, data = {} } =
      await request.json() as RequestBody;
    if (!Array.isArray(profileIds) || profileIds.length === 0 || !title || !body) {
      throw new Error("profileIds, title and body are required");
    }

    const { data: profiles, error: profileError } = await adminClient
      .from("profiles")
      .select("auth_user_id")
      .in("id", profileIds);
    if (profileError) throw profileError;

    const authUserIds = (profiles ?? []).map((profile) => profile.auth_user_id);
    const { data: devices, error: deviceError } = await adminClient
      .from("user_devices")
      .select("fcm_token")
      .in("auth_user_id", authUserIds);
    if (deviceError) throw deviceError;

    const accessToken = await createAccessToken();
    const results = await Promise.all((devices ?? []).map(async (device) => {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
        {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: device.fcm_token,
              notification: { title, body },
              data,
            },
          }),
        },
      );
      return { token: device.fcm_token, ok: response.ok };
    }));

    return new Response(JSON.stringify({ sent: results.filter((result) => result.ok).length }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
    } catch (error) {
      console.error("send-push-notification error:", error);

      const errorDetails =
        error instanceof Error
          ? error.message
          : JSON.stringify(error);

      return new Response(
        JSON.stringify({ error: errorDetails }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }
  });
