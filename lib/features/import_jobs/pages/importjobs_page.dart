import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/import_job_service.dart';
import '../models/import_job_model.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class ImportJobsPage extends StatefulWidget {
  const ImportJobsPage({super.key});

  @override
  State<ImportJobsPage> createState() => _ImportJobsPageState();
}

class _ImportJobsPageState extends State<ImportJobsPage> {
  final service = ImportJobService();
  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();
  StreamSubscription<List<ImportJobModel>>? _realtimeSubscription;

  List<ImportJobModel> jobs = [];

  bool loading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshData() async {
    final rows = await service.getImportJobs();

    if (!mounted) return;

    setState(() {
      jobs = rows;
      loading = false;
    });
  }

  // =====================================================
  // REALTIME
  // =====================================================

  void loadRealtime() {
    _realtimeSubscription = service.watchImportJobs().listen((rows) {
      if (!mounted) return;

      setState(() {
        jobs = rows;
        loading = false;
      });
    });
  }

  // =====================================================
  // DETAIL
  // =====================================================

  Future<void> openDetail(ImportJobModel job) async {
    await context.push('/import-job-rows', extra: job);
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color getStatusColor(String status) {
    switch (status) {
      case 'Completata':
        return Colors.green;

      case 'In corso':
        return Colors.orange;

      case 'Errore':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // DATE FORMAT
  // =====================================================

  String formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importMessageCustom13), // 'Importazioni CSV'
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : jobs.isEmpty
          ? Center(
              child: Text(
                l10n.importMessageCustom14, // 'Nessuna importazione trovata'
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                const minContentWidth = 900.0;
                final contentWidth = constraints.maxWidth > minContentWidth
                    ? constraints.maxWidth
                    : minContentWidth;

                return Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  notificationPredicate: (notif) =>
                      notif.metrics.axis == Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notif) =>
                          notif.metrics.axis == Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: contentWidth),
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(l10n.importMessageCustom15),
                              ), // 'Data importazione'
                              DataColumn(
                                label: Text(l10n.importMessageCustom16),
                              ), // 'Gara'
                              DataColumn(
                                label: Text(l10n.importMessageCustom17),
                              ), // 'File'
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  l10n.importMessageCustom18,
                                ), // 'Totali'
                              ),
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  l10n.importMessageCustom19,
                                ), // 'Inseriti'
                              ),
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  l10n.importMessageCustom20,
                                ), // 'Scartati'
                              ),
                              DataColumn(
                                label: Text(l10n.importMessageCustom21),
                              ), // 'Stato'
                              DataColumn(
                                label: Text(l10n.importMessageCustom22),
                              ), // 'Dettaglio'
                            ],
                            rows: jobs.map((job) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(formatDate(job.startedAt))),
                                  DataCell(
                                    Text(job.competitionDescription ?? '-'),
                                  ),
                                  DataCell(Text(job.fileName)),
                                  DataCell(Text(job.totalRows.toString())),
                                  DataCell(Text(job.insertedRows.toString())),
                                  DataCell(Text(job.discardedRows.toString())),
                                  DataCell(
                                    Chip(
                                      label: Text(job.status),
                                      backgroundColor: getStatusColor(
                                        job.status,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      tooltip: l10n
                                          .importMessageCustom22, // 'Dettaglio'
                                      onPressed: () => openDetail(job),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}