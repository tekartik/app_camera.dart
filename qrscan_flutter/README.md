# tekartik_qrscan_flutter

The QR code scanning contract for Flutter apps: one service,
`QRCodeScanService.scanQrCode(context, options:)`, and its options
(`QRCodeScanOptions`: `title`, `validator`). No camera code here: the
implementations are in the same repository.

| Package (`path`) | Service | Platforms |
|---|---|---|
| `tekartik_qrscan_flutter_mobile_scanner` (`qrscan_flutter_mobile_scanner`) | `qrCodeScanServiceMobileScanner` | Android, iOS, macOS (package `mobile_scanner`) |
| `tekartik_qrscan_flutter_web` (`qrscan_flutter_web`) | `qrCodeScanServiceWeb` | web (jsQR script in `index.html`, https or localhost) |

Both re-export this library.

## Getting started

Not on pub.dev, add it (or an implementation) as a git dependency:

```yaml
dependencies:
  tekartik_qrscan_flutter:
    git:
      url: https://github.com/tekartik/app_camera.dart
      path: qrscan_flutter
```

Write the UI against the contract and inject the implementation at startup:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_qrscan_flutter/qrscan_flutter.dart';

Future<void> scanTicket(BuildContext context, QRCodeScanService scanner) async {
  var messenger = ScaffoldMessenger.of(context);
  var code = await scanner.scanQrCode(
    context,
    options: QRCodeScanOptions(
      title: 'Scan a ticket',
      // false keeps scanning, true pops with the value.
      validator: (text) => text.startsWith('TICKET:'),
    ),
  );
  // null: the user left the page (or the web scanner timed out after 60 s).
  messenger.showSnackBar(SnackBar(content: Text(code ?? 'No code')));
}
```

## Common pitfalls

- `scanQrCode` pushes a route: `context` must be under a `Navigator`, and
  must not be used after the `await` without a `mounted` check (capture
  `ScaffoldMessenger.of(context)` before, as above).
- Always handle `null`.
- The scan pages are built with `package:material_ui`: use its `MaterialApp`
  in the app (not the `package:flutter/material.dart` one).
- In widget tests, implement `QRCodeScanService` with a fake returning a
  fixed string (see `test/`), no camera needed.
