import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as parse5 from "https://esm.sh/parse5@7";

// =========================================================
// CORS
// =========================================================

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// =========================================================
// CONFIG
// =========================================================

const DEFAULT_LANGUAGE = "it";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// =========================================================
// TIPI
// =========================================================

type EmailTemplate = {
  id: string;
  template_code: string;
  language: string;
  version: number;
  status: string;
  active: boolean;
  subject: string;
  html_body: string;
  is_default: boolean;
};

type VariableDefinition = {
  variable_code: string;
  data_type: "text" | "number" | "date" | "datetime" | "url" | "email";
  required: boolean;
  default_value: string | null;
  validation: Record<string, unknown>;
};

// =========================================================
// ENTRYPOINT
// =========================================================
//
// Input atteso (body JSON):
// {
//   "email": "destinatario@example.com",   // obbligatorio: destinatario reale
//   "toName": "Mario Rossi",                // opzionale: nome mostrato nel campo "A:"
//   "templateCode": "REG_GARA",             // obbligatorio: codice template
//   "language": "it",                       // opzionale, default "it"
//   "tags": ["extra-tag"],                  // opzionale: tag aggiuntivi per Brevo
//   "variables": {                          // chiave = variable_code del template
//     "NOME_ATLETA": "Mario Rossi",
//     "DESC_GARA": "Coppa Italia",
//     "QUALSIASI_ALTRA_VARIABILE": "..."
//   }
// }
//
// Header opzionale "x-registration-token": usato SOLO nel flusso di
// auto-registrazione, quando non esiste ancora una sessione utente.
// Vedi blocco di autenticazione/autorizzazione più sotto.
//
// Non esiste più alcun mapping "legacy": le chiavi di `variables` devono
// coincidere esattamente con i variable_code dichiarati in
// email_template_variables per quel template. Se il testo del template
// cambia (nuove variabili, variabili rimosse), basta aggiornare la pagina
// chiamante: questa function non richiede modifiche.

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

    const {
      email,
      toName,
      templateCode,
      language,
      tags,
      variables,
    } = body as {
      email?: string;
      toName?: string;
      templateCode?: string;
      language?: string;
      tags?: string[];
      variables?: Record<string, unknown>;
    };

    if (!email) {
      return jsonResponse({ error: "email mancante" }, 400);
    }

    if (!templateCode?.trim()) {
      return jsonResponse({ error: "templateCode mancante" }, 400);
    }

    const resolvedTemplateCode = templateCode.trim();
    const resolvedLanguage = language?.trim() || DEFAULT_LANGUAGE;

    // ── 1. Autenticazione e autorizzazione ─────────────────────────
    const authHeader = req.headers.get("authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    const registrationToken = req.headers.get("x-registration-token")?.trim();

    const isServiceContext = jwt === SUPABASE_SERVICE_ROLE_KEY;

    // Client con service role, usato per template/variabili e per la
    // validazione del token di registrazione (non richiede sessione utente).
    const db = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    if (!isServiceContext) {
      const requestedEmail = email.trim().toLowerCase();

      if (registrationToken) {
        // ── Percorso auto-registrazione: nessuna sessione utente ancora
        // attiva, autorizzazione basata su token monouso a scadenza breve.
        const { data: tokenRow, error: tokenError } = await db
          .from("email_send_tokens")
          .select("token, email, purpose, expires_at")
          .eq("token", registrationToken)
          .maybeSingle();

        if (tokenError) {
          throw new Error(`Errore validazione token: ${tokenError.message}`);
        }

        // TEMP DEBUG - rimuovi dopo la verifica
        console.log("registrationToken ricevuto:", registrationToken);
        console.log("tokenRow trovato:", JSON.stringify(tokenRow));
        console.log("requestedEmail:", requestedEmail);
        console.log("resolvedTemplateCode:", resolvedTemplateCode);
        if (tokenRow) {
          console.log("email match:", tokenRow.email.toLowerCase() === requestedEmail);
          console.log("purpose match:", tokenRow.purpose === resolvedTemplateCode);
          console.log("expires check:", new Date(tokenRow.expires_at).getTime(), ">", Date.now());
        }       

        const isValid = tokenRow &&
          tokenRow.email.toLowerCase() === requestedEmail &&
          tokenRow.purpose === resolvedTemplateCode &&
          new Date(tokenRow.expires_at).getTime() > Date.now();

        if (!isValid) {
          return jsonResponse({
            error: "Token di registrazione non valido o scaduto",
          }, 401);
        }

        // monouso: lo elimino subito dopo la validazione
        await db.from("email_send_tokens").delete().eq(
          "token",
          registrationToken,
        );
      } else {
        // ── Percorso utente autenticato (JWT di sessione) ──────────
        if (!jwt) {
          return jsonResponse({ error: "Autenticazione richiesta" }, 401);
        }

        // Client "come utente": necessario perché auth.uid() dentro
        // has_role() viene risolto dal JWT presente in questo client,
        // non dal client con service role.
        const supabaseAsUser = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
          global: { headers: { Authorization: `Bearer ${jwt}` } },
        });

        const { data: userData, error: userError } = await supabaseAsUser
          .auth.getUser(jwt);

        if (userError || !userData?.user) {
          return jsonResponse({ error: "Token non valido" }, 401);
        }

        const authEmail = userData.user.email?.trim().toLowerCase();
        const isSelf = authEmail === requestedEmail;

        if (!isSelf) {
          const { data: isAdmin, error: roleError } = await supabaseAsUser
            .rpc("has_role", { role_code: "admin" });

          if (roleError) {
            throw new Error(`Errore verifica ruolo: ${roleError.message}`);
          }

          if (!isAdmin) {
            return jsonResponse({
              error: "Non autorizzato a inviare mail per questo indirizzo",
            }, 403);
          }
        }
      }
    }

    // ── 2. Caricamento template attivo (code + lingua, poi fallback default) ──
    const template = await loadActiveTemplate(
      db,
      resolvedTemplateCode,
      resolvedLanguage,
    );

    if (!template) {
      return jsonResponse({
        error:
          `Nessun template attivo trovato per "${resolvedTemplateCode}"`,
      }, 404);
    }

    // ── 3. Caricamento variabili dichiarate per il template ───────────
    const { data: variableRows, error: variablesError } = await db
      .from("email_template_variables")
      .select(
        "variable_code, data_type, required, default_value, validation",
      )
      .eq("template_id", template.id);

    if (variablesError) {
      throw new Error(
        `Errore caricamento variabili template: ${variablesError.message}`,
      );
    }

    const definitions: VariableDefinition[] = (variableRows ?? []).map(
      (row) => ({
        variable_code: row.variable_code,
        data_type: row.data_type,
        required: !!row.required,
        default_value: row.default_value,
        validation: (row.validation ?? {}) as Record<string, unknown>,
      }),
    );

    const definitionsByCode = new Map(
      definitions.map((d) => [d.variable_code, d]),
    );

    // ── 4. Valori delle variabili: passati integralmente dal chiamante ──
    // Nessun mapping legacy: la pagina chiamante è responsabile di passare
    // in `variables` esattamente le chiavi dichiarate per il template.
    // Chiavi sconosciute o mancanti (se required) vengono rifiutate da
    // resolveValues più sotto.
    const values = resolveValues(definitions, variables ?? {});

    // ── 5. Sanitizzazione dell'HTML salvato ────────────────────────
    const sanitizedHtml = sanitizeHtml(template.html_body);

    // ── 6. Rendering: sostituzione token in testo/attributi ammessi ──
    const renderedHtml = renderHtml(sanitizedHtml, values, definitionsByCode);
    const renderedSubject = renderSubject(template.subject, values);

    // ── 7. Invio a Brevo del solo HTML risultante ──────────────────
    const resolvedTags = [resolvedTemplateCode, ...(tags ?? [])];

    await sendViaBrevo({
      toEmail: email,
      toName: toName?.trim() || " ",
      subject: renderedSubject,
      html: renderedHtml,
      tags: resolvedTags,
    });

    return jsonResponse({ ok: true }, 200);
  } catch (err) {
    console.error("Errore invio mail da template:", err.message);
    return jsonResponse({ error: err.message }, 500);
  }
});

