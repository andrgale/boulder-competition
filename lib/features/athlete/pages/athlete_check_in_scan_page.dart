import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        message: 'QR code non valido per questa app',
      );
      return;
    }

    final competitionId = parsed['competition_id'];

    if (competitionId == null) {
      _showResultAndReturn(
        success: false,
        message: 'QR code non valido',
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
          success ? 'Check-in effettuato' : 'Attenzione',
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(success);
            },
            child: const Text('OK'),
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
        title: const Text('Check-in gara'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _cameraUnavailable
          ? _buildCameraUnavailableView()
          : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
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
          onDetect: _onDetect,
        ),

        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: _processing
                    ? Colors.orange
                    : Colors.white,
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
                  ? 'Verifica in corso...'
                  : 'Inquadra il QR della gara',
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

  Widget _buildCameraUnavailableView() {
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
            const Text(
              'Fotocamera non disponibile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Per effettuare il check-in è necessario utilizzare un dispositivo dotato di fotocamera.',
              style: TextStyle(
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
              label: const Text(
                'Torna indietro',
                style: TextStyle(
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