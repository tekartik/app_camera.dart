import 'package:flutter_test/flutter_test.dart';
import 'package:qrscan_flutter_example/main.dart';

void main() {
  // flutter test runs on the VM: the jsQR scan is web only.
  testWidgets('web scan off the web shows the error', (tester) async {
    await tester.pumpWidget(const MyApp());
    for (var button in [
      'Scan with js_qr_web',
      'Scan with js_qr_web (https only)',
    ]) {
      await tester.tap(find.text(button));
      await tester.pump();
      expect(
        find.textContaining('only supported on the Web'),
        findsOneWidget,
        reason: button,
      );
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
    }
    expect(find.text('No QR code found'), findsOneWidget);
  });
}
