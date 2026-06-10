import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

class MockQRCodeScanService implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) async {
    return 'mock_qr_code';
  }
}

void main() {
  group('QRCodeScanService', () {
    test('mock implementation', () async {
      var service = MockQRCodeScanService();
      expect(service, isA<QRCodeScanService>());
    });
  });
}
