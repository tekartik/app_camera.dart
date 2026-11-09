# tekartik_qrscan_flutter_mobile_scanner

The [tekartik_qrscan_flutter](../qrscan_flutter/README.md) QR code scan
service on [mobile_scanner](https://pub.dev/packages/mobile_scanner): a full
screen camera page that pops with the first code read.

## Getting started

Not on pub.dev, add it as a git dependency (it brings the contract and
mobile_scanner):

```yaml
dependencies:
  tekartik_qrscan_flutter_mobile_scanner:
    git:
      url: https://github.com/tekartik/app_camera.dart
      path: qrscan_flutter_mobile_scanner
```

Scan from a button:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_qrscan_flutter_mobile_scanner/qrscan_flutter_mobile_scanner.dart';

Future<void> scan(BuildContext context) async {
  var messenger = ScaffoldMessenger.of(context);
  var code = await qrCodeScanServiceMobileScanner.scanQrCode(
    context,
    options: QRCodeScanOptions(
      title: 'Scan a ticket',
      // false keeps scanning, true pops with the value.
      validator: (text) => text.startsWith('TICKET:'),
    ),
  );
  // null when the user went back.
  messenger.showSnackBar(SnackBar(content: Text(code ?? 'No code')));
}
```

Type the rest of the app on `QRCodeScanService` and pick this implementation at
startup.

## Platforms

mobile_scanner's setup applies:

* Android: nothing to add (the ML Kit barcode model is bundled, about 3 to
  10 MB; `dev.steenbakker.mobile_scanner.useUnbundled=true` in
  `android/gradle.properties` downloads it through Play services instead).
* iOS: `NSCameraUsageDescription` in `ios/Runner/Info.plist`.
* macOS: `NSCameraUsageDescription` in `macos/Runner/Info.plist` and the
  `com.apple.security.device.camera` entitlement.
* Web: mobile_scanner's web implementation (https or localhost); the
  repository also has `tekartik_qrscan_flutter_web` (jsQR).

## Common pitfalls

* Without a `title` there is no app bar: the only way out is the system back.
* The validator runs on every detection (several times a second) while the
  camera sees a code, also while a previous call is still running: keep it
  cheap and idempotent, the page pops only once.
* Any barcode format is accepted, not only QR codes.

Agent skill:
[skills/tekartik-qrscan-flutter-mobile-scanner-setup](skills/tekartik-qrscan-flutter-mobile-scanner-setup/SKILL.md).
