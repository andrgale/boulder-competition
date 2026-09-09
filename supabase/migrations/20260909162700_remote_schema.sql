SELECT pg_catalog.set_config('search_path', '', false);
CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";
COMMENT ON SCHEMA "public" IS 'standard public schema';
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";
CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";
CREATE TYPE "public"."email_template_asset_status" AS ENUM (
    'pending',
    'ready',
    'deleted'
);
ALTER TYPE "public"."email_template_asset_status" OWNER TO "postgres";
CREATE TYPE "public"."email_template_status" AS ENUM (
    'draft',
    'active',
    'archived'
);
ALTER TYPE "public"."email_template_status" OWNER TO "postgres";
CREATE TYPE "public"."email_template_variable_type" AS ENUM (
    'text',
    'number',
    'date',
    'datetime',
    'url',
    'email'
);
ALTER TYPE "public"."email_template_variable_type" OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."can_manage_email_template_storage"("p_path" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  select public.is_email_template_admin()
     and exists (
       select 1
       from public.email_template_assets a
       where a.storage_path = p_path
         and a.bucket_id = 'email-template-assets'
         and a.status = 'pending'
     );
$$;
ALTER FUNCTION "public"."can_manage_email_template_storage"("p_path" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."check_email_exists"("p_email" "text") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1 from profiles where email = p_email
  );
$$;
ALTER FUNCTION "public"."check_email_exists"("p_email" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."create_categories_from_template"("p_competition_id" "uuid", "p_template_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    insert into public.categories (
        competition_id,
        nome,
        sesso,
        eta_min,
        eta_max
    )
    select
        p_competition_id,
        i.nome,
        i.sesso,
        i.eta_min,
        i.eta_max
    from public.category_template_items i
    where i.template_id = p_template_id
    order by i.ordine;
end;
$$;
ALTER FUNCTION "public"."create_categories_from_template"("p_competition_id" "uuid", "p_template_id" "uuid") OWNER TO "postgres";
SET default_tablespace = '';
SET default_table_access_method = "heap";
CREATE TABLE IF NOT EXISTS "public"."email_template_assets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "template_id" "uuid" NOT NULL,
    "bucket_id" "text" DEFAULT 'email-template-assets'::"text" NOT NULL,
    "storage_path" "text" NOT NULL,
    "original_filename" "text" NOT NULL,
    "mime_type" "text" NOT NULL,
    "size_bytes" bigint,
    "alt_text" "text",
    "status" "public"."email_template_asset_status" DEFAULT 'pending'::"public"."email_template_asset_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "email_template_assets_bucket_check" CHECK (("bucket_id" = 'email-template-assets'::"text")),
    CONSTRAINT "email_template_assets_image_mime_check" CHECK (("mime_type" = ANY (ARRAY['image/jpeg'::"text", 'image/png'::"text", 'image/gif'::"text", 'image/webp'::"text"]))),
    CONSTRAINT "email_template_assets_size_check" CHECK ((("size_bytes" IS NULL) OR ("size_bytes" > 0)))
);
ALTER TABLE "public"."email_template_assets" OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."create_email_template_asset"("p_template_id" "uuid", "p_filename" "text", "p_mime_type" "text", "p_alt_text" "text" DEFAULT NULL::"text") RETURNS "public"."email_template_assets"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_asset_id uuid := gen_random_uuid();
  v_filename text;
  v_asset public.email_template_assets;
begin
  if not public.is_email_template_admin() then
    raise exception 'Not authorized';
  end if;
  if p_mime_type not in ('image/jpeg', 'image/png', 'image/gif', 'image/webp') then
    raise exception 'Unsupported image type';
  end if;
  -- Un asset si aggiunge soltanto a una bozza, cosi' una versione pubblicata
  -- rimane riproducibile nel tempo.
  if not exists (
    select 1 from public.email_templates
    where id = p_template_id and status = 'draft'
  ) then
    raise exception 'Assets can only be added to a draft template';
  end if;
  v_filename := nullif(
    regexp_replace(lower(coalesce(p_filename, 'image')), '[^a-z0-9._-]+', '_', 'g'),
    ''
  );
  v_filename := coalesce(v_filename, 'image');
  insert into public.email_template_assets (
    id,
    template_id,
    bucket_id,
    storage_path,
    original_filename,
    mime_type,
    alt_text,
    status,
    created_by
  ) values (
    v_asset_id,
    p_template_id,
    'email-template-assets',
    p_template_id::text || '/' || v_asset_id::text || '/' || v_filename,
    p_filename,
    p_mime_type,
    p_alt_text,
    'pending',
    auth.uid()
  )
  returning * into v_asset;
  return v_asset;
end;
$$;
ALTER FUNCTION "public"."create_email_template_asset"("p_template_id" "uuid", "p_filename" "text", "p_mime_type" "text", "p_alt_text" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."current_profile_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
    select id
    from public.profiles
    where auth_user_id = auth.uid()
$$;
ALTER FUNCTION "public"."current_profile_id"() OWNER TO "postgres";
COMMENT ON FUNCTION "public"."current_profile_id"() IS 'Restituisce il profile_id associato all''utente autenticato';
CREATE OR REPLACE FUNCTION "public"."duplica_template_category"("p_template_id" "uuid", "p_nuovo_nome_template" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_new_template_id uuid;
begin
    -- Verifica esistenza template sorgente
    if not exists (
        select 1
        from public.category_templates
        where id = p_template_id
    ) then
        raise exception 'Template % non trovato', p_template_id;
    end if;
    -- Creazione nuovo template
    insert into public.category_templates (
        nome
    )
    values (
        p_nuovo_nome_template
    )
    returning id
    into v_new_template_id;
    -- Copia righe del template
    insert into public.category_template_items (
        template_id,
        nome,
        sesso,
        eta_min,
        eta_max,
        ordine,
        created_at,
        updated_at
    )
    select
        v_new_template_id,
        nome,
        sesso,
        eta_min,
        eta_max,
        ordine,
        now(),
        now()
    from public.category_template_items
    where template_id = p_template_id;
    return v_new_template_id;
end;
$$;
ALTER FUNCTION "public"."duplica_template_category"("p_template_id" "uuid", "p_nuovo_nome_template" "text") OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."generate_seed_file"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
select string_agg(sql_line, E'\n\n' order by sort_order)
from public.generate_seed_sql_lines();
$$;
ALTER FUNCTION "public"."generate_seed_file"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."generate_seed_sql"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $_$
declare
    v_sql text := '';
    r record;
begin
    ------------------------------------------------------------------
    -- HEADER
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    ------------------------------------------------------------------
    -- ROLES
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select code, name
        from public.roles
        order by code
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.roles (
    code,
    name
)
values (
    %L,
    %L
)
on conflict (code)
do update
set name = excluded.name;
$fmt$,
            r.code,
            r.name
        );
    end loop;
    ------------------------------------------------------------------
    -- PERMISSIONS
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select permission_code, activity
        from public.permissions
        order by permission_code
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.permissions (
    permission_code,
    activity
)
values (
    %L,
    %L
)
on conflict (permission_code)
do update
set activity = excluded.activity;
$fmt$,
            r.permission_code,
            r.activity
        );
    end loop;
    ------------------------------------------------------------------
    -- MENUS
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select
            m.label,
            m.route,
            m.icon,
            m.display_order,
            m.visible,
            m.mobile,
            m.desktop,
            p.route as parent_route
        from public.menus m
        left join public.menus p
            on p.id = m.parent_id
        order by m.display_order, m.route
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.menus (
    label,
    route,
    icon,
    display_order,
    parent_id,
    visible,
    mobile,
    desktop
)
values (
    %L,
    %L,
    %s,
    %s,
    %s,
    %L,
    %L,
    %L
)
on conflict (route)
do update
set
    label = excluded.label,
    icon = excluded.icon,
    display_order = excluded.display_order,
    parent_id = excluded.parent_id,
    visible = excluded.visible,
    mobile = excluded.mobile,
    desktop = excluded.desktop;
$fmt$,
            r.label,
            r.route,
            case
                when r.icon is null
                    then 'null'
                else quote_literal(r.icon)
            end,
            r.display_order,
            case
                when r.parent_route is null
                    then 'null'
                else
                    '(select id from public.menus where route = '
                    || quote_literal(r.parent_route)
                    || ')'
            end,
            r.visible,
            r.mobile,
            r.desktop
        );
    end loop;
    ------------------------------------------------------------------
    -- MENU TRANSLATIONS
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select
            m.route,
            mt.locale,
            mt.label
        from public.menu_translations mt
        join public.menus m
            on m.id = mt.menu_id
        order by m.route, mt.locale
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.menu_translations (
    menu_id,
    locale,
    label
)
values (
    (
        select id
        from public.menus
        where route = %L
    ),
    %L,
    %L
)
on conflict (menu_id, locale)
do update
set label = excluded.label;
$fmt$,
            r.route,
            r.locale,
            r.label
        );
    end loop;
    ------------------------------------------------------------------
    -- ROLE PERMISSIONS
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select
            ro.code as role_code,
            pe.permission_code
        from public.role_permissions rp
        join public.roles ro
            on ro.id = rp.role_id
        join public.permissions pe
            on pe.id = rp.permission_id
        order by ro.code, pe.permission_code
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.role_permissions (
    role_id,
    permission_id
)
values (
    (
        select id
        from public.roles
        where code = %L
    ),
    (
        select id
        from public.permissions
        where permission_code = %L
    )
)
on conflict do nothing;
$fmt$,
            r.role_code,
            r.permission_code
        );
    end loop;
    ------------------------------------------------------------------
    -- ROLE MENUS
    ------------------------------------------------------------------
    v_sql := v_sql ||
