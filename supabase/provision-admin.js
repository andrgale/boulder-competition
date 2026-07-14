import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const ADMIN_ROLE_CODE = 'admin';

async function provisionAdmin() {

  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const nome = process.env.ADMIN_NOME;
  const cognome = process.env.ADMIN_COGNOME;

  console.log(`Provisioning admin: ${email}`);

  // Recupera ruolo ADMIN

  const { data: role, error: roleError } =
    await supabase
      .from('roles')
      .select('id')
      .eq('code', ADMIN_ROLE_CODE)
      .maybeSingle();

  if (roleError) {
    throw roleError;
  }

  if (!role) {
    throw new Error(
      `Ruolo '${ADMIN_ROLE_CODE}' non trovato nella tabella roles`
    );
  }

  // Cerca profilo esistente

  const { data: existingProfile, error: profileSearchError } =
    await supabase
      .from('profiles')
      .select('id, email')
      .eq('email', email)
      .maybeSingle();

  if (profileSearchError) {
    throw profileSearchError;
  }

  // Se il profilo esiste già verifica user_roles

  if (existingProfile) {

    console.log('Profilo admin già presente');

    const { data: existingUserRole, error: userRoleSearchError } =
      await supabase
        .from('user_roles')
        .select('*')
        .eq('profile_id', existingProfile.id)
        .eq('role_id', role.id)
        .maybeSingle();

    if (userRoleSearchError) {
      throw userRoleSearchError;
    }

    if (!existingUserRole) {

      const { error: userRoleError } =
        await supabase
          .from('user_roles')
          .insert({
            profile_id: existingProfile.id,
            role_id: role.id
          });

      if (userRoleError) {
        throw userRoleError;
      }

      console.log('Ruolo ADMIN assegnato al profilo');
    }

    console.log('Admin già configurato');
    return;
  }

  // Cerca utente Auth

  const { data: usersData, error: listError } =
    await supabase.auth.admin.listUsers();

  if (listError) {
    throw listError;
  }

  const existingAuthUser =
    usersData.users.find(u => u.email === email);

  let authUserId;

  if (existingAuthUser) {

    console.log('Utente Auth già presente');

    authUserId = existingAuthUser.id;

  } else {

    console.log('Creazione utente Auth...');

    const { data: userData, error: userError } =
      await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true
      });

    if (userError) {
      throw userError;
    }

    authUserId = userData.user.id;

    console.log(`Utente Auth creato: ${authUserId}`);
  }

  // Creazione profilo

  const { data: profile, error: profileError } =
    await supabase
      .from('profiles')
      .insert({
        auth_user_id: authUserId,
        email,
        nome,
        cognome,
        password_changed: false
      })
      .select()
      .single();

  if (profileError) {
    throw profileError;
  }

  console.log('Profilo creato');

  // Associazione ruolo

  const { error: userRoleError } =
    await supabase
      .from('user_roles')
      .insert({
        profile_id: profile.id,
        role_id: role.id
      });

  if (userRoleError) {
    throw userRoleError;
  }

  console.log('Ruolo ADMIN associato');
  console.log('Provisioning completato');
}

provisionAdmin()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });