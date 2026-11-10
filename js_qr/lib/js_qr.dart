/// QR code decoding in the browser, a wrapper of the jsQR JavaScript library
/// (`lib/js/js_qr.js`, to load in the page): [decodeQrCode].
library;

import 'dart:typed_data';

import 'package:tekartik_js_qr/src/js_qr_impl.dart';

/// Default for Js.
const inversionAttemptBoth = 'attemptBoth';

/// Default for Dart.
const inversionAttemptDontInvert = 'dontInvert';

/// Only invert.
const inversionAttemptOnlyInvert = 'onlyInvert';

/// Invert first
const inversionAttemptInvertFirst = 'invertFirst';

/// Additional options
abstract class QrCodeOptions {
  /// Should jsQR attempt to invert the image to find QR codes with whit
  /// modules on black backgrounds instead of the black modules on white
  /// background.
  ///
  /// The option to attemptBoth causes a ~50% performance hit
  String get inversionAttempts;

  /// Creates QR code options.
  factory QrCodeOptions({String? inversionAttempts}) =>
      QrCodeOptionsImpl(inversionAttempts: inversionAttempts);
}

/// The Qr code location
abstract class QrCodeLocation {
  /// top left.
  QrCodePoint get topLeft;

  /// top right.
  QrCodePoint get topRight;

  /// bottom right.
  QrCodePoint get bottomRight;

  /// bottom left.
  QrCodePoint get bottomLeft;
}

/// Point.
abstract class QrCodePoint {
  /// x.
  num get x;

  /// y.
  num get y;
}

/// QrCode result
abstract class QrCode {
  /// The extracted text data
  String? get data;

  /// The qr code location.
  QrCodeLocation? get location;
}

/// Decodes the QR code found in [imageData], the RGBA bytes (4 per pixel,
/// `width * height * 4`) of an image, e.g. `getImageData(...).data.toDart` of
/// a canvas.
///
/// Throws when the image holds no QR code (jsQR answers null: the error is a
/// `Null check operator used on a null value`), so wrap each call in a
/// try/catch. Needs `packages/tekartik_js_qr/js/js_qr.js` loaded by the page;
/// throws [UnsupportedError] off the web.
QrCode decodeQrCode({
  required Uint8ClampedList imageData,
  required int width,
  required int height,
  QrCodeOptions? options,
}) => decodeQrCodeImpl(
  imageData: imageData,
  width: width,
  height: height,
  options: options,
);
