import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

void main() {
  group('qrscan_flutter_mobile_scanner', () {
    test('qrCodeScanServiceMobileScanner', () {
      expect(qrCodeScanServiceMobileScanner, isA<QRCodeScanService>());
    });
  });
}
