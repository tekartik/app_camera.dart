import 'dart:typed_data';
import 'package:meta/meta.dart';
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

/// Attempt to decode a QR code from an image data.
///
/// Returns null if non found
QrCode decodeQrCode(
        {required Uint8ClampedList imageData,
        required int width,
        required int height,
        QrCodeOptions? options}) =>
    decodeQrCodeImpl(
        imageData: imageData, width: width, height: height, options: options);
