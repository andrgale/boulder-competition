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
  /// **'Search bib, lastname or given firstname...'**
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
