import 'package:flutter/material.dart';

import 'src/scan_impl.dart' as impl;

/// Popup a scan QR code page for maximum 1 minute.
///
/// Returns the QR code text scanned if any.
Future<String> scanQrCode(BuildContext context, {String title}) =>
    impl.scanQrCode(context, title: title);
