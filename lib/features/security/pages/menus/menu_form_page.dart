import 'package:flutter/material.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/menu_service_admin.dart';
import '../../models/menu_model.dart';

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
          context, isEdit ? 'Voce aggiornata' : 'Voce creata');
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
      title: isEdit ? 'Modifica Voce Menu' : 'Nuova Voce Menu',
      subtitle: 'Configurazione voce di navigazione',
      actions: [
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: saving
              ? const SizedBox(
                  width: 18, height: 18,
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
                  // ── Label ──────────────────────────────
                  TextFormField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Etichetta'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Route ──────────────────────────────
                  TextFormField(
                    controller: routeController,
                    decoration: const InputDecoration(
                      labelText: 'Route',
                      hintText: '/dashboard',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obbligatorio';
                      }
                      if (!v.trim().startsWith('/')) {
                        return 'Deve iniziare con /';
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
                          decoration: const InputDecoration(labelText: 'Icona'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('— nessuna —')),
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
                                child: Text('${iconController.text} (non standard)'),
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
                              const InputDecoration(labelText: 'Ordine'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Parent ─────────────────────────────
                  if (!loadingMenus)
                    DropdownButtonFormField<String?>(
                      initialValue: parentId,
                      decoration: const InputDecoration(
                        labelText: 'Voce parent',
                        helperText: 'Lascia vuoto per voce di primo livello',
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('— Primo livello —')),
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
                    title: const Text('Visibile'),
                    value: visible,
                    onChanged: (v) => setState(() => visible = v),
                  ),
                  SwitchListTile(
                    title: const Text('Mostra su Mobile'),
                    value: mobile,
                    onChanged: (v) => setState(() => mobile = v),
                  ),
                  SwitchListTile(
                    title: const Text('Mostra su Desktop'),
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
