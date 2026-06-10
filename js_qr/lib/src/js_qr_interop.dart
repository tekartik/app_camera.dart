library;

import 'dart:js_interop' as js;

/// JS QR Code representation.
extension type JsQrCode._(js.JSObject _) implements js.JSObject {
  /// The decoded data.
  external String get data;

  /// The location of the QR code.
  external JsQrCodeLocation get location;
}

/// JS QR Code Point representation.
extension type JsQrPoint._(js.JSObject _) implements js.JSObject {
  /// X coordinate.
  external num get x;

  /// Y coordinate.
  external num get y;
}

/// JS QR Code Location representation.
extension type JsQrCodeLocation._(js.JSObject _) implements js.JSObject {
  /// Top right corner.
  external JsQrPoint get topRightCorner;

  /// Top left corner.
  external JsQrPoint get topLeftCorner;

  /// Bottom right corner.
  external JsQrPoint get bottomRightCorner;

  /// Bottom left corner.
  external JsQrPoint get bottomLeftCorner;
}

/// Decodes QR code using jsQR library.
@js.JS('jsQR')
external JsQrCode jsDecodeQrCode(
  js.JSUint8ClampedArray imageData,
  int width,
  int height,
  JsQrCodeOptions options,
);

/// JS QR Code Options representation.
extension type JsQrCodeOptions._(js.JSObject _) implements js.JSObject {
  /// Inversion attempts strategy.
  external String get inversionAttempts;

  /// Creates JS QR code options.
  external factory JsQrCodeOptions({String? inversionAttempts});
}
