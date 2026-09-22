import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {

    const body = await req.json()
    console.log("BODY:", body)

    const { profileId } = body

    if (!profileId) {
      throw new Error("profileId mancante")
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // =====================================
    // GET PROFILE
    // =====================================

    const { data: profile, error: profileError } =
      await supabase
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single()

    if (profileError) throw profileError

    const authUserId = profile.auth_user_id

    if (!authUserId) {
      throw new Error("auth_user_id mancante")
    }

    console.log("Deleting user:", authUserId)

    // =====================================
    // CHECK: impedisci cancellazione ultimo admin
    // =====================================

    const { data: adminRole, error: adminRoleError } = await supabase
      .from('roles')
      .select('id')
      .eq('code', 'admin')
      .single()

    if (adminRoleError) throw adminRoleError

    const { data: profileRoles, error: profileRolesError } = await supabase
      .from('user_roles')
      .select('role_id')
      .eq('profile_id', profileId)

    if (profileRolesError) throw profileRolesError

    const isAdmin = profileRoles?.some(r => r.role_id === adminRole.id)

    if (isAdmin) {
      const { count, error: countError } = await supabase
        .from('user_roles')
        .select('*', { count: 'exact', head: true })
        .eq('role_id', adminRole.id)

      if (countError) throw countError

      if ((count ?? 0) <= 1) {
        return new Response(
          JSON.stringify({
            error: "Impossibile eliminare l'utente: è l'unico amministratore presente nel sistema.",
          }),
          { status: 400, headers: { 'Content-Type': 'application/json' } },
        )
      }
    }

    console.log("Deleting user:", authUserId)  
    
    // =====================================
    // DELETE AUTH USER — FATTO PRIMA
    // =====================================
    // Se questa fallisce, profilo e ruoli restano intatti:
    // stato consistente, si può ritentare in sicurezza.
    // Se invece eliminassimo prima il profilo e poi questa
    // fallisse, resterebbe un utente auth orfano e senza
    // più modo di risalire al suo profileId.

    const { error: authDeleteError } =
      await supabase.auth.admin.deleteUser(authUserId)

    if (authDeleteError) throw authDeleteError

    // =====================================
    // DELETE USER ROLES
    // =====================================

    const { error: rolesDeleteError } = await supabase
      .from('user_roles')
      .delete()
      .eq('profile_id', profileId)

    if (rolesDeleteError) throw rolesDeleteError

    // =====================================
    // DELETE PROFILE
    // =====================================

    const { error: profileDeleteError } = await supabase
      .from('profiles')
      .delete()
      .eq('id', profileId)

    if (profileDeleteError) throw profileDeleteError

    console.log("DELETE COMPLETED")

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } },
    )

  } catch (err) {
    console.error("DELETE ERROR:", err)

    return new Response(
      JSON.stringify({
        error: err.message,
      }),
      { status: 500 },
    )
  }
})
