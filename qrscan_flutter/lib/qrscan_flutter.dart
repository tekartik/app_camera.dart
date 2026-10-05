import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Options for QR code scanning.
class QRCodeScanOptions {
  /// Optional title for the scan screen.
  final String? title;

  /// Optional validator callback (async returning bool) that allows testing
  /// the scan data before exiting the scan page.
  final FutureOr<bool> Function(String)? validator;

  /// Creates scan options.
  const QRCodeScanOptions({this.title, this.validator});
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
