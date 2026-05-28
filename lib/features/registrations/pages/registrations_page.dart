import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/registration_service.dart';
import '../models/registration_model.dart';

class RegistrationsPage extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const RegistrationsPage({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  State<RegistrationsPage> createState() =>
      _RegistrationsPageState();
}

class _RegistrationsPageState
    extends State<RegistrationsPage> {
  final service = RegistrationService();

  List<RegistrationModel> registrations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadRealtime();
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshData() async {
    final rows = await service.getRegistrations(
      widget.competitionId,
    );

    if (!mounted) return;

    setState(() {
      registrations = rows;
      loading = false;
    });
  }

  // =====================================================
  // REALTIME
  // =====================================================

  void loadRealtime() {
    service
        .watchRegistrations(
          widget.competitionId,
        )
        .listen((rows) {
      if (!mounted) return;

      setState(() {
        registrations = rows;
        loading = false;
      });
    });
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> deleteRegistration(
    String id,
  ) async {
    try {
      await service.deleteRegistration(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Iscrizione eliminata',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore: $e',
          ),
        ),
      );
    }

    await refreshData();
  }

  // =====================================================
  // NAV CREATE
  // =====================================================

  Future<void> openCreate() async {
    final res = await context.push(
      '/registrations/new',
      extra: widget.competitionId,
    );

    if (res == true) {
      await refreshData();
    }
  }

  // =====================================================
  // NAV EDIT
  // =====================================================

  Future<void> openEdit(
    RegistrationModel r,
  ) async {
    final res = await context.push(
      '/registrations/edit',
      extra: {
        'competitionId':
            widget.competitionId,
        'registration': r,
      },
    );

    if (res == true) {
      await refreshData();
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width <
            700;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Iscrizioni - ${widget.competitionName}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openCreate,
          ),
        ],
      ),

      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: openCreate,
              child: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : registrations.isEmpty
              ? const Center(
                  child: Text(
                    'Nessuna iscrizione',
                  ),
                )
              : ListView.builder(
                  itemCount:
                      registrations.length,
                  itemBuilder:
                      (context, index) {
                    final r =
                        registrations[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          r.pettorale
                                  ?.toString() ??
                              '-',
                        ),
                      ),

                      title: Text(
                        '${r.cognome} ${r.nome}',
                      ),

                      subtitle: Text(
                        '${r.email}'
                        '${r.societa != null && r.societa!.isNotEmpty ? ' | ${r.societa}' : ''}',
                      ),

                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          if (r.flPagato)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                right: 8,
                              ),
                              child: Icon(
                                Icons.euro,
                                color:
                                    Colors.green,
                              ),
                            ),

                          if (r.flPresente)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                right: 8,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color:
                                    Colors.blue,
                              ),
                            ),

                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed:
                                () => openEdit(
                                  r,
                                ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed:
                                () =>
                                    deleteRegistration(
                                      r.id,
                                    ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}