import 'package:boulder_competition/core/services/email_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/app_snackbar.dart';
import '../../data/security_profile_service.dart';
import '../../models/security_profile_model.dart';
import '../../models/role_model.dart';

class ProfileRolesPage extends StatefulWidget {
  final SecurityProfileModel profile;
  final List<RoleModel> roles;

  const ProfileRolesPage({
    super.key,
    required this.profile,
    required this.roles,
  });

  @override
  State<ProfileRolesPage> createState() => _ProfileRolesPageState();
}

class _ProfileRolesPageState extends State<ProfileRolesPage> {
  final service = SecurityProfileService(
    Supabase.instance.client,
    EmailService(Supabase.instance.client),
  );


  Set<String> selectedRoleIds = {};
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadCurrentRoles();
  }

  Future<void> loadCurrentRoles() async {
    try {
      final ids = await service.getProfileRoleIds(widget.profile.id);
      if (!mounted) return;
      setState(() {
        selectedRoleIds = Set<String>.from(ids);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppSnackbar.error(context, 'Errore: $e');
    }
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      await service.setProfileRoles(
        profileId: widget.profile.id,
        roleIds: selectedRoleIds.toList(),
      );
      if (!mounted) return;
      AppSnackbar.success(context, 'Ruoli aggiornati');
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    '${widget.profile.cognome.isNotEmpty ? widget.profile.cognome[0] : ''}'
                    '${widget.profile.nome.isNotEmpty ? widget.profile.nome[0] : ''}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.fullName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.profile.email,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                if (saving)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // content
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'RUOLI ASSEGNATI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: widget.roles.map((role) {
                            final isSelected =
                                selectedRoleIds.contains(role.id);
                            return CheckboxListTile(
                              title: Text(role.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(role.code,
                                  style: const TextStyle(
                                      fontFamily: 'monospace')),
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  val ?? false
                                      ? selectedRoleIds.add(role.id)
                                      : selectedRoleIds.remove(role.id);
                                });
                              },
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),

          // save bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: saving ? null : save,
                  icon: const Icon(Icons.save),
                  label: const Text('Salva Ruoli'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
