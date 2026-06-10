import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

void main() {
  group('qrscan_flutter_web', () {
    test('qrCodeScanServiceWeb', () {
      expect(qrCodeScanServiceWeb, isA<QRCodeScanService>());
    });
  });
}
