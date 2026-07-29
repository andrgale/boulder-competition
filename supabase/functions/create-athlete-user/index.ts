import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

async function sendWelcomeEmail({
  email,
  name,
}: {
  email: string
  name?: string
}) {
  const apiKey = Deno.env.get("BREVO_API_KEY")
  const senderEmail = Deno.env.get("BREVO_SENDER_EMAIL")
  const senderName = Deno.env.get("BREVO_SENDER_NAME") ?? "BoulderCompetition"

  if (!apiKey || !senderEmail) {
    throw new Error("Credenziali Brevo mancanti")
  }

  const safeName = name?.trim() || " "

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
      subject: `Benvenuto in ${senderName}`,
      htmlContent: `
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.5;">
            <h2>Benvenuto in ${senderName}, ${safeName}!</h2>

            <p>Il tuo account è stato creato correttamente.</p>

            <p>
              Apri l'app ed effettua il primo accesso con la tua mail e la password
              12345678. Al primo accesso ti verrà chiesto di modificare la password.
            </p>

            <p>Se non hai richiesto tu la registrazione, ignora questa email.</p>
          </body>
        </html>
      `,
      tags: ["welcome"],
    }),
  })

  if (!response.ok) {
    const detail = await response.text()
    console.error("Brevo error:", detail)
    throw new Error("Invio email di benvenuto non riuscito")
  }

  return await response.json()
}

serve(async (req) => {
  try {
    const body = await req.json()

    const {
      email,
      nome,
      cognome,
    } = body

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // ============================================
    // CHECK USER EXIST
    // ============================================

    const { data: usersData, error: usersError } =
      await supabase.auth.admin.listUsers({
        page: 1,
        perPage: 1000,
      })    

    if (usersError) throw usersError

    let user = usersData.users.find(
      (u) => u.email?.toLowerCase() == email.toLowerCase(),
    )

    // ============================================
    // CREATE AUTH USER
    // ============================================
    let createdNewUser = false

    if (!user) {
      const tempPassword = "12345678";
  //      crypto.randomUUID()
    

      const {
        data: createdUser,
        error: createError,
      } = await supabase.auth.admin.createUser({
        email,
        password: tempPassword,
        email_confirm: true,
        user_metadata: {
          nome,
          cognome,
        },
      })

      if (createError) throw createError

      user = createdUser.user
      createdNewUser = true
    }

    // ============================================
    // CHECK PROFILE
    // ============================================

    const {
      data: existingProfile,
      error: existingProfileError,
    } = await supabase
      .from('profiles')
      .select()
      .eq('auth_user_id', user.id)
      .maybeSingle()

    if (existingProfileError) throw existingProfileError


    let profileId = existingProfile?.id

    // ============================================
    // CREATE PROFILE
    // ============================================

    if (!existingProfile) {
      const {
        data: profile,
        error: profileError,
      } = await supabase
        .from('profiles')
        .insert({
          auth_user_id: user.id,
          email,
          nome,
          cognome,
        })
        .select()
        .single()

      if (profileError) throw profileError

      profileId = profile.id

      // ============================================
      // GET ATHLETE ROLE
      // ============================================

      const {
        data: role,
        error: roleError,
      } = await supabase
        .from('roles')
        .select()
        .eq('code', 'athlete')
        .single()

      if (roleError) throw roleError

      // ============================================
      // INSERT USER ROLE
      // ============================================

      const {
        error: roleInsertError,
      } = await supabase
        .from('user_roles')
        .insert({
          profile_id: profileId,
          role_id: role.id,
        })

      if (roleInsertError)
        throw roleInsertError

      if (createdNewUser) {
        await sendWelcomeEmail({
          email: user.email!,
          name: user.user_metadata?.nome,
        })
      }
    }
    return new Response(
      JSON.stringify({
        success: true,
        auth_user_id: user.id,
        profile_id: profileId,
      }),
      {
        headers: {
          'Content-Type':
              'application/json',
        },
      },
    )
  } catch (err) {
    return new Response(
      JSON.stringify({
        error: err.message,
      }),
      {
        status: 500,
      },
    )
  }
})