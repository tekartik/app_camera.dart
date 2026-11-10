# qrscan_flutter_example

Scans a QR code with the two implementations of the
[tekartik_qrscan_flutter](../qrscan_flutter) `QRCodeScanService`:

* [qrscan_flutter_web](../qrscan_flutter_web) (`qrCodeScanServiceWeb`,
  camera + jsQR): Flutter web only, elsewhere its buttons show "scanQrCode
  only supported on the Web";
* [qrscan_flutter_mobile_scanner](../qrscan_flutter_mobile_scanner)
  (`qrCodeScanServiceMobileScanner`, the `mobile_scanner` plugin): Android,
  iOS, macOS and the web.

The "https only" buttons pass a `validator`: the scan goes on until a code
starting with `https://` is found. The camera button (bottom right) is the
`scanQrCode` function of qrscan_flutter_web.

[Online demo](https://qrscan-example.surge.sh/)

## Run

Web (the jsQR script is already declared: the asset in `pubspec.yaml`, the
`<script>` in `web/index.html`); the camera needs https or `localhost`:

```sh
flutter run -d chrome
```

Android or iOS: the platform folders are not committed, create them first.
On iOS add an `NSCameraUsageDescription` to `ios/Runner/Info.plist`
(mobile_scanner needs it).

```sh
flutter create --platforms=android,ios .
flutter run
```
