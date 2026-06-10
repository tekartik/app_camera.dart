import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

export 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Implementation of [QRCodeScanService] using mobile_scanner.
class QRCodeScanServiceMobileScanner implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return _ScanPage(options: options);
        },
      ),
    );
  }
}

/// Mobile scanner QR code scan service instance.
final qrCodeScanServiceMobileScanner = QRCodeScanServiceMobileScanner();

class _ScanPage extends StatefulWidget {
  final QRCodeScanOptions? options;

  const _ScanPage({this.options});

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
      appBar: widget.options?.title != null
          ? AppBar(title: Text(widget.options!.title!))
          : null,
      body: MobileScanner(
        controller: _controller,
        onDetect: (BarcodeCapture capture) async {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && !_popped) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              if (widget.options?.validator != null) {
                var valid = await widget.options!.validator!(code);
                if (!valid) return;
              }
              if (!_popped && context.mounted) {
                _popped = true;
                Navigator.of(context).pop(code);
              }
            }
          }
        },
      ),
    );
  }
}
