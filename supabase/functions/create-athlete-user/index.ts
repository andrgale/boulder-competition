import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

    const {
      data: usersData,
      error: usersError,
    } = await supabase.auth.admin.listUsers()

    if (usersError) throw usersError

    let user = usersData.users.find(
      (u) => u.email?.toLowerCase() == email.toLowerCase(),
    )

    // ============================================
    // CREATE AUTH USER
    // ============================================

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
    }

    // ============================================
    // CHECK PROFILE
    // ============================================

    const {
      data: existingProfile,
    } = await supabase
      .from('profiles')
      .select()
      .eq('auth_user_id', user.id)
      .maybeSingle()

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