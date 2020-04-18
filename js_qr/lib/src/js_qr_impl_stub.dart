import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:tekartik_js_qr/js_qr.dart';

QrCode decodeQrCodeImpl(
        {@required Uint8ClampedList imageData,
        @required int width,
        @required int height,
        QrCodeOptions options}) =>
    throw UnsupportedError('decodeQrCodeImpl');
