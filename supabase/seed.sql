INSERT INTO
    "public"."roles" ("id", "code", "name", "created_at")
VALUES
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'judge',
        'Giudice',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        'athlete',
        'Atleta',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'admin',
        'Amministratore',
        '2026-05-26 16:36:16.727516+00'
    );

INSERT INTO
    "public"."menus" (
        "id",
        "label",
        "route",
        "icon",
        "display_order",
        "parent_id",
        "visible",
        "mobile",
        "desktop",
        "created_at"
    )
VALUES
    (
        '0c6109d1-68c4-4f59-aa97-ca04de2b742b',
        'Disconetti',
        '/login',
        'person',
        120,
        null,
        true,
        true,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '17cae514-7e3a-42b1-ad73-130b62325fe5',
        'Classifiche',
        '/rankings',
        'leaderboard',
        60,
        null,
        true,
        true,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '1e071289-4a39-4e85-9abd-30ac7e444872',
        'Check-in gara',
        '/check-in',
        'sports_score',
        55,
        null,
        true,
        true,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '39bd7815-b8c8-44f8-84ec-2c4ff7589ee5',
        'Dashboard',
        '/dashboard',
        'dashboard',
        1,
        null,
        true,
        true,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '40ec7f7a-9477-40ad-a02f-16eb2827d8f4',
        'Amministrazione',
        '/security',
        'admin_panel_settings',
        100,
        null,
        true,
        false,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'cc35f280-114c-4c19-bc25-6d85a003b35b',
        'Gare',
        '/competitions',
        'emoji_events',
        10,
        null,
        true,
        false,
        true,
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'dedd0db6-ba30-46f6-9ac2-09f278e3eec2',
        'Importazioni CSV',
        '/import-jobs',
        'upload_file',
        110,
        null,
        true,
        false,
        true,
        '2026-06-01 16:46:32.47698+00'
    );

INSERT INTO
    "public"."role_menus" ("role_id", "menu_id", "created_at")
VALUES
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '0c6109d1-68c4-4f59-aa97-ca04de2b742b',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '17cae514-7e3a-42b1-ad73-130b62325fe5',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '1e071289-4a39-4e85-9abd-30ac7e444872',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '39bd7815-b8c8-44f8-84ec-2c4ff7589ee5',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'cc35f280-114c-4c19-bc25-6d85a003b35b',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '17cae514-7e3a-42b1-ad73-130b62325fe5',
        '2026-06-10 16:54:02.871809+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '1e071289-4a39-4e85-9abd-30ac7e444872',
        '2026-06-10 16:54:02.871809+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '0c6109d1-68c4-4f59-aa97-ca04de2b742b',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '17cae514-7e3a-42b1-ad73-130b62325fe5',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '1e071289-4a39-4e85-9abd-30ac7e444872',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '39bd7815-b8c8-44f8-84ec-2c4ff7589ee5',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '40ec7f7a-9477-40ad-a02f-16eb2827d8f4',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'cc35f280-114c-4c19-bc25-6d85a003b35b',
        '2026-05-16 16:05:51.604887+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'dedd0db6-ba30-46f6-9ac2-09f278e3eec2',
        '2026-06-01 17:06:50.929605+00'
    );

INSERT INTO
    "public"."permissions" (
        "id",
        "permission_code",
        "activity",
        "created_at"
    )
