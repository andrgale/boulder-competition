import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../data/category_service.dart';

import '../../../core/services/permission_service.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';


class CategoryFormPage extends StatefulWidget {
  final String competitionId;
  final CategoryModel? category;

  const CategoryFormPage({
    super.key,
    required this.competitionId,
    this.category,
  });

  @override
  State<CategoryFormPage> createState() =>
      _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final service = CategoryService();

  final formKey = GlobalKey<FormState>();

  late TextEditingController nomeCtrl;
  late TextEditingController etaMinCtrl;
  late TextEditingController etaMaxCtrl;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? sesso;

  bool loading = false;

  bool get isEdit => widget.category != null;

  bool checkingPermission = true;
  bool canWrite = false;


  @override
  void initState() {
    super.initState();

    checkPermission();


    final c = widget.category;

    nomeCtrl = TextEditingController(text: c?.nome ?? '');
    etaMinCtrl = TextEditingController(text: c?.etaMin?.toString() ?? '');
    etaMaxCtrl = TextEditingController(text: c?.etaMax?.toString() ?? '');
    sesso = c?.sesso;
  }



  @override
  void dispose() {
    nomeCtrl.dispose();
    etaMinCtrl.dispose();
    etaMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async {
    final allowed =
        await PermissionService.hasPermission(
      'category.write',
    );

    if (!mounted) return;

    setState(() {
      canWrite = allowed;
      checkingPermission = false;
    });
  }


  Future<void> save() async {

    final canWrite =
        await PermissionService.hasPermission(
      'category.write',
    );

    if (!canWrite) {
      showError(
        l10n.categoryMessageCustom5, // 'Non hai i permessi per modificare le categorie'
      );
      return;
    }


    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final etaMin = etaMinCtrl.text.isEmpty
          ? null
          : int.parse(etaMinCtrl.text);

      final etaMax = etaMaxCtrl.text.isEmpty
          ? null
          : int.parse(etaMaxCtrl.text);

      if (isEdit) {
        await service.updateCategory(
          id: widget.category!.id,
          nome: nomeCtrl.text.trim(),
          sesso: sesso,
          etaMin: etaMin,
          etaMax: etaMax,
        );
      } else {
        await service.createCategory(
          competitionId: widget.competitionId,
          nome: nomeCtrl.text.trim(),
          sesso: sesso,
          etaMin: etaMin,
          etaMax: etaMax,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // =======================================================
  // ERROR
  // =======================================================

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? l10n.categoryMessageCustom6 : l10n.categoryMessageCustom7, // 'Modifica categoria' / 'Nuova categoria'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeCtrl,
                decoration: InputDecoration(labelText: l10n.categoryMessageCustom8), // 'Nome'
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.categoryMessageCustom9 : null, // 'Obbligatorio'
              ),

              DropdownButtonFormField<String>(
                initialValue: sesso,
                items: [
                  DropdownMenuItem(value: 'M', child: Text(l10n.categoryMessageCustom10)), // 'M'
                  DropdownMenuItem(value: 'F', child: Text(l10n.categoryMessageCustom11)), // 'F'
                ],
                onChanged: (v) => setState(() => sesso = v),
              ),

              TextFormField(
                controller: etaMinCtrl,
                decoration: InputDecoration(labelText: l10n.categoryMessageCustom12), // 'Età min'
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: etaMaxCtrl,
                decoration: InputDecoration(labelText: l10n.categoryMessageCustom13), // 'Età max'
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : save,
                child: Text(isEdit ? l10n.categoryMessageCustom14 : l10n.categoryMessageCustom15), // 'Aggiorna' / 'Crea'
              )
            ],
          ),
        ),
      ),
    );
  }
}