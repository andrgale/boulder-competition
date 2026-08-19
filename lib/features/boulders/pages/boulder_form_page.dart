import 'package:flutter/material.dart';

import '../data/boulder_service.dart';
import '../models/boulder_model.dart';
import 'boulder_card_export_pdf.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

class BoulderFormPage extends StatefulWidget {
  final String competitionId;
  final BoulderModel? boulder;

  const BoulderFormPage({
    super.key,
    required this.competitionId,
    this.boulder,
  });

  @override
  State<BoulderFormPage> createState() =>
      _BoulderFormPageState();
}

class _BoulderFormPageState
    extends State<BoulderFormPage> {
  final service = BoulderService();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final formKey =
      GlobalKey<FormState>();

  late TextEditingController numeroCtrl;

  double difficolta = 1;

  String? colore;

  late TextEditingController
      valoreCtrl;
  bool isFinale = false;
  bool loading = false;
  bool _exportingCartellino = false; // ← aggiunto

  bool get isEdit =>
      widget.boulder != null;

  late TextEditingController boulderDaCreareCtrl;

  @override
  void initState() {
    super.initState();

    final b = widget.boulder;

    numeroCtrl = TextEditingController(
      text: b?.numero.toString() ?? '',
    );

    difficolta = (b?.difficolta ?? 1).toDouble();
    
    colore = b?.colore;

    valoreCtrl = TextEditingController(
      text: b?.valoreTeorico.toString() ?? '1000',
    );

    boulderDaCreareCtrl = TextEditingController(
      text: '1',
    );

    isFinale = b?.isFinale ?? false;

    // AUTO NUMERO SOLO IN CREATE
    if (!isEdit) {
      loadNextNumero();
    }
  }

  Future<void> loadNextNumero() async {
    final next = await service.getNextNumero(
      widget.competitionId,
    );

    if (!mounted) return;

    numeroCtrl.text = next.toString();
  }

  @override
  void dispose() {
    numeroCtrl.dispose();
    valoreCtrl.dispose();
    boulderDaCreareCtrl.dispose();

    super.dispose();
  }

  // =====================================================
  // SAVE
  // =====================================================

  Future<void> save() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final numero = int.parse(
        numeroCtrl.text,
      );

      final valore = double.parse(
        valoreCtrl.text.replaceAll(
          ',',
          '.',
        ),
      );

      if (isEdit) {
        await service.updateBoulder(
          id: widget.boulder!.id,
          numero: numero,
          difficolta:
              difficolta.toInt(),
          colore: colore,
          valoreTeorico: valore,
          isfinale: isFinale,
        );
      } else {
        final totale =
            int.parse(
          boulderDaCreareCtrl.text,
        );

        for (int i = 0;
            i < totale;
            i++) {
          await service.createBoulder(
            competitionId:
                widget.competitionId,

            numero: numero + i,

            difficolta:
                difficolta.toInt(),

            colore: colore,

            valoreTeorico: valore,

            isfinale: isFinale,
          );
        }
      }

      if (mounted) {
        Navigator.pop(
          context,
          true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
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
  // STAMPA CARTELLINO — solo in modifica (boulder già creato)
  // =====================================================

  Future<void> _printCartellino() async {
    final b = widget.boulder;
    if (b == null || _exportingCartellino) return;

    setState(() => _exportingCartellino = true);

    try {
      await BoulderCardExportPdf.exportAndShare(
        competitionId: widget.competitionId,
        boulderId: b.id,
        numero: int.tryParse(numeroCtrl.text) ?? b.numero,
        difficolta: difficolta.toInt(),
        colore: colore,
        l10n: l10n,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore stampa cartellino: $e')),
      );
    } finally {
      if (mounted) setState(() => _exportingCartellino = false);
    }
  }

  // =====================================================
  // UI
  // =====================================================


@override
Widget build(BuildContext context) {

  return Scaffold(
    appBar: AppBar(
      title: Text(
        isEdit ? l10n.boulderMessageCustom9 : l10n.boulderMessageCustom10, // 'Modifica Boulder' / 'Nuovo Boulder'
      ),
      actions: [
        // ── bottone cartellino: solo in modifica ──────────
        if (isEdit)
          _exportingCartellino
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  tooltip: l10n.boulderMessageCustom24, // 'Stampa cartellino QR'
                  icon: const Icon(Icons.qr_code),
                  onPressed: _printCartellino,
                ),
      ],
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // =========================================
            // NUMERO
            // =========================================

            TextFormField(
              controller: numeroCtrl,
              decoration: InputDecoration(
                labelText: l10n.boulderMessageCustom11, // 'Numero Boulder'
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.boulderMessageCustom12; // 'Obbligatorio'
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // =========================================
            // DIFFICOLTA
            // =========================================

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.boulderMessageCustom13, // 'Difficoltà'
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        difficolta.toInt().toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Slider(
                  value: difficolta,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: difficolta.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      difficolta = value;
                    });
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.boulderMessageCustom14), // 'Facile'
                    Text(l10n.boulderMessageCustom15), // 'Difficile'
                  ],
                ),
              ],
            ),

            // =========================================
            // COLORE
            // =========================================
            DropdownButtonFormField<String>(
              initialValue: colore,
              decoration: InputDecoration(
                labelText: l10n.boulderMessageCustom16, // 'Colore'
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.boulderMessageCustom17), // 'Nessun colore'
                ),
                DropdownMenuItem(
                  value: 'Bianco',
                  child: Text(l10n.boulderMessageCustom18), // '⚪ Bianco'
                ),
                DropdownMenuItem(
                  value: 'Giallo',
                  child: Text(l10n.boulderMessageCustom19), // '🟡 Giallo'
                ),
                DropdownMenuItem(
                  value: 'Verde',
                  child: Text(l10n.boulderMessageCustom20), // '🟢 Verde'
                ),
                DropdownMenuItem(
                  value: 'Blu',
                  child: Text(l10n.boulderMessageCustom21), // '🔵 Blu'
                ),
                DropdownMenuItem(
                  value: 'Rosso',
                  child: Text(l10n.boulderMessageCustom22), // '🔴 Rosso'
                ),
                DropdownMenuItem(
                  value: 'Nero',
                  child: Text(l10n.boulderMessageCustom23), // '⚫ Nero'
                ),
              ],
              onChanged: (value) {
                setState(() {
                  colore = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            // =========================================
            // SOLO FINALE
            // =========================================

            SwitchListTile(
              value: isFinale,

              title: Text(
                l10n.boulderMessageCustom25, // 'Solo finale'
              ),

              subtitle: Text(
                l10n.boulderMessageCustom26, // 'Il boulder sarà disponibile solo nella fase finale'
              ),

              contentPadding: EdgeInsets.zero,

              onChanged: (value) {
                setState(() {
                  isFinale = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // =========================================
            // VALORE
            // =========================================

            TextFormField(
              controller: valoreCtrl,
              decoration: InputDecoration(
                labelText: l10n.boulderMessageCustom27, // 'Valore teorico'
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return l10n.boulderMessageCustom12; // 'Obbligatorio' (reuse)
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // =========================================
            // MULTI CREATE
            // =========================================

            if (!isEdit) ...[
              TextFormField(
                controller: boulderDaCreareCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.boulderMessageCustom28, // 'Boulder da creare'
                  helperText: l10n.boulderMessageCustom29, // 'Valori ammessi da 1 a 20'
                ),

                validator: (value) {
                  final n = int.tryParse(value ?? '');

                  if (n == null) {
                    return l10n.boulderMessageCustom30; // 'Inserire un numero'
                  }

                  if (n < 1 || n > 20) {
                    return l10n.boulderMessageCustom31; // 'Valore ammesso: 1-20'
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),
            ],


            // =========================================
            // SAVE BUTTON
            // =========================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Text(
                    isEdit ? l10n.boulderMessageCustom32 : l10n.boulderMessageCustom33, // 'Aggiorna' / 'Crea'
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
