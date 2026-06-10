import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

export 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Implementation of [QRCodeScanService] using mobile_scanner.
class QRCodeScanServiceMobileScanner implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(BuildContext context, {QRCodeScanOptions? options}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return _ScanPage(title: options?.title);
        },
      ),
    );
  }
}

/// Mobile scanner QR code scan service instance.
final qrCodeScanServiceMobileScanner = QRCodeScanServiceMobileScanner();

class _ScanPage extends StatefulWidget {
  final String? title;

  const _ScanPage({this.title});

  @override
  State<_ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<_ScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _popped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null ? AppBar(title: Text(widget.title!)) : null,
      body: MobileScanner(
        controller: _controller,
        onDetect: (BarcodeCapture capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && !_popped) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              _popped = true;
              Navigator.of(context).pop(code);
            }
          }
        },
      ),
    );
  }
}
