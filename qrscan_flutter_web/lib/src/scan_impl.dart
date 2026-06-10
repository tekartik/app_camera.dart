import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';
import 'package:tekartik_qrscan_flutter_web/src/scan_page.dart';

/// Scan QR code.
Future<String?> scanQrCode(BuildContext context, {QRCodeScanOptions? options}) {
  return Navigator.of(context).push(
    MaterialPageRoute<String>(
      builder: (BuildContext context) {
        return ScanPage(title: options?.title);
      },
    ),
  );
}
