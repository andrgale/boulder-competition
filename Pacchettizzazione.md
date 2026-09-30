Guida alla build degli eseguibili

#### ok MacOs ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
1 — macOS (.app + .dmg)
Build dell'app

`bash
fvm flutter build macos \
  --release \
  -t lib/main.dart


L'output è in:
`
build/macos/Build/Products/Release/boulder_competition.app
`

Creare il .dmg (distribuibile)

macOS non include un tool nativo per i dmg — usa create-dmg (installabile con Homebrew):

`bash
brew install create-dmg
`

`bash
sips -z 400 600 background.png --out background_600x400.png

create-dmg \
  --volname "Boulder Admin" \
  --window-size 600 400 \
  --icon-size 110 \
  --text-size 12 \
  --app-drop-link 450 200 \
  --icon "boulder_competition.app" 150 200 \
  --hide-extension "boulder_competition.app" \
  --background "./background_600x400.png" \
  "BoulderAdmin-1.0.5.dmg" \
  "build/macos/Build/Products/Release/boulder_competition.app"

 ## build Mac Console Clienti

`bash
fvm flutter build macos \
  --release \
  -t lib/main_client.dart


L'output è in:
`
build/macos/Build/Products/Release/boulder_competition.app (va rinominata in Console_clienti.app)
`


 create-dmg \
  --volname "Console Clienti" \
  --window-size 600 400 \
  --icon-size 110 \
  --text-size 12 \
  --app-drop-link 450 200 \
  --icon "Console_clienti.app" 150 200 \
  --hide-extension "Console_clienti.app" \
  --background "./background_600x400.png" \
  "ConsoleClienti-1.0.0.dmg" \
  "build/macos/Build/Products/Release/console_clienti.app"

### Ok Windows ############

brew install gh
gh auth login
gh workflow run build-windows.yml

### comando per creare la build windows della console clienti
gh workflow run build-windows-clienti.yml

### comando per trigger e impedire la inattivazione del DB Clienti
gh workflow run supabase-keep-alive.yml
### comando per trigger e impedire la inattivazione del DB di sviluppo di Boulder Competition
gh workflow run supabase-prod-keep-alive.yml
### comando per trigger e impedire la inattivazione del DB di produzione di Boulder Competition
gh workflow run supabase-svil-keep-alive.yml

gh run view 28184095736

su browser al link dato da gh
Actions → build → Artifacts

token GitHub Action:
export GITHUB_TOKEN=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

comando per lanciare github action e creare l'eseguibile windows:
Cmd + Shift + B

### Ok Android ##############

fvm flutter build apk \
  --release \
  -t lib/main_smartphone.dart \
  --split-per-abi

✓ Built build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (27.1MB)
✓ Built build/app/outputs/flutter-apk/boulder_competition.apk (30.7MB)
✓ Built build/app/outputs/flutter-apk/app-x86_64-release.apk (33.2MB)

adb install -r build/app/outputs/flutter-apk/boulder_competition.apk

####  Ok IOS (ipa)
iOS (.ipa)
Prerequisiti
• Mac con Xcode installato
• Apple Developer account (99$/anno) — obbligatorio per distribuire su dispositivi reali al di fuori del tuo
• Profilo di provisioning configurato in Xcode

Build

`bash
fvm flutter build ipa \
  --release \
  -t lib/main_smartphone.dart
`

Output:
`
build/ios/ipa/bouldercompetition.ipa
`

### Distribuzione

| Canale                         | Come                                                                                      |
|--------------------------------|-------------------------------------------------------------------------------------------|
| TestFlight (beta tester)       | Carica l'.ipa su App Store Connect → sezione TestFlight                                   |
| App Store                      | Carica su App Store Connect → sottometti per review                                       |
| Ad-hoc (dispositivi specifici) | Aggiungi UDID dei device al profilo di provisioning, poi distribuisci l'.ipa direttamente |
| Enterprise                     | Richiede Apple Developer Enterprise Program (299$/anno)                                   |

Per caricare su App Store Connect usa Transporter (app gratuita sul Mac App Store) o xcrun altool.

### Non avendo un account di sviluppatore Apple a pagamento non crea l'ipa, posso solo installarlo sul mio Iphone con questo comando:
fvm flutter run \
  --release \
  -t lib/main_smartphone.dart

### Build AAB (Google Play Store)

`bash
fvm flutter build appbundle \
  --release \
  -t lib/main_smartphone.dart
`

Output:
`
build/app/outputs/bundle/release/app-release.aab
`

L'.aab è il formato richiesto da Google Play — non è installabile direttamente ma Play Store lo ottimizza per ogni dispositivo.

Firma dell'APK/AAB (obbligatoria per Play Store)
Genera un keystore una sola volta e conservalo al sicuro:

`bash
keytool -genkey -v \
  -keystore boulder-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias boulder
