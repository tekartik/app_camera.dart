import 'dart:js_interop';
import 'dart:typed_data';

import 'package:tekartik_js_qr/js_qr.dart';
import 'package:tekartik_js_qr/src/js_qr_interop.dart';

import 'js_qr_impl.dart';

QrCodePointImpl fromJsQrCodePoint(JsQrPoint jsQrPoint) =>
    QrCodePointImpl(jsQrPoint.x, jsQrPoint.y);

QrCode decodeQrCodeImpl({
  required Uint8ClampedList imageData,
  required int width,
  required int height,
  QrCodeOptions? options,
}) {
  options ??= QrCodeOptions();
  var jsQrCodeOptions = JsQrCodeOptions(
    inversionAttempts: options.inversionAttempts,
  );
  var jsQrCode = jsDecodeQrCode(imageData.toJS, width, height, jsQrCodeOptions);

  return QrCodeImpl(
    data: jsQrCode.data,
    location: QrCodeLocationImpl(
      bottomLeft: fromJsQrCodePoint(jsQrCode.location.bottomLeftCorner),
      bottomRight: fromJsQrCodePoint(jsQrCode.location.bottomRightCorner),
      topLeft: fromJsQrCodePoint(jsQrCode.location.topLeftCorner),
      topRight: fromJsQrCodePoint(jsQrCode.location.topRightCorner),
    ),
  );
}
