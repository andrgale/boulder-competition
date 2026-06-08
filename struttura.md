.
├── lib
│   ├── config
│   │   └── app_mode.dart
│   ├── core
│   │   ├── config
│   │   │   ├── dev_env.dart
│   │   │   ├── env.dart
│   │   │   └── prod_env.dart
│   │   ├── guards
│   │   │   └── permission_guard.dart
│   │   ├── layout
│   │   │   └── main_layout.dart
│   │   ├── models
│   │   │   ├── app_menu.dart
│   │   │   └── app_user.dart
│   │   ├── routing
│   │   │   ├── app_router.dart
│   │   │   └── route_guard.dart
│   │   ├── services
│   │   │   ├── auth_service.dart
│   │   │   ├── menu_service.dart
│   │   │   ├── permission_service.dart
│   │   │   └── profile_service.dart
│   │   └── ui
│   │       └── responsive.dart
│   ├── features
│   │   ├── administration
│   │   │   └── administration_page.dart
│   │   ├── athlete
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   ├── auth
│   │   │   └── login_page.dart
│   │   ├── boulders
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   ├── categories
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   ├── competitions
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   ├── dashboard
│   │   │   └── dashboard_page.dart
│   │   ├── errors
│   │   │   └── forbidden_page.dart
│   │   ├── home
│   │   │   └── home_page.dart
│   │   ├── import_jobs
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   ├── rankings
│   │   │   └── rankings_page.dart
│   │   ├── registrations
│   │   │   ├── data
│   │   │   ├── models
│   │   │   └── pages
│   │   └── splash
│   │       └── splash_page.dart
│   ├── shared
│   │   ├── dialogs
│   │   │   └── app_confirm_dialog.dart
│   │   ├── widgets
│   │   │   ├── app_breadcrumb.dart
│   │   │   ├── app_drawer.dart
│   │   │   ├── app_shell.dart
│   │   │   └── base_page.dart
│   │   ├── app_snackbar.dart
│   │   └── services
│   ├── main.dart
│   ├── main_dev.dart
│   └── main_prod.dart
├── linux
│   ├── flutter
│   │   ├── ephemeral
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── runner
│   │   ├── CMakeLists.txt
│   │   ├── main.cc
│   │   ├── my_application.cc
│   │   └── my_application.h
│   └── CMakeLists.txt
├── macos
│   ├── Flutter
│   │   ├── ephemeral
│   │   │   ├── Packages
│   │   │   ├── Flutter-Generated.xcconfig
│   │   │   ├── FlutterInputs.xcfilelist
│   │   │   ├── FlutterMacOS.podspec
│   │   │   ├── FlutterOutputs.xcfilelist
│   │   │   ├── flutter_export_environment.sh
│   │   │   ├── flutter_native_integration.env
│   │   │   └── tripwire
│   │   ├── Flutter-Debug.xcconfig
│   │   ├── Flutter-Release.xcconfig
│   │   └── GeneratedPluginRegistrant.swift
│   ├── Pods
│   │   ├── Headers
│   │   ├── Local Podspecs
│   │   │   └── FlutterMacOS.podspec.json
│   │   ├── Pods.xcodeproj
│   │   │   ├── xcuserdata
│   │   │   └── project.pbxproj
│   │   ├── Target Support Files
│   │   │   ├── FlutterMacOS
│   │   │   ├── Pods-Runner
│   │   │   └── Pods-RunnerTests
│   │   └── Manifest.lock
│   ├── Runner
│   │   ├── Assets.xcassets
│   │   │   └── AppIcon.appiconset
│   │   ├── Base.lproj
│   │   │   └── MainMenu.xib
│   │   ├── Configs
│   │   │   ├── AppInfo.xcconfig
│   │   │   ├── Debug.xcconfig
│   │   │   ├── Release.xcconfig
│   │   │   └── Warnings.xcconfig
│   │   ├── AppDelegate.swift
│   │   ├── DebugProfile.entitlements
│   │   ├── Info.plist
│   │   ├── MainFlutterWindow.swift
│   │   └── Release.entitlements
│   ├── Runner.xcodeproj
│   │   ├── project.xcworkspace
│   │   │   ├── xcshareddata
│   │   │   └── xcuserdata
│   │   ├── xcshareddata
│   │   │   └── xcschemes
│   │   ├── xcuserdata
│   │   │   └── gale.xcuserdatad
│   │   └── project.pbxproj
│   ├── Runner.xcworkspace
│   │   ├── xcshareddata
│   │   │   ├── swiftpm
│   │   │   └── IDEWorkspaceChecks.plist
│   │   ├── xcuserdata
│   │   │   └── gale.xcuserdatad
│   │   └── contents.xcworkspacedata
│   ├── RunnerTests
│   │   └── RunnerTests.swift
│   ├── Podfile
│   └── Podfile.lock
├── supabase
│   ├── functions
│   │   ├── create-athlete-user
│   │   │   ├── deno.json
│   │   │   └── index.ts
│   │   └── import_competition_csv
│   │       ├── config.toml
│   │       ├── deno.json
│   │       └── index.ts
│   ├── snippets
│   └── config.toml
├── test
│   └── widget_test.dart
├── web
│   ├── icons
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── favicon.png
│   ├── index.html
│   └── manifest.json
├── windows
│   ├── flutter
│   │   ├── ephemeral
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── runner
│   │   ├── resources
│   │   │   └── app_icon.ico
│   │   ├── CMakeLists.txt
│   │   ├── Runner.rc
│   │   ├── flutter_window.cpp
│   │   ├── flutter_window.h
│   │   ├── main.cpp
│   │   ├── resource.h
│   │   ├── runner.exe.manifest
│   │   ├── utils.cpp
│   │   ├── utils.h
│   │   ├── win32_window.cpp
│   │   └── win32_window.h
│   └── CMakeLists.txt
├── Abilitazioni_Home_Page.txt
├── Installazione_Flutter.txt
├── README.md
├── SupaBase_db.sql
├── SupaBase_db.txt
├── analysis_options.yaml
├── boulder_competition.iml
├── devtools_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── struttura.md
├── struttura.txt
└── test_import.cvs

95 directories, 114 files