`

Crea android/key.properties:

`properties
storePassword=TUAPASSWORD
keyPassword=TUAPASSWORD
keyAlias=boulder
storeFile=/percorso/assoluto/boulder-release.jks
`

Modifica android/app/build.gradle aggiungendo prima di android {}:

`gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
`

E nella sezione android > buildTypes > release:

`gradle
signingConfig signingConfigs.release
`

Con la sezione signingConfigs:

`gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
`

> Importante: aggiungi android/key.properties e .jks al tuo .gitignore — non caricarli mai su Git.

Riepilogo comandi di build

| Target            | Comando                                                                       | Output                                    |
|-------------------|-------------------------------------------------------------------------------|-------------------------------------------|
| macOS app         | fvm flutter build macos --release -t lib/main.dart                 | .app in build/macos/...                   |
| macOS dmg         | create-dmg ... (post-build)                                                   | .dmg                                      |
| Windows exe       | fvm flutter build windows --release -t lib/main.dart               | cartella in build/windows/...             |
| Windows installer | Inno Setup (post-build)                                                       | .exe installer                            |
| iOS ipa           | fvm flutter build ipa --release -t lib/main_smartphone.dart                 | .ipa in build/ios/ipa/                    |
| Android apk       | fvm flutter build apk --release --split-per-abi -t lib/main_smartphone.dart | .apk in build/app/outputs/flutter-apk/    |
| Android aab       | fvm flutter build appbundle --release -t lib/main_smartphone.dart           | .aab in build/app/outputs/bundle/release/ |

Due cose da fare prima di qualsiasi build
Versiona correttamente in pubspec.yaml — il campo version diventa il numero di versione dell'app:
   `yaml
   version: 1.0.0+1  # formato: nomeversione+buildnumber
   `


*** creazione profilo su xcode ***********

1. Verifica di avere un Apple Developer Account

Devi avere:

Un Apple ID
Un abbonamento a Apple Developer Program (99€/anno)

Se non hai l'abbonamento puoi comunque fare test limitati sul tuo iPhone usando il tuo Apple ID personale.

2. Apri il progetto in Xcode

Dal terminale:
cd ios
open Runner.xcworkspace

3. Configura il Team

In Xcode:

Runner

→ Targets
→ Runner
→ Signing & Capabilities

Troverai:
Team
Bundle Identifier
Automatically manage signing
Imposta:
Automatically manage signing = ON

e seleziona il tuo Team:

Nome Cognome (Personal Team)

oppure

La tua azienda
4. Verifica il Bundle Identifier

Deve essere univoco.

Esempio:

com.tuaazienda.bouldercompetition

oppure

it.gale.bouldercompetition

Se usi:

com.example.boulderCompetition

potresti avere conflitti.

5. Collega l'iPhone

Collega il dispositivo via USB.

Poi:

Xcode
→ Window
→ Devices and Simulators

Verifica che il dispositivo venga riconosciuto.

6. Generazione automatica del profilo

Se hai selezionato:

Automatically manage signing

Xcode crea automaticamente:

Certificate
App ID
Provisioning Profile

Non devi fare nulla manualmente.

Dovresti vedere:

Provisioning Profile: iOS Team Provisioning Profile
Signing Certificate: Apple Development
7. Se compare un errore di firma

Premi:

Try Again

oppure:

Fix Issue

Xcode tenterà di creare tutto automaticamente.

8. Verifica dal portale Apple

Vai su:

Apple Developer Certificates, IDs & Profiles

e controlla:

Identifiers
com.tuaazienda.bouldercompetition
Profiles

Dovresti trovare qualcosa tipo:

iOS Team Provisioning Profile:
com.tuaazienda.bouldercompetition

9. Per distribuire su TestFlight

Quando arriverai a quel punto:

flutter build ipa

oppure:

Xcode
Product
Archive

e il provisioning passerà automaticamente dal profilo di sviluppo a quello di distribuzione.



Configurare il Provisioning Profile in Xcode per Flutter/iOS
Prerequisiti iniziali

Prima di toccare Xcode devi avere:

• Apple ID gratuito — sufficiente per testare su dispositivo personale
• Apple Developer Account (99$/anno) — obbligatorio per distribuire via TestFlight o App Store
• iPhone/iPad fisico collegato al Mac via USB, oppure un simulatore per i test iniziali

STEP 1 — Accedi al tuo Apple Developer Account in Xcode
Apri Xcode
Vai su Xcode → Settings (o ⌘,)
Clicca sulla tab Accounts
Clicca + in basso a sinistra → Add Apple ID
Inserisci le credenziali del tuo Apple ID

Dopo il login vedrai il tuo account con i team associati.

STEP 2 — Apri il progetto iOS in Xcode

Dalla root del tuo progetto Flutter:

``bash
open ios/Runner.xcworkspace
`

> ⚠️ Apri sempre il file .xcworkspace, mai il .xcodeproj — quello non include le dipendenze CocoaPods.

STEP 3 — Configura il Bundle Identifier

Nel navigator a sinistra clicca su Runner (la cartella blu in cima) → seleziona il target Runner → tab Signing & Capabilities.

Qui trovi il campo Bundle Identifier — deve essere unico a livello mondiale, di solito in formato reverse-domain:

`
com.tuaazienda.boulderathlete
`