'-- =======================================
';
    for r in
        select
            ro.code as role_code,
            me.route
        from public.role_menus rm
        join public.roles ro
            on ro.id = rm.role_id
        join public.menus me
            on me.id = rm.menu_id
        order by ro.code, me.route
    loop
        v_sql := v_sql || format(
$fmt$
insert into public.role_menus (
    role_id,
    menu_id
)
values (
    (
        select id
        from public.roles
        where code = %L
    ),
    (
        select id
        from public.menus
        where route = %L
    )
)
on conflict do nothing;
$fmt$,
            r.role_code,
            r.route
        );
    end loop;
    return v_sql;
end;
$_$;
ALTER FUNCTION "public"."generate_seed_sql"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."generate_seed_sql_lines"() RETURNS TABLE("sort_order" integer, "sql_line" "text")
    LANGUAGE "plpgsql"
    AS $$
declare
    r record;
begin
    ------------------------------------------------------------------
    -- HEADER
    ------------------------------------------------------------------
    return query
    select
        0,
        '-- GENERATED SEED FILE';
    ------------------------------------------------------------------
    -- ROLES
    ------------------------------------------------------------------
    return query
    select
        10,
        '-- ROLES';
    for r in
        select code, name
        from public.roles
        order by code
    loop
        return query
        select
            11,
            format(
                'insert into public.roles (code, name)
                 values (%L, %L)
                 on conflict (code)
                 do update
                 set name = excluded.name;',
                r.code,
                r.name
            );
    end loop;
    ------------------------------------------------------------------
    -- PERMISSIONS
    ------------------------------------------------------------------
    return query
    select
        20,
        '-- PERMISSIONS';
    for r in
        select permission_code, activity
        from public.permissions
        order by permission_code
    loop
        return query
        select
            21,
            format(
                'insert into public.permissions (permission_code, activity)
                 values (%L, %L)
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;',
                r.permission_code,
                r.activity
            );
    end loop;
    ------------------------------------------------------------------
    -- MENUS
    ------------------------------------------------------------------
    return query
    select
        30,
        '-- MENUS';
    for r in
        select
            m.label,
            m.route,
            m.icon,
            m.display_order,
            m.visible,
            m.mobile,
            m.desktop,
            p.route as parent_route
        from public.menus m
        left join public.menus p
            on p.id = m.parent_id
        order by m.display_order, m.route
    loop
        return query
        select
            31,
            format(
                'insert into public.menus (
                    label,
                    route,
                    icon,
                    display_order,
                    parent_id,
                    visible,
                    mobile,
                    desktop
                )
                values (
                    %L,
                    %L,
                    %s,
                    %s,
                    %s,
                    %L,
                    %L,
                    %L
                )
                on conflict (route)
                do update
                set
                    label = excluded.label,
                    icon = excluded.icon,
                    display_order = excluded.display_order,
                    parent_id = excluded.parent_id,
                    visible = excluded.visible,
                    mobile = excluded.mobile,
                    desktop = excluded.desktop;',
                r.label,
                r.route,
                case
                    when r.icon is null
                    then 'null'
                    else quote_literal(r.icon)
                end,
                r.display_order,
                case
                    when r.parent_route is null
                    then 'null'
                    else
                        '(select id from public.menus where route = '
                        || quote_literal(r.parent_route)
                        || ')'
                end,
                r.visible,
                r.mobile,
                r.desktop
            );
    end loop;
    ------------------------------------------------------------------
    -- MENU TRANSLATIONS
    ------------------------------------------------------------------
    return query
    select
        40,
        '-- MENU_TRANSLATIONS';
    for r in
        select
            m.route,
            mt.locale,
            mt.label
        from public.menu_translations mt
        join public.menus m
            on m.id = mt.menu_id
        order by m.route, mt.locale
    loop
        return query
        select
            41,
            format(
                'insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = %L
                    ),
                    %L,
                    %L
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;',
                r.route,
                r.locale,
                r.label
            );
    end loop;
    ------------------------------------------------------------------
    -- ROLE_PERMISSIONS
    ------------------------------------------------------------------
    return query
    select
        50,
        '-- ROLE_PERMISSIONS';
    for r in
        select
            ro.code as role_code,
            pe.permission_code
        from public.role_permissions rp
        join public.roles ro
          on ro.id = rp.role_id
        join public.permissions pe
          on pe.id = rp.permission_id
        order by ro.code, pe.permission_code
    loop
        return query
        select
            51,
            format(
                'insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = %L
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = %L
                    )
                )
                on conflict do nothing;',
                r.role_code,
                r.permission_code
            );
    end loop;
    ------------------------------------------------------------------
    -- ROLE_MENUS
    ------------------------------------------------------------------
    return query
    select
        60,
        '-- ROLE_MENUS';
    for r in
        select
            ro.code as role_code,
            me.route
        from public.role_menus rm
        join public.roles ro
          on ro.id = rm.role_id
        join public.menus me
          on me.id = rm.menu_id
        order by ro.code, me.route
    loop
        return query
        select
            61,
            format(
                'insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = %L
                    ),
                    (
                        select id
                        from public.menus
                        where route = %L
                    )
                )
                on conflict do nothing;',
                r.role_code,
                r.route
            );
    end loop;
