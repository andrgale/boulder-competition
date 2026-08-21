// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get competitionDescription => 'Description';

  @override
  String get competitionDate => 'Date';

  @override
  String get boulderLabelNumber => 'Nr Boulder';

  @override
  String get competitionMessageCustom1 => 'Race Modification';

  @override
  String get competitionMessageCustom2 => 'New Race';

  @override
  String get competitionMessageCustom3 => 'Competition Management';

  @override
  String get competitionMessageCustom4 => 'Rescue...';

  @override
  String get competitionMessageCustom5 => 'Print QR code card';

  @override
  String get competitionMessageCustom6 => 'Required field';

  @override
  String get competitionMessageCustom7 => 'Nr Finalists';

  @override
  String get competitionMessageCustom8 => 'Nr Max Registrations';

  @override
  String get competitionMessageCustom9 => 'Slots Enabling';

  @override
  String get competitionMessageCustom10 => 'First Slot Registered';

  @override
  String get competitionMessageCustom11 => 'Second Slot Registered';

  @override
  String get competitionMessageCustom12 => 'Registration Fee';

  @override
  String get competitionMessageCustom13 => 'Notes';

  @override
  String get competitionMessageCustom14 => 'Registration closed';

  @override
  String get competitionMessageCustom15 => 'Competition closed';

  @override
  String get competitionMessageCustom16 => 'Attendance management';

  @override
  String get competitionMessageCustom17 => 'Payment management';

  @override
  String get competitionMessageCustom18 => 'Gift management';

  @override
  String get competitionMessageCustom19 => 'Error generating the QR badge:';

  @override
  String get competitionMessageCustom20 =>
      'You do not have permission to modify competitions';

  @override
  String get competitionMessageCustom21 => 'Please select the competition date';

  @override
  String get competitionMessageCustom22 =>
      'Enter a maximum number of registrations greater than 0';

  @override
  String get competitionMessageCustom23 =>
      'The total number of registrations for the first and second time slots cannot exceed the maximum number of registrations';

  @override
  String get competitionMessageCustom24 => 'Competition updated';

  @override
  String get competitionMessageCustom25 => 'Competition created';

  @override
  String get competitionMessageCustom26 => 'Delete Competition';

  @override
  String get competitionMessageCustom27 => 'Delete';

  @override
  String get competitionMessageCustom28 =>
      'An open competition already exists: close it before creating a new one.';

  @override
  String get competitionMessageCustom29 => 'Competitions';

  @override
  String get competitionMessageCustom30 =>
      'Close the open competition before creating a new one';

  @override
  String get competitionMessageCustom31 => 'Search Competition';

  @override
  String get competitionMessageCustom32 => 'Open Competitions Only';

  @override
  String get competitionMessageCustom33 => 'No Competitions';

  @override
  String get competitionMessageCustom34 => 'Closed';

  @override
  String get competitionMessageCustom35 => 'Open';

  @override
  String get competitionMessageCustom36 => 'Status';

  @override
  String get competitionMessageCustom37 => 'Actions';

  @override
  String get competitionMessageCustom38 => 'Competition not found';

  @override
  String get competitionMessageCustom39 =>
      'Scan the QR code with your camera for check-in';

  @override
  String get categoryMessageCustom1 => 'Category deleted';

  @override
  String categoryMessageCustom2(Object error) {
    return 'Error: $error';
  }

  @override
  String categoryMessageCustom3(Object competitionName) {
    return 'Categories - $competitionName';
  }

  @override
  String get categoryMessageCustom4 => 'No categories';

  @override
  String get categoryMessageCustom5 =>
      'You do not have permission to edit categories';

  @override
  String get categoryMessageCustom6 => 'Edit category';

  @override
  String get categoryMessageCustom7 => 'New category';

  @override
  String get categoryMessageCustom8 => 'Name';

  @override
  String get categoryMessageCustom9 => 'Required';

  @override
  String get categoryMessageCustom10 => 'M';

  @override
  String get categoryMessageCustom11 => 'F';

  @override
  String get categoryMessageCustom12 => 'Age min';

  @override
  String get categoryMessageCustom13 => 'Age max';

  @override
  String get categoryMessageCustom14 => 'Update';

  @override
  String get categoryMessageCustom15 => 'Create';

  @override
  String get boulderMessageCustom1 => 'Boulder deleted';

  @override
  String boulderMessageCustom2(Object error) {
    return 'Error: $error';
  }

  @override
  String boulderMessageCustom3(Object competitionName) {
    return 'Boulders - $competitionName';
  }

  @override
  String get boulderMessageCustom4 => 'Finals only';

  @override
  String get boulderMessageCustom5 => 'No boulders';

  @override
  String boulderMessageCustom6(Object number) {
    return 'Boulder $number';
  }

  @override
  String get boulderMessageCustom7 => 'FINAL';

  @override
  String boulderMessageCustom8(Object difficulty, Object color, Object value) {
    return 'Diff: $difficulty | Color: $color | Value: $value';
  }

  @override
  String get boulderMessageCustom9 => 'Edit Boulder';

  @override
  String get boulderMessageCustom10 => 'New Boulder';

  @override
  String get boulderMessageCustom11 => 'Boulder number';

  @override
  String get boulderMessageCustom12 => 'Required';

  @override
  String get boulderMessageCustom13 => 'Difficulty';

  @override
  String get boulderMessageCustom14 => 'Easy';

  @override
  String get boulderMessageCustom15 => 'Hard';

  @override
  String get boulderMessageCustom16 => 'Color';

  @override
  String get boulderMessageCustom17 => 'No color';

  @override
  String get boulderMessageCustom18 => '⚪ White';

  @override
  String get boulderMessageCustom19 => '🟡 Yellow';

  @override
  String get boulderMessageCustom20 => '🟢 Green';

  @override
  String get boulderMessageCustom21 => '🔵 Blue';

  @override
  String get boulderMessageCustom22 => '🔴 Red';

  @override
  String get boulderMessageCustom23 => '⚫ Black';

  @override
  String get boulderMessageCustom24 => 'Print QR card';

  @override
  String get boulderMessageCustom25 => 'Finals only';

  @override
  String get boulderMessageCustom26 =>
      'The boulder will be available only in the final phase';

  @override
  String get boulderMessageCustom27 => 'Theoretical value';

  @override
  String get boulderMessageCustom28 => 'Boulders to create';

  @override
  String get boulderMessageCustom29 => 'Allowed values: 1 to 20';

  @override
  String get boulderMessageCustom30 => 'Enter a number';

  @override
  String get boulderMessageCustom31 => 'Allowed value: 1-20';

  @override
  String get boulderMessageCustom32 => 'Update';

  @override
  String get boulderMessageCustom33 => 'Create';

  @override
  String get boulderMessageCustom34 => 'BOULDER';

  @override
  String boulderMessageCustom35(Object difficulty) {
    return 'Difficulty: $difficulty / 10';
  }

  @override
  String get boulderMessageCustom36 => 'Scan to register the top';

  @override
  String registrationMessageCustom1(Object inserted, Object discarded) {
    return 'Import completed - Inserted: $inserted Discarded: $discarded';
  }

  @override
  String get registrationMessageCustom2 => 'Registration deleted';

  @override
  String registrationMessageCustom3(Object action) {
    return 'Registrations closed: $action not available';
  }

  @override
  String registrationMessageCustom4(Object action) {
    return 'Maximum registrations reached: $action not available';
  }

  @override
  String get registrationMessageCustom5 => 'Import CSV';

  @override
  String get registrationMessageCustom6 => 'New registration';

  @override
  String registrationMessageCustom7(Object competitionName) {
    return 'Registrations - $competitionName';
  }

  @override
  String get registrationMessageCustom8 =>
      'Registrations for this competition are closed. It is not possible to add new athletes or import CSV.';

  @override
  String registrationMessageCustom9(Object current, Object max) {
    return 'Maximum number of registrations reached ($current/$max). It is not possible to add new athletes or import CSV.';
  }

  @override
  String get registrationMessageCustom10 =>
      'Search bib, lastname or given firstname...';

  @override
  String get registrationMessageCustom11 => 'No registrations';

  @override
  String get registrationMessageCustom12 => 'Boulder';

  @override
  String get registrationMessageCustom13 => 'Athlete not present';

  @override
  String get registrationMessageCustom14 => 'Invalid email';

  @override
  String get registrationMessageCustom15 =>
      'Email already present in this competition';

  @override
  String get registrationMessageCustom16 =>
      'First turn is full, please select another option';

  @override
  String get registrationMessageCustom17 =>
      'Second turn is full, please select another option';

  @override
  String get registrationMessageCustom18 => 'Edit registration';

  @override
  String get registrationMessageCustom19 => 'New registration';

  @override
  String get registrationMessageCustom20 => 'Lastname';

  @override
  String get registrationMessageCustom21 => 'Firstname';

  @override
  String get registrationMessageCustom22 => 'Required';

  @override
  String get registrationMessageCustom23 => 'Email';

  @override
  String get registrationMessageCustom24 => 'Email required';

  @override
  String get registrationMessageCustom25 => 'Invalid email format';

  @override
  String get registrationMessageCustom26 => 'Club';

  @override
  String get registrationMessageCustom27 => 'Bib';

  @override
  String get registrationMessageCustom28 => 'Sex';

  @override
  String get registrationMessageCustom29 => 'M';

  @override
  String get registrationMessageCustom30 => 'F';

  @override
  String get registrationMessageCustom31 => 'Birth date';

  @override
  String get registrationMessageCustom32 => 'Required field';

  @override
  String get registrationMessageCustom33 => 'First turn';

  @override
  String get registrationMessageCustom34 =>
      'Turn management not active for this competition';

  @override
  String get registrationMessageCustom35 => 'Turn is full';

  @override
  String get registrationMessageCustom36 => 'Second turn';

  @override
  String get registrationMessageCustom37 => 'Present';

  @override
  String get registrationMessageCustom38 => 'Paid';

  @override
  String get registrationMessageCustom39 => 'Gift';

  @override
  String get registrationMessageCustom40 => 'Update';

  @override
  String get registrationMessageCustom41 => 'Create';

  @override
  String get checkinMessageCustom1 => 'Export PDF';

  @override
  String get checkinMessageCustom2 => 'Search bib, lastname, firstname...';

  @override
  String get checkinMessageCustom3 => 'No registrations found';

  @override
  String get checkinMessageCustom4 => 'Registered';

  @override
  String get checkinMessageCustom5 => 'Present';

  @override
  String get checkinMessageCustom6 => 'Paid';

  @override
  String get checkinMessageCustom7 => 'Gift';

  @override
  String get checkinMessageCustom8 => 'Tap the icons to update: ';

  @override
  String get checkinMessageCustom9 =>
      'Check-in management disabled for this competition';

  @override
  String get checkinMessageCustom10 => 'Remove presence';

  @override
  String get checkinMessageCustom11 => 'Mark present';

  @override
  String get checkinMessageCustom12 => 'Presence management not enabled';

  @override
  String get checkinMessageCustom13 => 'Cancel payment';

  @override
  String get checkinMessageCustom14 => 'Mark paid';

  @override
  String get checkinMessageCustom15 => 'Payment management not enabled';

  @override
  String get checkinMessageCustom16 => 'Cancel gift';

  @override
  String get checkinMessageCustom17 => 'Mark gift';

  @override
  String get checkinMessageCustom18 => 'Gifts not enabled';

  @override
  String get checkinMessageCustom19 => 'Check-in Race';

  @override
  String get checkinMessageCustom20 => 'Manage presence, payments and gifts';

  @override
  String get checkinMessageCustom21 => 'Search race';

  @override
  String get checkinMessageCustom22 => 'Open only';

  @override
  String get checkinMessageCustom23 => 'No races found';

  @override
  String get checkinMessageCustom24 => 'Registrations';

  @override
  String get checkinMessageCustom25 => 'Description';

  @override
  String get checkinMessageCustom26 => 'Race date';

  @override
  String get checkinMessageCustom27 => 'Status';

  @override
  String get checkinMessageCustom28 => 'Presence';

  @override
  String get checkinMessageCustom29 => 'Payments';

  @override
  String get checkinMessageCustom30 => 'Gifts';

  @override
  String get checkinMessageCustom31 => 'Actions';

  @override
  String get checkinMessageCustom32 => 'Disable presence management';

  @override
  String get checkinMessageCustom33 => 'Enable presence management';

  @override
  String get checkinMessageCustom34 => 'Disable payment management';

  @override
  String get checkinMessageCustom35 => 'Enable payment management';

  @override
  String get checkinMessageCustom36 => 'Disable gifts management';

  @override
  String get checkinMessageCustom37 => 'Enable gifts management';

  @override
  String get checkinMessageCustom38 => 'Open';

  @override
  String get checkinMessageCustom39 => 'Closed';

  @override
  String get checkinMessageCustom40 => 'Presence management';

  @override
  String get checkinMessageCustom41 => 'Payment management';

  @override
  String get checkinMessageCustom42 => 'Gifts management';

  @override
  String get checkinMessageCustom43 => 'Tap the icons to enable/disable';

  @override
  String get checkinMessageCustom44 => 'TOTALS';

  @override
  String checkinMessageCustom45(Object amount) {
    return 'Total amount collected: $amount';
  }

  @override
  String checkinMessageCustom46(Object date) {
    return 'Athletes check-in — $date';
  }

  @override
  String checkinMessageCustom47(Object datetime) {
    return 'Generated on $datetime';
  }

  @override
  String checkinMessageCustom48(Object page, Object total) {
    return 'Page $page of $total';
  }
}
