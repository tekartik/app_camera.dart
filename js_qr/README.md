# tekartik_js_qr

Decode a QR code in the browser from the RGBA pixels of an image (a canvas
frame of a camera stream): a Dart wrapper of the
[jsQR](https://github.com/cozmo/jsQR) JavaScript library, bundled in
`lib/js/js_qr.js`.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_js_qr:
    git:
      url: https://github.com/tekartik/app_camera.dart
      path: js_qr
```

Platforms: browser only (dart2js, dart2wasm, Flutter web); elsewhere
`decodeQrCode` throws `UnsupportedError`.

The page must load the JavaScript decoder before the first call:

```html
<!-- web/index.html of a webdev / build_web_compilers app -->
<script src="packages/tekartik_js_qr/js/js_qr.js"></script>
```

In a Flutter web app, list `packages/tekartik_js_qr/js/js_qr.js` under
`flutter: assets:` and load `assets/packages/tekartik_js_qr/js/js_qr.js`.

```dart
import 'dart:js_interop';

import 'package:tekartik_js_qr/js_qr.dart';
import 'package:web/web.dart' as web;

/// The text of the QR code drawn in [canvas], null when there is none.
String? decodeCanvas(web.HTMLCanvasElement canvas) {
  var imageData = canvas.context2D.getImageData(
    0,
    0,
    canvas.width,
    canvas.height,
  );
  try {
    var qrCode = decodeQrCode(
      imageData: imageData.data.toDart,
      width: canvas.width,
      height: canvas.height,
    );
    return qrCode.data;
  } catch (_) {
    // No QR code in this image.
    return null;
  }
}
```

## Pitfalls

- An image without a QR code throws (jsQR answers null): wrap every call in
  a try/catch, as above.
- `inversionAttempts` defaults to `inversionAttemptDontInvert` (jsQR's own
  default is `attemptBoth`): pass `QrCodeOptions(inversionAttempts:
  inversionAttemptBoth)` for white codes on black, about twice slower.
- Give the canvas size in pixels (`canvas.width`), not its CSS size.
- Frames come from elsewhere: `tekartik_camera_web` for the camera, or the
  ready made Flutter web scan page of this repository.

## Example

`example/js/index.html` is the jsQR demo page on a camera:
`dart run tool/run_web.dart`, then <http://localhost:8081/js/index.html>.
