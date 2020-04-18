import 'package:meta/meta.dart';
import 'package:tekartik_js_qr/js_qr.dart';

export 'js_qr_impl_stub.dart' if (dart.library.html) 'js_qr_impl_web.dart';

class QrCodePointImpl implements QrCodePoint {
  @override
  final num x;

  @override
  final num y;

  QrCodePointImpl(this.x, this.y);

  @override
  String toString() => '($x, $y)';

  @override
  int get hashCode => (x * y).toInt();

  @override
  bool operator ==(other) {
    if (other is QrCodePoint) {
      if (other.x != x) {
        return false;
      }
      if (other.y != y) {
        return false;
      }
      return true;
    }
    return false;
  }
}

class QrCodeLocationImpl implements QrCodeLocation {
  @override
  final QrCodePoint bottomLeft;

  @override
  final QrCodePoint bottomRight;

  @override
  final QrCodePoint topLeft;

  @override
  final QrCodePoint topRight;

  QrCodeLocationImpl(
      {@required this.bottomLeft,
      @required this.bottomRight,
      @required this.topLeft,
      @required this.topRight});

  @override
  String toString() => '$topLeft $topRight $bottomRight $bottomLeft';
}

class QrCodeImpl implements QrCode {
  @override
  final String data;

  @override
  final QrCodeLocation location;

  QrCodeImpl({this.data, this.location});

  @override
  String toString() => '$data $location';
}

class QrCodeOptionsImpl implements QrCodeOptions {
  @override
  final String inversionAttempts;

  QrCodeOptionsImpl({@required String inversionAttempts})
      : inversionAttempts = inversionAttempts ?? inversionAttemptDontInvert;
}
