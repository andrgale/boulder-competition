import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/permission_service.dart';
import '../../models/permission_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class PermissionFormPage extends StatefulWidget {
  final PermissionModel? permission;

  const PermissionFormPage({super.key, this.permission});

  @override
  State<PermissionFormPage> createState() => _PermissionFormPageState();
}

class _PermissionFormPageState extends State<PermissionFormPage> {
  final service = PermissionService();
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final activityController = TextEditingController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool saving = false;
  bool get isEdit => widget.permission != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      codeController.text = widget.permission!.permissionCode;
      activityController.text = widget.permission!.activity;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    activityController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);

    try {
      if (isEdit) {
        await service.updatePermission(
          id: widget.permission!.id,
          permissionCode: codeController.text,
          activity: activityController.text,
        );
      } else {
        await service.createPermission(
          permissionCode: codeController.text,
          activity: activityController.text,
        );
      }

      if (!mounted) return;
      AppSnackbar.success(
        context,
        isEdit
            ? l10n.administrationMessageCustom85 // 'Permesso aggiornato'
            : l10n.administrationMessageCustom86, // 'Permesso creato'
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, AppLocalizations.of(context)!.administrationMessaggeCustom27(e.toString())); // 'Errore: $e' (riutilizzata)
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: isEdit ? l10n.administrationMessageCustom87 : l10n.administrationMessaggeCustom75, // 'Modifica Permesso' / 'Nuovo Permesso'
      subtitle: l10n.administrationMessageCustom88, // 'Definizione del codice permesso'
      actions: [
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(saving ? l10n.administrationMessaggeCustom40 : l10n.administrationMessaggeCustom41), // 'Salvataggio...' / 'Salva' (riutilizzate)
        ),
      ],
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.administrationMessaggeCustom80, // 'Codice Permesso'
                      hintText: l10n.administrationMessageCustom89, // 'es. competition.read, boulder.write'
                      helperText: l10n.administrationMessageCustom90, // 'Formato suggerito: risorsa.azione'
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.administrationMessaggeCustom43; // 'Campo obbligatorio' (riutilizzata)
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: activityController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.administrationMessaggeCustom81, // 'Attività'
                      hintText: l10n.administrationMessageCustom91, // 'es. Lettura lista competizioni'
                      helperText: l10n.administrationMessageCustom92, // 'Descrizione leggibile del permesso'
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.administrationMessaggeCustom43; // 'Campo obbligatorio' (riutilizzata)
                      }
                      return null;
                    },
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