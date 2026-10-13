import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

void main() {
  group('qrscan_flutter_web', () {
    testWidgets('scanQrCode is not supported outside the web', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox();
          },
        ),
      );
      expect(
        () => qrCodeScanServiceWeb.scanQrCode(context),
        throwsUnsupportedError,
      );
      expect(() => scanQrCode(context), throwsUnsupportedError);
    }, skip: kIsWeb);
  });
}
