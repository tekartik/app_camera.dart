---
name: tekartik-qrscan-flutter-service
description: >-
  Use when adding QR code scanning to a Flutter app against the abstract
  tekartik_qrscan_flutter contract: QRCodeScanService.scanQrCode(context,
  options:), QRCodeScanOptions(title:, validator:), writing a fake scan service
  for widget tests, and picking a concrete implementation
  (qrCodeScanServiceMobileScanner from tekartik_qrscan_flutter_mobile_scanner,
  qrCodeScanServiceWeb from tekartik_qrscan_flutter_web) without tying UI code
  to a platform.
---

# QR scan contract for Flutter (tekartik_qrscan_flutter)

`tekartik_qrscan_flutter` is an interface-only package: one service
(`QRCodeScanService`) and its options (`QRCodeScanOptions`). It contains no
camera code — a concrete package (mobile_scanner based, or web/jsQR based)
provides the implementation, so application code can depend on the contract
alone.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_qrscan_flutter:
      git:
        url: https://github.com/tekartik/app_camera.dart
        path: qrscan_flutter
      version: '>=0.1.0'
  ```
  A concrete implementation re-exports this library, so an app that already
  depends on `tekartik_qrscan_flutter_web` or
  `tekartik_qrscan_flutter_mobile_scanner` gets `QRCodeScanService` and
  `QRCodeScanOptions` from its import and does not need this entry.
* Single library `package:tekartik_qrscan_flutter/qrscan_flutter.dart`, whole
  API:
  * `abstract class QRCodeScanService` with
    `Future<String?> scanQrCode(BuildContext context, {QRCodeScanOptions? options})`.
  * `class QRCodeScanOptions` with a `const` constructor and two optional
    fields: `String? title` and
    `FutureOr<bool> Function(String)? validator`.
* `scanQrCode` opens a full screen scan route from `context` and completes
  with the scanned text, or `null` when the user leaves the page without a
  result (back button, or the web implementation's own 60 second timeout).
  Always handle `null`.
* `context` must belong to a `Navigator` (a `MaterialApp` route). Because the
  call awaits a pushed route, check `mounted` (or capture
  `ScaffoldMessenger.of(context)` / `Navigator.of(context)` before the
  `await`) before touching `context` again.
* `title` drives the scan page app bar; when it is null the implementations
  show no app bar (full-bleed camera).
* `validator` is called with each decoded value: return `false` to reject it
  and keep scanning, `true` (or `null` validator) to pop with the value. It
  may be async (`FutureOr<bool>`), e.g. to check a code against a server.
  Keep it fast, it runs on every successful decode.
* Type fields, constructor parameters and providers as `QRCodeScanService`,
  and inject the concrete instance once at startup (`kIsWeb ?
  qrCodeScanServiceWeb : qrCodeScanServiceMobileScanner`). Never import an
  implementation package from a widget.
* Implementations available in the same repo:
  * `tekartik_qrscan_flutter_mobile_scanner` →
    `qrCodeScanServiceMobileScanner` (Android/iOS/desktop, `mobile_scanner`).
  * `tekartik_qrscan_flutter_web` → `qrCodeScanServiceWeb` and a top-level
    `scanQrCode(context, options:)`; needs the jsQR script in `index.html`
    and throws `UnsupportedError` off the web.
* Both implementations need camera permission and, on the web, a secure
  origin (https or localhost); there is nothing in the contract to query
  permission, so surface the failure from the returned `null` / thrown
  error.
* Testing: the contract is trivial to fake — implement `QRCodeScanService`
  and return a canned string (the package's own `test/` does exactly that).
  Use that fake in widget tests instead of a camera.

## Examples

### A widget that scans through the injected service

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

class ScanButton extends StatefulWidget {
  final QRCodeScanService scanService;

  const ScanButton({super.key, required this.scanService});

  @override
  State<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton> {
  String? _data;

  Future<void> _scan() async {
    // Captured before the await: context may be gone afterwards.
    var messenger = ScaffoldMessenger.of(context);
    var data = await widget.scanService.scanQrCode(
      context,
      options: const QRCodeScanOptions(title: 'Scan a QR code'),
    );
    if (!mounted) {
      return;
    }
    if (data == null) {
      // Cancelled or timed out.
      messenger.showSnackBar(const SnackBar(content: Text('No code scanned')));
      return;
    }
    setState(() => _data = data);
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton(onPressed: _scan, child: const Text('Scan')),
      Text(_data ?? 'No QR code found'),
    ],
  );
}
```

### Reject codes on the scan page with an async validator

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Keeps scanning until an https url the server accepts is found.
Future<Uri?> scanHttpsUrl(
  BuildContext context,
  QRCodeScanService scanService,
  Future<bool> Function(Uri uri) check,
) async {
  var data = await scanService.scanQrCode(
    context,
    options: QRCodeScanOptions(
      title: 'Scan a link',
      validator: (data) async {
        var uri = Uri.tryParse(data);
        if (uri == null || uri.scheme != 'https') {
          return false;
        }
        return check(uri);
      },
    ),
  );
  return data == null ? null : Uri.parse(data);
}
```

### Pick the implementation once, at startup

This block needs the two implementation packages as dependencies
(`tekartik_qrscan_flutter_web`, `tekartik_qrscan_flutter_mobile_scanner`); both
re-export the contract.

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

/// The single scan service for the app.
final QRCodeScanService qrCodeScanService = kIsWeb
    ? qrCodeScanServiceWeb
    : qrCodeScanServiceMobileScanner;

void main() {
  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            var data = await qrCodeScanService.scanQrCode(
              context,
              options: const QRCodeScanOptions(title: 'Scan'),
            );
            debugPrint('scanned: $data');
          },
          child: const Text('Scan'),
        ),
      ),
    ),
  );
}
```

### Fake service for widget tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

/// Returns [result] without opening any camera, after running the validator.
class FakeQRCodeScanService implements QRCodeScanService {
  final String? result;

  FakeQRCodeScanService(this.result);

  @override
  Future<String?> scanQrCode(
    BuildContext context, {
    QRCodeScanOptions? options,
  }) async {
    var data = result;
    if (data != null && options?.validator != null) {
      if (!await options!.validator!(data)) {
        return null;
      }
    }
    return data;
  }
}

void main() {
  testWidgets('scan returns the fake code', (tester) async {
    var service = FakeQRCodeScanService('https://example.com');
    late String? scanned;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              scanned = await service.scanQrCode(
                context,
                options: QRCodeScanOptions(
                  validator: (data) => data.startsWith('https://'),
                ),
              );
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
