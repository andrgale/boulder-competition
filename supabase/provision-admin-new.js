import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const requiredEnv = [
  'SUPABASE_URL',
  'SUPABASE_SERVICE_ROLE_KEY',
  'ADMIN_EMAIL',
  'ADMIN_PASSWORD',
  'ADMIN_NOME',
  'ADMIN_COGNOME'
];

for (const envName of requiredEnv) {
  if (!process.env[envName]) {
    throw new Error(`Variabile ambiente mancante: ${envName}`);
  }
}

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const ADMIN_ROLE_CODE = 'admin';

async function getAdminRole() {
  const { data, error } = await supabase
    .from('roles')
    .select('id, code')
    .eq('code', ADMIN_ROLE_CODE)
    .single();

  if (error) {
    throw new Error(
      `Ruolo '${ADMIN_ROLE_CODE}' non trovato: ${error.message}`
    );
  }

  return data;
}

async function getAuthUserByEmail(email) {
  let page = 1;
  const perPage = 1000;

  while (true) {
    const { data, error } =
      await supabase.auth.admin.listUsers({
        page,
        perPage
      });

    if (error) {
      throw error;
    }

    const user =
      data.users.find(
        u => u.email?.toLowerCase() === email.toLowerCase()
      );

    if (user) {
      return user;
    }

    if (data.users.length < perPage) {
      return null;
    }

    page++;
  }
}

async function createAuthUserIfNeeded(
  email,
  password,
  nome,
  cognome
) {
  let user = await getAuthUserByEmail(email);

  if (user) {
    console.log(`✅ Auth user già presente (${user.id})`);
    return user;
  }

  console.log('➕ Creazione Auth user...');

  const { data, error } =
    await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        nome,
        cognome
      }
    });

  if (error) {
    throw error;
  }

  console.log(`✅ Auth user creato (${data.user.id})`);

  return data.user;
}

async function getProfileByEmail(email) {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('email', email)
    .maybeSingle();

  if (error) {
    throw error;
  }

  return data;
}

async function createOrUpdateProfile({
  authUserId,
  email,
  nome,
  cognome
}) {
  let profile = await getProfileByEmail(email);

  if (profile) {
    console.log('✅ Profilo già presente');

    if (profile.auth_user_id !== authUserId) {
      console.log(
        '🔄 Aggiornamento auth_user_id del profilo'
      );

      const { error } = await supabase
        .from('profiles')
        .update({
          auth_user_id: authUserId
        })
        .eq('id', profile.id);

      if (error) {
        throw error;
      }

      profile.auth_user_id = authUserId;
    }

    return profile;
  }

  console.log('➕ Creazione profilo...');

  const { data, error } = await supabase
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

  if (error) {
    throw error;
  }

  console.log(`✅ Profilo creato (${data.id})`);

  return data;
}

async function ensureAdminRole(profileId, roleId) {
  const { data: existingRole, error: searchError } =
    await supabase
      .from('user_roles')
      .select('profile_id, role_id')
      .eq('profile_id', profileId)
      .eq('role_id', roleId)
      .maybeSingle();

  if (searchError) {
    throw searchError;
  }

  if (existingRole) {
    console.log('✅ Ruolo ADMIN già assegnato');
    return;
  }

  console.log('➕ Assegnazione ruolo ADMIN...');

  const { error } = await supabase
    .from('user_roles')
    .insert({
      profile_id: profileId,
      role_id: roleId
    });

  if (error) {
    throw error;
  }

  console.log('✅ Ruolo ADMIN assegnato');
}

async function provisionAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const nome = process.env.ADMIN_NOME;
  const cognome = process.env.ADMIN_COGNOME;

  console.log('');
  console.log('==================================');
  console.log('ADMIN PROVISIONING');
  console.log('==================================');
  console.log(`Email: ${email}`);
  console.log('');

  const role = await getAdminRole();

  console.log(`✅ Ruolo trovato (${role.code})`);

  const authUser = await createAuthUserIfNeeded(
    email,
    password,
    nome,
    cognome
  );

  const profile = await createOrUpdateProfile({
    authUserId: authUser.id,
    email,
    nome,
    cognome
  });

  await ensureAdminRole(
    profile.id,
    role.id
  );

  console.log('');
  console.log('==================================');
  console.log('✅ PROVISIONING COMPLETATO');
  console.log('==================================');
  console.log(`Auth User : ${authUser.id}`);
  console.log(`Profile   : ${profile.id}`);
  console.log(`Email     : ${email}`);
  console.log('');
}

provisionAdmin()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('');
    console.error('❌ ERRORE');
    console.error(error);
    console.error('');
    process.exit(1);
  });