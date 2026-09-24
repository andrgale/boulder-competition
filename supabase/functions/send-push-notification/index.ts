import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID")!;
const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
const firebasePrivateKey = Deno.env.get("FIREBASE_PRIVATE_KEY")!.replace(/\\n/g, "\n");
const adminClient = createClient(supabaseUrl, serviceRoleKey);

type NotificationType =
  | "competition_open"
  | "competition_closed"
  | "competition_qualificated";

type RequestBody = {
  type: NotificationType;
  titleIt: string;
  bodyIt: string;
  titleEn: string;
  bodyEn: string;
  turn?: "first" | "second";
};

function base64Url(value: string | Uint8Array): string {
  const bytes = typeof value === "string" ? new TextEncoder().encode(value) : value;
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
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (char) => char.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedToken),
  );
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsignedToken}.${base64Url(new Uint8Array(signature))}`,
    }),
  });
  if (!response.ok) throw new Error(`Google OAuth failed: ${await response.text()}`);
  return (await response.json()).access_token as string;
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

    const { type, titleIt, bodyIt, titleEn, bodyEn, turn } =
      await request.json() as RequestBody;

    if (
      !["competition_open", "competition_closed", "competition_qualificated"].includes(type) ||
      !titleIt?.trim() || !bodyIt?.trim() ||
      !titleEn?.trim() || !bodyEn?.trim()
    ) {
      throw new Error("type, titleIt, bodyIt, titleEn and bodyEn are required");
    }
    const { data: competition, error: competitionError } = await adminClient
      .from("competitions")
      .select("id, nr_finalisti, is_turn")
      .eq("fl_gara_chiusa", false)
      .order("dt_gara", { ascending: true })
      .limit(1)
      .maybeSingle();
    if (competitionError) throw competitionError;
    if (!competition) throw new Error("No open competition found");
    if (
      competition.is_turn &&
      type !== "competition_qualificated" &&
      turn !== "first" &&
      turn !== "second"
    ) {
      throw new Error("turn is required for this notification");
    }

    let registrationQuery = adminClient.from("registrations").select("profile_id");
    if (type === "competition_qualificated") {
      const { data: rankings, error: rankingError } = await adminClient
        .from("v_registration_rankings_qualificazione")
        .select("registration_id, sesso")
        .eq("competition_id", competition.id)
        .order("punteggio_totale", { ascending: false });
      if (rankingError) throw rankingError;
      const registrationIds = [
        ...(rankings ?? []).filter((row) => row.sesso === "M")
          .slice(0, competition.nr_finalisti ?? 0),
        ...(rankings ?? []).filter((row) => row.sesso === "F")
          .slice(0, competition.nr_finalisti ?? 0),
      ].map((row) => row.registration_id);
      if (registrationIds.length === 0) {
        return new Response(JSON.stringify({ sent: 0 }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      registrationQuery = registrationQuery.in("id", registrationIds);
    } else {
      registrationQuery = registrationQuery.eq("competition_id", competition.id);
      if (competition.is_turn) {
        registrationQuery = registrationQuery.eq(
          turn === "first" ? "is_first_turn" : "is_second_turn",
          true,
        );
      }
    }

    const { data: registrations, error: registrationError } = await registrationQuery;
    if (registrationError) throw registrationError;
    const profileIds = [...new Set(
      (registrations ?? [])
        .map((registration) => registration.profile_id)
        .filter((profileId): profileId is string => Boolean(profileId)),
    )];
    if (profileIds.length === 0) {
      return new Response(JSON.stringify({ sent: 0 }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: profiles, error: profileError } = await adminClient
      .from("profiles")
      .select("auth_user_id")
      .in("id", profileIds);
    if (profileError) throw profileError;
    const authUserIds = (profiles ?? []).map((profile) => profile.auth_user_id);
    const { data: devices, error: deviceError } = await adminClient
      .from("user_devices")
      .select("fcm_token, language_code")
      .in("auth_user_id", authUserIds);
    if (deviceError) throw deviceError;
    const accessToken = await createAccessToken();
    const results = await Promise.all((devices ?? []).map(async (device) => {
      const isItalian = device.language_code?.toUpperCase() === "IT";
      const notification = isItalian
        ? { title: titleIt, body: bodyIt }
        : { title: titleEn, body: bodyEn };

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
              notification,
              data: { type },
            },
          }),
        },
      );

      if (!response.ok) {
        console.error("FCM error:", response.status, await response.text());

        // Token non più registrato (app disinstallata, ecc.): lo rimuovo
        if (response.status === 404) {
          const { error: deleteError } = await adminClient
            .from("user_devices")
            .delete()
            .eq("fcm_token", device.fcm_token);
          if (deleteError) {
            console.error("Token cleanup failed:", deleteError);
          }
        }
      }

      return { ok: response.ok };
    }));

    return new Response(JSON.stringify({
      sent: results.filter((result) => result.ok).length,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("send-push-notification error:", error);
    return new Response(JSON.stringify({
      error: error instanceof Error ? error.message : JSON.stringify(error),
    }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});