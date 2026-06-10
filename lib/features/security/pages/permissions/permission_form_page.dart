import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/permission_service.dart';
import '../../models/permission_model.dart';

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
          context, isEdit ? 'Permesso aggiornato' : 'Permesso creato');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Errore: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: isEdit ? 'Modifica Permesso' : 'Nuovo Permesso',
      subtitle: 'Definizione del codice permesso',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Codice Permesso',
                      hintText: 'es. competition.read, boulder.write',
                      helperText: 'Formato suggerito: risorsa.azione',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obbligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: activityController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Attività',
                      hintText: 'es. Lettura lista competizioni',
                      helperText: 'Descrizione leggibile del permesso',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obbligatorio';
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
