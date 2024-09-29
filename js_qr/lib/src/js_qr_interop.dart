library;

import 'dart:js_interop' as js;

extension type JsQrCode._(js.JSObject _) implements js.JSObject {
  external String get data;

  external JsQrCodeLocation get location;
}

extension type JsQrPoint._(js.JSObject _) implements js.JSObject {
  external num get x;

  external num get y;
}

extension type JsQrCodeLocation._(js.JSObject _) implements js.JSObject {
  external JsQrPoint get topRightCorner;

  external JsQrPoint get topLeftCorner;

  external JsQrPoint get bottomRightCorner;

  external JsQrPoint get bottomLeftCorner;
}

@js.JS('jsQR')
external JsQrCode jsDecodeQrCode(js.JSUint8ClampedArray imageData, int width,
    int height, JsQrCodeOptions options);

extension type JsQrCodeOptions._(js.JSObject _) implements js.JSObject {
  external String get inversionAttempts;

  external factory JsQrCodeOptions({String? inversionAttempts});
}
