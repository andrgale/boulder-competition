import 'package:boulder_competition/features/category_templates/data/category_template_items_service.dart';
import 'package:flutter/material.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
import 'package:boulder_competition/features/categories/models/category_template_item_model.dart';
import '../../../core/services/permission_service.dart';

class CategoryTemplateItemsFormPage extends StatefulWidget {
  final String templateId;
  final CategoryTemplateItemModel? item;

  const CategoryTemplateItemsFormPage({
    super.key,
    required this.templateId,
    this.item,
  });

  @override
  State<CategoryTemplateItemsFormPage> createState() =>
      _CategoryTemplateItemsFormPageState();
}

class _CategoryTemplateItemsFormPageState
    extends State<CategoryTemplateItemsFormPage> {
  final service = CategoryTemplateItemsService();

  final formKey = GlobalKey<FormState>();

  late TextEditingController nomeCtrl;
  late TextEditingController etaMinCtrl;
  late TextEditingController etaMaxCtrl;
  late TextEditingController ordineCtrl;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? sesso;

  bool loading = false;

  bool get isEdit => widget.item != null;

  bool checkingPermission = true;
  bool canWrite = false;

  @override
  void initState() {
    super.initState();
    checkPermission();

    final c = widget.item;

    nomeCtrl = TextEditingController(text: c?.nome ?? '');
    etaMinCtrl = TextEditingController(text: c?.etaMin?.toString() ?? '');
    etaMaxCtrl = TextEditingController(text: c?.etaMax?.toString() ?? '');
    ordineCtrl = TextEditingController(text: c?.ordine.toString() ?? '');
    sesso = c?.sesso;
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    etaMinCtrl.dispose();
    etaMaxCtrl.dispose();
    ordineCtrl.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async {
    final allowed = await PermissionService.hasPermission(
      'security.admin',
    );

    if (!mounted) return;

    setState(() {
      canWrite = allowed;
      checkingPermission = false;
    });
  }

  int _normMin(int? v) => v ?? 1;
  int _normMax(int? v) => v ?? 99;

  bool _rangesOverlap(int aMin, int aMax, int bMin, int bMax) {
    return !(aMax < bMin || bMax < aMin);
  }

  Future<void> save() async {
    final allowed = await PermissionService.hasPermission(
      'security.admin',
    );

    if (!allowed) {
      showError(
        l10n.categoryTemplateMessageCustom52, // 'Non hai i permessi per modificare le categorie'
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final etaMin = etaMinCtrl.text.isEmpty ? null : int.parse(etaMinCtrl.text);
      final etaMax = etaMaxCtrl.text.isEmpty ? null : int.parse(etaMaxCtrl.text);
      final ordine = ordineCtrl.text.isEmpty ? 0 : int.parse(ordineCtrl.text);

      if (etaMin != null && etaMax != null && etaMin > etaMax) {
        showError(l10n.categoryTemplateMessageCustom54); // 'Età minima deve essere minore o uguale all\'età massima'
        return;
      }

      // Fetch existing items for the same template to validate overlap
      final others = await service.listForTemplate(widget.templateId);

      for (final other in others) {
        if (isEdit && other.id == widget.item!.id) continue;

        // Only check overlap for the same sex: skip if sexes differ (null matches null)
        if (other.sesso != sesso) continue;

        final aMin = _normMin(etaMin);
        final aMax = _normMax(etaMax);
        final bMin = _normMin(other.etaMin);
        final bMax = _normMax(other.etaMax);

        if (_rangesOverlap(aMin, aMax, bMin, bMax)) {
          showError(l10n.categoryTemplateMessageCustom53); // 'Sovrapposizione età con un\'altra categoria'
          return;
        }
      }

      if (isEdit) {
        // Assumes the service implements updateItem
        await service.updateItem(
          id: widget.item!.id,
          nome: nomeCtrl.text.trim(),
          sesso: sesso,
          etaMin: etaMin,
          etaMax: etaMax,
          ordine: ordine,
        );
      } else {
        // Assumes the service implements createItem
        await service.createItem(
          templateId: widget.templateId,
          nome: nomeCtrl.text.trim(),
          sesso: sesso,
          etaMin: etaMin,
          etaMax: etaMax,
          ordine: ordine,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

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
          isEdit
              ? l10n.categoryTemplateMessageCustom56 // 'Modifica categoria'
              : l10n.categoryTemplateMessageCustom55, // 'Nuova categoria'
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
                decoration: InputDecoration(
                  labelText: l10n.categoryTemplateMessageCustom46, // 'Nome'
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.categoryTemplateMessageCustom51 /* 'Obbligatorio' */ : null,
              ),

              DropdownButtonFormField<String>(
                value: sesso,
                items: [
                  DropdownMenuItem(value: 'M', child: Text(l10n.categoryTemplateMessageCustom44)), // 'Maschio'
                  DropdownMenuItem(value: 'F', child: Text(l10n.categoryTemplateMessageCustom45)), // 'Femmina'
                ],
                onChanged: (v) => setState(() => sesso = v),
                decoration: InputDecoration(labelText: l10n.categoryTemplateMessageCustom47), // 'Sesso'
              ),

              TextFormField(
                controller: etaMinCtrl,
                decoration: InputDecoration(labelText: l10n.categoryTemplateMessageCustom48), // 'Età min'
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: etaMaxCtrl,
                decoration: InputDecoration(labelText: l10n.categoryTemplateMessageCustom49), // 'Età max'
                keyboardType: TextInputType.number,
              ),

              TextFormField(
                controller: ordineCtrl,
                decoration: InputDecoration(labelText: l10n.categoryTemplateMessageCustom50), // 'Ordine'
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : save,
                child: Text(
                  isEdit
                      ? l10n.categoryTemplateMessageCustom58 // 'Aggiorna'
                      : l10n.categoryTemplateMessageCustom57, // 'Crea'
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}