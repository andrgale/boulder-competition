import 'package:boulder_competition/features/rankings/models/ranking_category_top_zone_model.dart';
import 'package:boulder_competition/features/rankings/models/ranking_qualification_model.dart';
import 'package:boulder_competition/features/rankings/models/ranking_top_zone_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'ranking_final_model.dart';
import 'ranking_category_finale_model.dart';

/// Helper enum interno per normalizzare il campo `sesso` ('M'|'F'|null/altro).
enum Sesso { male, female, unknown }

Sesso _sessoFromCode(String? code) {
  switch (code) {
    case 'M':
      return Sesso.male;
    case 'F':
      return Sesso.female;
    default:
      return Sesso.unknown;
  }
}

/// Extension per RankingFinalModel
extension RankingFinalModelSexL10n on RankingFinalModel {
  String localizedSessoLabel(BuildContext context) {
    return localizedSessoLabelFromL10n(AppLocalizations.of(context)!);
  }

  String localizedSessoLabelFromL10n(AppLocalizations l10n) {
    final s = _sessoFromCode(sesso);
    switch (s) {
      case Sesso.male:
        return l10n.rankingMessageCustom57; // 'Maschio' / 'Male'
      case Sesso.female:
        return l10n.rankingMessageCustom58; // 'Femmina' / 'Female'
      case Sesso.unknown:
        return '—';
    }
  }
}

/// Extension per RankingQualificationModel
extension RankingQualificationModelSexL10n on RankingQualificationModel {
  String localizedSessoLabel(BuildContext context) {
    return localizedSessoLabelFromL10n(AppLocalizations.of(context)!);
  }

  String localizedSessoLabelFromL10n(AppLocalizations l10n) {
    final s = _sessoFromCode(sesso);
    switch (s) {
      case Sesso.male:
        return l10n.rankingMessageCustom57;
      case Sesso.female:
        return l10n.rankingMessageCustom58;
      case Sesso.unknown:
        return '—';
    }
  }
}
/// Extension per RankingCategoryFinaleModel
extension RankingCategoryFinaleModelSexL10n on RankingCategoryFinaleModel {
  String localizedSessoLabel(BuildContext context) {
    return localizedSessoLabelFromL10n(AppLocalizations.of(context)!);
  }

  String localizedSessoLabelFromL10n(AppLocalizations l10n) {
    final s = _sessoFromCode(sesso);
    switch (s) {
      case Sesso.male:
        return l10n.rankingMessageCustom57;
      case Sesso.female:
        return l10n.rankingMessageCustom58;
      case Sesso.unknown:
        return '—';
    }
  }
}
/// Extension per RankingTopZoneModel
extension RankingTopZoneModelSexL10n on RankingTopZoneModel {
  String localizedSessoLabel(BuildContext context) {
    return localizedSessoLabelFromL10n(AppLocalizations.of(context)!);
  }

  String localizedSessoLabelFromL10n(AppLocalizations l10n) {
    final s = _sessoFromCode(sesso);
    switch (s) {
      case Sesso.male:
        return l10n.rankingMessageCustom57;
      case Sesso.female:
        return l10n.rankingMessageCustom58;
      case Sesso.unknown:
        return '—';
    }
  }
}

/// Extension per RankingCategoryTopZoneModel
extension RankingCategoryTopZoneModelSexL10n on RankingCategoryTopZoneModel {
  String localizedSessoLabel(BuildContext context) {
    return localizedSessoLabelFromL10n(AppLocalizations.of(context)!);
  }

  String localizedSessoLabelFromL10n(AppLocalizations l10n) {
    final s = _sessoFromCode(sesso);
    switch (s) {
      case Sesso.male:
        return l10n.rankingMessageCustom57;
      case Sesso.female:
        return l10n.rankingMessageCustom58;
      case Sesso.unknown:
        return '—';
    }
  }
}