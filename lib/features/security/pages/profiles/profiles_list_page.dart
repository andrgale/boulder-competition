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

  List<SecurityProfileModel> all = [];
  List<SecurityProfileModel> filtered = [];
  List<RoleModel> roles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
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
        filtered = all;
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
          SizedBox(
            width: 360,
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
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    '${p.cognome.isNotEmpty ? p.cognome[0] : ''}${p.nome.isNotEmpty ? p.nome[0] : ''}'),
              ),
              title: Text(p.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(p.email),
              trailing: IconButton(
                tooltip: 'Gestisci ruoli',
                icon: const Icon(Icons.manage_accounts),
                onPressed: () async {
                  await context.push('/security/profiles/roles',
                      extra: {'profile': p, 'roles': roles});
                  await loadAll();
                },
              ),
            ),
          );
        },
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        columnSpacing: 48,
        horizontalMargin: 32,
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        headingRowHeight: 56,
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Password cambiata')),
          DataColumn(label: Text('Azioni')),
        ],
        rows: filtered.map((p) {
          return DataRow(cells: [
            DataCell(Text(p.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(p.email)),
            DataCell(Icon(
              p.passwordChanged ? Icons.check_circle : Icons.cancel,
              color: p.passwordChanged ? Colors.green : Colors.red,
            )),
            DataCell(IconButton(
              tooltip: 'Gestisci ruoli',
              icon: const Icon(Icons.manage_accounts),
              onPressed: () async {
                await context.push('/security/profiles/roles',
                    extra: {'profile': p, 'roles': roles});
                await loadAll();
              },
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
