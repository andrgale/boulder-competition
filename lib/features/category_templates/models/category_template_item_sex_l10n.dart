
import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

enum CategoryTemplateItemSex { male, female, unknown }

CategoryTemplateItemSex _sexFromCode(String? code) {
  switch (code) {
    case 'M':
      return CategoryTemplateItemSex.male;
    case 'F':
      return CategoryTemplateItemSex.female;
    default:
      return CategoryTemplateItemSex.unknown;
  }
}

extension CategoryTemplateItemSexL10n on CategoryTemplateItemModel {
  String localizedSessoLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_sexFromCode(sesso)) {
      case CategoryTemplateItemSex.male:
        return l10n.categoryTemplateMessageCustom39; // 'Maschio' / 'Male'
      case CategoryTemplateItemSex.female:
        return l10n.categoryTemplateMessageCustom40; // 'Femmina' / 'Female'
      case CategoryTemplateItemSex.unknown:
        return '—';
    }
  }
}
