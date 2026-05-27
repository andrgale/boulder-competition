import 'package:flutter/material.dart';

import '../data/boulder_service.dart';
import '../models/boulder_model.dart';

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

  final formKey =
      GlobalKey<FormState>();

  late TextEditingController numeroCtrl;

  late TextEditingController
      difficoltaCtrl;

  late TextEditingController
      coloreCtrl;

  late TextEditingController
      valoreCtrl;

  bool loading = false;

  bool get isEdit =>
      widget.boulder != null;

  @override
  void initState() {
    super.initState();

    final b = widget.boulder;

    numeroCtrl = TextEditingController(
      text: b?.numero.toString() ?? '',
    );

    difficoltaCtrl = TextEditingController(
      text: b?.difficolta.toString() ?? '',
    );

    coloreCtrl = TextEditingController(
      text: b?.colore ?? '',
    );

    valoreCtrl = TextEditingController(
      text: b?.valoreTeorico.toString() ?? '1000',
    );

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
    difficoltaCtrl.dispose();
    coloreCtrl.dispose();
    valoreCtrl.dispose();

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

      final difficolta =
          int.parse(
        difficoltaCtrl.text,
      );

      final colore =
          coloreCtrl.text.trim().isEmpty
              ? null
              : coloreCtrl.text.trim();

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
          difficolta: difficolta,
          colore: colore,
          valoreTeorico: valore,
        );
      } else {
        await service.createBoulder(
          competitionId:
              widget.competitionId,
          numero: numero,
          difficolta: difficolta,
          colore: colore,
          valoreTeorico: valore,
        );
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
            'Errore: $e',
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
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Modifica Boulder'
              : 'Nuovo Boulder',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // =========================================
              // NUMERO
              // =========================================

              TextFormField(
                controller: numeroCtrl,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Numero Boulder',
                ),
                keyboardType:
                    TextInputType.number,
                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Obbligatorio';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================================
              // DIFFICOLTA
              // =========================================

              TextFormField(
                controller:
                    difficoltaCtrl,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Difficoltà',
                ),
                keyboardType:
                    TextInputType.number,
                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Obbligatorio';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================================
              // COLORE
              // =========================================

              TextFormField(
                controller: coloreCtrl,
                decoration:
                    const InputDecoration(
                  labelText: 'Colore',
                ),
              ),

              const SizedBox(height: 16),

              // =========================================
              // VALORE
              // =========================================

              TextFormField(
                controller: valoreCtrl,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Valore teorico',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Obbligatorio';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 32),

              // =========================================
              // SAVE BUTTON
              // =========================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : save,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      isEdit
                          ? 'Aggiorna'
                          : 'Crea',
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