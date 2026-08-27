import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:boulder_competition/l10n/app_localizations.dart';

import '../data/athlete_check_in_scan_service.dart';

class AthleteCheckInScanPage extends StatefulWidget {
  const AthleteCheckInScanPage({
    super.key,
  });

  @override
  State<AthleteCheckInScanPage> createState() =>
      _AthleteCheckInScanPageState();
}

class _AthleteCheckInScanPageState
    extends State<AthleteCheckInScanPage> {
  final service = AthleteCheckInScanService();
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  MobileScannerController? _controller;

  bool _processing = false;
  final bool _cameraUnavailable = false;
  String? _cameraErrorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // =========================================================
  // SCANSIONE QR
  // =========================================================

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;

    if (raw == null) return;

    final parsed = service.parseQrPayload(raw);

    if (parsed == null) {
      _showResultAndReturn(
        success: false,
        message: l10n.athleteMessageCustom96, // 'QR code non valido per questa app'
      );
      return;
    }

    final competitionId = parsed['competition_id'];

    if (competitionId == null) {
      _showResultAndReturn(
        success: false,
        message: l10n.athleteMessageCustom96, // 'QR code non valido per questa app'
      );
      return;
    }

    setState(() => _processing = true);

    await _controller?.stop();

    final result = await service.performCheckIn(
      competitionId: competitionId,
    );

    if (!mounted) return;

    _showResultAndReturn(
      success: result.success,
      message: result.message,
    );
  }

  // =========================================================
  // ESITO
  // =========================================================

  void _showResultAndReturn({
    required bool success,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle : Icons.error_outline,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(
          success ? l10n.athleteMessageCustom106 // 'Check-in effettuato'
                  : l10n.athleteMessageCustom98, // 'Attenzione'
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(success);
            },
            child: Text(l10n.athleteMessageCustom99), // 'OK'
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.athleteMessageCustom79), // 'Check-in Gara'
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _cameraUnavailable
          ? _buildCameraUnavailableView(l10n)
          : _buildScannerView(l10n),
    );
  }

  Widget _buildScannerView(AppLocalizations l10n) {
    if (_controller == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),

        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: _processing ? Colors.orange : Colors.white,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              _processing
                  ? l10n.athleteMessageCustom101 // 'Verifica in corso...'
                  : l10n.athleteMessageCustom107, // 'Inquadra il QR della gara'
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (_processing)
          const Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraUnavailableView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.athleteMessageCustom103, // 'Fotocamera non disponibile'
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.athleteMessageCustom108, // 'Per effettuare il check-in è necessario utilizzare un dispositivo dotato di fotocamera.'
              style: const TextStyle(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (_cameraErrorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _cameraErrorMessage!,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              label: Text(
                l10n.athleteMessageCustom105, // 'Torna indietro'
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}