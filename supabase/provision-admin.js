import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const ADMIN_ROLE_CODE = 'ADMIN';

async function provisionAdmin() {

  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const nome = process.env.ADMIN_NOME;
  const cognome = process.env.ADMIN_COGNOME;

  // creazione auth user

  const { data: userData, error: userError } =
    await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    });

  if (userError) {
    throw userError;
  }

  const authUserId = userData.user.id;

  // profilo

  const { data: profile, error: profileError } =
    await supabase
      .from('profiles')
      .insert({
        auth_user_id: authUserId,
        email: email,
        nome: nome,
        cognome: cognome,
        password_changed: false
      })
      .select()
      .single();

  if (profileError) {
    throw profileError;
  }

  // recupera ruolo ADMIN

  const { data: role, error: roleError } =
    await supabase
      .from('roles')
      .select('id')
      .eq('code', ADMIN_ROLE_CODE)
      .single();

  if (roleError) {
    throw roleError;
  }

  // collega utente -> ruolo

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

  console.log('Admin creato correttamente');
  console.log('Auth User ID:', authUserId);
}

provisionAdmin()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });