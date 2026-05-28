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

  double difficolta = 1;

  String? colore;

  late TextEditingController
      valoreCtrl;

  bool loading = false;

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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Difficoltà',
                        style: TextStyle(
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
                          borderRadius:
                              BorderRadius.circular(12),
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Facile'),
                      Text('Difficile'),
                    ],
                  ),
                ],
              ),

              // =========================================
              // COLORE
              // =========================================
              DropdownButtonFormField<String>(
                value: colore,
                decoration: const InputDecoration(
                  labelText: 'Colore',
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Nessun colore'),
                  ),

                  DropdownMenuItem(
                    value: 'Bianco',
                    child: Text('⚪ Bianco'),
                  ),

                  DropdownMenuItem(
                    value: 'Giallo',
                    child: Text('🟡 Giallo'),
                  ),

                  DropdownMenuItem(
                    value: 'Verde',
                    child: Text('🟢 Verde'),
                  ),

                  DropdownMenuItem(
                    value: 'Blu',
                    child: Text('🔵 Blu'),
                  ),

                  DropdownMenuItem(
                    value: 'Rosso',
                    child: Text('🔴 Rosso'),
                  ),

                  DropdownMenuItem(
                    value: 'Nero',
                    child: Text('⚫ Nero'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    colore = value;
                  });
                },
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
              // MULTI CREATE
              // =========================================

              if (!isEdit) ...[
                TextFormField(
                  controller: boulderDaCreareCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Boulder da creare',
                    helperText: 'Valori ammessi da 1 a 20',
                  ),

                  validator: (value) {
                    final n = int.tryParse(value ?? '');

                    if (n == null) {
                      return 'Inserire un numero';
                    }

                    if (n < 1 || n > 20) {
                      return 'Valore ammesso: 1-20';
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