import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "@supabase/supabase-js";
import { parse } from "csv-parse/sync";

serve(async (req) => {
  try {
    // =====================================================
    // INPUT
    // =====================================================
    const body = await req.json();

    const competition_id = body.competition_id;
    const csv_content = body.csv_content;

    if (!competition_id || !csv_content) {
      return new Response(
        JSON.stringify({ error: "Missing competition_id or csv_content" }),
        { status: 400 }
      );
    }

    // =====================================================
    // SUPABASE CLIENT (SERVICE ROLE ONLY)
    // =====================================================
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // =====================================================
    // CHECK COMPETITION
    // =====================================================
    const { data: competition, error: compErr } = await supabase
      .from("competitions")
      .select("*")
      .eq("id", competition_id)
      .single();

    if (compErr || !competition) {
      return new Response(
        JSON.stringify({ error: "Competition not found" }),
        { status: 400 }
      );
    }

    if (competition.fl_gara_chiusa) {
      return new Response(
        JSON.stringify({ error: "Competition closed" }),
        { status: 400 }
      );
    }

    // check solo una gara aperta
    const { count: openCompetitions } = await supabase
      .from("competitions")
      .select("*", { count: "exact", head: true })
      .eq("fl_gara_chiusa", false)
      .neq("id", competition_id);

    if ((openCompetitions ?? 0) > 0) {
      return new Response(
        JSON.stringify({ error: "Another competition is already open" }),
        { status: 400 }
      );
    }

    // =====================================================
    // IMPORT JOB
    // =====================================================
    const { data: importJob } = await supabase
      .from("import_jobs")
      .insert({
        competition_id,
        file_name: "manual_upload.csv",
        status: "RUNNING",
        total_rows: 0,
        inserted_rows: 0,
        discarded_rows: 0
      })
      .select()
      .single();

    // =====================================================
    // CSV PARSE
    // =====================================================
    const rows = parse(csv_content, {
      delimiter: ";",
      skip_empty_lines: true
    });

    // =====================================================
    // ROLE ATHLETE
    // =====================================================
    const { data: athleteRole } = await supabase
      .from("roles")
      .select("id")
      .eq("code", "athlete")
      .maybeSingle();

    if (!athleteRole) {
      throw new Error("Athlete role not found");
    }

    let inserted = 0;
    let discarded = 0;

    // =====================================================
    // PROCESS ROWS
    // =====================================================
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const raw_row = row.join(";");

      try {
        const cognome = row[0]?.trim();
        const nome = row[1]?.trim();
        const sesso = row[2]?.trim()?.toUpperCase();
        const data_nascita = row[3]?.trim();
        const email = row[4]?.trim()?.toLowerCase();
        const societa = row[5]?.trim();

        // -------------------------
        // VALIDATION BASIC
        // -------------------------
        if (!email || !email.includes("@")) throw new Error("Invalid email");

        if (sesso !== "M" && sesso !== "F") {
          throw new Error("Invalid gender");
        }

        // -------------------------
        // PROFILE CHECK
        // -------------------------
        let profileId: string;

        const { data: existingProfile } = await supabase
          .from("profiles")
          .select("id")
          .eq("email", email)
          .maybeSingle();

        if (existingProfile) {
          profileId = existingProfile.id;
        } else {
          // create auth user
          const { data: authUser, error: authErr } =
            await supabase.auth.admin.createUser({
              email,
              email_confirm: true
            });

          if (authErr || !authUser.user) {
            throw new Error(authErr?.message || "Auth user creation failed");
          }

          // create profile
          const { data: profile } = await supabase
            .from("profiles")
            .insert({
              auth_user_id: authUser.user.id,
              email,
              nome,
              cognome
            })
            .select("id")
            .single();

          profileId = profile.id;

          // assign role
          await supabase.from("user_roles").insert({
            profile_id: profileId,
            role_id: athleteRole.id
          });
        }

        // -------------------------
        // REGISTRATION CHECK
        // -------------------------
        const { data: existingRegistration } = await supabase
          .from("registrations")
          .select("id")
          .eq("competition_id", competition_id)
          .eq("profile_id", profileId)
          .maybeSingle();

        if (existingRegistration) {
          throw new Error("Already registered");
        }

        // -------------------------
        // INSERT REGISTRATION
        // -------------------------
        await supabase.from("registrations").insert({
          competition_id,
          profile_id: profileId,
          cognome,
          nome,
          email,
          societa,
          sesso,
          data_nascita
        });

        inserted++;

        // -------------------------
        // LOG SUCCESS
        // -------------------------
        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: i + 1,
          raw_row,
          status: "INSERTED"
        });

      } catch (err: any) {
        discarded++;

        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: i + 1,
          raw_row,
          status: "DISCARDED",
          error_message: err.message
        });
      }

      // update job progress
      await supabase
        .from("import_jobs")
        .update({
          total_rows: rows.length,
          inserted_rows: inserted,
          discarded_rows: discarded
        })
        .eq("id", importJob.id);
    }

    // =====================================================
    // COMPLETE JOB
    // =====================================================
    await supabase
      .from("import_jobs")
      .update({
        status: "COMPLETED",
        completed_at: new Date().toISOString()
      })
      .eq("id", importJob.id);

    // =====================================================
    // RESPONSE
    // =====================================================
    return new Response(
      JSON.stringify({
        success: true,
        inserted,
        discarded
      }),
      {
        headers: { "Content-Type": "application/json" }
      }
    );

  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500 }
    );
  }
});