// =========================================================
// HELPERS - RESPONSE
// =========================================================

function jsonResponse(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// =========================================================
// TEMPLATE LOADING
// =========================================================

async function loadActiveTemplate(
  // deno-lint-ignore no-explicit-any
  db: any,
  templateCode: string,
  language: string,
): Promise<EmailTemplate | null> {
  // Tentativo 1: versione attiva per code + lingua richiesta.
  const { data: exact, error: exactError } = await db
    .from("email_templates")
    .select(
      "id, template_code, language, version, status, active, subject, html_body, is_default",
    )
    .eq("template_code", templateCode)
    .eq("language", language)
    .eq("status", "active")
    .order("version", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (exactError) {
    throw new Error(`Errore caricamento template: ${exactError.message}`);
  }

  if (exact) return exact as EmailTemplate;

  // Tentativo 2: fallback sulla versione attiva marcata come default.
  const { data: fallback, error: fallbackError } = await db
    .from("email_templates")
    .select(
      "id, template_code, language, version, status, active, subject, html_body, is_default",
    )
    .eq("template_code", templateCode)
    .eq("is_default", true)
    .eq("status", "active")
    .order("version", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (fallbackError) {
    throw new Error(
      `Errore caricamento template di default: ${fallbackError.message}`,
    );
  }

  return (fallback as EmailTemplate) ?? null;
}

// =========================================================
// VALIDAZIONE E RENDERING VARIABILI
// =========================================================

const tokenPattern = /\{\{([A-Z][A-Z0-9_]*)\}\}/g;

function validateValue(def: VariableDefinition, raw: unknown): string {
  if (typeof raw !== "string") {
    throw new Error(`${def.variable_code} must be a string`);
  }

  const value = raw.trim();

  if (def.data_type === "number" && !Number.isFinite(Number(value))) {
    throw new Error(`${def.variable_code} must be a number`);
  }

  if (def.data_type === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
    throw new Error(`${def.variable_code} must be an email`);
  }

  if (def.data_type === "url") {
    const url = new URL(value);

    if (url.protocol !== "https:") {
      throw new Error(`${def.variable_code} accepts HTTPS URLs only`);
    }
  }

  const maxLength = Number(def.validation.maxLength ?? 1000);
  if (value.length > maxLength) {
    throw new Error(`${def.variable_code} exceeds max length`);
  }

  return value;
}

function resolveValues(
  definitions: VariableDefinition[],
  input: Record<string, unknown>,
): Record<string, string> {
  // Le chiavi in `input` non dichiarate dal template vengono ignorate
  // volutamente: il chiamante può passare un "paniere" con tutti i campi
  // potenzialmente disponibili, ed è il template a scegliere quali usare.
  // L'unico errore possibile è una variabile RICHIESTA dal template e
  // mancante (o vuota) in input.
  const values: Record<string, string> = {};

  for (const def of definitions) {
    const supplied = input[def.variable_code];
    const raw = supplied ?? def.default_value;

    if ((raw === null || raw === undefined || raw === "") && def.required) {
      throw new Error(`Missing required variable: ${def.variable_code}`);
    }

    if (raw !== null && raw !== undefined) {
      values[def.variable_code] = validateValue(def, raw);
    }
  }

  return values;
}

function renderSubject(
  subject: string,
  values: Record<string, string>,
): string {
  const rendered = subject.replace(tokenPattern, (_, code) => {
    if (!(code in values)) throw new Error(`Missing variable: ${code}`);
    return values[code];
  });

  // Evita header injection SMTP.
  if (/[\r\n]/.test(rendered)) {
    throw new Error("Invalid subject");
  }

  return rendered;
}

function renderHtml(
  sanitizedHtml: string,
  values: Record<string, string>,
  definitions: Map<string, VariableDefinition>,
): string {
  const document = parse5.parseFragment(sanitizedHtml);

  visitNodes(document, (node) => {
    // Token nei testi: il serializer HTML farà l'escaping.
    if (node.nodeName === "#text") {
      node.value = node.value.replace(tokenPattern, (_: string, code: string) => {
        if (!(code in values)) throw new Error(`Missing variable: ${code}`);
        return values[code];
      });
    }

    // Token negli attributi: ammetti solo l'intero valore {{VARIABLE}}.
    for (const attribute of node.attrs ?? []) {
      const match = attribute.value.match(/^\{\{([A-Z][A-Z0-9_]*)\}\}$/);

      if (!match) continue;

      const code = match[1];
      const definition = definitions.get(code);

      if (!definition || !(code in values)) {
        throw new Error(`Missing or unknown variable: ${code}`);
      }

      if (attribute.name.startsWith("on") || attribute.name === "style") {
        throw new Error(`Dynamic value forbidden in ${attribute.name}`);
      }

      if (
        ["href", "src"].includes(attribute.name) &&
        definition.data_type !== "url"
      ) {
        throw new Error(`${code} must be URL type in ${attribute.name}`);
      }

      attribute.value = values[code];
    }
  });

  return parse5.serialize(document);
}

// deno-lint-ignore no-explicit-any
function visitNodes(node: any, callback: (node: any) => void) {
  callback(node);
  if (node.childNodes) {
    for (const child of node.childNodes) {
      visitNodes(child, callback);
    }
  }
}

// =========================================================
// SANITIZZAZIONE HTML (allowlist)
// =========================================================

const ALLOWED_TAGS = new Set([
  "p",
  "br",
  "hr",
  "strong",
  "b",
  "em",
  "i",
  "u",
  "span",
  "div",
  "ul",
  "ol",
  "li",
  "a",
  "img",
  "h1",
  "h2",
  "h3",
  "h4",
  "blockquote",
  "table",
  "thead",
  "tbody",
  "tr",
  "td",
  "th",
]);

const ALLOWED_ATTRS: Record<string, Set<string>> = {
  a: new Set(["href", "target", "rel", "title"]),
  img: new Set(["src", "alt", "width", "height", "style"]),
  span: new Set(["style"]),
  div: new Set(["style"]),
  p: new Set(["style"]),
  table: new Set(["style", "width", "cellpadding", "cellspacing", "border"]),
  td: new Set(["style", "colspan", "rowspan", "align"]),
  th: new Set(["style", "colspan", "rowspan", "align"]),
};

function sanitizeHtml(rawHtml: string): string {
  const fragment = parse5.parseFragment(rawHtml);
  sanitizeNode(fragment);
  return parse5.serialize(fragment);
}

// deno-lint-ignore no-explicit-any
function sanitizeNode(node: any) {
  if (!node.childNodes) return;

  // deno-lint-ignore no-explicit-any
  const kept: any[] = [];

  for (const child of node.childNodes) {
    if (child.nodeName === "#comment") {
      continue; // rimuove i commenti
    }

    if (child.nodeName === "#text") {
      kept.push(child);
      continue;
    }

    const tag: string | undefined = child.tagName;

    if (!tag || !ALLOWED_TAGS.has(tag)) {
      // Tag non ammesso: viene scartato interamente (con i suoi figli),
      // così script/style/iframe/form ecc. non possono "sopravvivere"
      // spacchettando solo il tag esterno.
      continue;
    }

    if (child.attrs) {
      const allowed = ALLOWED_ATTRS[tag] ?? new Set<string>();

      // deno-lint-ignore no-explicit-any
      child.attrs = child.attrs.filter((attr: any) => {
        const name = attr.name.toLowerCase();

        if (name.startsWith("on")) return false;
        if (!allowed.has(name)) return false;

        if (name === "href" || name === "src") {
          const value = attr.value.trim();
          const isToken = /^\{\{[A-Z][A-Z0-9_]*\}\}$/.test(value);

          if (!isToken) {
            if (/^\s*javascript:/i.test(value)) return false;
            if (value.startsWith("//")) return false; // protocol-relative
            const isHttps = /^https:\/\//i.test(value);
            const isMailto = name === "href" && /^mailto:/i.test(value);
            if (!isHttps && !isMailto) return false;
          }
        }

        if (name === "style") {
          if (/url\s*\(|expression\s*\(|javascript:/i.test(attr.value)) {
            return false;
          }
        }

        return true;
      });
    }

    sanitizeNode(child);
    kept.push(child);
  }

  node.childNodes = kept;
}

// =========================================================
// INVIO BREVO
// =========================================================

async function sendViaBrevo(
  { toEmail, toName, subject, html, tags }: {
    toEmail: string;
    toName: string;
    subject: string;
    html: string;
    tags: string[];
  },
) {
  const apiKey = Deno.env.get("BREVO_API_KEY");
  const senderEmail = Deno.env.get("BREVO_SENDER_EMAIL");
  const senderName = Deno.env.get("BREVO_SENDER_NAME") ?? "BoulderCompetition";

  if (!apiKey || !senderEmail) {
    throw new Error("Credenziali Brevo mancanti");
  }

  const response = await fetch("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "api-key": apiKey,
    },
    body: JSON.stringify({
      sender: { name: senderName, email: senderEmail },
      to: [{ email: toEmail, name: toName }],
      subject,
      htmlContent: html,
      tags,
    }),
  });

  if (!response.ok) {
    const detail = await response.text();
    console.error("Brevo error:", detail);
    throw new Error("Invio email non riuscito");
  }

  return await response.json();
}