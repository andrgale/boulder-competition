import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/responsive.dart';
import '../../../../core/ui/responsive_table.dart';
import '../../../../shared/widgets/base_page.dart';
import '../../../../shared/app_snackbar.dart';

import '../../data/security_profile_service.dart';
import '../../data/role_service.dart';
import '../../models/security_profile_model.dart';
import '../../models/role_model.dart';

class ProfilesListPage extends StatefulWidget {
  const ProfilesListPage({super.key});

  @override
  State<ProfilesListPage> createState() =>
      _ProfilesListPageState();
}

class _ProfilesListPageState extends State<ProfilesListPage> {
  final profileService = SecurityProfileService();
  final roleService = RoleService();
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  List<SecurityProfileModel> all = [];
  List<SecurityProfileModel> filtered = [];
  List<RoleModel> roles = [];
  bool loading = true;

  final Map<String, Future<List<String>>> _roleNamesCache = {};

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
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
        _roleNamesCache.clear();
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

  Future<void> _openNewUser() async {
    final result =
        await context.push('/security/profiles/new');

    if (result == true) {
      await loadAll();
    }
  }

  // ✅ NUOVA: DELETE PAGE
  Future<void> _deleteUser(SecurityProfileModel p) async {
    final result = await context.push(
      '/security/profiles/delete',
      extra: {
        'id': p.id,
        'nome': p.nome,
        'cognome': p.cognome,
        'email': p.email,
      },
    );

    if (result == true) {
      await loadAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = context.responsive;

    return BasePage(
      title: 'Utenti',
      subtitle: 'Assegnazione ruoli agli utenti registrati',
      loading: loading,
      empty: !loading && filtered.isEmpty,
      emptyMessage: 'Nessun utente trovato',
      actions: [
        FilledButton.icon(
          onPressed: _openNewUser,
          icon: const Icon(Icons.add),
          label: const Text('Nuovo Utente'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearch(screen),
          const SizedBox(height: 24),
          Expanded(child: _buildContent(screen)),
        ],
      ),
    );
  }

  // SEARCH

  Widget _buildSearch(Responsive screen) {
    return SizedBox(
      width: screen.isMobile ? double.infinity : 420,
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Cerca per nome o email',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (_) => applyFilter(),
      ),
    );
  }

  // CONTENT

  Widget _buildContent(Responsive screen) {
    if (screen.isMobile) {
      return _buildMobileList();
    }
    return _buildTable();
  }

  // MOBILE

  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = filtered[i];

        return Card(
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.manage_accounts),
                  onPressed: () => _openRoles(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TABLE
  Widget _buildTable() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        primary: true, // ✅ fondamentale
        child: ResponsiveTable(
          controller: scrollController, // ✅ solo orizzontale
          minWidth: 1200,
          columns: const [
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Creato il')),
            DataColumn(label: Text('Password')),
            DataColumn(label: Text('Ruoli')),
            DataColumn(label: Text('Azioni')),
          ],
          rows: filtered.map(_buildRow).toList(),
        ),
      ),
    );
  }
 
  DataRow _buildRow(SecurityProfileModel p) {
    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(
              '${p.cognome.isNotEmpty ? p.cognome[0] : ''}'
              '${p.nome.isNotEmpty ? p.nome[0] : ''}',
            ),
          ),
          const SizedBox(width: 12),
          Text(p.fullName),
        ],
      )),

      DataCell(SizedBox(
        width: 240,
        child: Text(
          p.email,
          overflow: TextOverflow.ellipsis,
        ),
      )),

      DataCell(Text(_formatDate(p.createdAt))),

      DataCell(
        InkWell(
          onTap: () async {
            await profileService.updatePasswordChanged(
              profileId: p.id,
              passwordChanged: !p.passwordChanged,
            );
            await loadAll();
          },
          child: Row(
            children: [
              Icon(
                p.passwordChanged
                    ? Icons.check_circle
                    : Icons.cancel,
                color: p.passwordChanged
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(p.passwordChanged ? 'Sì' : 'No'),
            ],
          ),
        ),
      ),

      DataCell(
        FutureBuilder<List<String>>(
          future: _loadRoleNames(p.id),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 2),
              );
            }

            if (snap.data!.isEmpty) {
              return const Text('—');
            }

            return Wrap(
              spacing: 4,
              children: snap.data!
                  .map((r) => Chip(label: Text(r)))
                  .toList(),
            );
          },
        ),
      ),

      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: () => _openRoles(p),
          ),
          IconButton(
//            icon: const Icon(Icons.delete, color: Colors.red),
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteUser(p),
          ),
        ],
      )),
    ]);
  }

  // HELPERS

  Future<List<String>> _loadRoleNames(String profileId) {
    return _roleNamesCache.putIfAbsent(profileId, () async {
      final ids =
          await profileService.getProfileRoleIds(profileId);

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