end;
$$;
ALTER FUNCTION "public"."generate_seed_sql_lines"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."has_permission"("permission_code" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
    select exists (
        select 1
        from public.user_roles ur
        join public.role_permissions rp
            on rp.role_id = ur.role_id
        join public.permissions p
            on p.id = rp.permission_id
        where ur.profile_id = public.current_profile_id()
        and p.permission_code = permission_code
    );
$$;
ALTER FUNCTION "public"."has_permission"("permission_code" "text") OWNER TO "postgres";
COMMENT ON FUNCTION "public"."has_permission"("permission_code" "text") IS 'Verifica se il profilo corrente possiede il permesso richiesto';
CREATE OR REPLACE FUNCTION "public"."has_role"("role_code" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
    select exists (
        select 1
        from public.user_roles ur
        join public.roles r
            on r.id = ur.role_id
        where ur.profile_id = public.current_profile_id()
        and r.code = role_code
    );
$$;
ALTER FUNCTION "public"."has_role"("role_code" "text") OWNER TO "postgres";
COMMENT ON FUNCTION "public"."has_role"("role_code" "text") IS 'Verifica se il profilo corrente possiede il ruolo richiesto';
CREATE OR REPLACE FUNCTION "public"."is_email_template_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
  select public.has_role('email_template_admin');
$$;
ALTER FUNCTION "public"."is_email_template_admin"() OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."mark_email_template_asset_ready"("p_asset_id" "uuid", "p_size_bytes" bigint) RETURNS "public"."email_template_assets"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_asset public.email_template_assets;
begin
  if not public.is_email_template_admin() then
    raise exception 'Not authorized';
  end if;
  select * into v_asset
  from public.email_template_assets
  where id = p_asset_id
  for update;
  if not found or v_asset.status <> 'pending' then
    raise exception 'Pending asset not found';
  end if;
  if not exists (
    select 1 from storage.objects
    where bucket_id = v_asset.bucket_id
      and name = v_asset.storage_path
  ) then
    raise exception 'Storage object not found';
  end if;
  update public.email_template_assets
  set status = 'ready',
      size_bytes = p_size_bytes
  where id = p_asset_id
  returning * into v_asset;
  return v_asset;
end;
$$;
ALTER FUNCTION "public"."mark_email_template_asset_ready"("p_asset_id" "uuid", "p_size_bytes" bigint) OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."email_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "template_code" "text" NOT NULL,
    "language" "text" DEFAULT 'it'::"text" NOT NULL,
    "version" integer DEFAULT 1 NOT NULL,
    "status" "public"."email_template_status" DEFAULT 'draft'::"public"."email_template_status" NOT NULL,
    "active" boolean GENERATED ALWAYS AS (("status" = 'active'::"public"."email_template_status")) STORED,
    "subject" "text" NOT NULL,
    "html_body" "text" NOT NULL,
    "description" "text",
    "is_default" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "email_templates_code_check" CHECK (("template_code" ~ '^[A-Z][A-Z0-9_]*$'::"text")),
    CONSTRAINT "email_templates_default_only_active_check" CHECK ((("is_default" = false) OR ("status" = 'active'::"public"."email_template_status"))),
    CONSTRAINT "email_templates_html_body_check" CHECK (("length"(TRIM(BOTH FROM "html_body")) > 0)),
    CONSTRAINT "email_templates_language_check" CHECK (("language" ~ '^[a-z]{2,3}(-[A-Z]{2})?$'::"text")),
    CONSTRAINT "email_templates_subject_check" CHECK (("length"(TRIM(BOTH FROM "subject")) > 0)),
    CONSTRAINT "email_templates_version_check" CHECK (("version" > 0))
);
ALTER TABLE "public"."email_templates" OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."publish_email_template_version"("p_template_id" "uuid", "p_is_default" boolean DEFAULT false) RETURNS "public"."email_templates"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
declare
  v_template public.email_templates;
begin
  if not public.is_email_template_admin() then
    raise exception 'Not authorized';
  end if;
  select *
  into v_template
  from public.email_templates
  where id = p_template_id
  for update;
  if not found then
    raise exception 'Template version not found';
  end if;
  -- Disattiva prima l'eventuale versione attiva: evita conflitti sull'indice.
  update public.email_templates
  set status = 'archived',
      is_default = false
  where template_code = v_template.template_code
    and language = v_template.language
    and status = 'active'
    and id <> p_template_id;
  -- Se questa è la lingua default, rimuove il default dalle altre lingue.
  if p_is_default then
    update public.email_templates
    set is_default = false
    where template_code = v_template.template_code
      and status = 'active'
      and id <> p_template_id;
  end if;
  update public.email_templates
  set status = 'active',
      is_default = p_is_default
  where id = p_template_id
  returning * into v_template;
  return v_template;
end;
$$;
ALTER FUNCTION "public"."publish_email_template_version"("p_template_id" "uuid", "p_is_default" boolean) OWNER TO "postgres";
CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;
ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."ascents" (
    "registration_id" "uuid" NOT NULL,
    "boulder_id" "uuid" NOT NULL,
    "top" boolean DEFAULT false NOT NULL,
    "zone" boolean DEFAULT false NOT NULL,
    "tentativi_top" integer DEFAULT 0 NOT NULL,
    "tentativi_zone" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_ascents_tentativi_top" CHECK (("tentativi_top" >= 0)),
    CONSTRAINT "chk_ascents_tentativi_zone" CHECK (("tentativi_zone" >= 0)),
    CONSTRAINT "chk_ascents_zone_top" CHECK (((NOT "top") OR ("zone" = true)))
);
ALTER TABLE "public"."ascents" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."boulders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competition_id" "uuid" NOT NULL,
    "numero" integer NOT NULL,
    "difficolta" integer DEFAULT 0 NOT NULL,
    "colore" "text",
    "valore_teorico" numeric(10,2) DEFAULT 1000 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_finale" boolean DEFAULT false NOT NULL
);
ALTER TABLE "public"."boulders" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competition_id" "uuid" NOT NULL,
    "nome" "text" NOT NULL,
    "sesso" "text",
    "eta_min" integer,
    "eta_max" integer,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_categories_eta" CHECK ((("eta_min" IS NULL) OR ("eta_max" IS NULL) OR ("eta_min" <= "eta_max"))),
    CONSTRAINT "chk_categories_sesso" CHECK ((("sesso" IS NULL) OR ("sesso" = ANY (ARRAY['M'::"text", 'F'::"text"]))))
);
ALTER TABLE "public"."categories" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."category_template_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "template_id" "uuid" NOT NULL,
    "nome" "text" NOT NULL,
    "sesso" "text",
    "eta_min" integer,
    "eta_max" integer,
    "ordine" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_category_template_items_eta" CHECK ((("eta_min" IS NULL) OR ("eta_max" IS NULL) OR ("eta_min" <= "eta_max"))),
    CONSTRAINT "chk_category_template_items_sesso" CHECK ((("sesso" IS NULL) OR ("sesso" = ANY (ARRAY['M'::"text", 'F'::"text"]))))
);
ALTER TABLE "public"."category_template_items" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."category_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."category_templates" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."competitions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "descrizione" "text" NOT NULL,
    "dt_gara" "date" NOT NULL,
    "nr_boulder" integer DEFAULT 0 NOT NULL,
    "quota_iscrizione" numeric(10,2) DEFAULT 0 NOT NULL,
    "nr_finalisti" integer DEFAULT 0 NOT NULL,
    "fl_iscrizioni_chiuse" boolean DEFAULT false NOT NULL,
    "fl_gara_chiusa" boolean DEFAULT false NOT NULL,
    "fl_gestione_presenze" boolean DEFAULT false NOT NULL,
    "fl_gestione_pagamenti" boolean DEFAULT false NOT NULL,
    "fl_gestione_omaggi" boolean DEFAULT false NOT NULL,
    "note" "text",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "nr_max_registrations" integer DEFAULT 0 NOT NULL,
    "is_turn" boolean DEFAULT false NOT NULL,
    "nr_max_first_turn" integer DEFAULT 0 NOT NULL,
    "nr_max_second_turn" integer DEFAULT 0 NOT NULL
);
ALTER TABLE "public"."competitions" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."email_send_tokens" (
    "token" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text" NOT NULL,
    "purpose" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone NOT NULL
);
ALTER TABLE "public"."email_send_tokens" OWNER TO "postgres";
COMMENT ON TABLE "public"."email_send_tokens" IS 'Token monouso a scadenza breve per autorizzare l''invio di una mail
   verso un indirizzo specifico prima che esista una sessione utente
   (es. auto-registrazione atleta). Accesso riservato a service_role.';
CREATE TABLE IF NOT EXISTS "public"."email_template_variables" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "template_id" "uuid" NOT NULL,
    "variable_code" "text" NOT NULL,
    "label" "text" NOT NULL,
    "description" "text",
    "data_type" "public"."email_template_variable_type" DEFAULT 'text'::"public"."email_template_variable_type" NOT NULL,
    "required" boolean DEFAULT false NOT NULL,
    "default_value" "text",
    "validation" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "example_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "email_template_variables_code_check" CHECK (("variable_code" ~ '^[A-Z][A-Z0-9_]*$'::"text")),
    CONSTRAINT "email_template_variables_label_check" CHECK (("length"(TRIM(BOTH FROM "label")) > 0)),
    CONSTRAINT "email_template_variables_validation_object_check" CHECK (("jsonb_typeof"("validation") = 'object'::"text"))
);
ALTER TABLE "public"."email_template_variables" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."import_job_rows" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "import_job_id" "uuid" NOT NULL,
    "row_number" integer NOT NULL,
    "raw_row" "text" NOT NULL,
    "status" "text" NOT NULL,
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_import_job_rows_status" CHECK (("status" = ANY (ARRAY['INSERTED'::"text", 'DISCARDED'::"text"])))
);
ALTER TABLE "public"."import_job_rows" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."import_jobs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competition_id" "uuid" NOT NULL,
    "file_name" "text" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp with time zone,
    "status" "text" DEFAULT 'RUNNING'::"text" NOT NULL,
    "total_rows" integer DEFAULT 0 NOT NULL,
    "inserted_rows" integer DEFAULT 0 NOT NULL,
    "discarded_rows" integer DEFAULT 0 NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_import_jobs_status" CHECK (("status" = ANY (ARRAY['RUNNING'::"text", 'COMPLETED'::"text", 'ERROR'::"text"])))
);
ALTER TABLE "public"."import_jobs" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."menu_translations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "menu_id" "uuid" NOT NULL,
    "locale" character varying(5) NOT NULL,
    "label" character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."menu_translations" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."menus" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "label" character varying(100) NOT NULL,
    "route" character varying(255) NOT NULL,
    "icon" character varying(100),
    "display_order" integer DEFAULT 0 NOT NULL,
    "parent_id" "uuid",
    "visible" boolean DEFAULT true NOT NULL,
    "mobile" boolean DEFAULT true NOT NULL,
    "desktop" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."menus" OWNER TO "postgres";
COMMENT ON TABLE "public"."menus" IS 'Menù applicativi dinamici utilizzati dal frontend Flutter';
COMMENT ON COLUMN "public"."menus"."label" IS 'Etichetta visualizzata nel menu';
COMMENT ON COLUMN "public"."menus"."route" IS 'Route Flutter / GoRouter';
COMMENT ON COLUMN "public"."menus"."icon" IS 'Nome icona Flutter';
COMMENT ON COLUMN "public"."menus"."display_order" IS 'Ordine visualizzazione menu';
COMMENT ON COLUMN "public"."menus"."parent_id" IS 'Menu padre per struttura gerarchica';
COMMENT ON COLUMN "public"."menus"."visible" IS 'Abilitazione visualizzazione menu';
COMMENT ON COLUMN "public"."menus"."mobile" IS 'Visibile su applicazione mobile';
COMMENT ON COLUMN "public"."menus"."desktop" IS 'Visibile su applicazione desktop';
CREATE TABLE IF NOT EXISTS "public"."permissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "permission_code" character varying(100) NOT NULL,
    "activity" character varying(255) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."permissions" OWNER TO "postgres";
