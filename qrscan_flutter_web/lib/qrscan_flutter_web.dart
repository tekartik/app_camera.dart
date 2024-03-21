import 'package:flutter/material.dart';

import 'src/scan_stub.dart' if (dart.library.js_interop) 'src/scan_impl.dart'
    as impl;

/// Popup a scan QR code page for maximum 1 minute.
///
/// if [title] is specified, an AppBar is added with the text as the title.
///
/// Returns the QR code text scanned if any.
Future<String?> scanQrCode(BuildContext context, {String? title}) =>
    impl.scanQrCode(context, title: title);
