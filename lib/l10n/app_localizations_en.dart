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

  @override
  String get administrationMessaggeCustom1 => 'Roles';

  @override
  String get administrationMessaggeCustom2 =>
      'Define application roles and assign menus and permissions.';

  @override
  String get administrationMessaggeCustom3 => 'Permissions';

  @override
  String get administrationMessaggeCustom4 =>
      'Manage permission codes and associated activities.';

  @override
  String get administrationMessaggeCustom5 => 'Menu';

  @override
  String get administrationMessaggeCustom6 =>
      'Configure menu structure and platform visibility.';

  @override
  String get administrationMessaggeCustom7 => 'Users';

  @override
  String get administrationMessaggeCustom8 =>
      'Assign roles to registered users.';

  @override
  String get administrationMessaggeCustom9 => 'Email';

  @override
  String get administrationMessaggeCustom10 =>
      'Manage configurations, templates and email sending settings.';

  @override
  String get administrationMessaggeCustom11 => 'Security';

  @override
  String get administrationMessaggeCustom12 =>
      'Manage roles, permissions, menu and users';

  @override
  String get administrationMessaggeCustom13 => 'Development tools';

  @override
  String get administrationMessaggeCustom14 => 'Reset client configuration';

  @override
  String get administrationMessaggeCustom15 =>
      'The device will be disconnected from the current client. The application will close automatically: at restart you will need to enter the client code and password again.';

  @override
  String get administrationMessaggeCustom16 => 'Cancel';

  @override
  String get administrationMessaggeCustom17 => 'Confirm reset';

  @override
  String get administrationMessaggeCustom18 => 'Reset completed';

  @override
  String get administrationMessaggeCustom19 =>
      'The application will be closed. Reopen it to enter the new client code and password.';

  @override
  String get administrationMessaggeCustom20 => 'Close now';

  @override
  String get administrationMessaggeCustom21 => 'Force language (test only)';

  @override
  String get administrationMessaggeCustom22 =>
      'Current language: automatic (operating system)';

  @override
  String administrationMessaggeCustom23(Object code) {
    return 'Forced language: $code';
  }

  @override
  String get administrationMessaggeCustom24 => 'Automatic';

  @override
  String get administrationMessaggeCustom25 => 'Delete menu item';

  @override
  String administrationMessaggeCustom26(Object label) {
    return 'Do you want to delete \"$label\"?\nChild submenus will be deleted in cascade.';
  }

  @override
  String administrationMessaggeCustom27(Object error) {
    return 'Error: $error';
  }

  @override
  String get administrationMessaggeCustom28 => 'New Item';

  @override
  String get administrationMessaggeCustom29 => 'Translations';

  @override
  String get administrationMessaggeCustom30 => 'Add child';

  @override
  String get administrationMessaggeCustom31 => 'Edit';

  @override
  String get administrationMessaggeCustom32 => 'Delete';

  @override
  String get administrationMessaggeCustom33 => 'No menu items configured';

  @override
  String get administrationMessaggeCustom34 => 'Item deleted';

  @override
  String get administrationMessaggeCustom36 => 'Navigation structure';

  @override
  String get administrationMessaggeCustom37 => 'Edit Menu Item';

  @override
  String get administrationMessaggeCustom38 => 'New Menu Item';

  @override
  String get administrationMessaggeCustom39 => 'Navigation item configuration';

  @override
  String get administrationMessaggeCustom40 => 'Saving...';

  @override
  String get administrationMessaggeCustom41 => 'Save';

  @override
  String get administrationMessaggeCustom42 => 'Label';

  @override
  String get administrationMessaggeCustom43 => 'Required field';

  @override
  String get administrationMessaggeCustom44 => 'Route';

  @override
  String get administrationMessaggeCustom45 => '/dashboard';

  @override
  String get administrationMessaggeCustom46 => 'Must start with /';

  @override
  String get administrationMessaggeCustom47 => 'Icon';

  @override
  String get administrationMessaggeCustom48 => '— none —';

  @override
  String administrationMessaggeCustom49(Object icon) {
    return '$icon (non standard)';
  }

  @override
  String get administrationMessaggeCustom50 => 'Order';

  @override
  String get administrationMessaggeCustom51 => 'Parent item';

  @override
  String get administrationMessaggeCustom52 =>
      'Leave empty to create a top-level item';

  @override
  String get administrationMessaggeCustom53 => '— Top level —';

  @override
  String get administrationMessaggeCustom54 => 'Visible';

  @override
  String get administrationMessaggeCustom55 => 'Show on Mobile';

  @override
  String get administrationMessaggeCustom56 => 'Show on Desktop';

  @override
  String get administrationMessaggeCustom57 => 'Item updated';

  @override
  String get administrationMessaggeCustom58 => 'Item created';

  @override
  String get administrationMessaggeCustom59 => 'Translation updated';

  @override
  String get administrationMessaggeCustom60 => 'Translation created';

  @override
  String get administrationMessaggeCustom61 => 'Edit Translation';

  @override
  String get administrationMessaggeCustom62 => 'New Translation';

  @override
  String administrationMessaggeCustom63(Object label, Object route) {
    return '\"$label\" — $route';
  }

  @override
  String get administrationMessaggeCustom64 => 'Language';

  @override
  String get administrationMessaggeCustom65 => 'Select a language';

  @override
  String get administrationMessaggeCustom66 => 'Translated label';

  @override
  String administrationMessaggeCustom67(Object label) {
    return 'If left empty, the default label will be shown: \"$label\"';
  }

  @override
  String get administrationMessaggeCustom68 => 'Delete translation';

  @override
  String administrationMessaggeCustom69(Object locale, Object label) {
    return 'Do you want to delete the translation \"$locale\" (\"$label\")?';
  }

  @override
  String get administrationMessaggeCustom70 => 'Translation deleted';

  @override
  String get administrationMessaggeCustom71 => 'Translations';

  @override
  String get administrationMessaggeCustom72 =>
      'No translations configured (the default label will be used)';

  @override
  String administrationMessaggeCustom73(Object label) {
    return 'Default label (fallback): \"$label\"';
  }

  @override
  String get administrationMessaggeCustom74 => 'Delete permission';

  @override
  String get administrationMessaggeCustom75 => 'New Permission';

  @override
  String get administrationMessaggeCustom76 => 'Permissions';

  @override
  String get administrationMessaggeCustom77 =>
      'Permission codes and associated activities';

  @override
  String get administrationMessaggeCustom78 => 'No permissions found';

  @override
  String get administrationMessaggeCustom79 => 'Search code or activity';

  @override
  String get administrationMessaggeCustom80 => 'Permission Code';

  @override
  String get administrationMessaggeCustom81 => 'Activity';

  @override
  String get administrationMessaggeCustom82 => 'Actions';

  @override
  String administrationMessaggeCustom83(Object code) {
    return 'Do you want to delete \"$code\"?';
  }

  @override
  String get administrationMessaggeCustom84 => 'Permission deleted';

  @override
  String get administrationMessageCustom85 => 'Permission updated';

  @override
  String get administrationMessageCustom86 => 'Permission created';

  @override
  String get administrationMessageCustom87 => 'Edit Permission';

  @override
  String get administrationMessageCustom88 => 'Permission code definition';

  @override
  String get administrationMessageCustom89 =>
      'e.g. competition.read, boulder.write';

  @override
  String get administrationMessageCustom90 =>
      'Suggested format: resource.action';

  @override
  String get administrationMessageCustom91 => 'e.g. Read competitions list';

  @override
  String get administrationMessageCustom92 =>
      'Human-readable description of the permission';

  @override
  String administrationMessageCustom27(Object error) {
    return 'Error: $error';
  }

  @override
  String get administrationMessageCustom93 => 'Users';

  @override
  String get administrationMessageCustom94 =>
      'Assign roles to registered users';

  @override
  String get administrationMessageCustom95 => 'No users found';

  @override
  String get administrationMessageCustom96 => 'New User';

  @override
  String get administrationMessageCustom97 => 'Search by name or email';

  @override
  String get administrationMessageCustom98 => 'Roles';

  @override
  String get administrationMessageCustom99 => 'Name';

  @override
  String get administrationMessageCustom100 => 'Email';

  @override
  String get administrationMessageCustom101 => 'Created at';

  @override
  String get administrationMessageCustom102 => 'Password';

  @override
  String get administrationMessageCustom103 => 'Roles';

  @override
  String get administrationMessageCustom104 => 'Actions';

  @override
  String get administrationMessageCustom105 => 'Yes';

  @override
  String get administrationMessageCustom106 => 'No';

  @override
  String administrationMessageCustom107(Object error) {
    return 'Creation error: $error';
  }

  @override
  String administrationMessageCustom108(Object error) {
    return 'Deletion error: $error';
  }

  @override
  String get administrationMessageCustom109 => 'Delete User';

  @override
  String get administrationMessageCustom110 => 'Last name';

  @override
  String get administrationMessageCustom111 => 'Required';

  @override
  String get administrationMessageCustom112 => 'First name';

  @override
  String get administrationMessageCustom113 => 'Email';

  @override
  String get administrationMessageCustom114 => 'Email is required';

  @override
  String get administrationMessageCustom115 => 'Invalid email format';

  @override
  String get administrationMessageCustom116 => 'Create user';

  @override
  String get administrationMessageCustom117 => 'Confirm user deletion';

  @override
  String get administrationMessageCustom118 => 'Cancel';

  @override
  String get administrationMessageCustom119 => 'Delete';

  @override
  String get administrationMessageCustom120 => 'Roles updated';

  @override
  String get administrationMessageCustom121 => 'ASSIGNED ROLES';

  @override
  String get administrationMessageCustom122 => 'Save Roles';

  @override
  String get administrationMessageCustom123 => 'Roles';

  @override
  String get administrationMessageCustom124 => 'Manage application roles';

  @override
  String get administrationMessageCustom125 => 'No roles configured';

  @override
  String get administrationMessageCustom126 => 'New Role';

  @override
  String administrationMessageCustom127(Object error) {
    return 'Error loading roles: $error';
  }

  @override
  String get administrationMessageCustom128 => 'Delete role';

  @override
  String administrationMessageCustom129(Object name) {
    return 'Do you want to delete the role \"$name\"?\nAll users and associated menus will lose this role.';
  }

  @override
  String get administrationMessageCustom130 => 'Role deleted';

  @override
  String administrationMessageCustom131(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get administrationMessageCustom132 => 'Code';

  @override
  String get administrationMessageCustom133 => 'Name';

  @override
  String get administrationMessageCustom134 => 'Actions';

  @override
  String get administrationMessageCustom135 => 'Role updated';

  @override
  String get administrationMessageCustom136 => 'Role created';

  @override
  String get administrationMessageCustom137 => 'Edit Role';

  @override
  String get administrationMessageCustom138 => 'New Role';

  @override
  String get administrationMessageCustom139 => 'Application role data';

  @override
  String get administrationMessageCustom140 => 'e.g. admin, athlete, judge';

  @override
  String get administrationMessageCustom141 =>
      'Unique identifier, lowercase letters and underscore only';

  @override
  String get administrationMessageCustom142 =>
      'Only lowercase letters and underscore are allowed';

  @override
  String get administrationMessageCustom143 =>
      'e.g. Administrator, Athlete, Judge';

  @override
  String administrationMessageCustom144(Object name) {
    return 'Manage role: $name';
  }

  @override
  String administrationMessageCustom145(Object code) {
    return 'Code: $code';
  }

  @override
  String get administrationMessageCustom146 => 'Permissions';

  @override
  String get administrationMessageCustom147 => 'Menu';

  @override
  String administrationMessageCustom148(Object error) {
    return 'Error loading: $error';
  }

  @override
  String get administrationMessageCustom149 => 'Permissions saved';

  @override
  String administrationMessageCustom150(Object error) {
    return 'Error saving permissions: $error';
  }

  @override
  String get administrationMessageCustom151 => 'Menus saved';

  @override
  String administrationMessageCustom152(Object error) {
    return 'Error saving menus: $error';
  }

  @override
  String get administrationMessageCustom153 => 'Save Permissions';

  @override
  String get administrationMessageCustom154 => 'Save Menus';

  @override
  String get administrationMessageCustom155 => 'Search competitions, athletes…';

  @override
  String administrationMessageCustom156(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get administrationMessageCustom157 => 'Dashboard';

  @override
  String get administrationMessageCustom158 => 'Competition overview';

  @override
  String get administrationMessageCustom159 => 'Refresh';

  @override
  String get administrationMessageCustom160 => 'Error loading data';

  @override
  String get administrationMessageCustom161 => 'Retry';

  @override
  String get administrationMessageCustom162 => 'Competitions';

  @override
  String get administrationMessageCustom163 => 'Athletes';

  @override
  String get administrationMessageCustom164 => 'Boulders';

  @override
  String get administrationMessageCustom165 => 'Ascents';

  @override
  String get administrationMessageCustom166 => 'Competition';

  @override
  String get administrationMessageCustom167 => 'Athlete';

  @override
  String get administrationMessageCustom168 => 'Boulder';

  @override
  String get administrationMessageCustom169 => 'Ascent';

  @override
  String get importMessageCustom1 => 'Import CSV details';

  @override
  String importMessageCustom3(Object total) {
    return 'Total $total';
  }

  @override
  String importMessageCustom4(Object inserted) {
    return 'Inserted $inserted';
  }

  @override
  String importMessageCustom5(Object discarded) {
    return 'Discarded $discarded';
  }

  @override
  String get importMessageCustom6 => 'Show only discarded';

  @override
  String get importMessageCustom7 => 'No rows found';

  @override
  String get importMessageCustom8 => 'Inserted';

  @override
  String get importMessageCustom9 => 'Discarded';

  @override
  String importMessageCustom10(Object number) {
    return 'Row $number';
  }

  @override
  String get importMessageCustom11 => 'CSV row';

  @override
  String get importMessageCustom12 => 'Discard reason';

  @override
  String get importMessageCustom13 => 'CSV Imports';

  @override
  String get importMessageCustom14 => 'No import found';

  @override
  String get importMessageCustom15 => 'Import date';

  @override
  String get importMessageCustom16 => 'Competition';

  @override
  String get importMessageCustom17 => 'File';

  @override
  String get importMessageCustom18 => 'Total';

  @override
  String get importMessageCustom19 => 'Inserted';

  @override
  String get importMessageCustom20 => 'Discarded';

  @override
  String get importMessageCustom21 => 'Status';

  @override
  String get importMessageCustom22 => 'Detail';

  @override
  String rankingMessageCustom1(Object competition) {
    return 'Final ranking - $competition';
  }

  @override
  String get rankingMessageCustom2 => 'Export PDF';

  @override
  String get rankingMessageCustom3 => 'Search bib, last name, first name...';

  @override
  String get rankingMessageCustom4 => 'No athletes in ranking';

  @override
  String get rankingMessageCustom5 => 'Male ranking';

  @override
  String get rankingMessageCustom6 => 'Female ranking';

  @override
  String get rankingMessageCustom7 => 'Overall ranking';

  @override
  String rankingMessageCustom8(Object attempts) {
    return 'Top ($attempts)';
  }

  @override
  String rankingMessageCustom9(Object attempts) {
    return 'Zone ($attempts)';
  }

  @override
  String rankingMessageCustom10(Object error) {
    return 'Error loading ranking: $error';
  }

  @override
  String rankingMessageCustom11(Object error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String rankingMessageCustom12(Object error) {
    return 'Update error: $error';
  }

  @override
  String get rankingMessageCustom13 => 'Rankings';

  @override
  String get rankingMessageCustom14 => 'Manage rankings';

  @override
  String get rankingMessageCustom15 => 'Search competition';

  @override
  String get rankingMessageCustom16 => 'Only open';

  @override
  String get rankingMessageCustom17 => 'No competitions found';

  @override
  String get rankingMessageCustom18 => 'Qualifications ranking';

  @override
  String get rankingMessageCustom19 => 'Final ranking';

  @override
  String get rankingMessageCustom20 => 'Top & Zone ranking';

  @override
  String get rankingMessageCustom21 => 'Description';

  @override
  String get rankingMessageCustom22 => 'Competition date';

  @override
  String get rankingMessageCustom23 => 'Status';

  @override
  String get rankingMessageCustom24 => 'Qualifications';

  @override
  String get rankingMessageCustom25 => 'Final';

  @override
  String get rankingMessageCustom26 => 'Top & Zone';

  @override
  String get rankingMessageCustom27 => 'Tap to reopen competition';

  @override
  String get rankingMessageCustom28 => 'Tap to close competition';

  @override
  String get rankingMessageCustom29 => 'Closed';

  @override
  String get rankingMessageCustom30 => 'Open';

  @override
  String rankingMessageCustom31(Object competition) {
    return 'Qualifications ranking - $competition';
  }

  @override
  String get rankingMessageCustom32 => 'Top';

  @override
  String get rankingMessageCustom33 => 'points';

  @override
  String rankingMessageCustom34(Object competition) {
    return 'Top & Zone ranking - $competition';
  }

  @override
  String get rankingMessageCustom35 => 'Male ranking';

  @override
  String get rankingMessageCustom36 => 'Female ranking';

  @override
  String get rankingMessageCustom37 => 'Overall ranking';

  @override
  String get rankingMessageCustom38 => 'Athletes';

  @override
  String get rankingMessageCustom39 => 'Finalists';

  @override
  String get rankingMessageCustom40 => 'No athletes in this category';

  @override
  String rankingMessageCustom41(Object nr) {
    return 'Green bib = athlete qualified to final (first $nr)';
  }

  @override
  String get rankingMessageCustom42 => 'Boulder Competition Management';

  @override
  String rankingMessageCustom43(Object date) {
    return 'Generated on $date';
  }

  @override
  String rankingMessageCustom44(Object page, Object count) {
    return 'Page $page of $count';
  }

  @override
  String get rankingMessageCustom45 => '#';

  @override
  String get rankingMessageCustom46 => 'Bib';

  @override
  String get rankingMessageCustom47 => 'Last name · First name';

  @override
  String get rankingMessageCustom48 => 'Sex';

  @override
  String get rankingMessageCustom49 => 'Club';

  @override
  String get rankingMessageCustom51 => 'Attempts Top';

  @override
  String get rankingMessageCustom52 => 'Zones';

  @override
  String get rankingMessageCustom53 => 'Attempts Zone';

  @override
  String get rankingMessageCustom54 => '1st place';

  @override
  String get rankingMessageCustom55 => '2nd place';

  @override
  String get rankingMessageCustom56 => '3rd place';

  @override
  String get rankingMessageCustom57 => 'Male';

  @override
  String get rankingMessageCustom58 => 'Female';
}