COMMENT ON TABLE "public"."permissions" IS 'Permessi granulari applicativi';
COMMENT ON COLUMN "public"."permissions"."permission_code" IS 'Codice tecnico permesso';
COMMENT ON COLUMN "public"."permissions"."activity" IS 'Descrizione leggibile del permesso';
CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auth_user_id" "uuid" NOT NULL,
    "email" character varying(255) NOT NULL,
    "nome" character varying(100) NOT NULL,
    "cognome" character varying(100) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "password_changed" boolean DEFAULT false NOT NULL
);
ALTER TABLE "public"."profiles" OWNER TO "postgres";
COMMENT ON TABLE "public"."profiles" IS 'Estensione applicativa degli utenti autenticati Supabase';
COMMENT ON COLUMN "public"."profiles"."auth_user_id" IS 'Collegamento alla tabella auth.users di Supabase';
COMMENT ON COLUMN "public"."profiles"."email" IS 'Email corrente utente';
COMMENT ON COLUMN "public"."profiles"."nome" IS 'Nome utente';
COMMENT ON COLUMN "public"."profiles"."cognome" IS 'Cognome utente';
CREATE TABLE IF NOT EXISTS "public"."registrations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "competition_id" "uuid" NOT NULL,
    "profile_id" "uuid",
    "category_id" "uuid",
    "pettorale" integer,
    "cognome" "text" NOT NULL,
    "nome" "text" NOT NULL,
    "email" "text" NOT NULL,
    "societa" "text",
    "data_nascita" "date",
    "sesso" "text",
    "fl_presente" boolean DEFAULT false NOT NULL,
    "fl_pagato" boolean DEFAULT false NOT NULL,
    "fl_omaggio" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_first_turn" boolean DEFAULT false NOT NULL,
    "is_second_turn" boolean DEFAULT false NOT NULL,
    "owner_registration" "text" DEFAULT 'admin'::"text" NOT NULL,
    CONSTRAINT "chk_registrations_owner_registration" CHECK (("owner_registration" = ANY (ARRAY['admin'::"text", 'athlete'::"text", 'import'::"text"]))),
    CONSTRAINT "chk_registrations_sesso" CHECK ((("sesso" IS NULL) OR ("sesso" = ANY (ARRAY['M'::"text", 'F'::"text"]))))
);
ALTER TABLE "public"."registrations" OWNER TO "postgres";
CREATE TABLE IF NOT EXISTS "public"."role_menus" (
    "role_id" "uuid" NOT NULL,
    "menu_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."role_menus" OWNER TO "postgres";
COMMENT ON TABLE "public"."role_menus" IS 'Associazione tra ruoli applicativi e menu disponibili';
COMMENT ON COLUMN "public"."role_menus"."role_id" IS 'Ruolo applicativo';
COMMENT ON COLUMN "public"."role_menus"."menu_id" IS 'Menu associato al ruolo';
CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."role_permissions" OWNER TO "postgres";
COMMENT ON TABLE "public"."role_permissions" IS 'Associazione tra ruoli e permessi applicativi';
COMMENT ON COLUMN "public"."role_permissions"."role_id" IS 'Ruolo applicativo';
COMMENT ON COLUMN "public"."role_permissions"."permission_id" IS 'Permesso applicativo';
CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" character varying(50) NOT NULL,
    "name" character varying(100) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."roles" OWNER TO "postgres";
COMMENT ON TABLE "public"."roles" IS 'Ruoli applicativi del sistema';
COMMENT ON COLUMN "public"."roles"."code" IS 'Codice tecnico ruolo (admin, judge, athlete)';
COMMENT ON COLUMN "public"."roles"."name" IS 'Descrizione leggibile del ruolo';
CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "profile_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);
ALTER TABLE "public"."user_roles" OWNER TO "postgres";
COMMENT ON TABLE "public"."user_roles" IS 'Associazione tra utenti applicativi e ruoli';
COMMENT ON COLUMN "public"."user_roles"."profile_id" IS 'Riferimento al profilo utente';
COMMENT ON COLUMN "public"."user_roles"."role_id" IS 'Riferimento al ruolo applicativo';
CREATE OR REPLACE VIEW "public"."v_boulder_stats" WITH ("security_invoker"='on') AS
 SELECT "b"."id" AS "boulder_id",
    "b"."competition_id",
    "b"."numero",
    "b"."difficolta",
    "b"."colore",
    "b"."valore_teorico",
    "count"("a".*) FILTER (WHERE ("a"."top" = true)) AS "numero_chiusure",
        CASE
            WHEN ("count"("a".*) FILTER (WHERE ("a"."top" = true)) = 0) THEN "b"."valore_teorico"
            ELSE "round"(("b"."valore_teorico" / ("count"("a".*) FILTER (WHERE ("a"."top" = true)))::numeric), 2)
        END AS "valore_effettivo"
   FROM ("public"."boulders" "b"
     LEFT JOIN "public"."ascents" "a" ON (("a"."boulder_id" = "b"."id")))
  WHERE ("b"."is_finale" = false)
  GROUP BY "b"."id", "b"."competition_id", "b"."numero", "b"."difficolta", "b"."colore", "b"."valore_teorico";
ALTER VIEW "public"."v_boulder_stats" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_ascent_scores" WITH ("security_invoker"='on') AS
 SELECT "a"."registration_id",
    "a"."boulder_id",
    "a"."top",
    "a"."zone",
    "a"."tentativi_top",
    "a"."tentativi_zone",
    "bs"."valore_effettivo",
        CASE
            WHEN ("a"."top" = true) THEN "bs"."valore_effettivo"
            WHEN ("a"."zone" = true) THEN "round"(("bs"."valore_effettivo" * 0.5), 2)
            ELSE (0)::numeric
        END AS "punteggio"
   FROM ("public"."ascents" "a"
     JOIN "public"."v_boulder_stats" "bs" ON (("bs"."boulder_id" = "a"."boulder_id")));
ALTER VIEW "public"."v_ascent_scores" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_boulder_stats_finale" WITH ("security_invoker"='on') AS
 SELECT "id" AS "boulder_id",
    "competition_id",
    "numero",
    "difficolta",
    "colore"
   FROM "public"."boulders" "b"
  WHERE ("is_finale" = true);
ALTER VIEW "public"."v_boulder_stats_finale" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_ascent_scores_finale" WITH ("security_invoker"='on') AS
 SELECT "a"."registration_id",
    "a"."boulder_id",
    "a"."top",
    "a"."zone",
    COALESCE("a"."tentativi_top", 0) AS "tentativi_top",
    COALESCE("a"."tentativi_zone", 0) AS "tentativi_zone"
   FROM ("public"."ascents" "a"
     JOIN "public"."v_boulder_stats_finale" "bs" ON (("bs"."boulder_id" = "a"."boulder_id")));
ALTER VIEW "public"."v_ascent_scores_finale" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_boulder_stats_qualificazione" WITH ("security_invoker"='on') AS
 SELECT "b"."id" AS "boulder_id",
    "b"."competition_id",
    "b"."numero",
    "b"."difficolta",
    "b"."colore",
    "count"("a".*) FILTER (WHERE ("a"."top" = true)) AS "numero_top",
        CASE
            WHEN ("count"("a".*) FILTER (WHERE ("a"."top" = true)) = 0) THEN (1000)::numeric
            ELSE "round"((1000.0 / ("count"("a".*) FILTER (WHERE ("a"."top" = true)))::numeric), 2)
        END AS "valore_boulder"
   FROM ("public"."boulders" "b"
     LEFT JOIN "public"."ascents" "a" ON (("a"."boulder_id" = "b"."id")))
  WHERE ("b"."is_finale" = false)
  GROUP BY "b"."id", "b"."competition_id", "b"."numero", "b"."difficolta", "b"."colore";
ALTER VIEW "public"."v_boulder_stats_qualificazione" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_ascent_scores_qualificazione" WITH ("security_invoker"='on') AS
 SELECT "a"."registration_id",
    "a"."boulder_id",
    "bs"."valore_boulder" AS "punteggio"
   FROM ("public"."ascents" "a"
     JOIN "public"."v_boulder_stats_qualificazione" "bs" ON (("bs"."boulder_id" = "a"."boulder_id")))
  WHERE ("a"."top" = true);
ALTER VIEW "public"."v_ascent_scores_qualificazione" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_boulder_top_zone" WITH ("security_invoker"='on') AS
 SELECT "b"."id" AS "boulder_id",
    "b"."competition_id",
    "b"."numero",
    "b"."difficolta",
    "b"."colore",
    "count"("a".*) FILTER (WHERE ("a"."top" = true)) AS "numero_top",
    "count"("a".*) FILTER (WHERE ("a"."zone" = true)) AS "numero_zone",
        CASE
            WHEN ("count"("a".*) FILTER (WHERE ("a"."top" = true)) = 0) THEN (800)::numeric
            ELSE "round"((800.0 / ("count"("a".*) FILTER (WHERE ("a"."top" = true)))::numeric), 2)
        END AS "valore_top",
        CASE
            WHEN ("count"("a".*) FILTER (WHERE ("a"."zone" = true)) = 0) THEN (200)::numeric
            ELSE "round"((200.0 / ("count"("a".*) FILTER (WHERE ("a"."zone" = true)))::numeric), 2)
        END AS "valore_zone"
   FROM ("public"."boulders" "b"
     LEFT JOIN "public"."ascents" "a" ON (("a"."boulder_id" = "b"."id")))
  WHERE ("b"."is_finale" = false)
  GROUP BY "b"."id", "b"."competition_id", "b"."numero", "b"."difficolta", "b"."colore";
ALTER VIEW "public"."v_boulder_top_zone" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_ascent_top_zone" WITH ("security_invoker"='on') AS
 SELECT "a"."registration_id",
    "a"."boulder_id",
    "a"."top",
    "a"."zone",
    "a"."tentativi_top",
    "a"."tentativi_zone",
    "bs"."valore_top",
    "bs"."valore_zone",
        CASE
            WHEN ("a"."top" = true) THEN "round"(("bs"."valore_top" + "bs"."valore_zone"), 2)
            WHEN ("a"."zone" = true) THEN "round"("bs"."valore_zone", 2)
            ELSE (0)::numeric
        END AS "punteggio"
   FROM ("public"."ascents" "a"
     JOIN "public"."v_boulder_top_zone" "bs" ON (("bs"."boulder_id" = "a"."boulder_id")));
ALTER VIEW "public"."v_ascent_top_zone" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_registration_rankings" WITH ("security_invoker"='on') AS
 SELECT "r"."id" AS "registration_id",
    "r"."competition_id",
    "r"."category_id",
    "r"."pettorale",
    "r"."cognome",
    "r"."nome",
    "r"."societa",
    "count"("vs".*) FILTER (WHERE ("vs"."top" = true)) AS "nr_top",
    "count"("vs".*) FILTER (WHERE ("vs"."zone" = true)) AS "nr_zone",
    COALESCE("sum"("vs"."tentativi_top"), (0)::bigint) AS "tentativi_top",
    COALESCE("sum"("vs"."tentativi_zone"), (0)::bigint) AS "tentativi_zone",
    COALESCE("round"("sum"("vs"."punteggio"), 2), (0)::numeric) AS "punteggio_totale"
   FROM ("public"."registrations" "r"
     LEFT JOIN "public"."v_ascent_scores" "vs" ON (("vs"."registration_id" = "r"."id")))
  GROUP BY "r"."id", "r"."competition_id", "r"."category_id", "r"."pettorale", "r"."cognome", "r"."nome", "r"."societa";
ALTER VIEW "public"."v_registration_rankings" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_category_rankings" WITH ("security_invoker"='on') AS
 SELECT "row_number"() OVER (PARTITION BY "category_id" ORDER BY "punteggio_totale" DESC, "nr_top" DESC, "nr_zone" DESC, "tentativi_top", "tentativi_zone") AS "posizione",
    "registration_id",
    "competition_id",
    "category_id",
    "pettorale",
    "cognome",
    "nome",
    "societa",
    "nr_top",
    "nr_zone",
    "tentativi_top",
    "tentativi_zone",
    "punteggio_totale"
   FROM "public"."v_registration_rankings" "vr";
ALTER VIEW "public"."v_category_rankings" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_category_rankings_finale" WITH ("security_invoker"='true') AS
 SELECT "ar"."registration_id",
    "ar"."competition_id",
    "ar"."category_id",
    "ar"."pettorale",
    "ar"."cognome",
    "ar"."nome",
    "ar"."sesso",
    "ar"."societa",
    "ar"."nr_top",
    "ar"."nr_zone",
    "ar"."tentativi_top",
    "ar"."tentativi_zone",
    "c"."nome" AS "categoria_nome",
    "c"."sesso" AS "categoria_sesso",
    "c"."eta_min" AS "categoria_eta_min",
    "c"."eta_max" AS "categoria_eta_max",
    "row_number"() OVER (PARTITION BY "ar"."category_id" ORDER BY "ar"."nr_top" DESC, "ar"."nr_zone" DESC, "ar"."tentativi_top", "ar"."tentativi_zone", "ar"."cognome", "ar"."nome") AS "posizione"
   FROM (( SELECT "r"."id" AS "registration_id",
            "r"."competition_id",
            "r"."category_id",
            "r"."pettorale",
            "r"."cognome",
            "r"."nome",
            "r"."sesso",
            "r"."societa",
            "count"(*) FILTER (WHERE ("vs"."top" = true)) AS "nr_top",
            "count"(*) FILTER (WHERE ("vs"."zone" = true)) AS "nr_zone",
            COALESCE("sum"(
                CASE
                    WHEN ("vs"."top" = true) THEN "vs"."tentativi_top"
                    ELSE 0
                END), (0)::bigint) AS "tentativi_top",
            COALESCE("sum"(
                CASE
                    WHEN ("vs"."zone" = true) THEN "vs"."tentativi_zone"
                    ELSE 0
                END), (0)::bigint) AS "tentativi_zone"
           FROM ("public"."registrations" "r"
             LEFT JOIN "public"."v_ascent_scores_finale" "vs" ON (("vs"."registration_id" = "r"."id")))
          WHERE ("r"."category_id" IS NOT NULL)
          GROUP BY "r"."id", "r"."competition_id", "r"."category_id", "r"."pettorale", "r"."cognome", "r"."nome", "r"."sesso", "r"."societa") "ar"
     JOIN "public"."categories" "c" ON (("c"."id" = "ar"."category_id")));
ALTER VIEW "public"."v_category_rankings_finale" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_registration_rankings_qualificazione" WITH ("security_invoker"='on') AS
 SELECT "r"."id" AS "registration_id",
    "r"."competition_id",
    "r"."category_id",
    "r"."pettorale",
    "r"."cognome",
    "r"."nome",
    "r"."sesso",
    "r"."societa",
    "count"("vs".*) AS "nr_top",
    COALESCE("round"("sum"("vs"."punteggio"), 2), (0)::numeric) AS "punteggio_totale"
   FROM ("public"."registrations" "r"
     LEFT JOIN "public"."v_ascent_scores_qualificazione" "vs" ON (("vs"."registration_id" = "r"."id")))
  GROUP BY "r"."id", "r"."competition_id", "r"."category_id", "r"."pettorale", "r"."cognome", "r"."nome", "r"."sesso", "r"."societa";
ALTER VIEW "public"."v_registration_rankings_qualificazione" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_category_rankings_qualificazione" WITH ("security_invoker"='true') AS
 SELECT "row_number"() OVER (PARTITION BY "vr"."category_id" ORDER BY "vr"."punteggio_totale" DESC, "vr"."nr_top" DESC) AS "posizione",
    "vr"."registration_id",
    "vr"."competition_id",
    "vr"."category_id",
    "c"."nome" AS "categoria_nome",
    "c"."sesso" AS "categoria_sesso",
    "c"."eta_min" AS "categoria_eta_min",
    "c"."eta_max" AS "categoria_eta_max",
    "vr"."pettorale",
    "vr"."cognome",
    "vr"."nome",
    "vr"."sesso",
    "vr"."societa",
    "vr"."nr_top",
    "vr"."punteggio_totale"
   FROM ("public"."v_registration_rankings_qualificazione" "vr"
     JOIN "public"."categories" "c" ON (("c"."id" = "vr"."category_id")))
  WHERE ("vr"."category_id" IS NOT NULL);
ALTER VIEW "public"."v_category_rankings_qualificazione" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_registration_top_zone" WITH ("security_invoker"='on') AS
 SELECT "r"."id" AS "registration_id",
    "r"."competition_id",
    "r"."category_id",
    "r"."pettorale",
    "r"."cognome",
    "r"."nome",
    "r"."sesso",
    "r"."societa",
    "count"("vs".*) FILTER (WHERE ("vs"."top" = true)) AS "nr_top",
    "count"("vs".*) FILTER (WHERE ("vs"."zone" = true)) AS "nr_zone",
    COALESCE("sum"("vs"."tentativi_top"), (0)::bigint) AS "tentativi_top",
    COALESCE("sum"("vs"."tentativi_zone"), (0)::bigint) AS "tentativi_zone",
    COALESCE("round"("sum"("vs"."punteggio"), 2), (0)::numeric) AS "punteggio_totale"
   FROM ("public"."registrations" "r"
     LEFT JOIN "public"."v_ascent_top_zone" "vs" ON (("vs"."registration_id" = "r"."id")))
  GROUP BY "r"."id", "r"."competition_id", "r"."category_id", "r"."pettorale", "r"."cognome", "r"."nome", "r"."sesso", "r"."societa";
ALTER VIEW "public"."v_registration_top_zone" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_category_rankings_top_zone" WITH ("security_invoker"='on') AS
 SELECT "r"."registration_id",
    "r"."competition_id",
    "r"."category_id",
    "c"."nome" AS "categoria_nome",
    "c"."sesso" AS "categoria_sesso",
    "c"."eta_min" AS "categoria_eta_min",
    "c"."eta_max" AS "categoria_eta_max",
    "r"."pettorale",
    "r"."cognome",
    "r"."nome",
    "r"."sesso",
    "r"."societa",
    "r"."nr_top",
    "r"."nr_zone",
    "r"."tentativi_top",
    "r"."tentativi_zone",
    "r"."punteggio_totale",
    "row_number"() OVER (PARTITION BY "r"."category_id" ORDER BY "r"."nr_top" DESC, "r"."nr_zone" DESC, "r"."punteggio_totale" DESC, "r"."cognome", "r"."nome") AS "posizione"
   FROM ("public"."v_registration_top_zone" "r"
     JOIN "public"."categories" "c" ON (("c"."id" = "r"."category_id")))
  WHERE ("r"."category_id" IS NOT NULL);
ALTER VIEW "public"."v_category_rankings_top_zone" OWNER TO "postgres";
CREATE OR REPLACE VIEW "public"."v_registration_rankings_finale" WITH ("security_invoker"='on') AS
 SELECT "r"."id" AS "registration_id",
    "r"."competition_id",
    "r"."category_id",
    "r"."pettorale",
    "r"."cognome",
    "r"."nome",
    "r"."sesso",
    "r"."societa",
    "count"(*) FILTER (WHERE ("vs"."top" = true)) AS "nr_top",
    "count"(*) FILTER (WHERE ("vs"."zone" = true)) AS "nr_zone",
    COALESCE("sum"(
        CASE
            WHEN ("vs"."top" = true) THEN "vs"."tentativi_top"
            ELSE 0
        END), (0)::bigint) AS "tentativi_top",
    COALESCE("sum"(
        CASE
            WHEN ("vs"."zone" = true) THEN "vs"."tentativi_zone"
            ELSE 0
        END), (0)::bigint) AS "tentativi_zone"
   FROM ("public"."registrations" "r"
     LEFT JOIN "public"."v_ascent_scores_finale" "vs" ON (("vs"."registration_id" = "r"."id")))
  GROUP BY "r"."id", "r"."competition_id", "r"."category_id", "r"."pettorale", "r"."cognome", "r"."nome", "r"."sesso", "r"."societa";
ALTER VIEW "public"."v_registration_rankings_finale" OWNER TO "postgres";
ALTER TABLE ONLY "public"."ascents"
    ADD CONSTRAINT "ascents_pkey" PRIMARY KEY ("registration_id", "boulder_id");
ALTER TABLE ONLY "public"."boulders"
    ADD CONSTRAINT "boulders_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."category_template_items"
    ADD CONSTRAINT "category_template_items_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."category_templates"
    ADD CONSTRAINT "category_templates_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."competitions"
    ADD CONSTRAINT "competitions_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."email_send_tokens"
    ADD CONSTRAINT "email_send_tokens_pkey" PRIMARY KEY ("token");
ALTER TABLE ONLY "public"."email_template_assets"
    ADD CONSTRAINT "email_template_assets_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."email_template_assets"
    ADD CONSTRAINT "email_template_assets_storage_path_key" UNIQUE ("storage_path");
ALTER TABLE ONLY "public"."email_template_variables"
    ADD CONSTRAINT "email_template_variables_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."email_template_variables"
    ADD CONSTRAINT "email_template_variables_template_code_uq" UNIQUE ("template_id", "variable_code");
ALTER TABLE ONLY "public"."email_templates"
    ADD CONSTRAINT "email_templates_code_language_version_uq" UNIQUE ("template_code", "language", "version");
ALTER TABLE ONLY "public"."email_templates"
    ADD CONSTRAINT "email_templates_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."import_job_rows"
    ADD CONSTRAINT "import_job_rows_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."import_jobs"
    ADD CONSTRAINT "import_jobs_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."menu_translations"
    ADD CONSTRAINT "menu_translations_menu_id_locale_key" UNIQUE ("menu_id", "locale");
ALTER TABLE ONLY "public"."menu_translations"
    ADD CONSTRAINT "menu_translations_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."menus"
    ADD CONSTRAINT "menus_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."menus"
    ADD CONSTRAINT "menus_route_key" UNIQUE ("route");
ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_permission_code_key" UNIQUE ("permission_code");
ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."role_menus"
    ADD CONSTRAINT "pk_role_menus" PRIMARY KEY ("role_id", "menu_id");
ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "pk_role_permissions" PRIMARY KEY ("role_id", "permission_id");
ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "pk_user_roles" PRIMARY KEY ("profile_id", "role_id");
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_auth_user_id_key" UNIQUE ("auth_user_id");
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."registrations"
    ADD CONSTRAINT "registrations_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_code_key" UNIQUE ("code");
ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."boulders"
    ADD CONSTRAINT "uq_boulders_competition_numero" UNIQUE ("competition_id", "numero");
ALTER TABLE ONLY "public"."category_template_items"
    ADD CONSTRAINT "uq_category_template_item" UNIQUE ("template_id", "nome", "sesso");
ALTER TABLE ONLY "public"."category_templates"
    ADD CONSTRAINT "uq_category_templates_nome" UNIQUE ("nome");
CREATE INDEX "email_template_assets_template_idx" ON "public"."email_template_assets" USING "btree" ("template_id", "status");
CREATE INDEX "email_template_variables_template_idx" ON "public"."email_template_variables" USING "btree" ("template_id");
CREATE INDEX "email_templates_lookup_idx" ON "public"."email_templates" USING "btree" ("template_code", "language", "status");
CREATE UNIQUE INDEX "email_templates_one_active_version_uq" ON "public"."email_templates" USING "btree" ("template_code", "language") WHERE ("status" = 'active'::"public"."email_template_status");
CREATE UNIQUE INDEX "email_templates_one_default_language_uq" ON "public"."email_templates" USING "btree" ("template_code") WHERE (("status" = 'active'::"public"."email_template_status") AND ("is_default" = true));
CREATE INDEX "idx_ascents_boulder_id" ON "public"."ascents" USING "btree" ("boulder_id");
CREATE INDEX "idx_ascents_registration_id" ON "public"."ascents" USING "btree" ("registration_id");
CREATE INDEX "idx_boulders_competition_id" ON "public"."boulders" USING "btree" ("competition_id");
CREATE INDEX "idx_boulders_numero" ON "public"."boulders" USING "btree" ("numero");
CREATE INDEX "idx_categories_competition_id" ON "public"."categories" USING "btree" ("competition_id");
CREATE INDEX "idx_categories_nome" ON "public"."categories" USING "btree" ("nome");
CREATE INDEX "idx_category_template_items_template" ON "public"."category_template_items" USING "btree" ("template_id");
CREATE INDEX "idx_competitions_created_by" ON "public"."competitions" USING "btree" ("created_by");
CREATE INDEX "idx_competitions_dt_gara" ON "public"."competitions" USING "btree" ("dt_gara");
CREATE INDEX "idx_email_send_tokens_expires_at" ON "public"."email_send_tokens" USING "btree" ("expires_at");
CREATE INDEX "idx_import_job_rows_job_id" ON "public"."import_job_rows" USING "btree" ("import_job_id");
CREATE INDEX "idx_import_jobs_competition_id" ON "public"."import_jobs" USING "btree" ("competition_id");
CREATE INDEX "idx_menus_display_order" ON "public"."menus" USING "btree" ("display_order");
CREATE INDEX "idx_menus_parent_id" ON "public"."menus" USING "btree" ("parent_id");
CREATE INDEX "idx_menus_route" ON "public"."menus" USING "btree" ("route");
CREATE INDEX "idx_menus_visible" ON "public"."menus" USING "btree" ("visible");
CREATE INDEX "idx_permissions_activity" ON "public"."permissions" USING "btree" ("activity");
CREATE UNIQUE INDEX "idx_permissions_code" ON "public"."permissions" USING "btree" ("permission_code");
CREATE INDEX "idx_profiles_auth_user_id" ON "public"."profiles" USING "btree" ("auth_user_id");
CREATE INDEX "idx_profiles_cognome_nome" ON "public"."profiles" USING "btree" ("cognome", "nome");
CREATE INDEX "idx_profiles_email" ON "public"."profiles" USING "btree" ("email");
CREATE INDEX "idx_registrations_category_id" ON "public"."registrations" USING "btree" ("category_id");
CREATE INDEX "idx_registrations_competition_id" ON "public"."registrations" USING "btree" ("competition_id");
CREATE INDEX "idx_registrations_email" ON "public"."registrations" USING "btree" ("email");
CREATE INDEX "idx_registrations_pettorale" ON "public"."registrations" USING "btree" ("pettorale");
CREATE INDEX "idx_registrations_profile_id" ON "public"."registrations" USING "btree" ("profile_id");
CREATE INDEX "idx_role_menus_menu_id" ON "public"."role_menus" USING "btree" ("menu_id");
CREATE INDEX "idx_role_menus_role_id" ON "public"."role_menus" USING "btree" ("role_id");
CREATE INDEX "idx_role_permissions_permission_id" ON "public"."role_permissions" USING "btree" ("permission_id");
CREATE INDEX "idx_role_permissions_role_id" ON "public"."role_permissions" USING "btree" ("role_id");
CREATE UNIQUE INDEX "idx_roles_code" ON "public"."roles" USING "btree" ("code");
CREATE INDEX "idx_roles_name" ON "public"."roles" USING "btree" ("name");
CREATE INDEX "idx_user_roles_profile_id" ON "public"."user_roles" USING "btree" ("profile_id");
CREATE INDEX "idx_user_roles_role_id" ON "public"."user_roles" USING "btree" ("role_id");
CREATE INDEX "menu_translations_menu_id_locale_idx" ON "public"."menu_translations" USING "btree" ("menu_id", "locale");
CREATE UNIQUE INDEX "uq_registrations_competition_email" ON "public"."registrations" USING "btree" ("competition_id", "email");
CREATE OR REPLACE TRIGGER "email_template_assets_set_updated_at" BEFORE UPDATE ON "public"."email_template_assets" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
CREATE OR REPLACE TRIGGER "email_templates_set_updated_at" BEFORE UPDATE ON "public"."email_templates" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();
ALTER TABLE ONLY "public"."ascents"
    ADD CONSTRAINT "ascents_boulder_id_fkey" FOREIGN KEY ("boulder_id") REFERENCES "public"."boulders"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."ascents"
    ADD CONSTRAINT "ascents_registration_id_fkey" FOREIGN KEY ("registration_id") REFERENCES "public"."registrations"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."boulders"
    ADD CONSTRAINT "boulders_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "public"."competitions"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "public"."competitions"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."category_template_items"
    ADD CONSTRAINT "category_template_items_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."category_templates"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."competitions"
    ADD CONSTRAINT "competitions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");
