import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

void main() {
  group('qrscan_flutter_mobile_scanner', () {
    testWidgets('scan page, null when closed', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox();
            },
          ),
        ),
      );
      var result = qrCodeScanServiceMobileScanner.scanQrCode(
        context,
        options: const QRCodeScanOptions(title: 'Scan title'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scan title'), findsOneWidget);
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(find.text('Scan title'), findsNothing);
      expect(await result, isNull);
    });
  });
}
