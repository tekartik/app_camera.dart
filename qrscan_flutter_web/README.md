# tekartik_qrscan_flutter_web

Scans a QR code in a Flutter web app: a full screen page shows the camera
(`getUserMedia`, rear camera on phones) and decodes each frame with
[jsQR](https://github.com/cozmo/jsQR) until a code is found. The web
implementation of the
[tekartik_qrscan_flutter](../qrscan_flutter) contract; no plugin.

Flutter web only (dart2js and dart2wasm); calling it on another platform
throws an `UnsupportedError` (see
[qrscan_flutter_mobile_scanner](../qrscan_flutter_mobile_scanner) for mobile).

[Online demo](https://qrscan-example.surge.sh/)

## Getting started

Not on pub.dev, a git dependency:

```yaml
dependencies:
  tekartik_qrscan_flutter_web:
    git:
      url: https://github.com/tekartik/app_camera.dart
      path: qrscan_flutter_web
    version: '>=0.1.0'

flutter:
  assets:
    # The jsQR script of tekartik_js_qr
    - packages/tekartik_js_qr/js/js_qr.js
```

Load the script in `web/index.html`, before `flutter_bootstrap.js`:

```html
<script src="assets/packages/tekartik_js_qr/js/js_qr.js" type="application/javascript"></script>
```

Scan:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_qrscan_flutter_web/qrscan_flutter_web.dart';

/// The text of the QR code; null when back is pressed, the camera is
/// refused or no code is found within 60 seconds.
Future<String?> scan(BuildContext context) => qrCodeScanServiceWeb.scanQrCode(
  context,
  options: const QRCodeScanOptions(title: 'Scan a QR code'),
);
```

`scanQrCode(context, options: ...)` is the same call as a top-level
function; `qrCodeScanServiceWeb` keeps the app on the `QRCodeScanService`
contract (a mobile implementation elsewhere).

## Good to know

* The camera needs a secure page: https or `localhost`. The browser asks for
  the permission at the first scan; a refused or missing camera shows a
  snack bar and the page stays open until back (or the 60 s timeout).
* The value is returned after about 800 ms of the same code;
  `QRCodeScanOptions.validator` can refuse it (`false`: keep scanning).
* The camera stops when the page closes, also when it is closed before the
  permission was answered.
* Without the script (asset or `<script>` missing), nothing is ever scanned
  and no error is shown (a frame that fails to decode is skipped): check that
  `assets/packages/tekartik_js_qr/js/js_qr.js` loads.
* The scan page is built with `package:material_ui` (as the rest of the
  tekartik apps): in an app on `package:flutter/material.dart` it works, but
  no snack bar is shown on a camera error.