ALTER TABLE ONLY "public"."email_template_assets"
    ADD CONSTRAINT "email_template_assets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;
ALTER TABLE ONLY "public"."email_template_assets"
    ADD CONSTRAINT "email_template_assets_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."email_templates"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."email_template_variables"
    ADD CONSTRAINT "email_template_variables_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."email_templates"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."email_templates"
    ADD CONSTRAINT "email_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;
ALTER TABLE ONLY "public"."menus"
    ADD CONSTRAINT "fk_menus_parent" FOREIGN KEY ("parent_id") REFERENCES "public"."menus"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "fk_profiles_auth_users" FOREIGN KEY ("auth_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."role_menus"
    ADD CONSTRAINT "fk_role_menus_menu" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."role_menus"
    ADD CONSTRAINT "fk_role_menus_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "fk_role_permissions_permission" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "fk_role_permissions_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "fk_user_roles_profile" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "fk_user_roles_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."import_job_rows"
    ADD CONSTRAINT "import_job_rows_import_job_id_fkey" FOREIGN KEY ("import_job_id") REFERENCES "public"."import_jobs"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."import_jobs"
    ADD CONSTRAINT "import_jobs_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "public"."competitions"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."import_jobs"
    ADD CONSTRAINT "import_jobs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id");
ALTER TABLE ONLY "public"."menu_translations"
    ADD CONSTRAINT "menu_translations_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."registrations"
    ADD CONSTRAINT "registrations_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE SET NULL;