VALUES
    (
        '05e25d09-59f2-4554-ac25-f1f02847c8a1',
        'qualifications.read',
        'Visualizzazione classifica qualificazioni',
        '2026-06-24 14:42:16.522441+00'
    ),
    (
        '0c202471-97da-49b5-a55c-7824e2b6e6e2',
        'boulder.write',
        'Gestione boulder',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '1f90168d-49c6-4391-a161-7945a1350119',
        'top.read',
        'Visualizzazione classifica top e zone',
        '2026-06-24 14:43:27.390045+00'
    ),
    (
        '3b7f09e3-0d6b-49fd-9bb8-68942e20c4bb',
        'menu.read',
        'Visualizzazione menu',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '583ef9ce-2399-4295-863a-3e56cfa29337',
        'ascent.write',
        'Inserimento realizzazioni',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '61338807-98bd-4564-a991-10b48ea43eea',
        'ascent.read',
        'Visualizzazione realizzazioni',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '794b9105-21cc-4f1b-ac03-ce9da4f50e5d',
        'boulder.read',
        'Visualizzazione boulder',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '80139f8a-2251-4f4c-9c61-6e139b9c0414',
        'admin.panel',
        'Accesso pannello amministrazione',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        '9102e285-a989-4f45-b824-ea6e5ae27925',
        'category.read',
        'Visualizzazione categorie',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        'a0199f70-5307-4e45-bcd7-37b58f51eb43',
        'competition.read',
        'Visualizzazione gare',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'a7b32b75-04bf-4814-9070-8f60d2baf4bb',
        'category.write',
        'Gestione categorie',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        'b2a708de-cb35-463a-a6e9-36fcdf51bb31',
        'registration.read',
        'Visualizzazione iscritti',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'c15661c9-34bc-4622-8ab0-1433ca2e72ab',
        'import.read',
        'Visualizzazione importazioni CSV',
        '2026-06-01 16:48:16.344633+00'
    ),
    (
        'c301ada4-b57f-46ea-9a2b-871bcc5e56f0',
        'registration.write',
        'Gestione iscritti',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'c5eb10d4-f128-4324-abcb-30b63bab5fa9',
        'security.admin',
        'Gestione Profilazione e Menù',
        '2026-06-10 16:26:43.395559+00'
    ),
    (
        'cee6bede-032b-49f1-9100-af1c62846dc8',
        'ranking.read',
        'Visualizzazione classifiche',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'd8cb06a8-d57b-4cb3-8d92-9b14de50cccc',
        'checkin.read',
        'Visualizzazione ed esecuzione check-in',
        '2026-06-24 14:39:32.63983+00'
    ),
    (
        'dcdd3f0f-ed17-4d4a-9814-f5db5e97d473',
        'competition.write',
        'Gestione gare',
        '2026-05-26 16:36:16.727516+00'
    ),
    (
        'df36e8b8-6296-429b-85d2-db4659e96c2f',
        'final.read',
        'Visualizzazione classifica finale',
        '2026-06-24 14:42:49.773023+00'
    );
INSERT INTO
    "public"."role_permissions" ("role_id", "permission_id", "created_at")
VALUES
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '0c202471-97da-49b5-a55c-7824e2b6e6e2',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '3b7f09e3-0d6b-49fd-9bb8-68942e20c4bb',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '583ef9ce-2399-4295-863a-3e56cfa29337',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '61338807-98bd-4564-a991-10b48ea43eea',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '794b9105-21cc-4f1b-ac03-ce9da4f50e5d',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        '9102e285-a989-4f45-b824-ea6e5ae27925',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'a0199f70-5307-4e45-bcd7-37b58f51eb43',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'b2a708de-cb35-463a-a6e9-36fcdf51bb31',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'c301ada4-b57f-46ea-9a2b-871bcc5e56f0',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '62940578-1014-470c-ac5c-c146e02c839d',
        'cee6bede-032b-49f1-9100-af1c62846dc8',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '3b7f09e3-0d6b-49fd-9bb8-68942e20c4bb',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '583ef9ce-2399-4295-863a-3e56cfa29337',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '61338807-98bd-4564-a991-10b48ea43eea',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '794b9105-21cc-4f1b-ac03-ce9da4f50e5d',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        '9102e285-a989-4f45-b824-ea6e5ae27925',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        'a0199f70-5307-4e45-bcd7-37b58f51eb43',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        '72f0ec8f-13eb-4b06-a95d-13015609841e',
        'cee6bede-032b-49f1-9100-af1c62846dc8',
        '2026-06-12 15:35:43.924323+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '05e25d09-59f2-4554-ac25-f1f02847c8a1',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '0c202471-97da-49b5-a55c-7824e2b6e6e2',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '1f90168d-49c6-4391-a161-7945a1350119',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '3b7f09e3-0d6b-49fd-9bb8-68942e20c4bb',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '583ef9ce-2399-4295-863a-3e56cfa29337',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '61338807-98bd-4564-a991-10b48ea43eea',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '794b9105-21cc-4f1b-ac03-ce9da4f50e5d',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '80139f8a-2251-4f4c-9c61-6e139b9c0414',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        '9102e285-a989-4f45-b824-ea6e5ae27925',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'a0199f70-5307-4e45-bcd7-37b58f51eb43',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'a7b32b75-04bf-4814-9070-8f60d2baf4bb',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'b2a708de-cb35-463a-a6e9-36fcdf51bb31',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'c15661c9-34bc-4622-8ab0-1433ca2e72ab',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'c301ada4-b57f-46ea-9a2b-871bcc5e56f0',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'c5eb10d4-f128-4324-abcb-30b63bab5fa9',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'cee6bede-032b-49f1-9100-af1c62846dc8',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'd8cb06a8-d57b-4cb3-8d92-9b14de50cccc',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'dcdd3f0f-ed17-4d4a-9814-f5db5e97d473',
        '2026-06-24 14:43:56.686752+00'
    ),
    (
        'e9b177fa-6e51-476f-8d0c-0c601ef7dd40',
        'df36e8b8-6296-429b-85d2-db4659e96c2f',
        '2026-06-24 14:43:56.686752+00'
    );
