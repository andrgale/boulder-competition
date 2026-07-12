import 'package:flutter/material.dart';

import '../data/import_job_row_service.dart';
import '../models/import_job_model.dart';
import '../models/import_job_row_model.dart';

class ImportJobRowsPage extends StatefulWidget {
  final ImportJobModel job;

  const ImportJobRowsPage({
    super.key,
    required this.job,
  });

  @override
  State<ImportJobRowsPage> createState() =>
      _ImportJobRowsPageState();
}

class _ImportJobRowsPageState
    extends State<ImportJobRowsPage> {
  final service = ImportJobRowService();

  List<ImportJobRowModel> rows = [];
  bool loading = true;
  bool onlyDiscarded = false;

  @override
  void initState() {
    super.initState();
    loadRealtime();
  }

  Future<void> refreshData() async {
    final data = await service.getImportJobRows(widget.job.id);

    if (!mounted) return;

    setState(() {
      rows = data;
      loading = false;
    });
  }

  void loadRealtime() {
    service.watchImportJobRows(widget.job.id).listen((data) {
      if (!mounted) return;

      data.sort(
        (a, b) => a.rowNumber.compareTo(b.rowNumber),
      );

      setState(() {
        rows = data;
        loading = false;
      });
    });
  }

  List<ImportJobRowModel> get filteredRows {
    if (!onlyDiscarded) return rows;

    return rows
        .where((e) => e.status == 'DISCARDED')
        .toList();
  }

  Color getRowColor(String status) {
    switch (status) {
      case 'INSERTED':
        return Colors.green.shade50;
      case 'DISCARDED':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'INSERTED':
        return Colors.green;
      case 'DISCARDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final competitionName =
        widget.job.competitionDescription ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio import CSV'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competitionName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(widget.job.fileName),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('Totali ${widget.job.totalRows}')),
                            Chip(label: Text('Inseriti ${widget.job.insertedRows}')),
                            Chip(label: Text('Scartati ${widget.job.discardedRows}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Mostra solo gli scarti'),
                  value: onlyDiscarded,
                  onChanged: (v) {
                    setState(() {
                      onlyDiscarded = v;
                    });
                  },
                ),
                const Divider(height: 1),
                Expanded(
                  child: filteredRows.isEmpty
                      ? const Center(
                          child: Text('Nessuna riga trovata'),
                        )
                      : ListView.builder(
                          itemCount: filteredRows.length,
                          itemBuilder: (context, index) {
                            final row = filteredRows[index];

                            return Card(
                              color: getRowColor(row.status),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: getStatusColor(row.status),
                                  child: Text(
                                    row.rowNumber.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  row.status == 'INSERTED'
                                      ? 'Importata'
                                      : 'Scartata',
                                ),
                                subtitle: Text('Riga ${row.rowNumber}'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Riga CSV',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SelectableText(row.rawRow),
                                        ), 
                                        const SizedBox(height: 4),
                                        SelectableText(row.rawRow),
                                        if (row.errorMessage != null &&
                                            row.errorMessage!.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Motivo scarto',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            row.errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}