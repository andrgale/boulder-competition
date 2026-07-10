import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/athlete_boulder_scan_service.dart';

class AthleteBoulderScanPage extends StatefulWidget {
  final String competitionId;
  final String registrationId;

  const AthleteBoulderScanPage({
    super.key,
    required this.competitionId,
    required this.registrationId,
  });

  @override
  State<AthleteBoulderScanPage> createState() => _BoulderScanPageState();
}

class _BoulderScanPageState extends State<AthleteBoulderScanPage> {
  final service = AthleteBoulderScanService();
  MobileScannerController? _controller;

  bool _processing = false;
  bool _cameraUnavailable = false;
 // bool _cameraReady = false; // true solo dopo che start() è andato a buon fine
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
  // GESTIONE RILEVAMENTO QR
  // =========================================================

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return; // evita scansioni multiple simultanee

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

    final scannedCompetitionId = parsed['competition_id']!;
    final scannedBoulderId = parsed['boulder_id']!;

    // Ferma la fotocamera mentre elaboriamo, per evitare scan ripetuti.
    setState(() => _processing = true);
    await _controller?.stop();

    final result = await service.registerAscent(
      competitionId: scannedCompetitionId,
      boulderId: scannedBoulderId,
      registrationId: widget.registrationId,
    );

    if (!mounted) return;

    _showResultAndReturn(
      success: result.success,
      message: result.message,
    );
  }

  // =========================================================
  // MOSTRA ESITO E TORNA ALLA PAGINA PRECEDENTE
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
        title: Text(success ? 'Boulder registrato' : 'Attenzione'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // chiude il dialog
              Navigator.of(context).pop(success); // torna alla home atleta
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // GESTIONE ERRORE CAMERA (es. simulatore senza hardware camera)
  // =========================================================

  // void _onCameraError(Object error) {
  //   if (!mounted) return;
  //   setState(() {
  //     _cameraUnavailable = true;
  //     _cameraErrorMessage = error.toString();
  //   });
  // }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Registra Boulder'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _cameraUnavailable
          ? _buildCameraUnavailableView()
          : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    // Mostra spinner mentre la camera si inizializza
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

        // ── overlay con riquadro guida ──────────────────────────
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
                  ? 'Verifica in corso...'
                  : 'Inquadra il QR sotto al boulder',
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
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // VISTA FALLBACK — camera non disponibile (es. Simulatore iOS)
  // =========================================================

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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Il Simulatore iOS non dispone di una fotocamera reale. '
              'Questa funzione richiede un dispositivo fisico per '
              'scansionare il QR code del boulder.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (_cameraErrorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _cameraErrorMessage!,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Torna indietro',
                style: TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
