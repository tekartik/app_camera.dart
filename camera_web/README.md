# tekartik_camera_web

Open a camera in a Dart web page: list the cameras
(`navigator.mediaDevices.enumerateDevices`), open one as a stream
(`getUserMedia`) and show it in a `<video>` element, behind small Dart
interfaces (`MediaDevices`, `MediaStream`, `VideoElement`) implemented with
`package:web`. Used by the web QR code scanner of this repository.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_camera_web:
    git:
      url: https://github.com/tekartik/app_camera.dart
      path: camera_web
```

Platforms: browser only (dart2js, dart2wasm, Flutter web), on a secure page
(https or localhost): elsewhere `navigator.mediaDevices` does not exist.

```dart
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element_web.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  try {
    // Asks the user for the permission, the back camera on a phone.
    var stream = await mediaDevicesBrowser.getUserMedia(
      GetUserMediaConstraint(
        video: GetUserMediaVideoConstraint(
          facingMode: mediaVideoConstraintFacingModeEnvironment,
        ),
      ),
    );
    var video = VideoElementWeb()
      ..allowPlayInline() // Safari: no full screen
      ..autoplay = true
      ..srcObject = stream;
    web.document.body!.append(video.nativeVideoElement);
    await video.play();
  } catch (e) {
    // Permission refused, no camera, not a secure page...
    print('camera unavailable: $e');
  }
}
```

## Libraries

- `media_devices.dart`: the interfaces and constraints
  (`GetUserMediaConstraint`, `GetUserMediaVideoConstraint` with `deviceId`
  and `facingMode`, `mediaDeviceInfoKindVideo`).
- `media_devices_web.dart`: the browser implementation, `mediaDevicesBrowser`
  (`enumerateDevices`, `getUserMedia`, `getSupportedConstraints`),
  `MediaStreamWeb.htmlMediaStream` for the native stream.
- `video_element.dart` / `video_element_web.dart`: a `<video>` element,
  `VideoElementWeb.nativeVideoElement` to insert it in the page.

## Pitfalls

- `getUserMedia` fails when the user refuses, when there is no camera, or
  outside a secure page: catch every error (a `DOMException`, not a
  `String`).
- `deviceId` and `facingMode` are ideal values: the browser may open
  another camera.
- Camera labels (and often ids) are empty until the user granted the
  permission once: enumerate again after the first `getUserMedia`.
- Stop the tracks when done (`stream.getTracks()`, `track.stop()`), or the
  camera stays on.
- `videoWidth` / `videoHeight` are 0 until `hasEnoughData` is true.

## Example

`example/raw/main.dart` lists the devices and shows the first camera:
`dart run tool/run_web.dart`, then <http://localhost:8061/raw/index.html>.
