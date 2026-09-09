-- GENERATED SEED FILE

-- ROLES

insert into public.roles (code, name)
                 values ('admin', 'Amministratore')
                 on conflict (code)
                 do update
                 set name = excluded.name;

insert into public.roles (code, name)
                 values ('athlete', 'Atleta')
                 on conflict (code)
                 do update
                 set name = excluded.name;

insert into public.roles (code, name)
                 values ('email_template_admin', 'Gestore email')
                 on conflict (code)
                 do update
                 set name = excluded.name;

insert into public.roles (code, name)
                 values ('judge', 'Giudice')
                 on conflict (code)
                 do update
                 set name = excluded.name;

-- PERMISSIONS

insert into public.permissions (permission_code, activity)
                 values ('admin.panel', 'Accesso pannello amministrazione')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('ascent.read', 'Visualizzazione realizzazioni')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('ascent.write', 'Inserimento realizzazioni')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('boulder.read', 'Visualizzazione boulder')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('boulder.write', 'Gestione boulder')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('category.read', 'Visualizzazione categorie')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('category.write', 'Gestione categorie')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('checkin.read', 'Lettura ed esecuzione check-in')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('competition.read', 'Visualizzazione gare')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('competition.write', 'Gestione gare')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('final.read', 'Classifica finale')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('import.read', 'Visualizzazione importazioni CSV')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('menu.read', 'Visualizzazione menu')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('qualifications.read', 'Visualizzazione classifica qualificazioni')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('ranking.read', 'Visualizzazione classifiche')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('registration.read', 'Visualizzazione iscritti')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('registration.write', 'Gestione iscritti')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('security.admin', 'Gestione Profilazione e Menù')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

insert into public.permissions (permission_code, activity)
                 values ('top.read', 'Visualizzazione classifica top e zone')
                 on conflict (permission_code)
                 do update
                 set activity = excluded.activity;

-- MENUS

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
                    'Dashboard',
                    '/dashboard',
                    'dashboard',
                    1,
                    null,
                    't',
                    'f',
                    't'
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
                    'Iscrizione Gara',
                    '/athlete-competition-registration',
                    'app_registration',
                    10,
                    null,
                    't',
                    't',
                    'f'
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
                    'Gare',
                    '/competitions',
                    'emoji_events',
                    10,
                    null,
                    't',
                    'f',
                    't'
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
                    'Check-in Gara',
                    '/athlete-checkin',
                    'qr_code_scanner',
                    20,
                    null,
                    't',
                    't',
                    'f'
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
                    'Registrazione Boulder',
                    '/athlete-boulders',
                    'terrain',
                    30,
                    null,
                    't',
                    't',
                    'f'
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
                    'Check-in gara',
                    '/check-in',
                    'sports_score',
                    55,
                    null,
                    't',
                    'f',
                    't'
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
                    'Classifiche',
                    '/rankings',
                    'leaderboard',
                    60,
                    null,
                    't',
                    'f',
                    't'
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
                    'Amministrazione',
                    '/security',
                    'admin_panel_settings',
                    100,
                    null,
                    't',
                    'f',
                    't'
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
                    'Importazioni CSV',
                    '/import-jobs',
                    'upload_file',
                    110,
                    null,
                    't',
                    'f',
                    't'
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
                    'Disconetti',
                    '/login',
                    'person',
                    120,
                    null,
                    't',
                    'f',
                    't'
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

-- MENU_TRANSLATIONS

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-boulders'
                    ),
                    'en',
                    'Boulder registration'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-boulders'
                    ),
                    'it',
                    'Registrazione boulder'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-checkin'
                    ),
                    'en',
                    'Check-in race'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-checkin'
                    ),
                    'it',
                    'Check-in gara'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-competition-registration'
                    ),
                    'en',
                    'Registration Competition'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/athlete-competition-registration'
                    ),
                    'it',
                    'Iscrizione gara'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/check-in'
                    ),
                    'en',
                    'Check-in race'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/check-in'
                    ),
                    'it',
                    'Check-in gara'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/competitions'
                    ),
                    'en',
                    'Races'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/competitions'
                    ),
                    'it',
                    'Gare'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/dashboard'
                    ),
                    'en',
                    'Dashboard'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/dashboard'
                    ),
                    'it',
                    'Dashboard'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/import-jobs'
                    ),
                    'en',
                    'Import CSV'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/import-jobs'
                    ),
                    'it',
                    'Importazioni CSV'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/login'
                    ),
                    'en',
                    'Disconect'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/login'
                    ),
                    'it',
                    'Disconetti'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/rankings'
                    ),
                    'en',
                    'Rankings'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/rankings'
                    ),
                    'it',
                    'Classifiche'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/security'
                    ),
                    'en',
                    'Administration'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

insert into public.menu_translations (
                    menu_id,
                    locale,
                    label
                )
                values (
                    (
                        select id
                        from public.menus
                        where route = '/security'
                    ),
                    'it',
                    'Amministrazione'
                )
                on conflict (menu_id, locale)
                do update
                set label = excluded.label;

-- ROLE_PERMISSIONS

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'admin.panel'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'boulder.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'boulder.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'category.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'category.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'checkin.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'competition.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'competition.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'final.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'import.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'menu.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'qualifications.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ranking.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'registration.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'registration.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'security.admin'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'top.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'boulder.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'category.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'competition.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'menu.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ranking.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'email_template_admin'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'security.admin'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ascent.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'boulder.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'boulder.write'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'category.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'competition.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'final.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'menu.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'qualifications.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'ranking.read'
                    )
                )
                on conflict do nothing;

insert into public.role_permissions (
                    role_id,
                    permission_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.permissions
                        where permission_code = 'registration.read'
                    )
                )
                on conflict do nothing;

-- ROLE_MENUS

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/check-in'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/competitions'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/dashboard'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/import-jobs'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/login'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/rankings'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'admin'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/security'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/athlete-boulders'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/athlete-checkin'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'athlete'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/athlete-competition-registration'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/competitions'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/dashboard'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/login'
                    )
                )
                on conflict do nothing;

insert into public.role_menus (
                    role_id,
                    menu_id
                )
                values (
                    (
                        select id
                        from public.roles
                        where code = 'judge'
                    ),
                    (
                        select id
                        from public.menus
                        where route = '/rankings'
                    )
                )
                on conflict do nothing;
