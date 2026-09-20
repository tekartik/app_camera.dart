---
name: tekartik-qrscan-flutter-web-setup
description: >-
  Use when scanning QR codes in a Flutter web app with
  tekartik_qrscan_flutter_web, the jsQR/getUserMedia implementation of
  tekartik_qrscan_flutter: the top-level scanQrCode(context, options:),
  qrCodeScanServiceWeb / QRCodeScanServiceWeb, QRCodeScanOptions(title:,
  validator:), the git dependency, declaring the
  packages/tekartik_js_qr/js/js_qr.js asset and its script tag in
  web/index.html, the https/localhost requirement, the 60 second timeout and
  the UnsupportedError thrown off the web.
---

# Flutter web QR scan (tekartik_qrscan_flutter_web)

`tekartik_qrscan_flutter_web` implements the `tekartik_qrscan_flutter`
contract in the browser: it opens a full screen page that streams the camera
through `tekartik_camera_web`, draws every frame into a canvas platform view
and decodes it with `tekartik_js_qr` (Cozmo jsQR). No plugin, no native code —
but the jsQR script must be loaded by `index.html`.

## Guidelines

* Dependency (git, not on pub.dev). It brings `tekartik_qrscan_flutter`,
  `tekartik_camera_web` and `tekartik_js_qr`:
  ```yaml
  dependencies:
    tekartik_qrscan_flutter_web:
      git:
        url: https://github.com/tekartik/app_camera.dart
        path: qrscan_flutter_web
      version: '>=0.1.0'
  ```
* Two setup steps, both mandatory, or scanning silently never finds anything:
  1. export the jsQR file shipped by `tekartik_js_qr` as an asset in your
     app `pubspec.yaml`:
     ```yaml
     flutter:
       assets:
         - packages/tekartik_js_qr/js/js_qr.js
     ```
  2. load it in `web/index.html` (note the `assets/` prefix), before
     `flutter_bootstrap.js`:
     ```html
     <script src="assets/packages/tekartik_js_qr/js/js_qr.js" type="application/javascript"></script>
     ```
* Single library
  `package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart`; it
  re-exports `package:tekartik_qrscan_flutter/qrscan_flutter.dart`
  (`QRCodeScanService`, `QRCodeScanOptions`) and adds:
  * `Future<String?> scanQrCode(BuildContext context, {QRCodeScanOptions? options})`,
    the direct call;
  * `QRCodeScanServiceWeb` and the singleton `qrCodeScanServiceWeb`, the same
    thing behind the abstract contract — prefer it, so the rest of the app
    stays platform-agnostic (`kIsWeb ? qrCodeScanServiceWeb :
    qrCodeScanServiceMobileScanner`).
* Importing the library is safe on every platform (conditional import), but
  calling `scanQrCode` off the web throws
  `UnsupportedError('scanQrCode only supported on the Web')`. Guard with
  `kIsWeb`, as the repo example does.
* The camera needs a secure origin: https or `localhost`
  (`flutter run -d chrome` is fine, a plain http LAN address is not), and the
  browser prompts for permission on the first scan.
* Scan page behaviour to design around:
  * it asks for `facingMode: environment` (rear camera on phones); on a
    laptop you simply get the default camera;
  * `options.title` adds an `AppBar`, otherwise the page is bare;
  * it pops with `null` automatically after 60 seconds, and there is no
    cancel button beyond the app bar back button, so always handle `null`;
  * the decoded quad is highlighted on the canvas, and the value is only
    returned after ~800 ms of stability (debounce), so a wobbly frame is not
    returned twice;
  * `options.validator` runs at the end of that debounce: `false` discards
    the value and keeps scanning.
* The preview is an `HtmlElementView` platform view sized with the video
  aspect ratio; give the route normal screen room (it is pushed as a
  `MaterialPageRoute<String>`) and do not expect it to work inside a tiny
  box.
* The page stops the media tracks and pauses/removes the video element in
  `dispose`, so the camera light goes off as soon as the route is popped:
  do not keep the route alive in a `Offstage`/`IndexedStack`.
* `lib/src/` (`ScanPage`, `registerViewFactoryWeb`, `scan_impl.dart`,
  `scan_stub.dart`) is private: never import it.
* Testing: `flutter test` can only check the wiring
  (`expect(qrCodeScanServiceWeb, isA<QRCodeScanService>())`), and widget tests
  cannot open a camera — inject a fake `QRCodeScanService` in app tests. Try
  the real thing with `flutter run -d chrome` on the repo's
  `qrscan_flutter_example`.

## Examples

### Scan from a button, web only

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: () async {
      var messenger = ScaffoldMessenger.of(context);
      if (!kIsWeb) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Only supported on the web')),
        );
        return;
      }
      // Top-level function, or qrCodeScanServiceWeb.scanQrCode(...).
      var data = await scanQrCode(
        context,
        options: const QRCodeScanOptions(title: 'Scan a QR code'),
      );
      messenger.showSnackBar(
        SnackBar(content: Text(data ?? 'No QR code scanned')),
      );
    },
    child: const Text('Scan'),
  );
}
```

### Keep the app on the abstract service

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

/// Throws when used off the web; on a mobile app, replace this fallback with
/// qrCodeScanServiceMobileScanner from
/// package:tekartik_qrscan_flutter_mobile_scanner.
class UnsupportedQRCodeScanService implements QRCodeScanService {
  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) async => throw UnsupportedError('No QR scanner on this platform');
}

final QRCodeScanService qrCodeScanService = kIsWeb
    ? qrCodeScanServiceWeb
    : UnsupportedQRCodeScanService();

Future<Uri?> scanUrl(BuildContext context) async {
  var data = await qrCodeScanService.scanQrCode(
    context,
    options: QRCodeScanOptions(
      title: 'Scan a link',
      // Reject anything that is not an https url and keep scanning.
      validator: (data) => Uri.tryParse(data)?.scheme == 'https',
    ),
  );
  return data == null ? null : Uri.parse(data);
}
```

### Full page: scan, show the result, rescan

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _qrCodeData;

  Future<void> _scan() async {
    var data = await qrCodeScanServiceWeb.scanQrCode(
      context,
      options: const QRCodeScanOptions(title: 'Scan'),
    );
    if (!mounted) {
      return;
    }
    // null when cancelled or after the 60s timeout: keep the previous value.
    if (data != null) {
      setState(() => _qrCodeData = data);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scan QR Code demo')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: _scan, child: const Text('Scan')),
          const SizedBox(height: 20),
          Text(_qrCodeData ?? 'No QR code found'),
        ],
      ),
    ),
  );
}
```

### Test wiring, and fake the scan in app tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

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
  test('qrCodeScanServiceWeb implements the contract', () {
    expect(qrCodeScanServiceWeb, isA<QRCodeScanService>());
  });

  testWidgets('fake scan', (tester) async {
    QRCodeScanService service = FakeQRCodeScanService('https://example.com');
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
    expect(scanned, 'https://example.com');
  });
}
```