ALTER TABLE ONLY "public"."registrations"
    ADD CONSTRAINT "registrations_competition_id_fkey" FOREIGN KEY ("competition_id") REFERENCES "public"."competitions"("id") ON DELETE CASCADE;
ALTER TABLE ONLY "public"."registrations"
    ADD CONSTRAINT "registrations_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;
CREATE POLICY "Users can delete own competitions" ON "public"."competitions" FOR DELETE TO "authenticated" USING (("created_by" IN ( SELECT "profiles"."id"
   FROM "public"."profiles"
  WHERE ("profiles"."auth_user_id" = "auth"."uid"()))));
CREATE POLICY "admins manage email templates" ON "public"."email_templates" TO "authenticated" USING ("public"."is_email_template_admin"()) WITH CHECK ("public"."is_email_template_admin"());
CREATE POLICY "admins manage template assets" ON "public"."email_template_assets" TO "authenticated" USING ("public"."is_email_template_admin"()) WITH CHECK ("public"."is_email_template_admin"());
CREATE POLICY "admins manage template variables" ON "public"."email_template_variables" TO "authenticated" USING ("public"."is_email_template_admin"()) WITH CHECK ("public"."is_email_template_admin"());
ALTER TABLE "public"."ascents" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ascents_delete_policy" ON "public"."ascents" FOR DELETE USING ("public"."has_permission"('ascent.write'::"text"));
CREATE POLICY "ascents_insert_policy" ON "public"."ascents" FOR INSERT WITH CHECK (("public"."has_permission"('ascent.write'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."registrations" "r"
  WHERE (("r"."id" = "ascents"."registration_id") AND ("r"."profile_id" = "public"."current_profile_id"()))))));
