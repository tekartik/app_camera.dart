import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

import 'src/scan_stub.dart'
    if (dart.library.js_interop) 'src/scan_impl.dart'
    as impl;

export 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Popup a scan QR code page for maximum 1 minute.
///
/// [options] are the scan options.
///
/// Returns the QR code text scanned if any.
Future<String?> scanQrCode(
  BuildContext context, {
  QRCodeScanOptions? options,
}) => impl.scanQrCode(context, options: options);

/// Web implementation of [QRCodeScanService].
class QRCodeScanServiceWeb implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) => impl.scanQrCode(context, options: options);
}

/// Web QR code scan service instance.
final qrCodeScanServiceWeb = QRCodeScanServiceWeb();
