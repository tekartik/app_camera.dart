@JS()
library tekartik_js_qr_interop;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
@anonymous
class JsQrCode {
  external String get data;
  external JsQrCodeLocation get location;
}

@JS()
@anonymous
class JsQrPoint {
  external num get x;
  external num get y;
}

@JS()
@anonymous
class JsQrCodeLocation {
  external JsQrPoint get topRightCorner;
  external JsQrPoint get topLeftCorner;
  external JsQrPoint get bottomRightCorner;
  external JsQrPoint get bottomLeftCorner;
}

@JS('jsQR')
external JsQrCode jsDecodeQrCode(
    Uint8ClampedList imageData, int width, int height, JsQrCodeOptions options);

@anonymous
@JS()
abstract class JsQrCodeOptions {
  external String get inversionAttempts;
  external factory JsQrCodeOptions({String? inversionAttempts});
}
