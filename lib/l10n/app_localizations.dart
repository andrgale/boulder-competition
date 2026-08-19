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
