import 'package:flutter/material.dart';

/// Options for QR code scanning.
class QRCodeScanOptions {
  /// Optional title for the scan screen.
  final String? title;

  /// Creates scan options.
  const QRCodeScanOptions({this.title});
}

/// Service to scan QR codes.
abstract class QRCodeScanService {
  /// Scan a QR code.
  ///
  /// [context] is the build context.
  /// [options] are the scan options.
  ///
  /// Returns the QR code text scanned if any.
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  });
}
