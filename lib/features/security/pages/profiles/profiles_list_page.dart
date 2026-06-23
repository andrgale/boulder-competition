import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';
import '../../data/security_profile_service.dart';
import '../../data/role_service.dart';
import '../../models/security_profile_model.dart';
import '../../models/role_model.dart';

class ProfilesListPage extends StatefulWidget {
  const ProfilesListPage({super.key});

  @override
  State<ProfilesListPage> createState() => _ProfilesListPageState();
}

class _ProfilesListPageState extends State<ProfilesListPage> {
  final profileService = SecurityProfileService();
  final roleService = RoleService();
  final searchController = TextEditingController();

  // controller dedicato per la scrollbar verticale
  final _verticalScrollController = ScrollController();

  List<SecurityProfileModel> all = [];
  List<SecurityProfileModel> filtered = [];
  List<RoleModel> roles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> loadAll() async {
    try {
      final results = await Future.wait([
        profileService.getProfiles(),
        roleService.getRoles(),
      ]);

      if (!mounted) return;

      setState(() {
        all = results[0] as List<SecurityProfileModel>;
        filtered = List.from(all);
        roles = results[1] as List<RoleModel>;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, 'Errore: $e');
    }
  }

  void applyFilter() {
    final q = searchController.text.trim().toLowerCase();
    setState(() {
      filtered = all.where((p) {
        return p.fullName.toLowerCase().contains(q) ||
            p.email.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _openRoles(SecurityProfileModel p) async {
    await context.push(
      '/security/profiles/roles',
      extra: {'profile': p, 'roles': roles},
    );
    await loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Utenti',
      subtitle: 'Assegnazione ruoli agli utenti registrati',
      loading: loading,
      empty: !loading && filtered.isEmpty,
      emptyMessage: 'Nessun utente trovato',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── barra ricerca ──────────────────────────────
          SizedBox(
            width: 420,
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cerca per nome o email',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => applyFilter(),
            ),
          ),

          const SizedBox(height: 24),

          // ── tabella ────────────────────────────────────
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return _buildMobileList();
    }

    return _buildDesktopTable();
  }

  // ── MOBILE ────────────────────────────────────────────────

  Widget _buildMobileList() {
    return Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _verticalScrollController,
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = filtered[i];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  '${p.cognome.isNotEmpty ? p.cognome[0] : ''}'
                  '${p.nome.isNotEmpty ? p.nome[0] : ''}',
                ),
              ),
              title: Text(
                p.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(p.email),
              trailing: IconButton(
                tooltip: 'Gestisci ruoli',
                icon: const Icon(Icons.manage_accounts),
                onPressed: () => _openRoles(p),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── DESKTOP ───────────────────────────────────────────────

  Widget _buildDesktopTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,       // scrollbar sempre visibile
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            // scroll orizzontale per tabelle molto larghe
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // la tabella occupa almeno tutta la larghezza disponibile
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 360,
              ),
              child: DataTable(
                columnSpacing: 56,       // più spazio tra colonne
                horizontalMargin: 32,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                headingRowHeight: 56,
                // ── colonne ─────────────────────────────────
                columns: const [
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Creato il')),
                  DataColumn(label: Text('Password cambiata')),
                  DataColumn(label: Text('Ruoli assegnati')),
                  DataColumn(label: Text('Azioni')),
                ],
                rows: filtered.map((p) => _buildRow(p)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(SecurityProfileModel p) {
    return DataRow(
      cells: [
        // ── nome ──────────────────────────────────────────
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  '${p.cognome.isNotEmpty ? p.cognome[0] : ''}'
                  '${p.nome.isNotEmpty ? p.nome[0] : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                p.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // ── email ─────────────────────────────────────────
        DataCell(
          SizedBox(
            width: 260,
            child: Text(
              p.email,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // ── creato il ─────────────────────────────────────
        DataCell(
          Text(
            _formatDate(p.createdAt),
            style: const TextStyle(color: Colors.grey),
          ),
        ),

        // ── password cambiata ─────────────────────────────
        // DataCell(
        //   Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(
        //         p.passwordChanged ? Icons.check_circle : Icons.cancel,
        //         color: p.passwordChanged ? Colors.green : Colors.red,
        //         size: 20,
        //       ),
        //       const SizedBox(width: 6),
        //       Text(
        //         p.passwordChanged ? 'Sì' : 'No',
        //         style: TextStyle(
        //           color: p.passwordChanged ? Colors.green : Colors.red,
        //           fontWeight: FontWeight.w500,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        DataCell(
          InkWell(
                onTap: () async {
                  try {
                    await profileService.updatePasswordChanged(
                      profileId: p.id,
                      passwordChanged: !p.passwordChanged,
                    );

                    await loadAll();
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore aggiornamento: $e'),
                      ),
                    );
                  }
                },
           child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.passwordChanged
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      p.passwordChanged ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  p.passwordChanged ? 'Sì' : 'No',
                  style: TextStyle(
                    color:
                        p.passwordChanged ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── ruoli assegnati ───────────────────────────────
        DataCell(
          FutureBuilder<List<String>>(
            future: _loadRoleNames(p.id),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (snap.data!.isEmpty) {
                return const Text(
                  '—',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Wrap(
                spacing: 4,
                children: snap.data!
                    .map((name) => Chip(
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              );
            },
          ),
        ),

        // ── azioni ────────────────────────────────────────
        DataCell(
          FilledButton.tonalIcon(
            onPressed: () => _openRoles(p),
            icon: const Icon(Icons.manage_accounts, size: 18),
            label: const Text('Gestisci ruoli'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }

  // ── helpers ───────────────────────────────────────────────

  // cache locale per evitare chiamate ripetute nel FutureBuilder
  final Map<String, Future<List<String>>> _roleNamesCache = {};

  Future<List<String>> _loadRoleNames(String profileId) {
    return _roleNamesCache.putIfAbsent(profileId, () async {
      final ids = await profileService.getProfileRoleIds(profileId);
      return roles
          .where((r) => ids.contains(r.id))
          .map((r) => r.name)
          .toList();
    });
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
