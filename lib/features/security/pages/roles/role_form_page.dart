import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/role_service.dart';
import '../../models/role_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
class RoleFormPage extends StatefulWidget {
  final RoleModel? role;

  const RoleFormPage({super.key, this.role});

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  final service = RoleService();
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final nameController = TextEditingController();

  bool saving = false;
  bool get isEdit => widget.role != null;
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      codeController.text = widget.role!.code;
      nameController.text = widget.role!.name;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      if (isEdit) {
        await service.updateRole(
          id: widget.role!.id,
          code: codeController.text,
          name: nameController.text,
        );
      } else {
        await service.createRole(
          code: codeController.text,
          name: nameController.text,
        );
      }

      if (!mounted) return;
      AppSnackbar.success(
        context,
        isEdit ? l10n.administrationMessageCustom135 : l10n.administrationMessageCustom136, // 'Ruolo aggiornato' / 'Ruolo creato'
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, AppLocalizations.of(context)!.administrationMessageCustom27(e.toString())); // 'Errore: {error}'
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showBackButton: true,
      title: isEdit ? l10n.administrationMessageCustom137 : l10n.administrationMessageCustom138, // 'Modifica Ruolo' / 'Nuovo Ruolo'
      subtitle: l10n.administrationMessageCustom139, // 'Dati del ruolo applicativo'
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
                      labelText: l10n.administrationMessageCustom132, // 'Codice' (riutilizzata)
                      hintText: l10n.administrationMessageCustom140, // 'es. admin, athlete, judge'
                      helperText: l10n.administrationMessageCustom141, // 'Identificatore univoco, solo lettere minuscole e underscore'
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.administrationMessageCustom111; // 'Obbligatorio' (riutilizzata)
                      }
                      if (!RegExp(r'^[a-z_]+$').hasMatch(v.trim())) {
                        return l10n.administrationMessageCustom142; // 'Solo lettere minuscole e underscore'
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.administrationMessageCustom133, // 'Nome' (riutilizzata)
                      hintText: l10n.administrationMessageCustom143, // 'es. Amministratore, Atleta, Giudice'
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.administrationMessageCustom111; // 'Obbligatorio' (riutilizzata)
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