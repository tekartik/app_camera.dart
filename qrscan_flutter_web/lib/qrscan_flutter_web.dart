/// QR code scan for Flutter web (camera + jsQR): [scanQrCode],
/// [qrCodeScanServiceWeb].
library;

import 'package:material_ui/material_ui.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

import 'src/scan_stub.dart'
    if (dart.library.js_interop) 'src/scan_impl.dart'
    as impl;

export 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Pushes a full screen page scanning QR codes with the camera (web only,
/// an [UnsupportedError] elsewhere) for 1 minute at most.
///
/// [options] are the scan options (title, validator).
///
/// Returns the QR code text, or null when the page is closed without one
/// (back, or after 1 minute; a refused or missing camera is shown there). The
/// page needs the jsQR script of `tekartik_js_qr` in `web/index.html`.
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
