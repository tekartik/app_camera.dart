---
name: tekartik-js-qr-decode
description: >-
  Use when decoding QR codes in the browser from raw RGBA pixels with
  tekartik_js_qr, the Dart wrapper around the Cozmo jsQR JavaScript library:
  decodeQrCode(imageData:, width:, height:, options:), QrCode.data,
  QrCodeLocation topLeft/topRight/bottomRight/bottomLeft, QrCodePoint,
  QrCodeOptions(inversionAttempts:), inversionAttemptDontInvert /
  inversionAttemptBoth / inversionAttemptOnlyInvert /
  inversionAttemptInvertFirst, loading packages/tekartik_js_qr/js/js_qr.js in
  index.html, and decoding canvas getImageData frames from a camera stream.
---

# tekartik_js_qr: Cozmo jsQR wrapper (tekartik_js_qr)

`tekartik_js_qr` wraps the [jsQR](https://github.com/cozmo/jsQR) JavaScript
decoder behind a small Dart API: give it the RGBA bytes of an image (usually a
canvas frame grabbed from a camera) and it returns the decoded text and the
four corners of the code. It is web-only; the shipped `js/js_qr.js` must be
loaded by the page.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_js_qr:
      git:
        url: https://github.com/tekartik/app_camera.dart
        path: js_qr
      version: '>=0.1.0'
  ```
* Single library: `package:tekartik_js_qr/js_qr.dart`, exporting
  `decodeQrCode`, `QrCode`, `QrCodeLocation`, `QrCodePoint`, `QrCodeOptions`
  and the four `inversionAttempt*` constants. The `src/` implementation
  (`QrCodeImpl`, `JsQrCode` interop types) is private, do not import it.
* Load the bundled JavaScript, or every call fails. For a `webdev`/`build_web`
  app, in `web/index.html` before your `main.dart.js`:
  ```html
  <script src="packages/tekartik_js_qr/js/js_qr.js"></script>
  ```
  For a Flutter web app, declare the file as an asset in `pubspec.yaml`:
  ```yaml
  flutter:
    assets:
      - packages/tekartik_js_qr/js/js_qr.js
  ```
  and load it in `web/index.html` (note the `assets/` prefix):
  ```html
  <script src="assets/packages/tekartik_js_qr/js/js_qr.js" type="application/javascript"></script>
  ```
* `decodeQrCode(imageData:, width:, height:, options:)` takes a
  `Uint8ClampedList` of `width * height * 4` RGBA bytes: exactly what
  `CanvasRenderingContext2D.getImageData(0, 0, w, h).data.toDart` returns
  (`.toDart` comes from `dart:js_interop`). Pass the canvas width/height, not
  the CSS size.
* Failure is an exception, not `null`. jsQR returns `null` when no code is
  found and the wrapper dereferences it, so a frame without a QR code throws
  (a JS error). Always wrap the call: `try { ... } catch (_) { /* no code */ }`
  — that is exactly what `tekartik_qrscan_flutter_web` does in its frame loop.
  Off the web, the conditional-import stub throws
  `UnsupportedError('decodeQrCodeImpl')`.
* `QrCode.data` is the decoded text (`String?`) and `QrCode.location` the
  bounding quad (`QrCodeLocation?` with `topLeft`, `topRight`, `bottomRight`,
  `bottomLeft`, each a `QrCodePoint` with `num x` / `num y`) — useful to draw
  a highlight over the canvas. Both are nullable in the API, so null-check
  before use.
* `QrCodeOptions(inversionAttempts: ...)` defaults to
  `inversionAttemptDontInvert` (the Dart default, unlike jsQR's own
  `attemptBoth`). Use `inversionAttemptBoth` only when you must read
  white-on-black codes: it roughly halves throughput. The other values are
  `inversionAttemptOnlyInvert` and `inversionAttemptInvertFirst`.
* Scanning loop: decode one frame per `requestAnimationFrame`, after checking
  that the video has data (`hasEnoughData` in `tekartik_camera_web`), and
  debounce the result before acting on it — the same code decodes many times
  per second.
* Getting the frames is not this package's job: use `tekartik_camera_web`
  (`mediaDevicesBrowser`, `VideoElementWeb`) for the camera, or
  `tekartik_qrscan_flutter_web` for a ready-made Flutter web scan page.
* Tests run on `chrome` and `vm` (`dart_test.yaml`); only the chrome platform
  can decode anything, and a real decode needs the script tag in the test
  HTML. Run the demo with `dart run tool/run_web.dart`
  (<http://localhost:8081/js/index.html>).

## Examples

### Decode the current content of a canvas

```dart
import 'dart:js_interop';

import 'package:tekartik_js_qr/js_qr.dart';
import 'package:web/web.dart' as web;

/// Returns the QR code text found in [canvasElement], or null.
String? decodeCanvas(web.HTMLCanvasElement canvasElement) {
  var context = canvasElement.context2D;
  var imageData = context.getImageData(
    0,
    0,
    canvasElement.width,
    canvasElement.height,
  );
  try {
    var qrCode = decodeQrCode(
      imageData: imageData.data.toDart,
      width: canvasElement.width,
      height: canvasElement.height,
    );
    return qrCode.data;
  } catch (_) {
    // jsQR found nothing in this frame.
    return null;
  }
}
```

### Decode white-on-black codes and highlight the result

```dart
import 'dart:js_interop';

import 'package:tekartik_js_qr/js_qr.dart';
import 'package:web/web.dart' as web;

void scanAndDraw(web.HTMLCanvasElement canvasElement) {
  var context = canvasElement.context2D;
  var imageData = context.getImageData(
    0,
    0,
    canvasElement.width,
    canvasElement.height,
  );
  QrCode qrCode;
  try {
    qrCode = decodeQrCode(
      imageData: imageData.data.toDart,
      width: canvasElement.width,
      height: canvasElement.height,
      options: QrCodeOptions(inversionAttempts: inversionAttemptBoth),
    );
  } catch (_) {
    return;
  }
  var location = qrCode.location;
  if (location == null) {
    return;
  }
  void drawLine(QrCodePoint begin, QrCodePoint end) {
    context.beginPath();
    context.moveTo(begin.x, begin.y);
    context.lineTo(end.x, end.y);
    context.lineWidth = 4;
    context.strokeStyle = '#FF3B58'.toJS;
    context.stroke();
  }

  drawLine(location.topLeft, location.topRight);
  drawLine(location.topRight, location.bottomRight);
  drawLine(location.bottomRight, location.bottomLeft);
  drawLine(location.bottomLeft, location.topLeft);
  print('found ${qrCode.data}');
}
```

### Scan a video element, one frame per animation frame

```dart
import 'dart:async';
import 'dart:js_interop';

import 'package:tekartik_js_qr/js_qr.dart';
import 'package:web/web.dart' as web;

Future<void> get _animationFrame {
  var completer = Completer<void>.sync();
  web.window.requestAnimationFrame(
    (JSAny time) {
      completer.complete();
    }.toJS,
  );
  return completer.future;
}

/// Decodes [video] frames until a QR code is found.
Future<String> scanVideo(web.HTMLVideoElement video) async {
  var canvasElement = web.HTMLCanvasElement();
  var context = canvasElement.context2D;
  while (true) {
    await _animationFrame;
    if (video.readyState != web.HTMLMediaElement.HAVE_ENOUGH_DATA) {
      continue;
    }
    canvasElement.width = video.videoWidth;
    canvasElement.height = video.videoHeight;
    context.drawImage(video, 0, 0);
    var imageData = context.getImageData(
      0,
      0,
      canvasElement.width,
      canvasElement.height,
    );
    try {
      var data = decodeQrCode(
        imageData: imageData.data.toDart,
        width: canvasElement.width,
        height: canvasElement.height,
      ).data;
      if (data != null) {
        return data;
      }
    } catch (_) {
      // No code in this frame, keep scanning.
    }
  }
}
```

### Multiplatform code: degrade when not on the web

```dart
import 'dart:typed_data';

import 'package:tekartik_js_qr/js_qr.dart';

/// Null when nothing is found, or when not running in a browser.
String? tryDecodeRgba(Uint8ClampedList rgba, int width, int height) {
  try {
    return decodeQrCode(
      imageData: rgba,
      width: width,
      height: height,
      options: QrCodeOptions(inversionAttempts: inversionAttemptDontInvert),
    ).data;
  } on UnsupportedError catch (_) {
    // Stub implementation: dart:js_interop is not available here.
    return null;
  } catch (_) {
    // jsQR found no code (or js_qr.js was not loaded).
    return null;
  }
}
```
