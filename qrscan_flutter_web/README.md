# qrscan_flutter_web

Web support based on Cozmo jsQR.

[Online demo](https://tekartik.github.io/app_camera.dart)

## Setup

In pubspec.yaml

```yaml
dependencies:
  tekartik_qrscan_flutter_web:
    git:
      url: git://github.com/tekartik/app_camera.dart
      path: qrscan_flutter_web
      ref: null_safety
    version: '>=0.1.0'
...

flutter:
  # Export jsQR
  assets:
    - packages/tekartik_js_qr/js_qr.js
```

In your `index.html` file (could be at the end of the body section, before `main.dart.js`):

```html
<script src="assets/packages/tekartik_js_qr/js/js_qr.js" type="application/javascript"></script>
```

## Scanning a QR code


```dart
var qrCodeData = await scanQrCode(context, title: 'Scan QR code');
```