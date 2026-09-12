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
    const sendWelcomeEmails = body.send_welcome_emails === true;
    
    if (typeof body.send_welcome_emails !== "boolean") {
      return new Response(
        JSON.stringify({
          error: "Parametro send_welcome_emails mancante o non valido",
        }),
        { status: 400 },
      );
    }

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
    // CATEGORIE DELLA COMPETIZIONE
    // =====================================================

    // La data della gara è il riferimento per il calcolo
    // dell'età degli atleti.
    const competitionDate = competition.dt_gara;

    if (!competitionDate) {
      return new Response(
        JSON.stringify({
          error: "Data della gara non presente",
        }),
        { status: 500 },
      );
    }

    // Recuperiamo UNA SOLA VOLTA tutte le categorie della gara.
    const { data: competitionCategories, error: categoriesError } = await supabase
      .from("categories")
      .select(`
        id,
        eta_min,
        eta_max,
        sesso
      `)
      .eq("competition_id", competition_id);

    if (categoriesError) {
      throw new Error(
        "Errore recupero categorie della gara: " +
          categoriesError.message,
      );
    }

    // Se la gara non ha categorie, l'array sarà semplicemente vuoto.
    const hasCategories = (competitionCategories?.length ?? 0) > 0;

    // =====================================================
    // CONTEGGI INIZIALI PER CONTROLLI ISCRIZIONI/TURNI
    // =====================================================
    //
    // Vengono letti una sola volta e poi aggiornati in memoria a ogni
    // inserimento riuscito, per evitare una query di conteggio per riga.

    const nrMaxRegistrations = competition.nr_max_registrations ?? 0;
    const isTurn = competition.is_turn ?? false;
    const nrMaxFirstTurn = competition.nr_max_first_turn ?? 0;
    const nrMaxSecondTurn = competition.nr_max_second_turn ?? 0;

    const { count: totalRegisteredCount } = await supabase
      .from("registrations")
      .select("*", { count: "exact", head: true })
      .eq("competition_id", competition_id);

    let totalRegistered = totalRegisteredCount ?? 0;

    let firstTurnCount = 0;
    let secondTurnCount = 0;

    if (isTurn) {
      const { count: firstCount } = await supabase
        .from("registrations")
        .select("*", { count: "exact", head: true })
        .eq("competition_id", competition_id)
        .eq("is_first_turn", true);

      const { count: secondCount } = await supabase
        .from("registrations")
        .select("*", { count: "exact", head: true })
        .eq("competition_id", competition_id)
        .eq("is_second_turn", true);

      firstTurnCount = firstCount ?? 0;
      secondTurnCount = secondCount ?? 0;
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
    // CONTROLLO ISCRIZIONI CHIUSE (BLOCCA TUTTO IL FILE)
    // =====================================================
    //
    // Se le iscrizioni sono chiuse, l'intero import viene bloccato:
    // ogni riga del CSV viene scartata con lo stesso messaggio, senza
    // eseguire alcuna validazione o inserimento.

    if (competition.fl_iscrizioni_chiuse) {
      for (let j = 0; j < dataRows.length; j++) {
        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: j + 1,
          raw_row: dataRows[j].join(";"),
          status: "DISCARDED",
          error_message:
            "Iscrizioni chiuse per la gara, rivolgersi agli organizzatori",
        });
      }

      await supabase.from("import_jobs").update({
        total_rows: dataRows.length,
        inserted_rows: 0,
        discarded_rows: dataRows.length,
        status: "COMPLETED",
        completed_at: new Date().toISOString(),
      }).eq("id", importJob.id);

      return new Response(
        JSON.stringify({
          success: true,
          inserted: 0,
          discarded: dataRows.length,
        }),
        {
          headers: { "Content-Type": "application/json" },
        },
      );
    }    

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
    // CALCOLO ETA ALLA DATA DELLA GARA
    // =====================================================

    function calculateAgeAtCompetitionDate(
      birthDate: string,
      competitionDate: string,
    ): number {
      const birth = new Date(`${birthDate}T00:00:00`);
      const competition = new Date(`${competitionDate}T00:00:00`);

      let age = competition.getFullYear() - birth.getFullYear();

      const monthDifference =
        competition.getMonth() - birth.getMonth();

      const dayDifference =
        competition.getDate() - birth.getDate();

      // Se alla data della gara non ha ancora compiuto gli anni,
      // sottraiamo un anno.
      if (
        monthDifference < 0 ||
        (monthDifference === 0 && dayDifference < 0)
      ) {
        age--;
      }

      return age;
    }

    // =====================================================
    // RICERCA CATEGORIA
    // =====================================================

    function findMatchingCategory(
      categories: Array<{
        id: string;
        eta_min: number | null;
        eta_max: number | null;
        sesso: string | null;
      }>,
      age: number,
      athleteGender: string,
    ) {
      return categories.find((category) => {
        // -------------------------------------------------
        // CONTROLLO SESSO
        // -------------------------------------------------

        const categoryGender =
          category.sesso?.trim().toUpperCase();

        const normalizedAthleteGender =
          athleteGender.trim().toUpperCase();

        // Se la categoria ha un sesso specifico,
        // deve coincidere con quello dell'atleta.
        const genderMatches =
          !categoryGender ||
          categoryGender === normalizedAthleteGender;

        if (!genderMatches) {
          return false;
        }

        // -------------------------------------------------
        // CONTROLLO ETA MINIMA
        // -------------------------------------------------

        if (
          category.eta_min !== null &&
          age < category.eta_min
        ) {
          return false;
        }

        // -------------------------------------------------
        // CONTROLLO ETA MASSIMA
        // -------------------------------------------------

        if (
          category.eta_max !== null &&
          age > category.eta_max
        ) {
          return false;
        }

        return true;
      });
    } 
   
      function formatDate(dateStr?: string | null) {
      if (!dateStr) return null;

      const d = new Date(dateStr);

      return d.toLocaleDateString("it-IT");
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

      // ===================================================
      // CONTROLLO NUMERO MASSIMO ISCRITTI (GLOBALE)
      // ===================================================
      //
      // Se il tetto è già raggiunto, scarta questo record E TUTTI
      // i successivi ancora da elaborare, poi interrompe l'import.

      if (
        nrMaxRegistrations > 0 &&
        totalRegistered >= nrMaxRegistrations
      ) {
        for (let j = i; j < dataRows.length; j++) {
          discarded++;

          await supabase.from("import_job_rows").insert({
            import_job_id: importJob.id,
            row_number: j + 1,
            raw_row: dataRows[j].join(";"),
            status: "DISCARDED",
            error_message:
              "Atleta non iscrivibile per superamento numero massimo partecipanti",
          });
        }

        await supabase.from("import_jobs").update({
          total_rows: dataRows.length,
          inserted_rows: inserted,
          discarded_rows: discarded,
        }).eq("id", importJob.id);

        break;
      }

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

        // ===================================================
        // CALCOLO E ASSEGNAZIONE CATEGORIA
        // ===================================================

        let categoryId: string | null = null;

        // La categoria viene calcolata solamente se:
        // - la gara ha delle categorie;
        // - è presente la data di nascita dell'atleta.
        if (hasCategories && data_nascita) {
          const age = calculateAgeAtCompetitionDate(
            data_nascita,
            competitionDate,
          );

          const matchingCategory = findMatchingCategory(
            competitionCategories ?? [],
            age,
            sesso,
          );

          categoryId = matchingCategory?.id ?? null;
        }
        // ===================================================
        // CONTROLLO TURNI (SOLO SE is_turn = true)
        // ===================================================

        let isFirstTurn = false;
        let isSecondTurn = false;

        if (isTurn) {
          const turnoRaw = row[6]?.toString().trim();

          if (turnoRaw !== "1" && turnoRaw !== "2") {
            throw new Error("Turno non valido");
          }

          if (turnoRaw === "1") {
            if (
              nrMaxFirstTurn > 0 &&
              firstTurnCount >= nrMaxFirstTurn
            ) {
              throw new Error(
                "Turno completo, procedere con una nuova iscrizione nell'altro turno",
              );
            }
            isFirstTurn = true;
          } else {
            if (
              nrMaxSecondTurn > 0 &&
              secondTurnCount >= nrMaxSecondTurn
            ) {
              throw new Error(
                "Turno completo, procedere con una nuova iscrizione nell'altro turno",
              );
            }
            isSecondTurn = true;
          }
        }

        // PROFILE CHECK
        let profileId: string;
        let createdNewUser = false;

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
              password: "12345678",
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
          createdNewUser = true;

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
        // PETTORALE PROGRESSIVO
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
          category_id: categoryId,
          pettorale: nextPettorale,
          is_first_turn: isFirstTurn,
          is_second_turn: isSecondTurn,
          owner_registration: "import",
        });

        inserted++;
        totalRegistered++;
        if (isFirstTurn) firstTurnCount++;
        if (isSecondTurn) secondTurnCount++;

        // LOG SUCCESS
        await supabase.from("import_job_rows").insert({
          import_job_id: importJob.id,
          row_number: i + 1,
          raw_row,
          status: "INSERTED",
        });

        // =====================================================
        // INVIO MAIL DI CONFERMA
        // =====================================================
        //
        // Solo per i nuovi utenti (createdNewUser = true): la mail
        // comunica la password provvisoria "12345678", quindi non ha
        // senso inviarla a un profilo già esistente che ha già la
        // propria password. Isolato in un try/catch separato: se
        // l'invio fallisce, la registrazione resta comunque valida
        // (già inserita) e la riga non viene marcata come scartata.
 //       if (createdNewUser) {
      if (sendWelcomeEmails) {
          try {
              const turnoText = isTurn
              ? (isFirstTurn ? "Primo Turno" : "Secondo Turno")
              : null;

              const riepilogoParts = [
              competition.descrizione,
              turnoText,
              ].filter(Boolean);
            const response = await fetch(
              `${Deno.env.get("SUPABASE_URL")}/functions/v1/send-template-email`,
              {
                method: "POST",
                headers: {
                  Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
                  apikey: Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
                  "Content-Type": "application/json",
                },
                body: JSON.stringify({
                  email,
                  toName: `${nome} ${cognome}`.trim(),
                  templateCode: "REG_GARA_CSV",
                  language: "it",
                  variables: buildEmailVariables({
                    'NOME_ATLETA': `${nome} ${cognome}`.trim(),
                    'DESC_GARA': competition.descrizione,
                    'DT_GARA': formatDate(competition.dt_gara),
                    'TURNO': turnoText,
                    'RIEPILOGO_GARA':
                      riepilogoParts.length > 0
                        ? riepilogoParts.join(' — ')
                        : null,
                  }),
                }),
              },
            );

            if (!response.ok) {
              const detail = await response.text();
              throw new Error(
                `send-template-email (${response.status}): ${detail}`,
              );
            }
            } catch (mailErr: any) {
              console.error(
                `Errore invio mail iscrizione (riga ${i + 1}, ${email}):`,
                mailErr.message,
              );
            }
        }
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

// =====================================================
// BUILD EMAIL VARIABLES
// =====================================================

function buildEmailVariables(raw: Record<string, unknown>,): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(raw).filter(([, value]) => value !== null),
  );
}
