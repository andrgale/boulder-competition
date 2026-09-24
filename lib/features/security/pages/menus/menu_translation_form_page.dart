import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_translation_service_admin.dart';
import '../../models/menu_model.dart';
import '../../models/menu_translation_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class MenuTranslationFormPage extends StatefulWidget {
  final MenuModel menu;
  final MenuTranslationModel? translation; // null = nuova traduzione

  const MenuTranslationFormPage({
    super.key,
    required this.menu,
    this.translation,
  });

  @override
  State<MenuTranslationFormPage> createState() =>
      _MenuTranslationFormPageState();
}

class _MenuTranslationFormPageState extends State<MenuTranslationFormPage> {
  final service = MenuTranslationServiceAdmin();
  final formKey = GlobalKey<FormState>();
  final labelController = TextEditingController();

    AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? locale;
  bool saving = false;

  bool get isEdit => widget.translation != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      locale = widget.translation!.locale;
      labelController.text = widget.translation!.label;
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (locale == null) return;

    setState(() => saving = true);

    try {
      if (isEdit) {
        await service.updateTranslation(
          id: widget.translation!.id,
          locale: locale!,
          label: labelController.text,
        );
      } else {
        await service.createTranslation(
          menuId: widget.menu.id,
          locale: locale!,
          label: labelController.text,
        );
      }

      if (!mounted) return;
      AppSnackbar.success(
        context,
        isEdit
            ? l10n.administrationMessaggeCustom59 // 'Traduzione aggiornata'
            : l10n.administrationMessaggeCustom60, // 'Traduzione creata'
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // errore tipico: violazione unique (menu_id, locale)
      AppSnackbar.error(context, AppLocalizations.of(context)!.administrationMessaggeCustom27(e.toString())); // 'Errore: $e' (riutilizzata)
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showBackButton: true,
      title: isEdit ? l10n.administrationMessaggeCustom61 : l10n.administrationMessaggeCustom62, // 'Modifica Traduzione' / 'Nuova Traduzione'
      subtitle: l10n.administrationMessaggeCustom63(widget.menu.label, widget.menu.route), // '"${widget.menu.label}" — ${widget.menu.route}'
      actions: [
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(saving ? l10n.administrationMessaggeCustom40 : l10n.administrationMessaggeCustom41), // 'Salvataggio...' / 'Salva'
        ),
      ],
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  // ── Lingua ─────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: locale,
                    decoration: InputDecoration(labelText: l10n.administrationMessaggeCustom64), // 'Lingua'
                    items: MenuTranslationServiceAdmin.supportedLocales
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(l.toUpperCase()),
                            ))
                        .toList(),
                    validator: (v) =>
                        v == null ? l10n.administrationMessaggeCustom65 : null, // 'Seleziona una lingua'
                    onChanged: isEdit
                        ? null // non permettere di cambiare lingua in edit,
                               // per evitare conflitti con unique(menu_id, locale);
                               // se vuole cambiarla, elimina e ricrea
                        : (val) => setState(() => locale = val),
                  ),
                  const SizedBox(height: 24),

                  // ── Label ──────────────────────────────
                  TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(labelText: l10n.administrationMessaggeCustom66), // 'Etichetta tradotta'
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.administrationMessaggeCustom43 // 'Campo obbligatorio' (riutilizzata)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.administrationMessaggeCustom67(widget.menu.label), // 'Se lasci vuota questa lingua, verrà mostrata la label predefinita: "${widget.menu.label}"'
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}