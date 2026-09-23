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

  ///  Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  ///  Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  ///  Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// competition - Description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get competitionDescription;

  /// competition - Date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get competitionDate;

  /// boulder - LabelNumber
  ///
  /// In en, this message translates to:
  /// **'Nr Boulder'**
  String get boulderLabelNumber;

  /// Custom competition message 1
  ///
  /// In en, this message translates to:
  /// **'Race Modification'**
  String get competitionMessageCustom1;

  /// Custom competition message 2
  ///
  /// In en, this message translates to:
  /// **'New Race'**
  String get competitionMessageCustom2;

  /// Custom competition message 3
  ///
  /// In en, this message translates to:
  /// **'Competition Management'**
  String get competitionMessageCustom3;

  /// Custom competition message 4
  ///
  /// In en, this message translates to:
  /// **'Rescue...'**
  String get competitionMessageCustom4;

  /// Custom competition message 5
  ///
  /// In en, this message translates to:
  /// **'Print QR code card'**
  String get competitionMessageCustom5;

  /// Custom competition message 6
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get competitionMessageCustom6;

  /// Custom competition message 7
  ///
  /// In en, this message translates to:
  /// **'Nr Finalists'**
  String get competitionMessageCustom7;

  /// Custom competition message 8
  ///
  /// In en, this message translates to:
  /// **'Nr Max Registrations'**
  String get competitionMessageCustom8;

  /// Custom competition message 9
  ///
  /// In en, this message translates to:
  /// **'Slots Enabling'**
  String get competitionMessageCustom9;

  /// Custom competition message 10
  ///
  /// In en, this message translates to:
  /// **'First Slot Registered'**
  String get competitionMessageCustom10;

  /// Custom competition message 11
  ///
  /// In en, this message translates to:
  /// **'Second Slot Registered'**
  String get competitionMessageCustom11;

  /// Custom competition message 12
  ///
  /// In en, this message translates to:
  /// **'Registration Fee'**
  String get competitionMessageCustom12;

  /// Custom competition message 13
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get competitionMessageCustom13;

  /// Label of the option to close competition registrations
  ///
  /// In en, this message translates to:
  /// **'Registration closed'**
  String get competitionMessageCustom14;

  /// Label of the option indicating that the competition is closed
  ///
  /// In en, this message translates to:
  /// **'Competition closed'**
  String get competitionMessageCustom15;

  /// Label of the option to enable attendance management
  ///
  /// In en, this message translates to:
  /// **'Attendance management'**
  String get competitionMessageCustom16;

  /// Label of the option to enable payment management
  ///
  /// In en, this message translates to:
  /// **'Payment management'**
  String get competitionMessageCustom17;

  /// Label of the option to enable complimentary registrations management
  ///
  /// In en, this message translates to:
  /// **'Gift management'**
  String get competitionMessageCustom18;

  /// Custom competition message 19
  ///
  /// In en, this message translates to:
  /// **'Error generating the QR badge:'**
  String get competitionMessageCustom19;

  /// Message displayed when the user does not have permission to modify a competition
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to modify competitions'**
  String get competitionMessageCustom20;

  /// Validation message displayed when no competition date has been selected
  ///
  /// In en, this message translates to:
  /// **'Please select the competition date'**
  String get competitionMessageCustom21;

  /// Validation message displayed when the maximum number of registrations is not valid
  ///
  /// In en, this message translates to:
  /// **'Enter a maximum number of registrations greater than 0'**
  String get competitionMessageCustom22;

  /// Validation message displayed when the total registrations for the first and second time slots exceed the maximum number of registrations
  ///
  /// In en, this message translates to:
  /// **'The total number of registrations for the first and second time slots cannot exceed the maximum number of registrations'**
  String get competitionMessageCustom23;

  /// Message displayed after successfully updating a competition
  ///
  /// In en, this message translates to:
  /// **'Competition updated'**
  String get competitionMessageCustom24;

  /// Message displayed after successfully creating a new competition
  ///
  /// In en, this message translates to:
  /// **'Competition created'**
  String get competitionMessageCustom25;

  /// Delete Competition
  ///
  /// In en, this message translates to:
  /// **'Delete Competition'**
  String get competitionMessageCustom26;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get competitionMessageCustom27;

  /// An open competition already exists: close it before creating a new one
  ///
  /// In en, this message translates to:
  /// **'An open competition already exists: close it before creating a new one.'**
  String get competitionMessageCustom28;

  /// Competitions
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get competitionMessageCustom29;

  /// Close the open competition before creating a new one
  ///
  /// In en, this message translates to:
  /// **'Close the open competition before creating a new one'**
  String get competitionMessageCustom30;

  /// Search Competition
  ///
  /// In en, this message translates to:
  /// **'Search Competition'**
  String get competitionMessageCustom31;

  /// Open Competitions Only
  ///
  /// In en, this message translates to:
  /// **'Open Competitions Only'**
  String get competitionMessageCustom32;

  /// No Competitions
  ///
  /// In en, this message translates to:
  /// **'No Competitions'**
  String get competitionMessageCustom33;

  /// Closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get competitionMessageCustom34;

  /// Open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get competitionMessageCustom35;

  /// Status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get competitionMessageCustom36;

  /// Actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get competitionMessageCustom37;

  /// Competition not found
  ///
  /// In en, this message translates to:
  /// **'Competition not found'**
  String get competitionMessageCustom38;

  /// Scan the QR code with your camera for check-in
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with your camera for check-in'**
  String get competitionMessageCustom39;

  /// Confirmation that the category has been deleted
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryMessageCustom1;

  /// Error message with details of the error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String categoryMessageCustom2(Object error);

  /// Title of the categories page with the competition name
  ///
  /// In en, this message translates to:
  /// **'Categories - {competitionName}'**
  String categoryMessageCustom3(Object competitionName);

  /// Text displayed when there are no categories
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get categoryMessageCustom4;

  /// Message displayed when the user does not have permission to edit categories
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to edit categories'**
  String get categoryMessageCustom5;

  /// Title when editing a category
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryMessageCustom6;

  /// Title when creating a new category
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryMessageCustom7;

  /// Label for the category name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryMessageCustom8;

  /// Validation message for a required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get categoryMessageCustom9;

  /// Sex option: male
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get categoryMessageCustom10;

  /// Sex option: female
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get categoryMessageCustom11;

  /// Label for minimum age field
  ///
  /// In en, this message translates to:
  /// **'Age min'**
  String get categoryMessageCustom12;

  /// Label for maximum age field
  ///
  /// In en, this message translates to:
  /// **'Age max'**
  String get categoryMessageCustom13;

  /// Button text for updating a category
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get categoryMessageCustom14;

  /// Button text for creating a category
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get categoryMessageCustom15;

  /// Confirmation that the boulder was deleted
  ///
  /// In en, this message translates to:
  /// **'Boulder deleted'**
  String get boulderMessageCustom1;

  /// Error message with error detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String boulderMessageCustom2(Object error);

  /// Page title for boulders with the competition name
  ///
  /// In en, this message translates to:
  /// **'Boulders - {competitionName}'**
  String boulderMessageCustom3(Object competitionName);

  /// Label for the filter to show only final boulders
  ///
  /// In en, this message translates to:
  /// **'Finals only'**
  String get boulderMessageCustom4;

  /// Text shown when there are no boulders
  ///
  /// In en, this message translates to:
  /// **'No boulders'**
  String get boulderMessageCustom5;

  /// Title for a single boulder with its number
  ///
  /// In en, this message translates to:
  /// **'Boulder {number}'**
  String boulderMessageCustom6(Object number);

  /// Label indicating the boulder is a final
  ///
  /// In en, this message translates to:
  /// **'FINAL'**
  String get boulderMessageCustom7;

  /// Boulder subtitle with difficulty, color and theoretical value (value formatted to 2 decimals)
  ///
  /// In en, this message translates to:
  /// **'Diff: {difficulty} | Color: {color} | Value: {value}'**
  String boulderMessageCustom8(Object difficulty, Object color, Object value);

  /// Title when editing a boulder
  ///
  /// In en, this message translates to:
  /// **'Edit Boulder'**
  String get boulderMessageCustom9;

  /// Title when creating a new boulder
  ///
  /// In en, this message translates to:
  /// **'New Boulder'**
  String get boulderMessageCustom10;

  /// Label for the boulder number field
  ///
  /// In en, this message translates to:
  /// **'Boulder number'**
  String get boulderMessageCustom11;

  /// Validation message for a required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get boulderMessageCustom12;

  /// Label for the difficulty field
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get boulderMessageCustom13;

  /// Scale label: easy
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get boulderMessageCustom14;

  /// Scale label: hard
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get boulderMessageCustom15;

  /// Label for the color field
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get boulderMessageCustom16;

  /// Option for no color
  ///
  /// In en, this message translates to:
  /// **'No color'**
  String get boulderMessageCustom17;

  /// Color option: White
  ///
  /// In en, this message translates to:
  /// **'⚪ White'**
  String get boulderMessageCustom18;

  /// Color option: Yellow
  ///
  /// In en, this message translates to:
  /// **'🟡 Yellow'**
  String get boulderMessageCustom19;

  /// Color option: Green
  ///
  /// In en, this message translates to:
  /// **'🟢 Green'**
  String get boulderMessageCustom20;

  /// Color option: Blue
  ///
  /// In en, this message translates to:
  /// **'🔵 Blue'**
  String get boulderMessageCustom21;

  /// Color option: Red
  ///
  /// In en, this message translates to:
  /// **'🔴 Red'**
  String get boulderMessageCustom22;

  /// Color option: Black
  ///
  /// In en, this message translates to:
  /// **'⚫ Black'**
  String get boulderMessageCustom23;

  /// Tooltip for the button that prints the QR card
  ///
  /// In en, this message translates to:
  /// **'Print QR card'**
  String get boulderMessageCustom24;

  /// Label for the option to show only final boulders
  ///
  /// In en, this message translates to:
  /// **'Finals only'**
  String get boulderMessageCustom25;

  /// Subtitle that explains the finals-only option
  ///
  /// In en, this message translates to:
  /// **'The boulder will be available only in the final phase'**
  String get boulderMessageCustom26;

  /// Label for the theoretical value field
  ///
  /// In en, this message translates to:
  /// **'Theoretical value'**
  String get boulderMessageCustom27;

  /// Label for the multi-create field (how many boulders to create)
  ///
  /// In en, this message translates to:
  /// **'Boulders to create'**
  String get boulderMessageCustom28;

  /// Helper text indicating allowed values for the multi-create field
  ///
  /// In en, this message translates to:
  /// **'Allowed values: 1 to 20'**
  String get boulderMessageCustom29;

  /// Validation message when no number was entered
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get boulderMessageCustom30;

  /// Validation message when the number is out of allowed range
  ///
  /// In en, this message translates to:
  /// **'Allowed value: 1-20'**
  String get boulderMessageCustom31;

  /// Button text for updating a boulder
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get boulderMessageCustom32;

  /// Button text for creating a boulder
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get boulderMessageCustom33;

  /// Card header: 'BOULDER'
  ///
  /// In en, this message translates to:
  /// **'BOULDER'**
  String get boulderMessageCustom34;

  /// Text that shows the boulder difficulty
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty} / 10'**
  String boulderMessageCustom35(Object difficulty);

  /// Instruction under the QR to register the top by scanning the code
  ///
  /// In en, this message translates to:
  /// **'Scan to register the top'**
  String get boulderMessageCustom36;

  /// Message shown at the end of import with counts of inserted and discarded records
  ///
  /// In en, this message translates to:
  /// **'Import completed - Inserted: {inserted} Discarded: {discarded}'**
  String registrationMessageCustom1(Object inserted, Object discarded);

  /// Confirmation that a registration was deleted
  ///
  /// In en, this message translates to:
  /// **'Registration deleted'**
  String get registrationMessageCustom2;

  /// Tooltip when registrations are closed and the action is not available
  ///
  /// In en, this message translates to:
  /// **'Registrations closed: {action} not available'**
  String registrationMessageCustom3(Object action);

  /// Tooltip when the maximum number of registrations is reached and the action is not available
  ///
  /// In en, this message translates to:
  /// **'Maximum registrations reached: {action} not available'**
  String registrationMessageCustom4(Object action);

  /// Label for the import CSV action
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get registrationMessageCustom5;

  /// Label for the action to create a new registration
  ///
  /// In en, this message translates to:
  /// **'New registration'**
  String get registrationMessageCustom6;

  /// Page title for registrations with the competition name
  ///
  /// In en, this message translates to:
  /// **'Registrations - {competitionName}'**
  String registrationMessageCustom7(Object competitionName);

  /// Message shown when registrations are closed
  ///
  /// In en, this message translates to:
  /// **'Registrations for this competition are closed. It is not possible to add new athletes or import CSV.'**
  String get registrationMessageCustom8;

  /// Message shown when the maximum number of registrations is reached, with current and max counts
  ///
  /// In en, this message translates to:
  /// **'Maximum number of registrations reached ({current}/{max}). It is not possible to add new athletes or import CSV.'**
  String registrationMessageCustom9(Object current, Object max);

  /// Hint for searching registrations
  ///
  /// In en, this message translates to:
  /// **'Search bib, lastname or given firstname or club or category...'**
  String get registrationMessageCustom10;

  /// Text shown when there are no registrations
  ///
  /// In en, this message translates to:
  /// **'No registrations'**
  String get registrationMessageCustom11;

  /// Label to indicate the boulder
  ///
  /// In en, this message translates to:
  /// **'Boulder'**
  String get registrationMessageCustom12;

  /// Message indicating the athlete is not present
  ///
  /// In en, this message translates to:
  /// **'Athlete not present'**
  String get registrationMessageCustom13;

  /// Message shown when the email is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get registrationMessageCustom14;

  /// Message shown when the email is already registered for the competition
  ///
  /// In en, this message translates to:
  /// **'Email already present in this competition'**
  String get registrationMessageCustom15;

  /// Message shown when the first turn is full
  ///
  /// In en, this message translates to:
  /// **'First turn is full, please select another option'**
  String get registrationMessageCustom16;

  /// Message shown when the second turn is full
  ///
  /// In en, this message translates to:
  /// **'Second turn is full, please select another option'**
  String get registrationMessageCustom17;

  /// Title when editing a registration
  ///
  /// In en, this message translates to:
  /// **'Edit registration'**
  String get registrationMessageCustom18;

  /// Title when creating a new registration
  ///
  /// In en, this message translates to:
  /// **'New registration'**
  String get registrationMessageCustom19;

  /// Label for surname field
  ///
  /// In en, this message translates to:
  /// **'Lastname'**
  String get registrationMessageCustom20;

  /// Label for given name field
  ///
  /// In en, this message translates to:
  /// **'Firstname'**
  String get registrationMessageCustom21;

  /// Validation message for required field (registration)
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get registrationMessageCustom22;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registrationMessageCustom23;

  /// Validation message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get registrationMessageCustom24;

  /// Validation message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get registrationMessageCustom25;

  /// Label for club/society field
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get registrationMessageCustom26;

  /// Label for bib number field
  ///
  /// In en, this message translates to:
  /// **'Bib'**
  String get registrationMessageCustom27;

  /// Label for sex field
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get registrationMessageCustom28;

  /// Sex option: male (registration)
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get registrationMessageCustom29;

  /// Sex option: female (registration)
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get registrationMessageCustom30;

  /// Label for birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get registrationMessageCustom31;

  /// Validation message when birth date is not set
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get registrationMessageCustom32;

  /// Title for the first turn switch
  ///
  /// In en, this message translates to:
  /// **'First turn'**
  String get registrationMessageCustom33;

  /// Subtitle when turn management is not active
  ///
  /// In en, this message translates to:
  /// **'Turn management not active for this competition'**
  String get registrationMessageCustom34;

  /// Subtitle when the turn is full
  ///
  /// In en, this message translates to:
  /// **'Turn is full'**
  String get registrationMessageCustom35;

  /// Title for the second turn switch
  ///
  /// In en, this message translates to:
  /// **'Second turn'**
  String get registrationMessageCustom36;

  /// Title for the present switch
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get registrationMessageCustom37;

  /// Title for the paid switch
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get registrationMessageCustom38;

  /// Title for the free/complimentary switch
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get registrationMessageCustom39;

  /// Button text to update the registration
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get registrationMessageCustom40;

  /// Button text to create the registration
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get registrationMessageCustom41;

  /// Tooltip for the button that exports to PDF on the check-in page
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get checkinMessageCustom1;

  /// Hint for searching on the check-in page
  ///
  /// In en, this message translates to:
  /// **'Search bib, lastname, firstname...'**
  String get checkinMessageCustom2;

  /// Text shown when the search finds no registrations
  ///
  /// In en, this message translates to:
  /// **'No registrations found'**
  String get checkinMessageCustom3;

  /// Stat label: total registered
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get checkinMessageCustom4;

  /// Stat label: number of present athletes
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get checkinMessageCustom5;

  /// Stat label: number of paid registrations
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get checkinMessageCustom6;

  /// Stat label: number of complimentary/free registrations
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get checkinMessageCustom7;

  /// Legend instruction inviting to tap icons to update state
  ///
  /// In en, this message translates to:
  /// **'Tap the icons to update: '**
  String get checkinMessageCustom8;

  /// Message shown when check-in management is disabled for the competition
  ///
  /// In en, this message translates to:
  /// **'Check-in management disabled for this competition'**
  String get checkinMessageCustom9;

  /// Tooltip to remove presence
  ///
  /// In en, this message translates to:
  /// **'Remove presence'**
  String get checkinMessageCustom10;

  /// Tooltip to mark as present
  ///
  /// In en, this message translates to:
  /// **'Mark present'**
  String get checkinMessageCustom11;

  /// Tooltip when presence management is not enabled
  ///
  /// In en, this message translates to:
  /// **'Presence management not enabled'**
  String get checkinMessageCustom12;

  /// Tooltip to cancel payment
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get checkinMessageCustom13;

  /// Tooltip to mark as paid
  ///
  /// In en, this message translates to:
  /// **'Mark paid'**
  String get checkinMessageCustom14;

  /// Tooltip when payment management is not enabled
  ///
  /// In en, this message translates to:
  /// **'Payment management not enabled'**
  String get checkinMessageCustom15;

  /// Tooltip to cancel free/complimentary status
  ///
  /// In en, this message translates to:
  /// **'Cancel gift'**
  String get checkinMessageCustom16;

  /// Tooltip to mark as free/complimentary
  ///
  /// In en, this message translates to:
  /// **'Mark gift'**
  String get checkinMessageCustom17;

  /// Tooltip when free/complimentary management is not enabled
  ///
  /// In en, this message translates to:
  /// **'Gifts not enabled'**
  String get checkinMessageCustom18;

  /// Title of the check-in page
  ///
  /// In en, this message translates to:
  /// **'Check-in Race'**
  String get checkinMessageCustom19;

  /// Subtitle of the check-in page
  ///
  /// In en, this message translates to:
  /// **'Manage presence, payments and gifts'**
  String get checkinMessageCustom20;

  /// Hint for searching competitions on the check-in page
  ///
  /// In en, this message translates to:
  /// **'Search race'**
  String get checkinMessageCustom21;

  /// Label for the filter to show only open competitions
  ///
  /// In en, this message translates to:
  /// **'Open only'**
  String get checkinMessageCustom22;

  /// Text shown when no competitions are found
  ///
  /// In en, this message translates to:
  /// **'No races found'**
  String get checkinMessageCustom23;

  /// Tooltip for the button that opens the registrations page
  ///
  /// In en, this message translates to:
  /// **'Registrations'**
  String get checkinMessageCustom24;

  /// Column header: competition description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get checkinMessageCustom25;

  /// Column header: competition date
  ///
  /// In en, this message translates to:
  /// **'Race date'**
  String get checkinMessageCustom26;

  /// Column header: competition status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get checkinMessageCustom27;

  /// Column header: presences
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get checkinMessageCustom28;

  /// Column header: payments
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get checkinMessageCustom29;

  /// Column header: freebies/complimentary
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get checkinMessageCustom30;

  /// Column header: actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get checkinMessageCustom31;

  /// Tooltip to disable presence management
  ///
  /// In en, this message translates to:
  /// **'Disable presence management'**
  String get checkinMessageCustom32;

  /// Tooltip to enable presence management
  ///
  /// In en, this message translates to:
  /// **'Enable presence management'**
  String get checkinMessageCustom33;

  /// Tooltip to disable payment management
  ///
  /// In en, this message translates to:
  /// **'Disable payment management'**
  String get checkinMessageCustom34;

  /// Tooltip to enable payment management
  ///
  /// In en, this message translates to:
  /// **'Enable payment management'**
  String get checkinMessageCustom35;

  /// Tooltip to disable gifts management
  ///
  /// In en, this message translates to:
  /// **'Disable gifts management'**
  String get checkinMessageCustom36;

  /// Tooltip to enable gifts management
  ///
  /// In en, this message translates to:
  /// **'Enable gifts management'**
  String get checkinMessageCustom37;

  /// Competition status: open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get checkinMessageCustom38;

  /// Competition status: closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get checkinMessageCustom39;

  /// Legend: presence management
  ///
  /// In en, this message translates to:
  /// **'Presence management'**
  String get checkinMessageCustom40;

  /// Legend: payment management
  ///
  /// In en, this message translates to:
  /// **'Payment management'**
  String get checkinMessageCustom41;

  /// Legend: gifts management
  ///
  /// In en, this message translates to:
  /// **'Gifts management'**
  String get checkinMessageCustom42;

  /// Instruction in the legend to enable/disable flags
  ///
  /// In en, this message translates to:
  /// **'Tap the icons to enable/disable'**
  String get checkinMessageCustom43;

  /// Header for totals summary in the PDF
  ///
  /// In en, this message translates to:
  /// **'TOTALS'**
  String get checkinMessageCustom44;

  /// Line in the PDF that shows the total amount collected
  ///
  /// In en, this message translates to:
  /// **'Total amount collected: {amount}'**
  String checkinMessageCustom45(Object amount);

  /// PDF header: Athletes check-in with competition date
  ///
  /// In en, this message translates to:
  /// **'Athletes check-in — {date}'**
  String checkinMessageCustom46(Object date);

  /// PDF line showing generation date/time
  ///
  /// In en, this message translates to:
  /// **'Generated on {datetime}'**
  String checkinMessageCustom47(Object datetime);

  /// PDF footer: shows current page number and total pages
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String checkinMessageCustom48(Object page, Object total);

  /// Card title: Roles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get administrationMessaggeCustom1;

  /// Card description: Roles
  ///
  /// In en, this message translates to:
  /// **'Define application roles and assign menus and permissions.'**
  String get administrationMessaggeCustom2;

  /// Card title: Permissions
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get administrationMessaggeCustom3;

  /// Card description: Permissions
  ///
  /// In en, this message translates to:
  /// **'Manage permission codes and associated activities.'**
  String get administrationMessaggeCustom4;

  /// Card title: Menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get administrationMessaggeCustom5;

  /// Card description: Menu
  ///
  /// In en, this message translates to:
  /// **'Configure menu structure and platform visibility.'**
  String get administrationMessaggeCustom6;

  /// Card title: Users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get administrationMessaggeCustom7;

  /// Card description: Users
  ///
  /// In en, this message translates to:
  /// **'Assign roles to registered users.'**
  String get administrationMessaggeCustom8;

  /// Card title: Email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get administrationMessaggeCustom9;

  /// Card description: Email
  ///
  /// In en, this message translates to:
  /// **'Manage configurations, templates and email sending settings.'**
  String get administrationMessaggeCustom10;

  /// Administration page title: Security
  ///
  /// In en, this message translates to:
  /// **'Security and Templates'**
  String get administrationMessaggeCustom11;

  /// Administration page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage roles, permissions, menu and users'**
  String get administrationMessaggeCustom12;

  /// Header for development tools section
  ///
  /// In en, this message translates to:
  /// **'Development tools'**
  String get administrationMessaggeCustom13;

  /// Label for the button resetting client configuration
  ///
  /// In en, this message translates to:
  /// **'Reset client configuration'**
  String get administrationMessaggeCustom14;

  /// Confirmation dialog message warning about disconnection and app closure
  ///
  /// In en, this message translates to:
  /// **'The device will be disconnected from the current client. The application will close automatically: at restart you will need to enter the client code and password again.'**
  String get administrationMessaggeCustom15;

  /// Label for the cancel button in the reset confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get administrationMessaggeCustom16;

  /// Label for the confirm button in the reset dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm reset'**
  String get administrationMessaggeCustom17;

  /// Title of the dialog shown after reset completes
  ///
  /// In en, this message translates to:
  /// **'Reset completed'**
  String get administrationMessaggeCustom18;

  /// Final message informing the user the app will close and credentials must be re-entered
  ///
  /// In en, this message translates to:
  /// **'The application will be closed. Reopen it to enter the new client code and password.'**
  String get administrationMessaggeCustom19;

  /// Label for the button that closes the app immediately after reset
  ///
  /// In en, this message translates to:
  /// **'Close now'**
  String get administrationMessaggeCustom20;

  /// Title of the card to force the language (test only)
  ///
  /// In en, this message translates to:
  /// **'Force language (test only)'**
  String get administrationMessaggeCustom21;

  /// Text indicating language is automatic (OS)
  ///
  /// In en, this message translates to:
  /// **'Current language: automatic (operating system)'**
  String get administrationMessaggeCustom22;

  /// Text showing forced language with the language code (e.g. IT/EN)
  ///
  /// In en, this message translates to:
  /// **'Forced language: {code}'**
  String administrationMessaggeCustom23(Object code);

  /// Label for the automatic (system) option
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get administrationMessaggeCustom24;

  /// Dialog title for deleting a menu item
  ///
  /// In en, this message translates to:
  /// **'Delete menu item'**
  String get administrationMessaggeCustom25;

  /// Confirmation message for deleting a menu, including the label of the item
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{label}\"?\nChild submenus will be deleted in cascade.'**
  String administrationMessaggeCustom26(Object label);

  /// Generic error message with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String administrationMessaggeCustom27(Object error);

  /// Label for the button that creates a new menu item
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get administrationMessaggeCustom28;

  /// Tooltip for the translations button
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get administrationMessaggeCustom29;

  /// Tooltip for the button that adds a child item
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get administrationMessaggeCustom30;

  /// Tooltip for the edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get administrationMessaggeCustom31;

  /// Tooltip for the delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get administrationMessaggeCustom32;

  /// Message shown when there are no menu items
  ///
  /// In en, this message translates to:
  /// **'No menu items configured'**
  String get administrationMessaggeCustom33;

  /// Success message after deleting a menu item
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get administrationMessaggeCustom34;

  /// Subtitle for the menu page: navigation structure
  ///
  /// In en, this message translates to:
  /// **'Navigation structure'**
  String get administrationMessaggeCustom36;

  /// Page title: edit menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Menu Item'**
  String get administrationMessaggeCustom37;

  /// Page title: new menu item
  ///
  /// In en, this message translates to:
  /// **'New Menu Item'**
  String get administrationMessaggeCustom38;

  /// Subtitle for the menu form page
  ///
  /// In en, this message translates to:
  /// **'Navigation item configuration'**
  String get administrationMessaggeCustom39;

  /// Label shown while saving is in progress
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get administrationMessaggeCustom40;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get administrationMessaggeCustom41;

  /// Menu label field
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get administrationMessaggeCustom42;

  /// Validation message for required field
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get administrationMessaggeCustom43;

  /// Route field label
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get administrationMessaggeCustom44;

  /// Hint for route field
  ///
  /// In en, this message translates to:
  /// **'/dashboard'**
  String get administrationMessaggeCustom45;

  /// Validation message: route must start with /
  ///
  /// In en, this message translates to:
  /// **'Must start with /'**
  String get administrationMessaggeCustom46;

  /// Icon field label
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get administrationMessaggeCustom47;

  /// Option for no icon
  ///
  /// In en, this message translates to:
  /// **'— none —'**
  String get administrationMessaggeCustom48;

  /// Label for non-standard icon
  ///
  /// In en, this message translates to:
  /// **'{icon} (non standard)'**
  String administrationMessaggeCustom49(Object icon);

  /// Order field label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get administrationMessaggeCustom50;

  /// Parent field label
  ///
  /// In en, this message translates to:
  /// **'Parent item'**
  String get administrationMessaggeCustom51;

  /// Helper text for parent field
  ///
  /// In en, this message translates to:
  /// **'Leave empty to create a top-level item'**
  String get administrationMessaggeCustom52;

  /// Option for top-level (no parent)
  ///
  /// In en, this message translates to:
  /// **'— Top level —'**
  String get administrationMessaggeCustom53;

  /// Switch label: visible
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get administrationMessaggeCustom54;

  /// Switch label: show on mobile
  ///
  /// In en, this message translates to:
  /// **'Show on Mobile'**
  String get administrationMessaggeCustom55;

  /// Switch label: show on desktop
  ///
  /// In en, this message translates to:
  /// **'Show on Desktop'**
  String get administrationMessaggeCustom56;

  /// Success message for item updated
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get administrationMessaggeCustom57;

  /// Success message for item created
  ///
  /// In en, this message translates to:
  /// **'Item created'**
  String get administrationMessaggeCustom58;

  /// Success message: translation updated
  ///
  /// In en, this message translates to:
  /// **'Translation updated'**
  String get administrationMessaggeCustom59;

  /// Success message: translation created
  ///
  /// In en, this message translates to:
  /// **'Translation created'**
  String get administrationMessaggeCustom60;

  /// Page title: edit translation
  ///
  /// In en, this message translates to:
  /// **'Edit Translation'**
  String get administrationMessaggeCustom61;

  /// Page title: new translation
  ///
  /// In en, this message translates to:
  /// **'New Translation'**
  String get administrationMessaggeCustom62;

  /// Subtitle: shows original label and route
  ///
  /// In en, this message translates to:
  /// **'\"{label}\" — {route}'**
  String administrationMessaggeCustom63(Object label, Object route);

  /// Language field label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get administrationMessaggeCustom64;

  /// Validation message for language selection
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get administrationMessaggeCustom65;

  /// Label for translated label field
  ///
  /// In en, this message translates to:
  /// **'Translated label'**
  String get administrationMessaggeCustom66;

  /// Informative note telling that default label will be used if left empty
  ///
  /// In en, this message translates to:
  /// **'If left empty, the default label will be shown: \"{label}\"'**
  String administrationMessaggeCustom67(Object label);

  /// Dialog title for deleting a translation
  ///
  /// In en, this message translates to:
  /// **'Delete translation'**
  String get administrationMessaggeCustom68;

  /// Confirmation message for deleting a translation with locale and label
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the translation \"{locale}\" (\"{label}\")?'**
  String administrationMessaggeCustom69(Object locale, Object label);

  /// Success message after deleting a translation
  ///
  /// In en, this message translates to:
  /// **'Translation deleted'**
  String get administrationMessaggeCustom70;

  /// Page title: translations
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get administrationMessaggeCustom71;

  /// Message shown when there are no translations
  ///
  /// In en, this message translates to:
  /// **'No translations configured (the default label will be used)'**
  String get administrationMessaggeCustom72;

  /// Informative line showing the default label used as fallback
  ///
  /// In en, this message translates to:
  /// **'Default label (fallback): \"{label}\"'**
  String administrationMessaggeCustom73(Object label);

  /// Dialog title for deleting a permission
  ///
  /// In en, this message translates to:
  /// **'Delete permission'**
  String get administrationMessaggeCustom74;

  /// Label for the button that creates a new permission
  ///
  /// In en, this message translates to:
  /// **'New Permission'**
  String get administrationMessaggeCustom75;

  /// Page title: Permissions
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get administrationMessaggeCustom76;

  /// Page subtitle for permissions
  ///
  /// In en, this message translates to:
  /// **'Permission codes and associated activities'**
  String get administrationMessaggeCustom77;

  /// Message shown when no permissions match the query
  ///
  /// In en, this message translates to:
  /// **'No permissions found'**
  String get administrationMessaggeCustom78;

  /// Hint text for the permissions search field
  ///
  /// In en, this message translates to:
  /// **'Search code or activity'**
  String get administrationMessaggeCustom79;

  /// Table header: permission code
  ///
  /// In en, this message translates to:
  /// **'Permission Code'**
  String get administrationMessaggeCustom80;

  /// Table header: activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get administrationMessaggeCustom81;

  /// Table header: actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get administrationMessaggeCustom82;

  /// Confirmation message to delete a permission including the code
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{code}\"?'**
  String administrationMessaggeCustom83(Object code);

  /// Success message after deleting a permission
  ///
  /// In en, this message translates to:
  /// **'Permission deleted'**
  String get administrationMessaggeCustom84;

  /// Success message: permission updated
  ///
  /// In en, this message translates to:
  /// **'Permission updated'**
  String get administrationMessageCustom85;

  /// Success message: permission created
  ///
  /// In en, this message translates to:
  /// **'Permission created'**
  String get administrationMessageCustom86;

  /// Page title: edit permission
  ///
  /// In en, this message translates to:
  /// **'Edit Permission'**
  String get administrationMessageCustom87;

  /// Subtitle for the permission form page
  ///
  /// In en, this message translates to:
  /// **'Permission code definition'**
  String get administrationMessageCustom88;

  /// Hint for the permission code field
  ///
  /// In en, this message translates to:
  /// **'e.g. competition.read, boulder.write'**
  String get administrationMessageCustom89;

  /// Helper text for the permission code field
  ///
  /// In en, this message translates to:
  /// **'Suggested format: resource.action'**
  String get administrationMessageCustom90;

  /// Hint for the activity field
  ///
  /// In en, this message translates to:
  /// **'e.g. Read competitions list'**
  String get administrationMessageCustom91;

  /// Helper text for the activity field
  ///
  /// In en, this message translates to:
  /// **'Human-readable description of the permission'**
  String get administrationMessageCustom92;

  /// Generic error message with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String administrationMessageCustom27(Object error);

  /// Page title: Users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get administrationMessageCustom93;

  /// Page subtitle: assign roles to users
  ///
  /// In en, this message translates to:
  /// **'Assign roles to registered users'**
  String get administrationMessageCustom94;

  /// Message shown when no users found
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get administrationMessageCustom95;

  /// Label for new user button
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get administrationMessageCustom96;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get administrationMessageCustom97;

  /// Tooltip/label for roles action
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get administrationMessageCustom98;

  /// Table header: Name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get administrationMessageCustom99;

  /// Table header: Email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get administrationMessageCustom100;

  /// Table header: Created at
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get administrationMessageCustom101;

  /// Table header: Password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get administrationMessageCustom102;

  /// Table header: Roles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get administrationMessageCustom103;

  /// Table header: Actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get administrationMessageCustom104;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get administrationMessageCustom105;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get administrationMessageCustom106;

  /// Error message during user creation
  ///
  /// In en, this message translates to:
  /// **'Creation error: {error}'**
  String administrationMessageCustom107(Object error);

  /// Error message during user deletion
  ///
  /// In en, this message translates to:
  /// **'Deletion error: {error}'**
  String administrationMessageCustom108(Object error);

  /// Appbar title for delete user page
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get administrationMessageCustom109;

  /// Label for last name field
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get administrationMessageCustom110;

  /// Validation message: required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get administrationMessageCustom111;

  /// Label for first name field
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get administrationMessageCustom112;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get administrationMessageCustom113;

  /// Validation message: email required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get administrationMessageCustom114;

  /// Validation message: invalid email format
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get administrationMessageCustom115;

  /// Label for create user button
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get administrationMessageCustom116;

  /// Title for user deletion view
  ///
  /// In en, this message translates to:
  /// **'Confirm user deletion'**
  String get administrationMessageCustom117;

  /// Label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get administrationMessageCustom118;

  /// Label for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get administrationMessageCustom119;

  /// Success message when profile roles are saved
  ///
  /// In en, this message translates to:
  /// **'Roles updated'**
  String get administrationMessageCustom120;

  /// Header for the assigned roles section
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED ROLES'**
  String get administrationMessageCustom121;

  /// Label for the button that saves assigned roles
  ///
  /// In en, this message translates to:
  /// **'Save Roles'**
  String get administrationMessageCustom122;

  /// Page title: Roles
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get administrationMessageCustom123;

  /// Page subtitle for roles
  ///
  /// In en, this message translates to:
  /// **'Manage application roles'**
  String get administrationMessageCustom124;

  /// Message shown when no roles exist
  ///
  /// In en, this message translates to:
  /// **'No roles configured'**
  String get administrationMessageCustom125;

  /// Label for button creating a new role
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get administrationMessageCustom126;

  /// Error message when loading roles fails
  ///
  /// In en, this message translates to:
  /// **'Error loading roles: {error}'**
  String administrationMessageCustom127(Object error);

  /// Dialog title for deleting a role
  ///
  /// In en, this message translates to:
  /// **'Delete role'**
  String get administrationMessageCustom128;

  /// Confirmation message for deleting a role with role name
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the role \"{name}\"?\nAll users and associated menus will lose this role.'**
  String administrationMessageCustom129(Object name);

  /// Success message after role deletion
  ///
  /// In en, this message translates to:
  /// **'Role deleted'**
  String get administrationMessageCustom130;

  /// Error message when role deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {error}'**
  String administrationMessageCustom131(Object error);

  /// Table header: Code
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get administrationMessageCustom132;

  /// Table header: Name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get administrationMessageCustom133;

  /// Table header: Actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get administrationMessageCustom134;

  /// Success message: role updated
  ///
  /// In en, this message translates to:
  /// **'Role updated'**
  String get administrationMessageCustom135;

  /// Success message: role created
  ///
  /// In en, this message translates to:
  /// **'Role created'**
  String get administrationMessageCustom136;

  /// Page title: edit role
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get administrationMessageCustom137;

  /// Page title: new role
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get administrationMessageCustom138;

  /// Subtitle for role page
  ///
  /// In en, this message translates to:
  /// **'Application role data'**
  String get administrationMessageCustom139;

  /// Hint for role code field
  ///
  /// In en, this message translates to:
  /// **'e.g. admin, athlete, judge'**
  String get administrationMessageCustom140;

  /// Helper text for role code field
  ///
  /// In en, this message translates to:
  /// **'Unique identifier, lowercase letters and underscore only'**
  String get administrationMessageCustom141;

  /// Validation message for role code format
  ///
  /// In en, this message translates to:
  /// **'Only lowercase letters and underscore are allowed'**
  String get administrationMessageCustom142;

  /// Hint for role name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Administrator, Athlete, Judge'**
  String get administrationMessageCustom143;

  /// Header: manage role with role name
  ///
  /// In en, this message translates to:
  /// **'Manage role: {name}'**
  String administrationMessageCustom144(Object name);

  /// Line showing the role code
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String administrationMessageCustom145(Object code);

  /// Tab label: Permissions
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get administrationMessageCustom146;

  /// Tab label: Menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get administrationMessageCustom147;

  /// Generic error message for loading
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String administrationMessageCustom148(Object error);

  /// Success message: permissions saved
  ///
  /// In en, this message translates to:
  /// **'Permissions saved'**
  String get administrationMessageCustom149;

  /// Error while saving permissions
  ///
  /// In en, this message translates to:
  /// **'Error saving permissions: {error}'**
  String administrationMessageCustom150(Object error);

  /// Success message: menus saved
  ///
  /// In en, this message translates to:
  /// **'Menus saved'**
  String get administrationMessageCustom151;

  /// Error while saving menus
  ///
  /// In en, this message translates to:
  /// **'Error saving menus: {error}'**
  String administrationMessageCustom152(Object error);

  /// Label for save permissions button
  ///
  /// In en, this message translates to:
  /// **'Save Permissions'**
  String get administrationMessageCustom153;

  /// Label for save menus button
  ///
  /// In en, this message translates to:
  /// **'Save Menus'**
  String get administrationMessageCustom154;

  /// Hint for the global search bar
  ///
  /// In en, this message translates to:
  /// **'Search competitions, athletes…'**
  String get administrationMessageCustom155;

  /// Message shown when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String administrationMessageCustom156(Object query);

  /// Page title: Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get administrationMessageCustom157;

  /// Dashboard page subtitle
  ///
  /// In en, this message translates to:
  /// **'Competition overview'**
  String get administrationMessageCustom158;

  /// Tooltip for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get administrationMessageCustom159;

  /// Title shown when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get administrationMessageCustom160;

  /// Label for retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get administrationMessageCustom161;

  /// Dashboard card title: Competitions
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get administrationMessageCustom162;

  /// Dashboard card title: Athletes
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get administrationMessageCustom163;

  /// Dashboard card title: Boulders
  ///
  /// In en, this message translates to:
  /// **'Boulders'**
  String get administrationMessageCustom164;

  /// Dashboard card title: Ascents
  ///
  /// In en, this message translates to:
  /// **'Ascents'**
  String get administrationMessageCustom165;

  /// Search result type: Competition
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get administrationMessageCustom166;

  /// Search result type: Athlete
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get administrationMessageCustom167;

  /// Search result type: Boulder
  ///
  /// In en, this message translates to:
  /// **'Boulder'**
  String get administrationMessageCustom168;

  /// Search result type: Ascent
  ///
  /// In en, this message translates to:
  /// **'Ascent'**
  String get administrationMessageCustom169;

  /// Page title: import CSV details
  ///
  /// In en, this message translates to:
  /// **'Import CSV details'**
  String get importMessageCustom1;

  /// Chip: total import rows
  ///
  /// In en, this message translates to:
  /// **'Total {total}'**
  String importMessageCustom3(Object total);

  /// Chip: inserted rows
  ///
  /// In en, this message translates to:
  /// **'Inserted {inserted}'**
  String importMessageCustom4(Object inserted);

  /// Chip: discarded rows
  ///
  /// In en, this message translates to:
  /// **'Discarded {discarded}'**
  String importMessageCustom5(Object discarded);

  /// Switch: show only discarded rows
  ///
  /// In en, this message translates to:
  /// **'Show only discarded'**
  String get importMessageCustom6;

  /// Message when there are no rows to show
  ///
  /// In en, this message translates to:
  /// **'No rows found'**
  String get importMessageCustom7;

  /// Row status: inserted
  ///
  /// In en, this message translates to:
  /// **'Inserted'**
  String get importMessageCustom8;

  /// Row status: discarded
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get importMessageCustom9;

  /// Row subtitle with number
  ///
  /// In en, this message translates to:
  /// **'Row {number}'**
  String importMessageCustom10(Object number);

  /// Header for the CSV row section
  ///
  /// In en, this message translates to:
  /// **'CSV row'**
  String get importMessageCustom11;

  /// Header for the discard reason section
  ///
  /// In en, this message translates to:
  /// **'Discard reason'**
  String get importMessageCustom12;

  /// Page title: CSV imports
  ///
  /// In en, this message translates to:
  /// **'CSV Imports'**
  String get importMessageCustom13;

  /// Message shown when no imports are available
  ///
  /// In en, this message translates to:
  /// **'No import found'**
  String get importMessageCustom14;

  /// Table header: import date
  ///
  /// In en, this message translates to:
  /// **'Import date'**
  String get importMessageCustom15;

  /// Table header: competition
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get importMessageCustom16;

  /// Table header: file
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get importMessageCustom17;

  /// Table header: total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get importMessageCustom18;

  /// Table header: inserted
  ///
  /// In en, this message translates to:
  /// **'Inserted'**
  String get importMessageCustom19;

  /// Table header: discarded
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get importMessageCustom20;

  /// Table header: status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get importMessageCustom21;

  /// Table header / tooltip: detail
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get importMessageCustom22;

  /// Page title: final ranking with competition name
  ///
  /// In en, this message translates to:
  /// **'Final ranking - {competition}'**
  String rankingMessageCustom1(Object competition);

  /// Tooltip for export PDF
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get rankingMessageCustom2;

  /// Hint for ranking search
  ///
  /// In en, this message translates to:
  /// **'Search bib, last name, first name...'**
  String get rankingMessageCustom3;

  /// Message shown when ranking is empty
  ///
  /// In en, this message translates to:
  /// **'No athletes in ranking'**
  String get rankingMessageCustom4;

  /// Filter label: male
  ///
  /// In en, this message translates to:
  /// **'Male ranking'**
  String get rankingMessageCustom5;

  /// Filter label: female
  ///
  /// In en, this message translates to:
  /// **'Female ranking'**
  String get rankingMessageCustom6;

  /// Filter label: overall
  ///
  /// In en, this message translates to:
  /// **'Overall ranking'**
  String get rankingMessageCustom7;

  /// Label for Top attempts with placeholder
  ///
  /// In en, this message translates to:
  /// **'Top ({attempts})'**
  String rankingMessageCustom8(Object attempts);

  /// Label for Zone attempts with placeholder
  ///
  /// In en, this message translates to:
  /// **'Zone ({attempts})'**
  String rankingMessageCustom9(Object attempts);

  /// Error message when loading ranking fails
  ///
  /// In en, this message translates to:
  /// **'Error loading ranking: {error}'**
  String rankingMessageCustom10(Object error);

  /// Error message when PDF export fails
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF: {error}'**
  String rankingMessageCustom11(Object error);

  /// Error message when updating competition
  ///
  /// In en, this message translates to:
  /// **'Update error: {error}'**
  String rankingMessageCustom12(Object error);

  /// Page title: Rankings
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankingMessageCustom13;

  /// Page subtitle: manage rankings
  ///
  /// In en, this message translates to:
  /// **'Manage rankings'**
  String get rankingMessageCustom14;

  /// Search hint for competitions
  ///
  /// In en, this message translates to:
  /// **'Search competition'**
  String get rankingMessageCustom15;

  /// Filter chip: only open competitions
  ///
  /// In en, this message translates to:
  /// **'Only open'**
  String get rankingMessageCustom16;

  /// Message when no competitions are found
  ///
  /// In en, this message translates to:
  /// **'No competitions found'**
  String get rankingMessageCustom17;

  /// Button label: qualifications
  ///
  /// In en, this message translates to:
  /// **'Qualifications ranking'**
  String get rankingMessageCustom18;

  /// Button label: final
  ///
  /// In en, this message translates to:
  /// **'Final ranking'**
  String get rankingMessageCustom19;

  /// Button label: top and zone
  ///
  /// In en, this message translates to:
  /// **'Top & Zone ranking'**
  String get rankingMessageCustom20;

  /// Table header: description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get rankingMessageCustom21;

  /// Table header: competition date
  ///
  /// In en, this message translates to:
  /// **'Competition date'**
  String get rankingMessageCustom22;

  /// Table header: status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get rankingMessageCustom23;

  /// Table header: qualifications
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get rankingMessageCustom24;

  /// Table header: final
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get rankingMessageCustom25;

  /// Table header: top & zone
  ///
  /// In en, this message translates to:
  /// **'Top & Zone'**
  String get rankingMessageCustom26;

  /// Tooltip: reopen competition
  ///
  /// In en, this message translates to:
  /// **'Tap to reopen competition'**
  String get rankingMessageCustom27;

  /// Tooltip: close competition
  ///
  /// In en, this message translates to:
  /// **'Tap to close competition'**
  String get rankingMessageCustom28;

  /// Status label: closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get rankingMessageCustom29;

  /// Status label: open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get rankingMessageCustom30;

  /// Page title: qualifications ranking with competition name
  ///
  /// In en, this message translates to:
  /// **'Qualifications ranking - {competition}'**
  String rankingMessageCustom31(Object competition);

  /// Label: Top
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get rankingMessageCustom32;

  /// Unit: points
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get rankingMessageCustom33;

  /// Page title: top & zone ranking with competition name
  ///
  /// In en, this message translates to:
  /// **'Top & Zone ranking - {competition}'**
  String rankingMessageCustom34(Object competition);

  /// PDF section title: Male ranking
  ///
  /// In en, this message translates to:
  /// **'Male ranking'**
  String get rankingMessageCustom35;

  /// PDF section title: Female ranking
  ///
  /// In en, this message translates to:
  /// **'Female ranking'**
  String get rankingMessageCustom36;

  /// PDF section title: Overall ranking
  ///
  /// In en, this message translates to:
  /// **'Overall ranking'**
  String get rankingMessageCustom37;

  /// Statistic label: athletes
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get rankingMessageCustom38;

  /// Statistic label: finalists
  ///
  /// In en, this message translates to:
  /// **'Finalists'**
  String get rankingMessageCustom39;

  /// Message when no athletes in section
  ///
  /// In en, this message translates to:
  /// **'No athletes in this category'**
  String get rankingMessageCustom40;

  /// Legend for finalists with placeholder
  ///
  /// In en, this message translates to:
  /// **'Green bib = athlete qualified to final (first {nr})'**
  String rankingMessageCustom41(Object nr);

  /// Branding footer
  ///
  /// In en, this message translates to:
  /// **'Boulder Competition Management'**
  String get rankingMessageCustom42;

  /// PDF generation date label
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String rankingMessageCustom43(Object date);

  /// PDF page numbering
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String rankingMessageCustom44(Object page, Object count);

  /// Table header: position
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get rankingMessageCustom45;

  /// Table header: bib (abbrev.)
  ///
  /// In en, this message translates to:
  /// **'Bib'**
  String get rankingMessageCustom46;

  /// Table header: last name and first name
  ///
  /// In en, this message translates to:
  /// **'Last name · First name'**
  String get rankingMessageCustom47;

  /// Table header: sex
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get rankingMessageCustom48;

  /// Table header: club
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get rankingMessageCustom49;

  /// Table header: attempts top
  ///
  /// In en, this message translates to:
  /// **'Attempts Top'**
  String get rankingMessageCustom51;

  /// Table header: zones
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get rankingMessageCustom52;

  /// Table header: attempts zone
  ///
  /// In en, this message translates to:
  /// **'Attempts Zone'**
  String get rankingMessageCustom53;

  /// Podium legend: first place
  ///
  /// In en, this message translates to:
  /// **'1st place'**
  String get rankingMessageCustom54;

  /// Podium legend: second place
  ///
  /// In en, this message translates to:
  /// **'2nd place'**
  String get rankingMessageCustom55;

  /// Podium legend: third place
  ///
  /// In en, this message translates to:
  /// **'3rd place'**
  String get rankingMessageCustom56;

  /// Sex: male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get rankingMessageCustom57;

  /// Sex: female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get rankingMessageCustom58;

  /// Page title: Email templates
  ///
  /// In en, this message translates to:
  /// **'Email templates'**
  String get emailMessageCustom1;

  /// Tooltip refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get emailMessageCustom2;

  /// FAB / dialog title: New template
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get emailMessageCustom3;

  /// Error opening template
  ///
  /// In en, this message translates to:
  /// **'Unable to open template: {error}'**
  String emailMessageCustom4(Object error);

  /// Error creating draft
  ///
  /// In en, this message translates to:
  /// **'Unable to create draft: {error}'**
  String emailMessageCustom5(Object error);

  /// Error loading list
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String emailMessageCustom6(Object error);

  /// Empty list message
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any email templates yet.'**
  String get emailMessageCustom7;

  /// Button label: Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get emailMessageCustom8;

  /// Button label: Create draft
  ///
  /// In en, this message translates to:
  /// **'Create draft'**
  String get emailMessageCustom9;

  /// Template code field label
  ///
  /// In en, this message translates to:
  /// **'Code, e.g. WELCOME'**
  String get emailMessageCustom11;

  /// Validator: code format
  ///
  /// In en, this message translates to:
  /// **'Use uppercase letters, numbers and _.'**
  String get emailMessageCustom12;

  /// Language field label
  ///
  /// In en, this message translates to:
  /// **'Language, e.g. it or en-US'**
  String get emailMessageCustom13;

  /// Validator: language format
  ///
  /// In en, this message translates to:
  /// **'Invalid language format.'**
  String get emailMessageCustom14;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Internal description'**
  String get emailMessageCustom15;

  /// Placeholder for empty subject
  ///
  /// In en, this message translates to:
  /// **'No subject'**
  String get emailMessageCustom16;

  /// Status label: active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get emailMessageCustom18;

  /// Status label: draft
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get emailMessageCustom19;

  /// Status label: unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get emailMessageCustom20;

  /// AppBar title: code · language · version
  ///
  /// In en, this message translates to:
  /// **'{code} · {language} · v{version}'**
  String emailMessageCustom21(Object code, Object language, Object version);

  /// Button label: save draft
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get emailMessageCustom22;

  /// Button label: publish
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get emailMessageCustom23;

  /// Card title: published version
  ///
  /// In en, this message translates to:
  /// **'Published version'**
  String get emailMessageCustom24;

  /// Card subtitle when viewing published version
  ///
  /// In en, this message translates to:
  /// **'Saving will automatically create a new draft.'**
  String get emailMessageCustom25;

  /// Subject field label
  ///
  /// In en, this message translates to:
  /// **'Email subject'**
  String get emailMessageCustom26;

  /// Validator: subject required
  ///
  /// In en, this message translates to:
  /// **'Subject is required.'**
  String get emailMessageCustom27;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Internal description'**
  String get emailMessageCustom28;

  /// Variables panel title
  ///
  /// In en, this message translates to:
  /// **'Dynamic variables'**
  String get emailMessageCustom29;

  /// Button label: add variable
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get emailMessageCustom30;

  /// Empty variables message
  ///
  /// In en, this message translates to:
  /// **'No variables. You can still write a static email.'**
  String get emailMessageCustom31;

  /// Section title: email body
  ///
  /// In en, this message translates to:
  /// **'Email body'**
  String get emailMessageCustom32;

  /// Button label: upload image
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get emailMessageCustom33;

  /// Quill placeholder
  ///
  /// In en, this message translates to:
  /// **'Write the email content…'**
  String get emailMessageCustom34;

  /// Paragraph explaining variables
  ///
  /// In en, this message translates to:
  /// **'Text variables are inserted as {token}. For a dynamic link, create a URL variable and use {token} in the link URL field.'**
  String emailMessageCustom35(Object token);

  /// Save success message
  ///
  /// In en, this message translates to:
  /// **'Draft v{version} saved.'**
  String emailMessageCustom36(Object version);

  /// Publish dialog title
  ///
  /// In en, this message translates to:
  /// **'Publish version'**
  String get emailMessageCustom37;

  /// Publish dialog content
  ///
  /// In en, this message translates to:
  /// **'The previous active version for this language will be archived. Do you also want to set this language as default?'**
  String get emailMessageCustom38;

  /// Dialog button: No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get emailMessageCustom39;

  /// Dialog button: Yes, publish
  ///
  /// In en, this message translates to:
  /// **'Yes, publish'**
  String get emailMessageCustom40;

  /// Message: save first before inserting image
  ///
  /// In en, this message translates to:
  /// **'Save first: a new draft will be created to associate the image with.'**
  String get emailMessageCustom41;

  /// Image uploaded message
  ///
  /// In en, this message translates to:
  /// **'Image uploaded and inserted into the editor.'**
  String get emailMessageCustom42;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {error}'**
  String emailMessageCustom43(Object error);

  /// Undefined variables error
  ///
  /// In en, this message translates to:
  /// **'Undeclared variables: {list}'**
  String emailMessageCustom44(Object list);

  /// Duplicate variable message
  ///
  /// In en, this message translates to:
  /// **'This variable is already present.'**
  String get emailMessageCustom45;

  /// New variable dialog title
  ///
  /// In en, this message translates to:
  /// **'New variable'**
  String get emailMessageCustom46;

  /// Edit variable dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit variable'**
  String get emailMessageCustom47;

  /// Variable label field
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get emailMessageCustom50;

  /// Validator: label required
  ///
  /// In en, this message translates to:
  /// **'Label is required.'**
  String get emailMessageCustom51;

  /// Variable type field
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get emailMessageCustom52;

  /// Switch label: required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get emailMessageCustom59;

  /// Default value field
  ///
  /// In en, this message translates to:
  /// **'Default value'**
  String get emailMessageCustom60;

  /// Example value field
  ///
  /// In en, this message translates to:
  /// **'Preview value'**
  String get emailMessageCustom61;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get emailMessageCustom62;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get emailMessageCustom63;

  /// Chip label: default template
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get emailMessageCustom17;

  /// Status label: archived
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get emailMessageCustom64;

  /// Message shown when activation fails due to invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Activation failed: invalid credentials'**
  String get athleteMessageCustom1;

  /// App title / name
  ///
  /// In en, this message translates to:
  /// **'Athlete Boulder'**
  String get athleteMessageCustom2;

  /// Tooltip / label for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get athleteMessageCustom3;

  /// Message shown when no menu items are configured for athlete
  ///
  /// In en, this message translates to:
  /// **'No menu items configured for your profile. Contact the event organizers.'**
  String get athleteMessageCustom4;

  /// Menu label: boulder registration
  ///
  /// In en, this message translates to:
  /// **'Boulder registration'**
  String get athleteMessageCustom5;

  /// Menu label: competition registration
  ///
  /// In en, this message translates to:
  /// **'Competition registration'**
  String get athleteMessageCustom6;

  /// Menu label: competition check-in
  ///
  /// In en, this message translates to:
  /// **'Competition check-in'**
  String get athleteMessageCustom7;

  /// Label: coming soon
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get athleteMessageCustom8;

  /// Greeting: morning
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get athleteMessageCustom9;

  /// Greeting: afternoon
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get athleteMessageCustom10;

  /// Greeting: evening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get athleteMessageCustom11;

  /// Page title: athlete registration
  ///
  /// In en, this message translates to:
  /// **'Athlete registration'**
  String get athleteMessageCustom12;

  /// Page subtitle: registration
  ///
  /// In en, this message translates to:
  /// **'Create your account to participate'**
  String get athleteMessageCustom13;

  /// Label field: family name / surname
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get athleteMessageCustom14;

  /// Label field: given name / first name
  ///
  /// In en, this message translates to:
  /// **'Given name'**
  String get athleteMessageCustom15;

  /// Label field: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get athleteMessageCustom16;

  /// Validator: required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get athleteMessageCustom17;

  /// Validator: email required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get athleteMessageCustom18;

  /// Validator: invalid email format
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get athleteMessageCustom19;

  /// Message shown when email already registered
  ///
  /// In en, this message translates to:
  /// **'User already registered'**
  String get athleteMessageCustom20;

  /// Dialog title: registration completed
  ///
  /// In en, this message translates to:
  /// **'Registration completed'**
  String get athleteMessageCustom21;

  /// Dialog content: registration completed
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully. Check your email for the initial password.'**
  String get athleteMessageCustom22;

  /// Button label: OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get athleteMessageCustom23;

  /// Button label: register
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get athleteMessageCustom24;

  /// Link text: already have account
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get athleteMessageCustom25;

  /// Error message when registration fails
  ///
  /// In en, this message translates to:
  /// **'Registration error: {error}'**
  String athleteMessageCustom26(Object error);

  /// App name / title shown on login page
  ///
  /// In en, this message translates to:
  /// **'Boulder Competition'**
  String get athleteMessageCustom27;

  /// Subtitle on login page
  ///
  /// In en, this message translates to:
  /// **'Athlete sign in'**
  String get athleteMessageCustom28;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get athleteMessageCustom29;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get athleteMessageCustom30;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get athleteMessageCustom31;

  /// Change password link label
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get athleteMessageCustom32;

  /// Registration link label
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get athleteMessageCustom33;

  /// Login error message shown in snackbar
  ///
  /// In en, this message translates to:
  /// **'Login error: {error}'**
  String athleteMessageCustom34(Object error);

  /// AppBar title: change password
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get athleteMessageCustom35;

  /// Heading: set a new password
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get athleteMessageCustom36;

  /// Label: current password
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get athleteMessageCustom37;

  /// Label: new password
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get athleteMessageCustom38;

  /// Label: confirm password
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get athleteMessageCustom39;

  /// Button label: save password
  ///
  /// In en, this message translates to:
  /// **'SAVE PASSWORD'**
  String get athleteMessageCustom40;

  /// Validation: enter email
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get athleteMessageCustom41;

  /// Validation: enter current password
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get athleteMessageCustom42;

  /// Validation: new password length
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get athleteMessageCustom43;

  /// Validation: passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get athleteMessageCustom44;

  /// Success message: password changed
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get athleteMessageCustom46;

  /// Error: user not authenticated
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get athleteMessageCustom47;

  /// Error when password change fails
  ///
  /// In en, this message translates to:
  /// **'Password change error: {error}'**
  String athleteMessageCustom48(Object error);

  /// Loading error
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String athleteMessageCustom49(Object error);

  /// No open competition
  ///
  /// In en, this message translates to:
  /// **'No competitions with open registrations at the moment'**
  String get athleteMessageCustom50;

  /// Message: already registered
  ///
  /// In en, this message translates to:
  /// **'Registration already present, check your email inbox'**
  String get athleteMessageCustom51;

  /// Message: max registrations reached
  ///
  /// In en, this message translates to:
  /// **'Maximum number of registrations reached for this competition'**
  String get athleteMessageCustom52;

  /// Message: select a turn
  ///
  /// In en, this message translates to:
  /// **'Select a turn'**
  String get athleteMessageCustom53;

  /// Message: first turn full
  ///
  /// In en, this message translates to:
  /// **'First turn is full, please choose another option'**
  String get athleteMessageCustom54;

  /// Message: second turn full
  ///
  /// In en, this message translates to:
  /// **'Second turn is full, please choose another option'**
  String get athleteMessageCustom55;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String athleteMessageCustom56(Object error);

  /// Dialog title: registration completed
  ///
  /// In en, this message translates to:
  /// **'Registration completed'**
  String get athleteMessageCustom57;

  /// Dialog content: registration recorded
  ///
  /// In en, this message translates to:
  /// **'Your registration has been recorded. You will receive a confirmation email.'**
  String get athleteMessageCustom58;

  /// Button label: back to home
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get athleteMessageCustom59;

  /// Page title with competition and date
  ///
  /// In en, this message translates to:
  /// **'{competition} · Date: {date}'**
  String athleteMessageCustom60(Object competition, Object date);

  /// Page title: competition registration
  ///
  /// In en, this message translates to:
  /// **'Competition registration'**
  String get athleteMessageCustom61;

  /// Label: family name / surname
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get athleteMessageCustom63;

  /// Label: given name / first name
  ///
  /// In en, this message translates to:
  /// **'Given name'**
  String get athleteMessageCustom64;

  /// Label: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get athleteMessageCustom65;

  /// Label: date of birth
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get athleteMessageCustom66;

  /// Label: sex
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get athleteMessageCustom67;

  /// Label: club (optional)
  ///
  /// In en, this message translates to:
  /// **'Club (optional)'**
  String get athleteMessageCustom68;

  /// Label: bib
  ///
  /// In en, this message translates to:
  /// **'Bib'**
  String get athleteMessageCustom69;

  /// Label: first turn
  ///
  /// In en, this message translates to:
  /// **'First turn'**
  String get athleteMessageCustom71;

  /// Label: second turn
  ///
  /// In en, this message translates to:
  /// **'Second turn'**
  String get athleteMessageCustom72;

  /// Subtitle when turns not active
  ///
  /// In en, this message translates to:
  /// **'Turn management not active for this competition'**
  String get athleteMessageCustom73;

  /// Subtitle when turn is full
  ///
  /// In en, this message translates to:
  /// **'Turn full'**
  String get athleteMessageCustom74;

  /// Button label: create registration
  ///
  /// In en, this message translates to:
  /// **'Create registration'**
  String get athleteMessageCustom75;

  /// Label: Competition (for recap)
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get athleteMessageCustom76;

  /// Label: Date (for recap)
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get athleteMessageCustom77;

  /// Label: Turn (for recap)
  ///
  /// In en, this message translates to:
  /// **'Turn'**
  String get athleteMessageCustom78;

  /// Title / tooltip: competition check-in
  ///
  /// In en, this message translates to:
  /// **'Competition check-in'**
  String get athleteMessageCustom79;

  /// Instruction to perform check-in
  ///
  /// In en, this message translates to:
  /// **'Tap the icon in the top-left to perform check-in'**
  String get athleteMessageCustom80;

  /// Message when there are no competitions in progress
  ///
  /// In en, this message translates to:
  /// **'No competitions in progress at the moment'**
  String get athleteMessageCustom81;

  /// Fallback title when no competition
  ///
  /// In en, this message translates to:
  /// **'Boulder registration'**
  String get athleteMessageCustom82;

  /// Message shown when competition closed or athlete not checked-in
  ///
  /// In en, this message translates to:
  /// **'Competition closed or athlete not checked-in'**
  String get athleteMessageCustom83;

  /// Page title: my boulders
  ///
  /// In en, this message translates to:
  /// **'My boulders'**
  String get athleteMessageCustom84;

  /// Tooltip: open QR scanner to register a boulder
  ///
  /// In en, this message translates to:
  /// **'Register boulder (scan QR)'**
  String get athleteMessageCustom85;

  /// Label: competition
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get athleteMessageCustom86;

  /// Filter: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get athleteMessageCustom87;

  /// Filter: todo
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get athleteMessageCustom88;

  /// Filter: done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get athleteMessageCustom89;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty {difficulty}'**
  String athleteMessageCustom90(Object difficulty);

  /// Status: done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get athleteMessageCustom92;

  /// Status: todo
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get athleteMessageCustom93;

  /// Tooltip: mark as done
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get athleteMessageCustom94;

  /// Tooltip: undo / cancel
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get athleteMessageCustom95;

  /// Message: invalid QR
  ///
  /// In en, this message translates to:
  /// **'QR code not valid for this app'**
  String get athleteMessageCustom96;

  /// Dialog title: boulder successfully registered
  ///
  /// In en, this message translates to:
  /// **'Boulder registered'**
  String get athleteMessageCustom97;

  /// Dialog title: attention / error
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get athleteMessageCustom98;

  /// Button label: OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get athleteMessageCustom99;

  /// AppBar title: boulder scanner
  ///
  /// In en, this message translates to:
  /// **'Register boulder'**
  String get athleteMessageCustom100;

  /// Text shown while processing the scan
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get athleteMessageCustom101;

  /// Instruction for scanning the QR
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR below the boulder'**
  String get athleteMessageCustom102;

  /// Fallback title when camera unavailable
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get athleteMessageCustom103;

  /// Fallback explanation: camera not available
  ///
  /// In en, this message translates to:
  /// **'The iOS Simulator doesn\'t have a real camera. This feature requires a physical device to scan the boulder QR code.'**
  String get athleteMessageCustom104;

  /// Label for back button in fallback view
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get athleteMessageCustom105;

  /// Dialog title: check-in completed
  ///
  /// In en, this message translates to:
  /// **'Check-in completed'**
  String get athleteMessageCustom106;

  /// Instruction: point the camera at the competition QR
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the competition QR'**
  String get athleteMessageCustom107;

  /// Message: check-in requires a device with a camera
  ///
  /// In en, this message translates to:
  /// **'To perform check-in you need a device with a camera.'**
  String get athleteMessageCustom108;

  /// Custom competition message 40
  ///
  /// In en, this message translates to:
  /// **'Do you want to create categories from a template?'**
  String get competitionMessageCustom40;

  /// Custom competition message 41
  ///
  /// In en, this message translates to:
  /// **'Category template'**
  String get competitionMessageCustom41;

  /// Custom competition message 42
  ///
  /// In en, this message translates to:
  /// **'Select a category template'**
  String get competitionMessageCustom42;

  /// Unable to determine the athlete's category.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine the athlete category.'**
  String get athleteMessageCustom109;

  /// No category available for the athlete's age and gender.
  ///
  /// In en, this message translates to:
  /// **'No category available for the athlete\'s age and gender.'**
  String get athleteMessageCustom110;

  /// General
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get rankingMessageCustom59;

  /// Categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get rankingMessageCustom60;

  /// Category template management title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get administrationMessageCustom170;

  /// Category template management description
  ///
  /// In en, this message translates to:
  /// **'Manage category templates'**
  String get administrationMessageCustom171;

  /// Category template page title
  ///
  /// In en, this message translates to:
  /// **'Category templates'**
  String get categoryTemplateMessageCustom1;

  /// Refresh list tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get categoryTemplateMessageCustom2;

  /// New template action
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get categoryTemplateMessageCustom3;

  /// Loading error
  ///
  /// In en, this message translates to:
  /// **'Loading error: {error}'**
  String categoryTemplateMessageCustom4(Object error);

  /// Empty list
  ///
  /// In en, this message translates to:
  /// **'You have not created any category templates yet.'**
  String get categoryTemplateMessageCustom5;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryTemplateMessageCustom6;

  /// Name validation
  ///
  /// In en, this message translates to:
  /// **'The name is required.'**
  String get categoryTemplateMessageCustom7;

  /// Cancel dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoryTemplateMessageCustom8;

  /// Confirm creation
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get categoryTemplateMessageCustom9;

  /// Edit dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get categoryTemplateMessageCustom10;

  /// Save edit
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get categoryTemplateMessageCustom11;

  /// Creation confirmation
  ///
  /// In en, this message translates to:
  /// **'Template created.'**
  String get categoryTemplateMessageCustom12;

  /// Creation error
  ///
  /// In en, this message translates to:
  /// **'Unable to create the template: {error}'**
  String categoryTemplateMessageCustom13(Object error);

  /// Update confirmation
  ///
  /// In en, this message translates to:
  /// **'Template updated.'**
  String get categoryTemplateMessageCustom14;

  /// Update error
  ///
  /// In en, this message translates to:
  /// **'Unable to update the template: {error}'**
  String categoryTemplateMessageCustom15(Object error);

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get categoryTemplateMessageCustom16;

  /// Deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the \"{nome}\" template?'**
  String categoryTemplateMessageCustom17(Object nome);

  /// Confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryTemplateMessageCustom18;

  /// Deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Template deleted.'**
  String get categoryTemplateMessageCustom19;

  /// Deletion error
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the template: {error}'**
  String categoryTemplateMessageCustom20(Object error);

  /// Update date
  ///
  /// In en, this message translates to:
  /// **'Updated on {data}'**
  String categoryTemplateMessageCustom21(Object data);

  /// Edit icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get categoryTemplateMessageCustom22;

  /// Delete icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get categoryTemplateMessageCustom23;

  /// Categories icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get categoryTemplateMessageCustom24;

  /// Categories page title
  ///
  /// In en, this message translates to:
  /// **'Categories - {nomeTemplate}'**
  String categoryTemplateMessageCustom25(Object nomeTemplate);

  /// Refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get categoryTemplateMessageCustom26;

  /// Create action
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryTemplateMessageCustom27;

  /// Loading error
  ///
  /// In en, this message translates to:
  /// **'Loading error: {error}'**
  String categoryTemplateMessageCustom28(Object error);

  /// Empty list
  ///
  /// In en, this message translates to:
  /// **'There are no categories in this template.'**
  String get categoryTemplateMessageCustom29;

  /// Sex label
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get categoryTemplateMessageCustom30;

  /// Age label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get categoryTemplateMessageCustom31;

  /// Cancel dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoryTemplateMessageCustom32;

  /// Edit tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryTemplateMessageCustom33;

  /// Delete dialog title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryTemplateMessageCustom34;

  /// Deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the \"{nome}\" category?'**
  String categoryTemplateMessageCustom35(Object nome);

  /// Confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryTemplateMessageCustom36;

  /// Deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Category deleted.'**
  String get categoryTemplateMessageCustom37;

  /// Deletion error
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the category: {error}'**
  String categoryTemplateMessageCustom38(Object error);

  /// Male sex label
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get categoryTemplateMessageCustom39;

  /// Female sex label
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get categoryTemplateMessageCustom40;

  /// Tooltip / dialog title for duplicating a template
  ///
  /// In en, this message translates to:
  /// **'Duplicate template'**
  String get categoryTemplateMessageCustom41;

  /// Confirmation message when a template was duplicated successfully
  ///
  /// In en, this message translates to:
  /// **'Template duplicated.'**
  String get categoryTemplateMessageCustom42;

  /// Error message when duplication fails
  ///
  /// In en, this message translates to:
  /// **'Unable to duplicate the template: {error}'**
  String categoryTemplateMessageCustom43(Object error);

  /// Male sex label
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get categoryTemplateMessageCustom44;

  /// Female sex label
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get categoryTemplateMessageCustom45;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryTemplateMessageCustom46;

  /// Sex field label
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get categoryTemplateMessageCustom47;

  /// Minimum age label
  ///
  /// In en, this message translates to:
  /// **'Age min'**
  String get categoryTemplateMessageCustom48;

  /// Maximum age label
  ///
  /// In en, this message translates to:
  /// **'Age max'**
  String get categoryTemplateMessageCustom49;

  /// Order label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get categoryTemplateMessageCustom50;

  /// Validation required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get categoryTemplateMessageCustom51;

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to modify categories'**
  String get categoryTemplateMessageCustom52;

  /// Error when age ranges overlap
  ///
  /// In en, this message translates to:
  /// **'Age overlaps with another category'**
  String get categoryTemplateMessageCustom53;

  /// Error when min > max
  ///
  /// In en, this message translates to:
  /// **'Minimum age must be less than or equal to maximum age'**
  String get categoryTemplateMessageCustom54;

  /// New category page title
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryTemplateMessageCustom55;

  /// Edit category page title
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryTemplateMessageCustom56;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get categoryTemplateMessageCustom57;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get categoryTemplateMessageCustom58;

  /// Send Welcome Email
  ///
  /// In en, this message translates to:
  /// **'Send Welcome Email'**
  String get registrationMessageCustom42;

  /// Do you want to send welcome emails to the athletes?
  ///
  /// In en, this message translates to:
  /// **'Do you want to send welcome emails to the athletes?'**
  String get registrationMessageCustom43;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get registrationMessageCustom44;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get registrationMessageCustom45;

  /// Permission denied message title
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDeniedTitle;

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action'**
  String get permissionDeniedMessage;

  /// Button OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get permissionOk;

  /// Delete registration
  ///
  /// In en, this message translates to:
  /// **'Delete Registration'**
  String get registrationMessageCustom46;

  /// Registration deletion page title
  ///
  /// In en, this message translates to:
  /// **'Delete {cognome} {nome} from the registration for the competition {competitionName}?'**
  String registrationMessageCustom47(
    Object cognome,
    Object nome,
    Object competitionName,
  );

  /// Delete boulder
  ///
  /// In en, this message translates to:
  /// **'Delete Boulder'**
  String get boulderMessageCustom37;

  /// Confirmation message for deleting a boulder
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete boulder {numero}?'**
  String boulderMessageCustom38(Object numero);

  /// Error message displayed when attempting to delete a boulder with associated ascents
  ///
  /// In en, this message translates to:
  /// **'Unable to delete: there are recorded ascents associated with this boulder...'**
  String get boulderMessageCustom39;

  /// You do not have permission to change the status
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change the status'**
  String get rankingMessageCustom61;

  /// Error message displayed when attempting to delete a category with associated registrations
  ///
  /// In en, this message translates to:
  /// **'Unable to delete: there are registered ascents associated with this category...'**
  String get categoryMessageCustom16;

  /// Category deletion page title
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoryMessageCustom17;

  /// Confirmation message displayed when attempting to delete a category with associated registrations
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get categoryMessageCustom18;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics - {competition}'**
  String statisticsMessageCustom1(String competition);

  /// Athletes statistics section
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get statisticsMessageCustom2;

  /// Boulders statistics section
  ///
  /// In en, this message translates to:
  /// **'Boulders'**
  String get statisticsMessageCustom3;

  /// Categories statistics section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statisticsMessageCustom4;

  /// Message displayed when statistics data is not yet available
  ///
  /// In en, this message translates to:
  /// **'Data not yet available'**
  String get statisticsMessageCustom5;

  /// Error message displayed when statistics loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String statisticsMessageCustom6(String error);

  /// Registrations statistics section
  ///
  /// In en, this message translates to:
  /// **'Registrations'**
  String get statisticsMessageCustom7;

  /// Total number of registered athletes
  ///
  /// In en, this message translates to:
  /// **'Total registered athletes'**
  String get statisticsMessageCustom8;

  /// Total number of participants
  ///
  /// In en, this message translates to:
  /// **'Total participants'**
  String get statisticsMessageCustom9;

  /// Total number of registered male athletes
  ///
  /// In en, this message translates to:
  /// **'Registered males'**
  String get statisticsMessageCustom10;

  /// Total number of registered female athletes
  ///
  /// In en, this message translates to:
  /// **'Registered females'**
  String get statisticsMessageCustom11;

  /// Total number of male participants
  ///
  /// In en, this message translates to:
  /// **'Male participants'**
  String get statisticsMessageCustom12;

  /// Total number of female participants
  ///
  /// In en, this message translates to:
  /// **'Female participants'**
  String get statisticsMessageCustom13;

  /// Registration source statistics section
  ///
  /// In en, this message translates to:
  /// **'Registration sources'**
  String get statisticsMessageCustom14;

  /// Registrations created by an administrator
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get statisticsMessageCustom15;

  /// Registrations created directly by the athlete
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get statisticsMessageCustom16;

  /// Registrations created through data import
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get statisticsMessageCustom17;

  /// Athlete demographic records section
  ///
  /// In en, this message translates to:
  /// **'Demographic records'**
  String get statisticsMessageCustom18;

  /// Youngest male athlete
  ///
  /// In en, this message translates to:
  /// **'Youngest athlete (M)'**
  String get statisticsMessageCustom19;

  /// Youngest female athlete
  ///
  /// In en, this message translates to:
  /// **'Youngest athlete (F)'**
  String get statisticsMessageCustom20;

  /// Oldest male athlete
  ///
  /// In en, this message translates to:
  /// **'Oldest athlete (M)'**
  String get statisticsMessageCustom21;

  /// Oldest female athlete
  ///
  /// In en, this message translates to:
  /// **'Oldest athlete (F)'**
  String get statisticsMessageCustom22;

  /// Bib number label
  ///
  /// In en, this message translates to:
  /// **'Bib number'**
  String get statisticsMessageCustom23;

  /// Club label
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get statisticsMessageCustom24;

  /// Date of birth label
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get statisticsMessageCustom25;

  /// Message displayed when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get statisticsMessageCustom26;

  /// Message displayed when no statistics are available for the competition
  ///
  /// In en, this message translates to:
  /// **'No statistics available for this competition'**
  String get statisticsMessageCustom27;

  /// Section title with the numerical summary of boulders in the Boulder tab
  ///
  /// In en, this message translates to:
  /// **'Boulder Overview'**
  String get statisticsMessageCustom28;

  /// Label of the card showing the total number of boulders in the competition
  ///
  /// In en, this message translates to:
  /// **'Total Boulders'**
  String get statisticsMessageCustom29;

  /// Label of the card showing the number of final boulders in the competition
  ///
  /// In en, this message translates to:
  /// **'Final Boulders'**
  String get statisticsMessageCustom30;

  /// Section title containing the detailed list of each boulder
  ///
  /// In en, this message translates to:
  /// **'Boulder Details'**
  String get statisticsMessageCustom31;

  /// Header of the individual boulder card displaying its number
  ///
  /// In en, this message translates to:
  /// **'Boulder No. {numero}'**
  String statisticsMessageCustom32(int numero);

  /// Chip displayed on the boulder card when the boulder belongs to the final round
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get statisticsMessageCustom33;

  /// Chip displayed on the boulder card when the boulder belongs to the qualification round
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get statisticsMessageCustom34;

  /// Label for the boulder difficulty value
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get statisticsMessageCustom35;

  /// Label for the boulder color/hold
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get statisticsMessageCustom36;

  /// Label for the total number of successful ascents on the boulder
  ///
  /// In en, this message translates to:
  /// **'Total Ascents'**
  String get statisticsMessageCustom37;

  /// Label for the number of successful ascents on the boulder by male athletes
  ///
  /// In en, this message translates to:
  /// **'Male Ascents'**
  String get statisticsMessageCustom38;

  /// Label for the number of successful ascents on the boulder by female athletes
  ///
  /// In en, this message translates to:
  /// **'Female Ascents'**
  String get statisticsMessageCustom39;

  /// Label for the theoretical value assigned to the boulder
  ///
  /// In en, this message translates to:
  /// **'Theoretical Value'**
  String get statisticsMessageCustom40;

  /// Label for the current recalculated value of the boulder based on ascents
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get statisticsMessageCustom41;

  /// Error message displayed in the Boulder tab when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading boulder statistics: {error}'**
  String statisticsMessageCustom42(String error);

  /// Section title with the numerical summary of categories in the Categories tab
  ///
  /// In en, this message translates to:
  /// **'Categories Overview'**
  String get statisticsMessageCustom43;

  /// Label of the card showing the total number of categories in the competition
  ///
  /// In en, this message translates to:
  /// **'Total Categories'**
  String get statisticsMessageCustom44;

  /// Label of the card showing the total number of registered athletes across all categories
  ///
  /// In en, this message translates to:
  /// **'Total Registered Athletes'**
  String get statisticsMessageCustom45;

  /// Label of the card showing the total number of participants across all categories
  ///
  /// In en, this message translates to:
  /// **'Total Participants'**
  String get statisticsMessageCustom46;

  /// Section title containing the detailed list of each category
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get statisticsMessageCustom47;

  /// Label for the number of registered athletes in a category card
  ///
  /// In en, this message translates to:
  /// **'Registered Athletes'**
  String get statisticsMessageCustom48;

  /// Label for the number of participating athletes in a category card
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get statisticsMessageCustom49;

  /// Chip displayed on a category card when it has no registered athletes
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get statisticsMessageCustom50;

  /// Error message displayed in the Categories tab when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading category statistics: {error}'**
  String statisticsMessageCustom51(String error);

  /// AppBar title of the athlete statistics page showing the list of competitions the athlete has participated in
  ///
  /// In en, this message translates to:
  /// **'My Competitions'**
  String get athleteMessageCustom111;

  /// Message displayed on the athlete statistics page when no competitions are found that the athlete has participated in
  ///
  /// In en, this message translates to:
  /// **'No competitions found'**
  String get athleteMessageCustom112;

  /// Chip displayed on a competition card in the athlete statistics page when the competition is still open (fl_gara_chiusa = false)
  ///
  /// In en, this message translates to:
  /// **'Competition Open'**
  String get athleteMessageCustom113;

  /// Chip displayed on a competition card in the athlete statistics page when the competition is closed (fl_gara_chiusa = true)
  ///
  /// In en, this message translates to:
  /// **'Competition Closed'**
  String get athleteMessageCustom114;

  /// Text displayed below the progress bar on a competition card in the athlete statistics page, indicating how many boulders the athlete has completed out of the competition total
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} boulders completed'**
  String athleteMessageCustom115(int completed, int total);

  /// Tooltip of the statistics icon on a competition card in the athlete statistics page
  ///
  /// In en, this message translates to:
  /// **'Statistics Details'**
  String get athleteMessageCustom116;

  /// Fallback AppBar title of the statistics details page, used when the competition description is not available
  ///
  /// In en, this message translates to:
  /// **'Statistics Details'**
  String get athleteMessageCustom117;

  /// Message displayed on the statistics details page when the athlete's ranking data is not available
  ///
  /// In en, this message translates to:
  /// **'Statistics not available'**
  String get athleteMessageCustom118;

  /// Label of the overall ranking card on the statistics details page
  ///
  /// In en, this message translates to:
  /// **'Overall Ranking'**
  String get athleteMessageCustom119;

  /// Label of the gender ranking card on the statistics details page
  ///
  /// In en, this message translates to:
  /// **'Gender Ranking'**
  String get athleteMessageCustom120;

  /// Label of the category ranking card on the statistics details page
  ///
  /// In en, this message translates to:
  /// **'Category Ranking'**
  String get athleteMessageCustom121;

  /// Title of the section listing completed boulders by color/difficulty on the statistics details page
  ///
  /// In en, this message translates to:
  /// **'Completed Boulders'**
  String get athleteMessageCustom122;

  /// Message displayed on the statistics details page when the athlete has not completed any boulders
  ///
  /// In en, this message translates to:
  /// **'No boulders completed'**
  String get athleteMessageCustom123;

  /// Badge displayed on a boulder card in the statistics details page, indicating how many boulders of that color/difficulty the athlete has completed
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String athleteMessageCustom124(int count);

  /// Error message shown to the administrator when attempting to remove the ADMIN role from the last profile that has it, an operation not allowed to prevent the system from being left without administrators
  ///
  /// In en, this message translates to:
  /// **'Operation blocked: at least one administrator must exist in the system'**
  String get administrationMessageLastAdminBlocked;

  /// Avviso: impossibile eliminare l'unico amministratore
  ///
  /// In en, this message translates to:
  /// **'This user cannot be deleted: it is the only administrator in the system.'**
  String get administrationMessageCustom172;

  /// Title of the banner displayed to the athlete when the competition ends.
  ///
  /// In en, this message translates to:
  /// **'Competition Ended'**
  String get notificationMessageCustom1;

  /// Message in the banner displayed to the athlete when the competition ends.
  ///
  /// In en, this message translates to:
  /// **'The competition has ended. It is no longer possible to record boulders.'**
  String get notificationMessageCustom2;

  /// Button to close the competition ended banner.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get notificationMessageCustom3;

  /// Title of the banner displayed to the athlete when the competition opens.
  ///
  /// In en, this message translates to:
  /// **'Competition Open'**
  String get notificationMessageCustom4;

  /// Message in the banner displayed to the athlete when the competition opens.
  ///
  /// In en, this message translates to:
  /// **'Your competition has started. You can now start recording boulders.'**
  String get notificationMessageCustom5;

  /// Button to open the boulder page after the competition opens.
  ///
  /// In en, this message translates to:
  /// **'OPEN COMPETITION'**
  String get notificationMessageCustom6;

  /// Default title for the competition open notification.
  ///
  /// In en, this message translates to:
  /// **'Competition open'**
  String get notificationMessageCustom7;

  /// Default message for the competition open notification.
  ///
  /// In en, this message translates to:
  /// **'The competition is open. You can record boulders.'**
  String get notificationMessageCustom8;

  /// Default title for the competition closed notification.
  ///
  /// In en, this message translates to:
  /// **'Competition closed'**
  String get notificationMessageCustom9;

  /// Default message for the competition closed notification.
  ///
  /// In en, this message translates to:
  /// **'The competition has ended. Boulders can no longer be recorded.'**
  String get notificationMessageCustom10;

  /// Default title for the finalist notification.
  ///
  /// In en, this message translates to:
  /// **'Qualified athlete'**
  String get notificationMessageCustom11;

  /// Default message for the finalist notification.
  ///
  /// In en, this message translates to:
  /// **'You qualified for the final.'**
  String get notificationMessageCustom12;

  /// Error shown when no open competition exists.
  ///
  /// In en, this message translates to:
  /// **'No open competition found.'**
  String get notificationMessageCustom13;

  /// Message shown when a notification has no recipients.
  ///
  /// In en, this message translates to:
  /// **'There are no recipients for this notification.'**
  String get notificationMessageCustom14;

  /// Title of the notification send confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm sending'**
  String get notificationMessageCustom15;

  /// Question in the notification send confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Send the notification to {count} athletes?'**
  String notificationMessageCustom16(Object count);

  /// Button to send a notification.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get notificationMessageCustom17;

  /// Notification sending result.
  ///
  /// In en, this message translates to:
  /// **'Sent: {count}.'**
  String notificationMessageCustom18(Object count);

  /// Error returned while sending the notification.
  ///
  /// In en, this message translates to:
  /// **'Error while sending: {error}'**
  String notificationMessageCustom19(Object error);

  /// Title of the administrative notifications page.
  ///
  /// In en, this message translates to:
  /// **'Athlete notifications'**
  String get notificationMessageCustom20;

  /// Number of athletes registered for the competition.
  ///
  /// In en, this message translates to:
  /// **'Registered athletes'**
  String get notificationMessageCustom21;

  /// Number of finalist athletes.
  ///
  /// In en, this message translates to:
  /// **'Finalists'**
  String get notificationMessageCustom22;

  /// Title of the competition open notification section.
  ///
  /// In en, this message translates to:
  /// **'Competition open'**
  String get notificationMessageCustom23;

  /// Title of the competition closed notification section.
  ///
  /// In en, this message translates to:
  /// **'Competition closed'**
  String get notificationMessageCustom24;

  /// Title of the finalist notification section.
  ///
  /// In en, this message translates to:
  /// **'Finalist athletes'**
  String get notificationMessageCustom25;

  /// Notification title field label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationMessageCustom26;

  /// Notification message field label.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notificationMessageCustom27;

  /// Notification recipient count.
  ///
  /// In en, this message translates to:
  /// **'Recipients: {count}'**
  String notificationMessageCustom28(Object count);

  /// Title of the banner shown to a qualified athlete.
  ///
  /// In en, this message translates to:
  /// **'Qualified for the final'**
  String get notificationMessageCustom29;

  /// Message of the banner shown to a qualified athlete.
  ///
  /// In en, this message translates to:
  /// **'You qualified for the final.'**
  String get notificationMessageCustom30;

  /// Error shown when no competition turn has been selected.
  ///
  /// In en, this message translates to:
  /// **'Select a turn.'**
  String get notificationMessageCustom31;

  /// Label for the first competition turn.
  ///
  /// In en, this message translates to:
  /// **'First turn'**
  String get notificationMessageCustom32;

  /// Label for the second competition turn.
  ///
  /// In en, this message translates to:
  /// **'Second turn'**
  String get notificationMessageCustom33;
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
