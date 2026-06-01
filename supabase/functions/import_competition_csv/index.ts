import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "@supabase/supabase-js";
import { parse } from "csv-parse/sync";

serve(async (req) => {
  try {
    // =====================================================
    // INPUT
    // =====================================================

    const body = await req.json();

    console.log("BODY =", JSON.stringify(body));

    const competition_id = body.competition_id;
    const csv_content = body.csv_content;

    console.log("competition_id =", competition_id);

    if (!competition_id || !csv_content) {
      return new Response(
        JSON.stringify({
          error: "Parametri competition_id o csv_content mancanti",
        }),
        { status: 400 },
      );
    }

    // =====================================================
    // SUPABASE CLIENT
    // =====================================================

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // =====================================================
    // CHECK COMPETITION
    // =====================================================

    const { data: competition, error: compErr } = await supabase
      .from("competitions")
      .select("*")
      .eq("id", competition_id)
      .single();

    console.log("competition =", competition);
    console.log("compErr =", compErr);

    if (compErr) {
      return new Response(
        JSON.stringify({
          error: compErr.message,
          details: compErr,
        }),
        { status: 500 },
      );
    }

    if (!competition) {
      return new Response(
        JSON.stringify({
          error: "Competizione non trovata",
          competition_id,
        }),
        { status: 404 },
      );
    }

    if (competition.fl_gara_chiusa) {
      return new Response(
        JSON.stringify({
          error: "La competizione risulta chiusa",
        }),
        { status: 400 },
      );
    }

    // =====================================================
    // UNA SOLA GARA APERTA
    // =====================================================

    const { count: openCompetitions } = await supabase
      .from("competitions")
      .select("*", { count: "exact", head: true })
      .eq("fl_gara_chiusa", false)
      .neq("id", competition_id);

    if ((openCompetitions ?? 0) > 0) {
      return new Response(
        JSON.stringify({
          error: "Esiste già un'altra competizione aperta",
        }),
        { status: 400 },
      );
    }

    // =====================================================
    // IMPORT JOB
    // =====================================================

    const { data: importJob, error: importJobError } = await supabase
      .from("import_jobs")
      .insert({
        competition_id,
        file_name: "manual_upload.csv",
        status: "RUNNING",
        total_rows: 0,
        inserted_rows: 0,
        discarded_rows: 0,
  //      created_by: "import_function",
      })
      .select()
      .single();

    console.log("importJobError =", importJobError);

    if (importJobError) {
      throw new Error("Errore creazione import job: " + importJobError.message);
    }

    // =====================================================
    // CSV PARSE
    // =====================================================

    const rows = parse(csv_content, {
      delimiter: ";",
      skip_empty_lines: true,
      trim: true,
    });

    const hasHeader =
      rows.length > 0 &&
      rows[0][0]?.toLowerCase().includes("cognome");

    const dataRows = hasHeader ? rows.slice(1) : rows;

    // =====================================================
    // DATE CONVERSION
    // =====================================================

    function convertItalianDate(value: string | null | undefined): string | null {
      if (!value) return null;

      const parts = value.split("/");

      if (parts.length !== 3) {
        throw new Error("Data nascita non valida (GG/MM/AAAA)");
      }

      const [gg, mm, aaaa] = parts;

      return `${aaaa}-${mm.padStart(2, "0")}-${gg.padStart(2, "0")}`;
    }

    // =====================================================
    // NEXT PETTORALE (FIX: SOLO UNA VOLTA)
    // =====================================================

    async function getLastPettorale(supabase: any, competitionId: string) {
      const { data, error } = await supabase
        .from("registrations")
        .select("pettorale")
        .eq("competition_id", competitionId)
        .order("pettorale", { ascending: false })
        .limit(1);

      if (error) throw error;

      return data?.[0]?.pettorale ?? 0;
    }

    let lastPettorale = await getLastPettorale(supabase, competition_id);

    // =====================================================
    // ROLE ATHLETE
    // =====================================================

    const { data: athleteRole } = await supabase
      .from("roles")
      .select("id")
      .eq("code", "athlete")
      .maybeSingle();

    if (!athleteRole) {
      throw new Error("Ruolo atleta non trovato");
    }

    let inserted = 0;
    let discarded = 0;

    // =====================================================
    // PROCESS ROWS
    // =====================================================

    for (let i = 0; i < dataRows.length; i++) {
      const row = dataRows[i];
      const raw_row = row.join(";");

      try {
        const cognome = row[0]?.trim();
        const nome = row[1]?.trim();
        const sesso = row[2]?.trim()?.toUpperCase();
        const data_nascita = convertItalianDate(row[3]?.trim());
        const email = row[4]?.trim()?.toLowerCase();
        const societa = row[5]?.trim();

        // VALIDAZIONI
        if (!cognome) throw new Error("Cognome mancante");
        if (!nome) throw new Error("Nome mancante");
        if (!email || !email.includes("@")) throw new Error("Email non valida");
        if (sesso !== "M" && sesso !== "F") throw new Error("Sesso non valido");

        // PROFILE CHECK
        let profileId: string;

        const { data: existingProfile } = await supabase
          .from("profiles")
          .select("id")
          .eq("email", email)
          .maybeSingle();

        if (existingProfile) {
          profileId = existingProfile.id;
        } else {
          const { data: authUser, error: authErr } =
            await supabase.auth.admin.createUser({
              email,
              email_confirm: true,
            });

          if (authErr || !authUser.user) {
            throw new Error(authErr?.message ?? "Errore creazione utente");
          }

          const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .insert({
              auth_user_id: authUser.user.id,
              email,
              nome,
              cognome,
            })
            .select("id")
            .single();

          if (profileError || !profile) {
            throw new Error("Errore creazione profilo");
          }

          profileId = profile.id;

          const { error: roleInsertError } = await supabase
            .from("user_roles")
            .insert({
              profile_id: profileId,
              role_id: athleteRole.id,
            });

          if (roleInsertError) {
            throw new Error("Errore assegnazione ruolo atleta");
          }
        }

        // REGISTRATION CHECK
        const { data: existingRegistration } = await supabase
          .from("registrations")
          .select("id")
          .eq("competition_id", competition_id)
          .eq("profile_id", profileId)
          .maybeSingle();

        if (existingRegistration) {
          throw new Error("Utente già iscritto alla competizione");
        }

        // =====================================================
        // PETTORALE PROGRESSIVO (FIX)
        // =====================================================

        lastPettorale++;
        const nextPettorale = lastPettorale;

        // INSERT REGISTRATION
        await supabase.from("registrations").insert({
          competition_id,
          profile_id: profileId,
          cognome,
          nome,
          email,
          societa,
          sesso,
          data_nascita,
          pettorale: nextPettorale,
        });

        inserted++;

        // LOG SUCCESS
        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: i + 1,
          raw_row,
          status: "INSERTED",
        });

      } catch (err: any) {
        discarded++;

        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: i + 1,
          raw_row,
          status: "DISCARDED",
          error_message: err.message,
        });
      }

      // UPDATE JOB PROGRESS
      await supabase.from("import_jobs").update({
        total_rows: dataRows.length,
        inserted_rows: inserted,
        discarded_rows: discarded,
      }).eq("id", importJob.id);
    }

    // COMPLETE JOB
    await supabase.from("import_jobs").update({
      status: "COMPLETED",
      completed_at: new Date().toISOString(),
    }).eq("id", importJob.id);

    return new Response(
      JSON.stringify({
        success: true,
        inserted,
        discarded,
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );

  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500 },
    );
  }
});