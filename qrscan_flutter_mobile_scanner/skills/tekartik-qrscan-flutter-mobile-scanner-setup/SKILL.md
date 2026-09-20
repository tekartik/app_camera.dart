---
name: tekartik-qrscan-flutter-mobile-scanner-setup
description: >-
  Use when implementing QR code scanning on Android, iOS, macOS or web Flutter
  apps with tekartik_qrscan_flutter_mobile_scanner, the mobile_scanner backed
  implementation of tekartik_qrscan_flutter: qrCodeScanServiceMobileScanner,
  QRCodeScanServiceMobileScanner, scanQrCode(context, options:),
  QRCodeScanOptions(title:, validator:), the git dependency and the
  mobile_scanner platform setup (NSCameraUsageDescription, MLKit bundled vs
  unbundled), plus writing a custom scan page with MobileScanner /
  MobileScannerController / BarcodeCapture.
---

# mobile_scanner implementation (tekartik_qrscan_flutter_mobile_scanner)

`tekartik_qrscan_flutter_mobile_scanner` implements the
`tekartik_qrscan_flutter` contract with the
[mobile_scanner](https://pub.dev/packages/mobile_scanner) plugin: pushing a
full screen camera route that pops with the first decoded barcode. It is the
implementation to use everywhere the native plugin runs (Android, iOS, macOS,
and web through ZXing).

## Guidelines

* Dependency (git, not on pub.dev). It pulls `tekartik_qrscan_flutter` (same
  repo) and `mobile_scanner` (`>=6.0.0 <8.0.0`) for you:
  ```yaml
  dependencies:
    tekartik_qrscan_flutter_mobile_scanner:
      git:
        url: https://github.com/tekartik/app_camera.dart
        path: qrscan_flutter_mobile_scanner
      version: '>=0.1.0'
  ```
* One library, `package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart`,
  which re-exports `package:tekartik_qrscan_flutter/qrscan_flutter.dart`
  (`QRCodeScanService`, `QRCodeScanOptions`), and adds
  `QRCodeScanServiceMobileScanner` plus the ready-made singleton
  `qrCodeScanServiceMobileScanner`. Use the singleton; there is no top-level
  `scanQrCode` function here (that one only exists in
  `tekartik_qrscan_flutter_web`).
* `qrCodeScanServiceMobileScanner.scanQrCode(context, options: ...)` pushes a
  `MaterialPageRoute<String>` and completes with the decoded text, or `null`
  when the user pops the page. `options.title` adds an `AppBar`; without it
  the camera preview is full screen and the only way out is the system back
  gesture/button, so pass a title unless you provide your own exit.
* `options.validator` is awaited on every detection: return `false` to ignore
  the value and keep scanning, `true` to pop with it. The page keeps
  detecting while a validator is running, so make it cheap/idempotent; the
  route pops only once.
* The scan page accepts any barcode format mobile_scanner detects, not only
  QR codes, and reads `capture.barcodes.first.rawValue` (values with a null
  `rawValue` are skipped). Need QR only, a torch button, a scan window or a
  camera switch? The page is private: write your own `QRCodeScanService` with
  `MobileScanner` + `MobileScannerController(formats: [BarcodeFormat.qrCode])`
  (last example) and keep the rest of the app on the abstract type.
* Platform setup is mobile_scanner's:
  * iOS/macOS: add `NSCameraUsageDescription` to `ios/Runner/Info.plist`
    (and grant the Camera capability in Xcode for macOS), or the route opens
    on a black preview and the app is rejected at review.
  * Android: nothing required; the bundled MLKit model adds ~3-10 MB. Add
    `dev.steenbakker.mobile_scanner.useUnbundled=true` to
    `android/gradle.properties` to download it from Play Services instead.
  * Web: served over https (or localhost) and the browser asks for camera
    permission on the first scan.
* Pick the implementation once at startup and inject it as
  `QRCodeScanService` (`kIsWeb ? qrCodeScanServiceWeb :
  qrCodeScanServiceMobileScanner` when you also use
  `tekartik_qrscan_flutter_web`); widgets should never import this package
  directly.
* Testing: nothing here can run in `flutter test` (no camera, plugin channels
  missing). The package's own test only checks
  `qrCodeScanServiceMobileScanner is QRCodeScanService`; in app tests inject
  a fake `QRCodeScanService` returning a canned string.

## Examples

### Scan from a button

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                var messenger = ScaffoldMessenger.of(context);
                var data = await qrCodeScanServiceMobileScanner.scanQrCode(
                  context,
                  options: const QRCodeScanOptions(title: 'Scan a QR code'),
                );
                messenger.showSnackBar(
                  SnackBar(content: Text(data ?? 'No QR code scanned')),
                );
              },
              child: const Text('Scan'),
            ),
          ),
        ),
      ),
    ),
  );
}
```

### Inject the service, validate before leaving the page

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

/// The app scan service, typed as the abstract contract.
final QRCodeScanService qrCodeScanService = qrCodeScanServiceMobileScanner;

/// Scans until a code of the `myapp:<id>` form is found, returns the id.
Future<String?> scanMyAppId(BuildContext context) async {
  var data = await qrCodeScanService.scanQrCode(
    context,
    options: QRCodeScanOptions(
      title: 'Scan a member card',
      validator: (data) => data.startsWith('myapp:'),
    ),
  );
  return data?.substring('myapp:'.length);
}
```

### A custom scan page (QR only, torch toggle) behind the same contract

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

/// Same contract, custom UI: QR format only and a torch button.
class QrOnlyScanService implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) => Navigator.of(context).push<String>(
    MaterialPageRoute<String>(builder: (_) => QrOnlyScanPage(options: options)),
  );
}

class QrOnlyScanPage extends StatefulWidget {
  final QRCodeScanOptions? options;

  const QrOnlyScanPage({super.key, this.options});

  @override
  State<QrOnlyScanPage> createState() => _QrOnlyScanPageState();
}

class _QrOnlyScanPageState extends State<QrOnlyScanPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  var _popped = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_popped || capture.barcodes.isEmpty) {
      return;
    }
    var code = capture.barcodes.first.rawValue;
    if (code == null) {
      return;
    }
    var validator = widget.options?.validator;
    if (validator != null && !await validator(code)) {
      return;
    }
    if (!_popped && mounted) {
      _popped = true;
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.options?.title ?? 'Scan'),
      actions: [
        IconButton(
          icon: const Icon(Icons.flashlight_on),
          onPressed: _controller.toggleTorch,
        ),
      ],
    ),
    body: MobileScanner(controller: _controller, onDetect: _onDetect),
  );
}
```

### Fake the service in widget tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

class FakeQRCodeScanService implements QRCodeScanService {
  final String? result;

  FakeQRCodeScanService(this.result);

  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) async => result;
}

void main() {
  test('the real service implements the contract', () {
    expect(qrCodeScanServiceMobileScanner, isA<QRCodeScanService>());
  });

  testWidgets('the fake replaces it', (tester) async {
    QRCodeScanService service = FakeQRCodeScanService('myapp:1234');
    String? scanned;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              scanned = await service.scanQrCode(context);
            },
            child: const Text('Scan'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(scanned, 'myapp:1234');
  });
}
```
