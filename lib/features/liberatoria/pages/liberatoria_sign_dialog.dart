import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import 'package:boulder_competition/l10n/app_localizations.dart';

class LiberatoriaSignResult {
  final Uint8List png;
  final String? tutore;
  LiberatoriaSignResult(this.png, this.tutore);
}

class LiberatoriaSignDialog extends StatefulWidget {
  final String athleteName;
  final bool needsTutore;
  final List<Uint8List> logos;

  /// Restituisce il testo già compilato (aggiornato col nome del tutore).
  final String Function(String tutore) renderText;

  const LiberatoriaSignDialog({
    super.key,
    required this.athleteName,
    required this.needsTutore,
    required this.logos,
    required this.renderText,
  });

  @override
  State<LiberatoriaSignDialog> createState() => _LiberatoriaSignDialogState();
}

class _LiberatoriaSignDialogState extends State<LiberatoriaSignDialog> {
  final _sig = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final _tutore = TextEditingController();

  @override
  void dispose() {
    _sig.dispose();
    _tutore.dispose();
    super.dispose();
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.needsTutore && _tutore.text.trim().isEmpty) {
      _msg(l10n.liberatoriaTutoreRequired);
      return;
    }
    if (_sig.isEmpty) {
      _msg(l10n.liberatoriaSignatureRequired);
      return;
    }

    final png = await _sig.toPngBytes();
    if (png == null || !mounted) return;

    Navigator.pop(
      context,
      LiberatoriaSignResult(
        png,
        widget.needsTutore ? _tutore.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.liberatoriaSignTitle} — ${widget.athleteName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.logos.isNotEmpty) ...[
                          Wrap(
                            spacing: 16,
                            children: widget.logos
                                .map((b) => Image.memory(b, height: 48))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(widget.renderText(_tutore.text.trim())),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.needsTutore) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _tutore,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.liberatoriaTutoreLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(l10n.liberatoriaSignHere,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Signature(
                    controller: _sig,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _sig.clear,
                    child: Text(l10n.liberatoriaClearSignature),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _confirm,
                    child: Text(l10n.liberatoriaConfirmSign),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}