import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_translation_service_admin.dart';
import '../../models/menu_model.dart';
import '../../models/menu_translation_model.dart';

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
          context, isEdit ? 'Traduzione aggiornata' : 'Traduzione creata');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // errore tipico: violazione unique (menu_id, locale)
      AppSnackbar.error(context, 'Errore: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: isEdit ? 'Modifica Traduzione' : 'Nuova Traduzione',
      subtitle: '"${widget.menu.label}" — ${widget.menu.route}',
      actions: [
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(saving ? 'Salvataggio...' : 'Salva'),
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
                    decoration: const InputDecoration(labelText: 'Lingua'),
                    items: MenuTranslationServiceAdmin.supportedLocales
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text(l.toUpperCase()),
                            ))
                        .toList(),
                    validator: (v) =>
                        v == null ? 'Seleziona una lingua' : null,
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
                    decoration: const InputDecoration(labelText: 'Etichetta tradotta'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se lasci vuota questa lingua, verrà mostrata la label predefinita: "${widget.menu.label}"',
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