Cambialo con qualcosa di tuo. Questo valore deve corrispondere esattamente a quello registrato sul portale Apple Developer.

STEP 4 — Firma automatica (il modo più semplice)

Nella stessa schermata Signing & Capabilities:

Spunta Automatically manage signing
Nel dropdown Team seleziona il tuo account Apple

Xcode farà tutto da solo:
• Crea l'App ID sul portale Apple
• Genera il certificato di sviluppo (Development Certificate)
• Crea il Provisioning Profile e lo scarica
• Registra il dispositivo collegato

Se vedi una spunta verde con scritto "Xcode Managed Profile" hai finito per lo sviluppo.

STEP 5 — Registrare il dispositivo fisico

Se hai un iPhone collegato e vuoi eseguire l'app direttamente:

Collega l'iPhone via USB
Sul telefono apparirà il popup "Vuoi fidarti di questo computer?" → tocca Fidati
In Xcode, in alto a sinistra nel selettore del dispositivo, seleziona il tuo iPhone
Con la firma automatica attiva, Xcode registra automaticamente il dispositivo nel tuo account

Con account gratuito puoi avere al massimo 3 app e 1 settimana di validità del profilo (devi rifare il build ogni 7 giorni). Con account a pagamento la validità è 1 anno.

STEP 6 — Build e run su dispositivo da terminale

Dopo aver configurato Xcode, torna al terminale e usa il tuo comando abituale:

`bash
fvm flutter run -d EAA2CF92-0397-4E19-8BA0-BBCF27948E6B -t lib/maindev.dart
`

Oppure per la build di release:

`bash
fvm flutter build ipa --release -t lib/maindev.dart
`

STEP 7 — Configurazione manuale (quando serve)

La firma automatica va bene per sviluppo. Per distribuzione App Store o Enterprise può servire la configurazione manuale. In quel caso:

Sul portale Apple Developer (developer.apple.com)

Il flusso è questo:

`
Certificates → App IDs → Devices → Profiles
`

a) Crea un certificato di distribuzione
• Vai su Certificates → +
• Scegli Apple Distribution (per App Store) o iOS App Development
• Segui la procedura: genera un CSR dal Keychain Access del Mac → caricalo → scarica il certificato → doppio click per installarlo nel Keychain

b) Registra l'App ID
• Vai su Identifiers → +
• Tipo: App IDs → App
• Bundle ID: inserisci lo stesso di Xcode (com.tuaazienda.boulderathlete)
• Spunta le capability che usi (Push Notifications, ecc.)

c) Registra i dispositivi (solo per distribuzione Ad-hoc)
• Vai su Devices → +
• Inserisci il nome del dispositivo e l'UDID

Per trovare l'UDID del telefono:
`bash
con il telefono collegato
flutter devices
oppure
ideviceid -l
`

d) Crea il Provisioning Profile
• Vai su Profiles → +
• Scegli il tipo:

| Tipo                | Quando usarlo                                  |
|---------------------|------------------------------------------------|
| iOS App Development | Test su dispositivi registrati                 |
| Ad Hoc              | Distribuzione a un gruppo fisso di dispositivi |
| App Store Connect   | Distribuzione tramite TestFlight e App Store   |

• Associa: il certificato creato al punto a), l'App ID, i dispositivi
• Scarica il file .mobileprovision
• Doppio click sul file → si installa automaticamente in Xcode

e) Imposta il profilo manuale in Xcode

Torna in Xcode → Signing & Capabilities:
Deseleziona Automatically manage signing
In Provisioning Profile seleziona quello appena importato dal menu dropdown

Situazione del tuo progetto specifico

Hai due app distinte che condividono lo stesso codebase (maindev.dart per Athlete, mainprod.dart per Admin). Per iOS devi configurare due Bundle Identifier separati se vuoi che coesistano sul dispositivo:

`
com.tuaazienda.boulderadmin    ← per main.dart
com.tuaazienda.boulderathlete  ← per main_smartphone.dart
`

Per cambiare il Bundle ID in base al flavor puoi usare gli Xcode Schemes — ma per iniziare è più semplice tenere due configurazioni separate in ios/Runner.xcworkspace e switchare manualmente prima della build.

Cosa fare nell'ordine pratico

`
Apri ios/Runner.xcworkspace in Xcode
Imposta Bundle Identifier univoco
Seleziona il tuo Team (Apple ID)
Spunta "Automatically manage signing"
Collega iPhone → Fidati del computer
Premi ▶ o usa fvm flutter run
``

Se Xcode mostra errori di firma i più comuni sono:

| Errore                                            | Soluzione                                                              |
|---------------------------------------------------|------------------------------------------------------------------------|
| "No accounts with App Store Connect access"       | Hai solo Apple ID gratuito, non Developer Account a pagamento          |
| "Failed to register bundle ID"                    | Bundle ID già usato da un'altra app nel tuo account — cambialo         |
| "Device not registered"                           | Con firma manuale devi registrare il dispositivo sul portale Developer |
| "Provisioning profile doesn't include the device" | Rigenera il profilo includendo il nuovo dispositivo                    |


