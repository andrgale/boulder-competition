import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Message shown when competition is closed
  ///
  /// In en, this message translates to:
  /// **'Competition closed or athlete without check-in'**
  String get competitionClosed;

  /// OK
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  ///  Ok
  ///
  /// In en, this message translates to:
  /// **'common Ok'**
  String get commonOk;

  ///  Cancel
  ///
  /// In en, this message translates to:
  /// **'common Cancel'**
  String get commonCancel;

  ///  Save
  ///
  /// In en, this message translates to:
  /// **'common Save'**
  String get commonSave;

  ///  Delete
  ///
  /// In en, this message translates to:
  /// **'common Delete'**
  String get commonDelete;

  ///  Close
  ///
  /// In en, this message translates to:
  /// **'common Close'**
  String get commonClose;

  ///  Back
  ///
  /// In en, this message translates to:
  /// **'common Back'**
  String get commonBack;

  ///  Yes
  ///
  /// In en, this message translates to:
  /// **'common Yes'**
  String get commonYes;

  ///  No
  ///
  /// In en, this message translates to:
  /// **'common No'**
  String get commonNo;

  ///  Search
  ///
  /// In en, this message translates to:
  /// **'common Search'**
  String get commonSearch;

  ///  Refresh
  ///
  /// In en, this message translates to:
  /// **'common Refresh'**
  String get commonRefresh;

  /// Title
  ///
  /// In en, this message translates to:
  /// **'login Title'**
  String get loginTitle;

  /// Email
  ///
  /// In en, this message translates to:
  /// **'login Email'**
  String get loginEmail;

  /// Password
  ///
  /// In en, this message translates to:
  /// **'login Password'**
  String get loginPassword;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'login Button'**
  String get loginButton;

  /// ForgotPassword
  ///
  /// In en, this message translates to:
  /// **'login ForgotPassword'**
  String get loginForgotPassword;

  /// competition - Title
  ///
  /// In en, this message translates to:
  /// **'competition Title'**
  String get competitionTitle;

  /// competition - Description
  ///
  /// In en, this message translates to:
  /// **'competition Description'**
  String get competitionDescription;

  /// competition - Date
  ///
  /// In en, this message translates to:
  /// **'competition Date'**
  String get competitionDate;

  /// competition - Location
  ///
  /// In en, this message translates to:
  /// **'competition Location'**
  String get competitionLocation;

  /// competition - ButtonCreate
  ///
  /// In en, this message translates to:
  /// **'competition ButtonCreate'**
  String get competitionButtonCreate;

  /// competition - ButtonSave
  ///
  /// In en, this message translates to:
  /// **'competition ButtonSave'**
  String get competitionButtonSave;

  /// competition - MessageClosed
  ///
  /// In en, this message translates to:
  /// **'competition MessageClosed'**
  String get competitionMessageClosed;

  /// competition - LabelName
  ///
  /// In en, this message translates to:
  /// **'competition LabelName'**
  String get competitionLabelName;

  /// category - Title
  ///
  /// In en, this message translates to:
  /// **'category Title'**
  String get categoryTitle;

  /// category - LabelName
  ///
  /// In en, this message translates to:
  /// **'category LabelName'**
  String get categoryLabelName;

  /// category - LabelGender
  ///
  /// In en, this message translates to:
  /// **'category LabelGender'**
  String get categoryLabelGender;

  /// category - LabelMinAge
  ///
  /// In en, this message translates to:
  /// **'category LabelMinAge'**
  String get categoryLabelMinAge;

  /// category - LabelMaxAge
  ///
  /// In en, this message translates to:
  /// **'category LabelMaxAge'**
  String get categoryLabelMaxAge;

  /// registration - Title
  ///
  /// In en, this message translates to:
  /// **'registration Title'**
  String get registrationTitle;

  /// registration - ButtonRegister
  ///
  /// In en, this message translates to:
  /// **'registration ButtonRegister'**
  String get registrationButtonRegister;

  /// registration - MessageSuccess
  ///
  /// In en, this message translates to:
  /// **'registration MessageSuccess'**
  String get registrationMessageSuccess;

  /// registration - LabelBib
  ///
  /// In en, this message translates to:
  /// **'registration LabelBib'**
  String get registrationLabelBib;

  /// registration - LabelClub
  ///
  /// In en, this message translates to:
  /// **'registration LabelClub'**
  String get registrationLabelClub;

  /// athlete - Title
  ///
  /// In en, this message translates to:
  /// **'athlete Title'**
  String get athleteTitle;

  /// athlete - LabelFirstName
  ///
  /// In en, this message translates to:
  /// **'athlete LabelFirstName'**
  String get athleteLabelFirstName;

  /// athlete - LabelLastName
  ///
  /// In en, this message translates to:
  /// **'athlete LabelLastName'**
  String get athleteLabelLastName;

  /// athlete - LabelBirthDate
  ///
  /// In en, this message translates to:
  /// **'athlete LabelBirthDate'**
  String get athleteLabelBirthDate;

  /// boulder - Title
  ///
  /// In en, this message translates to:
  /// **'boulder Title'**
  String get boulderTitle;

  /// boulder - LabelNumber
  ///
  /// In en, this message translates to:
  /// **'boulder LabelNumber'**
  String get boulderLabelNumber;

  /// boulder - LabelDifficulty
  ///
  /// In en, this message translates to:
  /// **'boulder LabelDifficulty'**
  String get boulderLabelDifficulty;

  /// boulder - LabelColor
  ///
  /// In en, this message translates to:
  /// **'boulder LabelColor'**
  String get boulderLabelColor;

  /// boulder - LabelTop
  ///
  /// In en, this message translates to:
  /// **'boulder LabelTop'**
  String get boulderLabelTop;

  /// boulder - LabelZone
  ///
  /// In en, this message translates to:
  /// **'boulder LabelZone'**
  String get boulderLabelZone;

  /// checkin - Title
  ///
  /// In en, this message translates to:
  /// **'checkin Title'**
  String get checkinTitle;

  /// checkin - ButtonScanQr
  ///
  /// In en, this message translates to:
  /// **'checkin ButtonScanQr'**
  String get checkinButtonScanQr;

  /// checkin - MessageCompleted
  ///
  /// In en, this message translates to:
  /// **'checkin MessageCompleted'**
  String get checkinMessageCompleted;

  /// checkin - MessageNotFound
  ///
  /// In en, this message translates to:
  /// **'checkin MessageNotFound'**
  String get checkinMessageNotFound;

  /// ranking - Title
  ///
  /// In en, this message translates to:
  /// **'ranking Title'**
  String get rankingTitle;

  /// ranking - LabelPosition
  ///
  /// In en, this message translates to:
  /// **'ranking LabelPosition'**
  String get rankingLabelPosition;

  /// ranking - LabelScore
  ///
  /// In en, this message translates to:
  /// **'ranking LabelScore'**
  String get rankingLabelScore;

  /// ranking - LabelAttempts
  ///
  /// In en, this message translates to:
  /// **'ranking LabelAttempts'**
  String get rankingLabelAttempts;

  /// admin - Dashboard
  ///
  /// In en, this message translates to:
  /// **'admin Dashboard'**
  String get adminDashboard;

  /// admin - Users
  ///
  /// In en, this message translates to:
  /// **'admin Users'**
  String get adminUsers;

  /// admin - Roles
  ///
  /// In en, this message translates to:
  /// **'admin Roles'**
  String get adminRoles;

  /// admin - Permissions
  ///
  /// In en, this message translates to:
  /// **'admin Permissions'**
  String get adminPermissions;

  /// admin - Settings
  ///
  /// In en, this message translates to:
  /// **'admin Settings'**
  String get adminSettings;

  /// error - Generic
  ///
  /// In en, this message translates to:
  /// **'error Generic'**
  String get errorGeneric;

  /// error - Network
  ///
  /// In en, this message translates to:
  /// **'error Network'**
  String get errorNetwork;

  /// error - Unauthorized
  ///
  /// In en, this message translates to:
  /// **'error Unauthorized'**
  String get errorUnauthorized;

  /// error - CompetitionClosed
  ///
  /// In en, this message translates to:
  /// **'error CompetitionClosed'**
  String get errorCompetitionClosed;

  /// error - SavingData
  ///
  /// In en, this message translates to:
  /// **'error SavingData'**
  String get errorSavingData;

  /// Custom competition message 1
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 1'**
  String get competitionMessageCustom1;

  /// Custom competition message 2
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 2'**
  String get competitionMessageCustom2;

  /// Custom competition message 3
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 3'**
  String get competitionMessageCustom3;

  /// Custom competition message 4
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 4'**
  String get competitionMessageCustom4;

  /// Custom competition message 5
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 5'**
  String get competitionMessageCustom5;

  /// Custom competition message 6
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 6'**
  String get competitionMessageCustom6;

  /// Custom competition message 7
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 7'**
  String get competitionMessageCustom7;

  /// Custom competition message 8
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 8'**
  String get competitionMessageCustom8;

  /// Custom competition message 9
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 9'**
  String get competitionMessageCustom9;

  /// Custom competition message 10
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 10'**
  String get competitionMessageCustom10;

  /// Custom competition message 11
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 11'**
  String get competitionMessageCustom11;

  /// Custom competition message 12
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 12'**
  String get competitionMessageCustom12;

  /// Custom competition message 13
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 13'**
  String get competitionMessageCustom13;

  /// Custom competition message 14
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 14'**
  String get competitionMessageCustom14;

  /// Custom competition message 15
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 15'**
  String get competitionMessageCustom15;

  /// Custom competition message 16
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 16'**
  String get competitionMessageCustom16;

  /// Custom competition message 17
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 17'**
  String get competitionMessageCustom17;

  /// Custom competition message 18
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 18'**
  String get competitionMessageCustom18;

  /// Custom competition message 19
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 19'**
  String get competitionMessageCustom19;

  /// Custom competition message 20
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 20'**
  String get competitionMessageCustom20;

  /// Custom competition message 21
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 21'**
  String get competitionMessageCustom21;

  /// Custom competition message 22
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 22'**
  String get competitionMessageCustom22;

  /// Custom competition message 23
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 23'**
  String get competitionMessageCustom23;

  /// Custom competition message 24
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 24'**
  String get competitionMessageCustom24;

  /// Custom competition message 25
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 25'**
  String get competitionMessageCustom25;

  /// Custom competition message 26
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 26'**
  String get competitionMessageCustom26;

  /// Custom competition message 27
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 27'**
  String get competitionMessageCustom27;

  /// Custom competition message 28
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 28'**
  String get competitionMessageCustom28;

  /// Custom competition message 29
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 29'**
  String get competitionMessageCustom29;

  /// Custom competition message 30
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 30'**
  String get competitionMessageCustom30;

  /// Custom competition message 31
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 31'**
  String get competitionMessageCustom31;

  /// Custom competition message 32
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 32'**
  String get competitionMessageCustom32;

  /// Custom competition message 33
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 33'**
  String get competitionMessageCustom33;

  /// Custom competition message 34
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 34'**
  String get competitionMessageCustom34;

  /// Custom competition message 35
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 35'**
  String get competitionMessageCustom35;

  /// Custom competition message 36
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 36'**
  String get competitionMessageCustom36;

  /// Custom competition message 37
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 37'**
  String get competitionMessageCustom37;

  /// Custom competition message 38
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 38'**
  String get competitionMessageCustom38;

  /// Custom competition message 39
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 39'**
  String get competitionMessageCustom39;

  /// Custom competition message 40
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 40'**
  String get competitionMessageCustom40;

  /// Custom competition message 41
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 41'**
  String get competitionMessageCustom41;

  /// Custom competition message 42
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 42'**
  String get competitionMessageCustom42;

  /// Custom competition message 43
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 43'**
  String get competitionMessageCustom43;

  /// Custom competition message 44
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 44'**
  String get competitionMessageCustom44;

  /// Custom competition message 45
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 45'**
  String get competitionMessageCustom45;

  /// Custom competition message 46
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 46'**
  String get competitionMessageCustom46;

  /// Custom competition message 47
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 47'**
  String get competitionMessageCustom47;

  /// Custom competition message 48
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 48'**
  String get competitionMessageCustom48;

  /// Custom competition message 49
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 49'**
  String get competitionMessageCustom49;

  /// Custom competition message 50
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 50'**
  String get competitionMessageCustom50;

  /// Custom competition message 51
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 51'**
  String get competitionMessageCustom51;

  /// Custom competition message 52
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 52'**
  String get competitionMessageCustom52;

  /// Custom competition message 53
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 53'**
  String get competitionMessageCustom53;

  /// Custom competition message 54
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 54'**
  String get competitionMessageCustom54;

  /// Custom competition message 55
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 55'**
  String get competitionMessageCustom55;

  /// Custom competition message 56
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 56'**
  String get competitionMessageCustom56;

  /// Custom competition message 57
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 57'**
  String get competitionMessageCustom57;

  /// Custom competition message 58
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 58'**
  String get competitionMessageCustom58;

  /// Custom competition message 59
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 59'**
  String get competitionMessageCustom59;

  /// Custom competition message 60
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 60'**
  String get competitionMessageCustom60;

  /// Custom competition message 61
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 61'**
  String get competitionMessageCustom61;

  /// Custom competition message 62
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 62'**
  String get competitionMessageCustom62;

  /// Custom competition message 63
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 63'**
  String get competitionMessageCustom63;

  /// Custom competition message 64
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 64'**
  String get competitionMessageCustom64;

  /// Custom competition message 65
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 65'**
  String get competitionMessageCustom65;

  /// Custom competition message 66
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 66'**
  String get competitionMessageCustom66;

  /// Custom competition message 67
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 67'**
  String get competitionMessageCustom67;

  /// Custom competition message 68
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 68'**
  String get competitionMessageCustom68;

  /// Custom competition message 69
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 69'**
  String get competitionMessageCustom69;

  /// Custom competition message 70
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 70'**
  String get competitionMessageCustom70;

  /// Custom competition message 71
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 71'**
  String get competitionMessageCustom71;

  /// Custom competition message 72
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 72'**
  String get competitionMessageCustom72;

  /// Custom competition message 73
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 73'**
  String get competitionMessageCustom73;

  /// Custom competition message 74
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 74'**
  String get competitionMessageCustom74;

  /// Custom competition message 75
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 75'**
  String get competitionMessageCustom75;

  /// Custom competition message 76
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 76'**
  String get competitionMessageCustom76;

  /// Custom competition message 77
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 77'**
  String get competitionMessageCustom77;

  /// Custom competition message 78
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 78'**
  String get competitionMessageCustom78;

  /// Custom competition message 79
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 79'**
  String get competitionMessageCustom79;

  /// Custom competition message 80
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 80'**
  String get competitionMessageCustom80;

  /// Custom competition message 81
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 81'**
  String get competitionMessageCustom81;

  /// Custom competition message 82
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 82'**
  String get competitionMessageCustom82;

  /// Custom competition message 83
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 83'**
  String get competitionMessageCustom83;

  /// Custom competition message 84
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 84'**
  String get competitionMessageCustom84;

  /// Custom competition message 85
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 85'**
  String get competitionMessageCustom85;

  /// Custom competition message 86
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 86'**
  String get competitionMessageCustom86;

  /// Custom competition message 87
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 87'**
  String get competitionMessageCustom87;

  /// Custom competition message 88
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 88'**
  String get competitionMessageCustom88;

  /// Custom competition message 89
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 89'**
  String get competitionMessageCustom89;

  /// Custom competition message 90
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 90'**
  String get competitionMessageCustom90;

  /// Custom competition message 91
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 91'**
  String get competitionMessageCustom91;

  /// Custom competition message 92
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 92'**
  String get competitionMessageCustom92;

  /// Custom competition message 93
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 93'**
  String get competitionMessageCustom93;

  /// Custom competition message 94
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 94'**
  String get competitionMessageCustom94;

  /// Custom competition message 95
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 95'**
  String get competitionMessageCustom95;

  /// Custom competition message 96
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 96'**
  String get competitionMessageCustom96;

  /// Custom competition message 97
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 97'**
  String get competitionMessageCustom97;

  /// Custom competition message 98
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 98'**
  String get competitionMessageCustom98;

  /// Custom competition message 99
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 99'**
  String get competitionMessageCustom99;

  /// Custom competition message 100
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 100'**
  String get competitionMessageCustom100;

  /// Custom competition message 101
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 101'**
  String get competitionMessageCustom101;

  /// Custom competition message 102
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 102'**
  String get competitionMessageCustom102;

  /// Custom competition message 103
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 103'**
  String get competitionMessageCustom103;

  /// Custom competition message 104
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 104'**
  String get competitionMessageCustom104;

  /// Custom competition message 105
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 105'**
  String get competitionMessageCustom105;

  /// Custom competition message 106
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 106'**
  String get competitionMessageCustom106;

  /// Custom competition message 107
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 107'**
  String get competitionMessageCustom107;

  /// Custom competition message 108
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 108'**
  String get competitionMessageCustom108;

  /// Custom competition message 109
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 109'**
  String get competitionMessageCustom109;

  /// Custom competition message 110
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 110'**
  String get competitionMessageCustom110;

  /// Custom competition message 111
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 111'**
  String get competitionMessageCustom111;

  /// Custom competition message 112
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 112'**
  String get competitionMessageCustom112;

  /// Custom competition message 113
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 113'**
  String get competitionMessageCustom113;

  /// Custom competition message 114
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 114'**
  String get competitionMessageCustom114;

  /// Custom competition message 115
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 115'**
  String get competitionMessageCustom115;

  /// Custom competition message 116
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 116'**
  String get competitionMessageCustom116;

  /// Custom competition message 117
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 117'**
  String get competitionMessageCustom117;

  /// Custom competition message 118
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 118'**
  String get competitionMessageCustom118;

  /// Custom competition message 119
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 119'**
  String get competitionMessageCustom119;

  /// Custom competition message 120
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 120'**
  String get competitionMessageCustom120;

  /// Custom competition message 121
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 121'**
  String get competitionMessageCustom121;

  /// Custom competition message 122
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 122'**
  String get competitionMessageCustom122;

  /// Custom competition message 123
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 123'**
  String get competitionMessageCustom123;

  /// Custom competition message 124
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 124'**
  String get competitionMessageCustom124;

  /// Custom competition message 125
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 125'**
  String get competitionMessageCustom125;

  /// Custom competition message 126
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 126'**
  String get competitionMessageCustom126;

  /// Custom competition message 127
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 127'**
  String get competitionMessageCustom127;

  /// Custom competition message 128
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 128'**
  String get competitionMessageCustom128;

  /// Custom competition message 129
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 129'**
  String get competitionMessageCustom129;

  /// Custom competition message 130
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 130'**
  String get competitionMessageCustom130;

  /// Custom competition message 131
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 131'**
  String get competitionMessageCustom131;

  /// Custom competition message 132
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 132'**
  String get competitionMessageCustom132;

  /// Custom competition message 133
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 133'**
  String get competitionMessageCustom133;

  /// Custom competition message 134
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 134'**
  String get competitionMessageCustom134;

  /// Custom competition message 135
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 135'**
  String get competitionMessageCustom135;

  /// Custom competition message 136
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 136'**
  String get competitionMessageCustom136;

  /// Custom competition message 137
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 137'**
  String get competitionMessageCustom137;

  /// Custom competition message 138
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 138'**
  String get competitionMessageCustom138;

  /// Custom competition message 139
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 139'**
  String get competitionMessageCustom139;

  /// Custom competition message 140
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 140'**
  String get competitionMessageCustom140;

  /// Custom competition message 141
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 141'**
  String get competitionMessageCustom141;

  /// Custom competition message 142
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 142'**
  String get competitionMessageCustom142;

  /// Custom competition message 143
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 143'**
  String get competitionMessageCustom143;

  /// Custom competition message 144
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 144'**
  String get competitionMessageCustom144;

  /// Custom competition message 145
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 145'**
  String get competitionMessageCustom145;

  /// Custom competition message 146
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 146'**
  String get competitionMessageCustom146;

  /// Custom competition message 147
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 147'**
  String get competitionMessageCustom147;

  /// Custom competition message 148
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 148'**
  String get competitionMessageCustom148;

  /// Custom competition message 149
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 149'**
  String get competitionMessageCustom149;

  /// Custom competition message 150
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 150'**
  String get competitionMessageCustom150;

  /// Custom competition message 151
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 151'**
  String get competitionMessageCustom151;

  /// Custom competition message 152
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 152'**
  String get competitionMessageCustom152;

  /// Custom competition message 153
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 153'**
  String get competitionMessageCustom153;

  /// Custom competition message 154
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 154'**
  String get competitionMessageCustom154;

  /// Custom competition message 155
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 155'**
  String get competitionMessageCustom155;

  /// Custom competition message 156
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 156'**
  String get competitionMessageCustom156;

  /// Custom competition message 157
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 157'**
  String get competitionMessageCustom157;

  /// Custom competition message 158
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 158'**
  String get competitionMessageCustom158;

  /// Custom competition message 159
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 159'**
  String get competitionMessageCustom159;

  /// Custom competition message 160
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 160'**
  String get competitionMessageCustom160;

  /// Custom competition message 161
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 161'**
  String get competitionMessageCustom161;

  /// Custom competition message 162
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 162'**
  String get competitionMessageCustom162;

  /// Custom competition message 163
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 163'**
  String get competitionMessageCustom163;

  /// Custom competition message 164
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 164'**
  String get competitionMessageCustom164;

  /// Custom competition message 165
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 165'**
  String get competitionMessageCustom165;

  /// Custom competition message 166
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 166'**
  String get competitionMessageCustom166;

  /// Custom competition message 167
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 167'**
  String get competitionMessageCustom167;

  /// Custom competition message 168
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 168'**
  String get competitionMessageCustom168;

  /// Custom competition message 169
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 169'**
  String get competitionMessageCustom169;

  /// Custom competition message 170
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 170'**
  String get competitionMessageCustom170;

  /// Custom competition message 171
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 171'**
  String get competitionMessageCustom171;

  /// Custom competition message 172
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 172'**
  String get competitionMessageCustom172;

  /// Custom competition message 173
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 173'**
  String get competitionMessageCustom173;

  /// Custom competition message 174
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 174'**
  String get competitionMessageCustom174;

  /// Custom competition message 175
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 175'**
  String get competitionMessageCustom175;

  /// Custom competition message 176
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 176'**
  String get competitionMessageCustom176;

  /// Custom competition message 177
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 177'**
  String get competitionMessageCustom177;

  /// Custom competition message 178
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 178'**
  String get competitionMessageCustom178;

  /// Custom competition message 179
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 179'**
  String get competitionMessageCustom179;

  /// Custom competition message 180
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 180'**
  String get competitionMessageCustom180;

  /// Custom competition message 181
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 181'**
  String get competitionMessageCustom181;

  /// Custom competition message 182
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 182'**
  String get competitionMessageCustom182;

  /// Custom competition message 183
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 183'**
  String get competitionMessageCustom183;

  /// Custom competition message 184
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 184'**
  String get competitionMessageCustom184;

  /// Custom competition message 185
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 185'**
  String get competitionMessageCustom185;

  /// Custom competition message 186
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 186'**
  String get competitionMessageCustom186;

  /// Custom competition message 187
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 187'**
  String get competitionMessageCustom187;

  /// Custom competition message 188
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 188'**
  String get competitionMessageCustom188;

  /// Custom competition message 189
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 189'**
  String get competitionMessageCustom189;

  /// Custom competition message 190
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 190'**
  String get competitionMessageCustom190;

  /// Custom competition message 191
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 191'**
  String get competitionMessageCustom191;

  /// Custom competition message 192
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 192'**
  String get competitionMessageCustom192;

  /// Custom competition message 193
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 193'**
  String get competitionMessageCustom193;

  /// Custom competition message 194
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 194'**
  String get competitionMessageCustom194;

  /// Custom competition message 195
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 195'**
  String get competitionMessageCustom195;

  /// Custom competition message 196
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 196'**
  String get competitionMessageCustom196;

  /// Custom competition message 197
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 197'**
  String get competitionMessageCustom197;

  /// Custom competition message 198
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 198'**
  String get competitionMessageCustom198;

  /// Custom competition message 199
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 199'**
  String get competitionMessageCustom199;

  /// Custom competition message 200
  ///
  /// In en, this message translates to:
  /// **'Messaggio gara 200'**
  String get competitionMessageCustom200;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
