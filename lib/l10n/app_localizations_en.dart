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
}
