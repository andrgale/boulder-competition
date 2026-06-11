import 'package:flutter/material.dart';

import '../../athlete/models/athlete_boulder_model.dart';
import '../data/ascents_boulders_service.dart';

class AscentsBouldersFormPage extends StatefulWidget {
  final String registrationId;
  final String athleteName;
  final AthleteBoulderModel boulder;

  const AscentsBouldersFormPage({
    super.key,
    required this.registrationId,
    required this.athleteName,
    required this.boulder,
  });

  @override
  State<AscentsBouldersFormPage> createState() =>
      _AscentsBouldersFormPageState();
}

class _AscentsBouldersFormPageState
    extends State<AscentsBouldersFormPage> {
  final service = AscentsBouldersService();
  final formKey = GlobalKey<FormState>();

  bool top = false;
  bool zone = false;
  int tentativiTop = 0;
  int tentativiZone = 0;

  bool saving = false;

  // controller per i campi numerici
  late TextEditingController tentativiTopController;
  late TextEditingController tentativiZoneController;

  @override
  void initState() {
    super.initState();

    // pre-popola con i dati esistenti del boulder passato
    top = widget.boulder.top;
    zone = widget.boulder.zone;
    tentativiTop = widget.boulder.tentativiTop;
    tentativiZone = widget.boulder.tentativiZone;

    tentativiTopController =
        TextEditingController(text: tentativiTop.toString());
    tentativiZoneController =
        TextEditingController(text: tentativiZone.toString());
  }

  @override
  void dispose() {
    tentativiTopController.dispose();
    tentativiZoneController.dispose();
    super.dispose();
  }

  // =========================================================
  // COLORE
  // =========================================================

  Color _parseColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'rosso':
        return Colors.red;
      case 'blu':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'giallo':
        return Colors.yellow.shade700;
      case 'nero':
        return Colors.black;
      case 'bianco':
        return Colors.grey.shade300;
      case 'arancione':
        return Colors.orange;
      case 'viola':
        return Colors.purple;
      case 'rosa':
        return Colors.pink;
      case 'grigio':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  // =========================================================
  // LOGICA AUTOMATICA top/zone
  // =========================================================

  // Se top viene attivato → zone si attiva automaticamente
  // Se zone viene disattivato → top si disattiva automaticamente
  void onTopChanged(bool val) {
    setState(() {
      top = val;
      if (val) zone = true;
      if (!val) {
        tentativiTop = 0;
        tentativiTopController.text = '0';
      }
    });
  }

  void onZoneChanged(bool val) {
    setState(() {
      zone = val;
      if (!val) {
        top = false;
        tentativiTop = 0;
        tentativiZone = 0;
        tentativiTopController.text = '0';
        tentativiZoneController.text = '0';
      }
    });
  }

  // =========================================================
  // SAVE
  // =========================================================

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final tt = int.tryParse(tentativiTopController.text) ?? 0;
      final tz = int.tryParse(tentativiZoneController.text) ?? 0;

      await service.upsertAscent(
        registrationId: widget.registrationId,
        boulderId: widget.boulder.boulderId,
        top: top,
        zone: zone,
        tentativiTop: tt,
        tentativiZone: tz,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ascent salvato')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final b = widget.boulder;
    final boulderColor = _parseColor(b.colore);

    return Scaffold(
      appBar: AppBar(
        title: Text('Boulder ${b.numero} — ${widget.athleteName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: saving ? null : save,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(saving ? 'Salvataggio...' : 'Salva'),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── info boulder ────────────────────────────────
              _BoulderInfoCard(
                boulder: b,
                color: boulderColor,
              ),

              const SizedBox(height: 32),

              // ─── zone ────────────────────────────────────────
              const _SectionLabel('ZONE'),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Zone raggiunta',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                          'L\'atleta ha raggiunto la zona intermedia'),
                      value: zone,
                      onChanged: onZoneChanged,
                    ),
                    if (zone) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _CounterField(
                          label: 'Tentativi Zone',
                          controller: tentativiZoneController,
                          enabled: zone,
                          onChanged: (v) =>
                              tentativiZone = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── top ─────────────────────────────────────────
              const _SectionLabel('TOP'),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Top raggiunto',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                          'L\'atleta ha completato il boulder'),
                      value: top,
                      onChanged: zone ? onTopChanged : null,
                    ),
                    if (top) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _CounterField(
                          label: 'Tentativi Top',
                          controller: tentativiTopController,
                          enabled: top,
                          onChanged: (v) =>
                              tentativiTop = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── riepilogo stato ─────────────────────────────
              _StatusSummary(top: top, zone: zone),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// BOULDER INFO CARD
// ──────────────────────────────────────────────────────────────

class _BoulderInfoCard extends StatelessWidget {
  final AthleteBoulderModel boulder;
  final Color color;

  const _BoulderInfoCard({
    required this.boulder,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color,
              child: Text(
                '${boulder.numero}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _contrastColor(color),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boulder ${boulder.numero}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.terrain, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(boulder.colore ?? '—'),
                      const SizedBox(width: 16),
                      const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Difficoltà ${boulder.difficolta}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _contrastColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// ──────────────────────────────────────────────────────────────
// COUNTER FIELD  (+/- buttons)
// ──────────────────────────────────────────────────────────────

class _CounterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _CounterField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  void _increment() {
    final current = int.tryParse(controller.text) ?? 0;
    final next = (current + 1).toString();
    controller.text = next;
    onChanged(next);
  }

  void _decrement() {
    final current = int.tryParse(controller.text) ?? 0;
    if (current <= 0) return;
    final next = (current - 1).toString();
    controller.text = next;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 16),
        IconButton.outlined(
          onPressed: enabled ? _decrement : null,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            validator: (v) {
              if (!enabled) return null;
              final n = int.tryParse(v ?? '');
              if (n == null || n < 0) return 'n/v';
              return null;
            },
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: enabled ? _increment : null,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// STATUS SUMMARY
// ──────────────────────────────────────────────────────────────

class _StatusSummary extends StatelessWidget {
  final bool top;
  final bool zone;

  const _StatusSummary({required this.top, required this.zone});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    String label;

    if (top) {
      bgColor = Colors.green;
      icon = Icons.emoji_events;
      label = 'TOP';
    } else if (zone) {
      bgColor = Colors.orange;
      icon = Icons.flag;
      label = 'ZONE';
    } else {
      bgColor = Colors.grey.shade400;
      icon = Icons.block;
      label = 'NESSUN RISULTATO';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: bgColor, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// SECTION LABEL
// ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.grey,
        letterSpacing: 1.4,
      ),
    );
  }
}
