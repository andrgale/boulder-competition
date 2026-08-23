import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_service_admin.dart';
import '../../models/menu_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';
class MenuFormPage extends StatefulWidget {
  final MenuModel? menu;
  final String? parentId; // per creare un figlio direttamente

  const MenuFormPage({super.key, this.menu, this.parentId});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final service = MenuServiceAdmin();
  final formKey = GlobalKey<FormState>();

  final labelController = TextEditingController();
  final routeController = TextEditingController();
  final iconController = TextEditingController();
  final orderController = TextEditingController(text: '0');

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool visible = true;
  bool mobile = true;
  bool desktop = true;
  String? parentId;

  List<MenuModel> allMenus = [];
  bool loadingMenus = true;
  bool saving = false;

  bool get isEdit => widget.menu != null;

  // icone disponibili (stessa lista di AppShell)
  static const _iconOptions = [
    'dashboard', 'groups', 'terrain', 'leaderboard',
    'sports_score', 'emoji_events', 'admin_panel_settings',
    'category', 'person', 'lock', 'menu_book', 'security',
    'upload_file',
  ];

  @override
  void initState() {
    super.initState();
    parentId = widget.parentId ?? widget.menu?.parentId;

    if (isEdit) {
      labelController.text = widget.menu!.label;
      routeController.text = widget.menu!.route;
      iconController.text = widget.menu!.icon ?? '';
      orderController.text = widget.menu!.displayOrder.toString();
      visible = widget.menu!.visible;
      mobile = widget.menu!.mobile;
      desktop = widget.menu!.desktop;
    }

    loadParentOptions();
  }

  @override
  void dispose() {
    labelController.dispose();
    routeController.dispose();
    iconController.dispose();
    orderController.dispose();
    super.dispose();
  }

  Future<void> loadParentOptions() async {
    try {
      final data = await service.getMenus();
      if (!mounted) return;
      setState(() {
        // solo le radici possono essere parent
        allMenus = data.where((m) => m.parentId == null).toList();
        // escludi sé stesso in edit
        if (isEdit) {
          allMenus.removeWhere((m) => m.id == widget.menu!.id);
        }
        loadingMenus = false;
      });
    } catch (_) {
      if (mounted) setState(() => loadingMenus = false);
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);

    try {
      final order = int.tryParse(orderController.text) ?? 0;
      final icon = iconController.text.trim().isEmpty
          ? null
          : iconController.text.trim();

      if (isEdit) {
        await service.updateMenu(
          id: widget.menu!.id,
          label: labelController.text,
          route: routeController.text,
          icon: icon,
          displayOrder: order,
          parentId: parentId,
          visible: visible,
          mobile: mobile,
          desktop: desktop,
        );
      } else {
        await service.createMenu(
          label: labelController.text,
          route: routeController.text,
          icon: icon,
          displayOrder: order,
          parentId: parentId,
          visible: visible,
          mobile: mobile,
          desktop: desktop,
        );
      }

      if (!mounted) return;
      AppSnackbar.success(
          context, isEdit ? l10n.administrationMessaggeCustom56 : l10n.administrationMessaggeCustom57); // 'Voce aggiornata' / 'Voce creata'
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
      title: isEdit ? l10n.administrationMessaggeCustom37 : l10n.administrationMessaggeCustom38, // 'Modifica Voce Menu' / 'Nuova Voce Menu'
      subtitle: l10n.administrationMessaggeCustom39, // 'Configurazione voce di navigazione'
      actions: [
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: saving
              ? const SizedBox(
                  width: 18, height: 18,
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
                  // ── Label ──────────────────────────────
                  TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(labelText: l10n.administrationMessaggeCustom42), // 'Etichetta'
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.administrationMessaggeCustom43 // 'Campo obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Route ──────────────────────────────
                  TextFormField(
                    controller: routeController,
                    decoration: InputDecoration(
                      labelText: l10n.administrationMessaggeCustom44, // 'Route'
                      hintText: l10n.administrationMessaggeCustom45, // '/dashboard'
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.administrationMessaggeCustom43; // 'Campo obbligatorio'
                      }
                      if (!v.trim().startsWith('/')) {
                        return l10n.administrationMessaggeCustom46; // 'Deve iniziare con /'
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Icon + Order ────────────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: iconController.text.isEmpty
                              ? null
                              : iconController.text,
                          decoration: InputDecoration(labelText: l10n.administrationMessaggeCustom47), // 'Icona'
                          items: [
                            DropdownMenuItem(value: null, child: Text(l10n.administrationMessaggeCustom48)), // '— nessuna —'
                            ..._iconOptions.map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                )),
                            // fallback: se il valore a DB non è tra le opzioni note,
                            // aggiungilo comunque per evitare il crash del DropdownButtonFormField
                            if (iconController.text.isNotEmpty &&
                                !_iconOptions.contains(iconController.text))
                              DropdownMenuItem(
                                value: iconController.text,
                                child: Text(l10n.administrationMessaggeCustom49(iconController.text)), // '{icon} (non standard)'
                              ),
                          ],
                          onChanged: (val) {
                            iconController.text = val ?? '';
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: orderController,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(labelText: l10n.administrationMessaggeCustom50), // 'Ordine'
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Parent ─────────────────────────────
                  if (!loadingMenus)
                    DropdownButtonFormField<String?>(
                      initialValue: parentId,
                      decoration: InputDecoration(
                        labelText: l10n.administrationMessaggeCustom51, // 'Voce parent'
                        helperText: l10n.administrationMessaggeCustom52, // 'Lascia vuoto per voce di primo livello'
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.administrationMessaggeCustom53)), // '— Primo livello —'
                        ...allMenus.map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.label),
                            )),
                      ],
                      onChanged: (val) => setState(() => parentId = val),
                    ),
                  const SizedBox(height: 32),

                  // ── Flags ──────────────────────────────
                  SwitchListTile(
                    title: Text(l10n.administrationMessaggeCustom54), // 'Visibile'
                    value: visible,
                    onChanged: (v) => setState(() => visible = v),
                  ),
                  SwitchListTile(
                    title: Text(l10n.administrationMessaggeCustom55), // 'Mostra su Mobile'
                    value: mobile,
                    onChanged: (v) => setState(() => mobile = v),
                  ),
                  SwitchListTile(
                    title: Text(l10n.administrationMessaggeCustom56), // 'Mostra su Desktop'
                    value: desktop,
                    onChanged: (v) => setState(() => desktop = v),
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