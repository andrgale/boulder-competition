import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/registration_service.dart';
import '../models/registration_model.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
// IMPORT CSV
// =====================================================

  Future<void> importCsv() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      final path =
          result.files.single.path;

      if (path == null) return;

      final file = File(path);

      final csvContent =
          await file.readAsString();

      if (!mounted) return;

      setState(() {
        loading = true;
      });

      debugPrint(
        'IMPORT CSV competitionId=${widget.competitionId}',
      );

      final response =
          await Supabase.instance.client.functions
              .invoke(
        'import_competition_csv',
        body: {
          'competition_id':
              widget.competitionId,
          'csv_content': csvContent,
        },
      );

      debugPrint('STATUS: ${response.status}');
      debugPrint('DATA: ${response.data}');
      debugPrint('TYPE: ${response.data.runtimeType}');

      if (!mounted) return;

      debugPrint(response.data.toString());

      if (response.data != null) {
        final inserted =
            response.data['inserted'] ?? 0;

        final discarded =
            response.data['discarded'] ?? 0;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Import completato - '
              'Inseriti: $inserted '
              'Scartati: $discarded',
            ),
          ),
        );

        await refreshData();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Errore import CSV: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
            tooltip: 'Importa CSV',
            icon: const Icon(
              Icons.upload_file,
            ),
            onPressed: importCsv,
          ),

          IconButton(
            tooltip: 'Nuova iscrizione',
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