CREATE POLICY "ascents_select_policy" ON "public"."ascents" FOR SELECT USING (("public"."has_permission"('competition.read'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."registrations" "r"
  WHERE (("r"."id" = "ascents"."registration_id") AND ("r"."profile_id" = "public"."current_profile_id"()))))));
CREATE POLICY "ascents_update_policy" ON "public"."ascents" FOR UPDATE USING (("public"."has_permission"('ascent.write'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."registrations" "r"
  WHERE (("r"."id" = "ascents"."registration_id") AND ("r"."profile_id" = "public"."current_profile_id"())))))) WITH CHECK (("public"."has_permission"('ascent.write'::"text") OR (EXISTS ( SELECT 1
   FROM "public"."registrations" "r"
  WHERE (("r"."id" = "ascents"."registration_id") AND ("r"."profile_id" = "public"."current_profile_id"()))))));
ALTER TABLE "public"."boulders" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "boulders_delete_policy" ON "public"."boulders" FOR DELETE USING ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "boulders_insert_policy" ON "public"."boulders" FOR INSERT WITH CHECK ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "boulders_select_policy" ON "public"."boulders" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "boulders_update_policy" ON "public"."boulders" FOR UPDATE USING ("public"."has_permission"('competition.write'::"text")) WITH CHECK ("public"."has_permission"('competition.write'::"text"));
ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_delete_policy" ON "public"."categories" FOR DELETE USING (("public"."has_permission"('competition.write'::"text") OR ("auth"."role"() = 'service_role'::"text")));
CREATE POLICY "categories_insert_policy" ON "public"."categories" FOR INSERT WITH CHECK (("public"."has_permission"('competition.write'::"text") OR ("auth"."role"() = 'service_role'::"text")));
CREATE POLICY "categories_select_policy" ON "public"."categories" FOR SELECT USING (("public"."has_permission"('competition.read'::"text") OR ("auth"."role"() = 'service_role'::"text")));
CREATE POLICY "categories_update_policy" ON "public"."categories" FOR UPDATE USING ("public"."has_permission"('competition.write'::"text")) WITH CHECK (("public"."has_permission"('competition.write'::"text") OR ("auth"."role"() = 'service_role'::"text")));
ALTER TABLE "public"."category_template_items" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "category_template_items_delete_policy" ON "public"."category_template_items" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_template_items_insert_policy" ON "public"."category_template_items" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_template_items_select_policy" ON "public"."category_template_items" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_template_items_update_policy" ON "public"."category_template_items" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text")) WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
ALTER TABLE "public"."category_templates" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "category_templates_delete_policy" ON "public"."category_templates" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_templates_insert_policy" ON "public"."category_templates" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_templates_select_policy" ON "public"."category_templates" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "category_templates_update_policy" ON "public"."category_templates" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text")) WITH CHECK (("auth"."role"() = 'authenticated'::"text"));
ALTER TABLE "public"."competitions" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "competitions_delete_policy" ON "public"."competitions" FOR DELETE USING ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "competitions_insert_policy" ON "public"."competitions" FOR INSERT WITH CHECK ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "competitions_select_policy" ON "public"."competitions" FOR SELECT USING ("public"."has_permission"('competition.read'::"text"));
CREATE POLICY "competitions_update_policy" ON "public"."competitions" FOR UPDATE USING ("public"."has_permission"('competition.write'::"text")) WITH CHECK ("public"."has_permission"('competition.write'::"text"));
ALTER TABLE "public"."email_send_tokens" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."email_template_assets" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."email_template_variables" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."email_templates" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."import_job_rows" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_job_rows_insert_policy" ON "public"."import_job_rows" FOR INSERT WITH CHECK ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "import_job_rows_select_policy" ON "public"."import_job_rows" FOR SELECT USING ("public"."has_permission"('competition.write'::"text"));
ALTER TABLE "public"."import_jobs" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "import_jobs_insert_policy" ON "public"."import_jobs" FOR INSERT WITH CHECK ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "import_jobs_select_policy" ON "public"."import_jobs" FOR SELECT USING ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "import_jobs_update_policy" ON "public"."import_jobs" FOR UPDATE USING ("public"."has_permission"('competition.write'::"text"));
ALTER TABLE "public"."menu_translations" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "menu_translations_delete_policy" ON "public"."menu_translations" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "menu_translations_insert_policy" ON "public"."menu_translations" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "menu_translations_select_policy" ON "public"."menu_translations" FOR SELECT USING (("public"."has_role"('admin'::"text") OR (EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."role_menus" "rm" ON (("rm"."role_id" = "ur"."role_id")))
  WHERE (("ur"."profile_id" = "public"."current_profile_id"()) AND ("rm"."menu_id" = "menu_translations"."menu_id"))))));
