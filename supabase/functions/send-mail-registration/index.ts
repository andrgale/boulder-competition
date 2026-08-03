import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// =========================================================
// CORS
// =========================================================

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// =========================================================
// ENTRYPOINT
// =========================================================

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      email,
      nome,
      cognome,
      competitionName,
      competitionDate,
      turno,
    } = await req.json();

    if (!email) {
      return new Response(
        JSON.stringify({ error: "email mancante" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const name = `${nome ?? ""} ${cognome ?? ""}`.trim();

    await sendRegistrationConfirmationEmail({
      email,
      name,
      competitionName,
      competitionDate,
      turno,
    });

    return new Response(
      JSON.stringify({ ok: true }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    console.error("Errore invio mail conferma iscrizione:", err.message);

    return new Response(
      JSON.stringify({ error: err.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

// =========================================================
// EMAIL CONFERMA ISCRIZIONE
// =========================================================

async function sendRegistrationConfirmationEmail({
  email,
  name,
  competitionName,
  competitionDate,
  turno,
}: {
  email: string;
  name?: string;
  competitionName?: string;
  competitionDate?: string;
  turno?: string | null;
}) {
  const apiKey = Deno.env.get("BREVO_API_KEY");
  const senderEmail = Deno.env.get("BREVO_SENDER_EMAIL");
  const senderName = Deno.env.get("BREVO_SENDER_NAME") ?? "BoulderCompetition";

  if (!apiKey || !senderEmail) {
    throw new Error("Credenziali Brevo mancanti");
  }

  const safeName = name?.trim() || " ";
  const safeCompetition = competitionName?.trim();
  const safeDate = competitionDate?.trim();
  const safeTurno = turno?.trim();

  // ── riepilogo iscrizione: gara, data e (se presente) turno ────────
  const riepilogoRighe: string[] = [];

  if (safeCompetition) {
    riepilogoRighe.push(
      `<li><strong>Gara:</strong> ${safeCompetition}</li>`,
    );
  }
  if (safeDate) {
    riepilogoRighe.push(`<li><strong>Data:</strong> ${safeDate}</li>`);
  }
  if (safeTurno) {
    riepilogoRighe.push(`<li><strong>Turno:</strong> ${safeTurno}</li>`);
  }

  const riepilogoHtml = riepilogoRighe.length
    ? `<ul>${riepilogoRighe.join("")}</ul>`
    : "";

  const response = await fetch("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: {
      "accept": "application/json",
      "content-type": "application/json",
      "api-key": apiKey,
    },
    body: JSON.stringify({
      sender: {
        name: senderName,
        email: senderEmail,
      },
      to: [
        {
          email,
          name: safeName,
        },
      ],
      subject: safeCompetition
        ? `Iscrizione alla gara di boulder "${safeCompetition}"${
            safeDate ? ` del ${safeDate}` : ""
          }`
        : "Iscrizione alla gara di boulder",
      htmlContent: `
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.5;">
            <h2>Ciao ${safeName}!</h2>

            <p>Ti confermiamo che la tua iscrizione${
              safeCompetition ? ` alla gara "${safeCompetition}"` : " alla gara"
            } è stata registrata correttamente. Ecco il riepilogo:</p>

            ${riepilogoHtml}

            <p>Se non hai richiesto tu l'iscrizione, ignora questa email.</p>
          </body>
        </html>
      `,
      tags: ["registration-confirmation"],
    }),
  });

  if (!response.ok) {
    const detail = await response.text();
    console.error("Brevo error:", detail);
    throw new Error("Invio email di conferma iscrizione non riuscito");
  }

  return await response.json();
}