CREATE POLICY "menu_translations_update_policy" ON "public"."menu_translations" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER TABLE "public"."menus" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "menus_delete_policy" ON "public"."menus" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "menus_insert_policy" ON "public"."menus" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "menus_select_policy" ON "public"."menus" FOR SELECT USING (("public"."has_role"('admin'::"text") OR (EXISTS ( SELECT 1
   FROM ("public"."user_roles" "ur"
     JOIN "public"."role_menus" "rm" ON (("rm"."role_id" = "ur"."role_id")))
  WHERE (("ur"."profile_id" = "public"."current_profile_id"()) AND ("rm"."menu_id" = "menus"."id"))))));
CREATE POLICY "menus_update_policy" ON "public"."menus" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "permissions_delete_policy" ON "public"."permissions" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "permissions_insert_policy" ON "public"."permissions" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "permissions_select_policy" ON "public"."permissions" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "permissions_update_policy" ON "public"."permissions" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_delete_policy" ON "public"."profiles" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "profiles_insert_policy" ON "public"."profiles" FOR INSERT WITH CHECK (true);
CREATE POLICY "profiles_select_policy" ON "public"."profiles" FOR SELECT USING (("public"."has_role"('admin'::"text") OR ("id" = "public"."current_profile_id"())));
CREATE POLICY "profiles_update_policy" ON "public"."profiles" FOR UPDATE USING (("public"."has_role"('admin'::"text") OR ("id" = "public"."current_profile_id"()))) WITH CHECK (("public"."has_role"('admin'::"text") OR ("id" = "public"."current_profile_id"())));
ALTER TABLE "public"."registrations" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "registrations_delete_policy" ON "public"."registrations" FOR DELETE USING ("public"."has_permission"('competition.write'::"text"));
CREATE POLICY "registrations_insert_policy" ON "public"."registrations" FOR INSERT WITH CHECK (("public"."has_permission"('competition.write'::"text") OR ("auth"."role"() = 'service_role'::"text")));
CREATE POLICY "registrations_select_policy" ON "public"."registrations" FOR SELECT USING (("public"."has_permission"('competition.read'::"text") OR ("profile_id" = "public"."current_profile_id"())));
CREATE POLICY "registrations_update_policy" ON "public"."registrations" FOR UPDATE USING ("public"."has_permission"('competition.write'::"text")) WITH CHECK ("public"."has_permission"('competition.write'::"text"));
ALTER TABLE "public"."role_menus" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "role_menus_delete_policy" ON "public"."role_menus" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "role_menus_insert_policy" ON "public"."role_menus" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "role_menus_select_policy" ON "public"."role_menus" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "role_menus_update_policy" ON "public"."role_menus" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "role_permissions_delete_policy" ON "public"."role_permissions" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "role_permissions_insert_policy" ON "public"."role_permissions" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "role_permissions_select_policy" ON "public"."role_permissions" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "role_permissions_update_policy" ON "public"."role_permissions" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "roles_delete_policy" ON "public"."roles" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "roles_insert_policy" ON "public"."roles" FOR INSERT WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "roles_select_policy" ON "public"."roles" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));
CREATE POLICY "roles_update_policy" ON "public"."roles" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
CREATE POLICY "service full access" ON "public"."import_jobs" TO "service_role" USING (true) WITH CHECK (true);
CREATE POLICY "service full access rows" ON "public"."import_job_rows" TO "service_role" USING (true) WITH CHECK (true);
ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_roles_delete_policy" ON "public"."user_roles" FOR DELETE USING ("public"."has_role"('admin'::"text"));
CREATE POLICY "user_roles_insert_policy" ON "public"."user_roles" FOR INSERT WITH CHECK (("public"."has_role"('admin'::"text") OR ("auth"."role"() = 'service_role'::"text")));
CREATE POLICY "user_roles_select_policy" ON "public"."user_roles" FOR SELECT USING (("public"."has_role"('admin'::"text") OR ("profile_id" = "public"."current_profile_id"())));
CREATE POLICY "user_roles_update_policy" ON "public"."user_roles" FOR UPDATE USING ("public"."has_role"('admin'::"text")) WITH CHECK ("public"."has_role"('admin'::"text"));
ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."ascents";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."boulders";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."categories";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."category_template_items";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."category_templates";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."competitions";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."email_send_tokens";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."email_template_assets";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."email_template_variables";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."email_templates";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."import_job_rows";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."import_jobs";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."menu_translations";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."menus";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."permissions";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."profiles";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."registrations";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."role_menus";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."role_permissions";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."roles";
ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."user_roles";
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT ALL ON FUNCTION "public"."check_email_exists"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_email_exists"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_categories_from_template"("p_competition_id" "uuid", "p_template_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_categories_from_template"("p_competition_id" "uuid", "p_template_id" "uuid") TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_template_assets" TO "anon";
GRANT ALL ON TABLE "public"."email_template_assets" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_template_assets" TO "service_role";
REVOKE ALL ON FUNCTION "public"."create_email_template_asset"("p_template_id" "uuid", "p_filename" "text", "p_mime_type" "text", "p_alt_text" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."create_email_template_asset"("p_template_id" "uuid", "p_filename" "text", "p_mime_type" "text", "p_alt_text" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."duplica_template_category"("p_template_id" "uuid", "p_nuovo_nome_template" "text") TO "authenticated";
REVOKE ALL ON FUNCTION "public"."mark_email_template_asset_ready"("p_asset_id" "uuid", "p_size_bytes" bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."mark_email_template_asset_ready"("p_asset_id" "uuid", "p_size_bytes" bigint) TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_templates" TO "anon";
GRANT ALL ON TABLE "public"."email_templates" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_templates" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."ascents" TO "anon";
GRANT ALL ON TABLE "public"."ascents" TO "authenticated";
GRANT ALL ON TABLE "public"."ascents" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."boulders" TO "anon";
GRANT ALL ON TABLE "public"."boulders" TO "authenticated";
GRANT ALL ON TABLE "public"."boulders" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."categories" TO "anon";
GRANT ALL ON TABLE "public"."categories" TO "authenticated";
GRANT ALL ON TABLE "public"."categories" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."category_template_items" TO "anon";
GRANT ALL ON TABLE "public"."category_template_items" TO "authenticated";
GRANT ALL ON TABLE "public"."category_template_items" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."category_templates" TO "anon";
GRANT ALL ON TABLE "public"."category_templates" TO "authenticated";
GRANT ALL ON TABLE "public"."category_templates" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."competitions" TO "anon";
GRANT ALL ON TABLE "public"."competitions" TO "authenticated";
GRANT ALL ON TABLE "public"."competitions" TO "service_role";
GRANT ALL ON TABLE "public"."email_send_tokens" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_template_variables" TO "anon";
GRANT ALL ON TABLE "public"."email_template_variables" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."email_template_variables" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."import_job_rows" TO "anon";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."import_job_rows" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."import_job_rows" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."import_jobs" TO "anon";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."import_jobs" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."import_jobs" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."menu_translations" TO "anon";
GRANT ALL ON TABLE "public"."menu_translations" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."menu_translations" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."menus" TO "anon";
GRANT ALL ON TABLE "public"."menus" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."menus" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."permissions" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."registrations" TO "anon";
GRANT ALL ON TABLE "public"."registrations" TO "authenticated";
GRANT ALL ON TABLE "public"."registrations" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."role_menus" TO "anon";
GRANT ALL ON TABLE "public"."role_menus" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."role_menus" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."role_permissions" TO "service_role";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."roles" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_finale" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_finale" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_finale" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_finale" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_finale" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_finale" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_qualificazione" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_qualificazione" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_stats_qualificazione" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_qualificazione" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_qualificazione" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_scores_qualificazione" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_top_zone" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_top_zone" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_boulder_top_zone" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_top_zone" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_top_zone" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_ascent_top_zone" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_finale" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_finale" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_finale" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_qualificazione" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_qualificazione" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_qualificazione" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_qualificazione" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_qualificazione" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_qualificazione" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_top_zone" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_top_zone" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_top_zone" TO "service_role";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_top_zone" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_top_zone" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_category_rankings_top_zone" TO "service_role";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_finale" TO "anon";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_finale" TO "authenticated";
GRANT SELECT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."v_registration_rankings_finale" TO "service_role";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLES TO "service_role";