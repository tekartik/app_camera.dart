---
name: tekartik-camera-web-setup
description: >-
  Use when accessing a browser camera from Dart web code with
  tekartik_camera_web: enumerating cameras with mediaDevicesBrowser /
  MediaDevicesBrowser.enumerateDevices, opening a stream with getUserMedia,
  GetUserMediaConstraint, GetUserMediaVideoConstraint, mediaDeviceInfoKindVideo,
  mediaVideoConstraintFacingModeEnvironment, MediaDeviceInfo, MediaStream,
  MediaStreamTrack.stop, MediaStreamWeb.htmlMediaStream, getSupportedConstraints
  / MediaTrackSupportedConstraints, and displaying it through VideoElement /
  VideoElementWeb (media_devices.dart, media_devices_web.dart,
  video_element.dart, video_element_web.dart).
---

# tekartik_camera_web: browser camera and video element

`tekartik_camera_web` is a thin Dart abstraction over `navigator.mediaDevices`
and `<video>`, implemented with `package:web`. It is a web-only package: the
abstract libraries hold no platform code, the `*_web` libraries are what you
instantiate in a browser (or in Flutter web through
`tekartik_qrscan_flutter_web`).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_camera_web:
      git:
        url: https://github.com/tekartik/app_camera.dart
        path: camera_web
      version: '>=0.1.0'
  ```
* Four libraries, in two pairs:
  * `package:tekartik_camera_web/media_devices.dart`: the abstractions
    `MediaDevices`, `MediaDeviceInfo` (+ `MediaDeviceInfoMixin`),
    `MediaStream`, `MediaStreamTrack`, `MediaTrackSupportedConstraints`, the
    constraint holders `GetUserMediaConstraint` /
    `GetUserMediaVideoConstraint`, and the constants
    `mediaDeviceInfoKindVideo` (`'videoinput'`) and
    `mediaVideoConstraintFacingModeEnvironment` (`'environment'`).
  * `package:tekartik_camera_web/media_devices_web.dart`: the browser
    implementation, `MediaDevicesBrowser` with the ready-made singleton
    `mediaDevicesBrowser`, plus `MediaDeviceInfoBrowser`,
    `MediaTrackSupportedConstraintsBrowser`, `MediaStreamWeb` and
    `MediaStreamTrackWeb`.
  * `package:tekartik_camera_web/video_element.dart`: the abstract
    `VideoElement`.
  * `package:tekartik_camera_web/video_element_web.dart`: `VideoElementWeb`,
    which creates its own `web.HTMLVideoElement` and exposes it through
    `nativeVideoElement`.
* Type your code against `MediaDevices` / `MediaStream` / `VideoElement` and
  take `mediaDevicesBrowser` (or `VideoElementWeb()`) only at the edge; that
  is what keeps shared code testable and mirrors how
  `tekartik_qrscan_flutter_web` uses it.
* `enumerateDevices()` returns every input/output device: filter on
  `device.kind == mediaDeviceInfoKindVideo` for cameras. Before the first
  successful `getUserMedia()` the browser hides `label` (and often
  `deviceId`), so enumerate again after permission is granted if you need
  human-readable camera names.
* `getUserMedia()` takes a `GetUserMediaConstraint` whose `video` field is
  dereferenced with `!`: always pass
  `GetUserMediaConstraint(video: GetUserMediaVideoConstraint(...))`, never
  `GetUserMediaConstraint()`.
* Caveat in the current browser implementation: `MediaDevicesBrowser`
  builds the `web.MediaTrackConstraints` from `deviceId` / `facingMode` but
  assigns a fresh empty one to `MediaStreamConstraints.video`, so both hints
  are effectively dropped and the user agent picks the default camera. Treat
  camera selection as best-effort; do not build a UI that promises a
  specific camera without checking the resulting track, and fall back to
  `web.window.navigator.mediaDevices` directly when you really need the
  constraint applied.
* `getUserMedia()` rejects when the user denies permission, when the page is
  not on a secure origin (https or localhost) or when no camera matches:
  wrap it in `try`/`catch` and show the failure.
* Always stop the stream when you are done (leaving the camera LED on is the
  classic bug): `for (var track in stream.getTracks()) track.stop();`, then
  `videoElement.pause()` / `videoElement.remove()`.
* `VideoElementWeb` is detached on creation: append `nativeVideoElement` to
  the document yourself (`appendChild`), or wrap an existing `<video>` by
  using `web.HTMLVideoElement` directly.
* Playback rules for mobile browsers: call `allowPlayInline()` (sets
  `playsInline`, required by Safari to capture without going full screen)
  and set `autoplay = true` before `play()`. Note `autoplay` ignores its
  argument and always sets `true`; use `pause()` to stop. `play()` may still
  reject without a user gesture, so call it from a click/tap handler.
* Before reading frames (canvas capture, QR decoding) wait for
  `hasEnoughData` (`readyState == HAVE_ENOUGH_DATA`) and use `videoWidth` /
  `videoHeight`, which are 0 until then.
* `getSupportedConstraints()` tells you whether the user agent supports
  `facingMode`; `toDebugMap()` on it (and on `MediaDeviceInfo`) returns a
  plain map, handy for logging in the browser console.
* No mocks or fakes are shipped: the `test/` folder is a stub because
  everything here needs a real browser. Test with
  `dart test -p chrome` (or `-p chrome --pause-after-load` to grant camera
  permission by hand) and run the demo with
  `dart run tool/run_web.dart` (webdev on <http://localhost:8061/raw/index.html>).

## Examples

### Open the first camera and show it in a video element

```dart
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element.dart';
import 'package:tekartik_camera_web/video_element_web.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  var mediaDevices = mediaDevicesBrowser;
  var devices = await mediaDevices.enumerateDevices();
  MediaDeviceInfo? camera;
  for (var device in devices) {
    if (device.kind == mediaDeviceInfoKindVideo) {
      camera = device;
      break;
    }
  }
  if (camera == null) {
    print('no camera found');
    return;
  }
  var stream = await mediaDevices.getUserMedia(
    GetUserMediaConstraint(
      video: GetUserMediaVideoConstraint(deviceId: camera.deviceId),
    ),
  );

  VideoElement videoElement = VideoElementWeb();
  videoElement.allowPlayInline();
  videoElement.autoplay = true;
  videoElement.srcObject = stream;
  web.document.body!.appendChild(
    (videoElement as VideoElementWeb).nativeVideoElement,
  );
  await videoElement.play();
}
```

### Prefer the back camera, then release everything

```dart
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element.dart';
import 'package:tekartik_camera_web/video_element_web.dart';

Future<void> main() async {
  var mediaDevices = mediaDevicesBrowser;
  var supported = mediaDevices.getSupportedConstraints();
  print('facingMode supported: ${supported.facingMode}');
  print('constraints: ${supported.toDebugMap()}');

  MediaStream? stream;
  VideoElement? videoElement;
  try {
    stream = await mediaDevices.getUserMedia(
      GetUserMediaConstraint(
        video: GetUserMediaVideoConstraint(
          facingMode: supported.facingMode
              ? mediaVideoConstraintFacingModeEnvironment
              : null,
        ),
      ),
    );
    videoElement = VideoElementWeb()
      ..allowPlayInline()
      ..autoplay = true
      ..srcObject = stream;
    await videoElement.play();
  } catch (e) {
    print('camera unavailable: $e');
  } finally {
    videoElement?.pause();
    videoElement?.remove();
    for (var track in stream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
  }
}
```

### Wait for the first frame and grab it to a canvas

```dart
import 'package:tekartik_camera_web/video_element_web.dart';
import 'package:web/web.dart' as web;

/// Copies the current video frame to a canvas, once the stream is ready.
Future<web.HTMLCanvasElement> grabFrame(VideoElementWeb videoElement) async {
  while (!videoElement.hasEnoughData) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  var canvas = web.HTMLCanvasElement()
    ..width = videoElement.videoWidth
    ..height = videoElement.videoHeight;
  var context = canvas.getContext('2d') as web.CanvasRenderingContext2D;
  context.drawImage(videoElement.nativeVideoElement, 0, 0);
  return canvas;
}

Future<void> main() async {
  var videoElement = VideoElementWeb();
  videoElement.src = 'sample.webm';
  await videoElement.play();
  var canvas = await grabFrame(videoElement);
  print('frame ${canvas.width}x${canvas.height}');
}
```

### Use an existing `<video>` tag from the page

```dart
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  var video =
      web.document.querySelector('#videoElement') as web.HTMLVideoElement?;
  var stream = await mediaDevicesBrowser.getUserMedia(
    GetUserMediaConstraint(video: GetUserMediaVideoConstraint()),
  );
  // MediaStreamWeb exposes the native stream for direct DOM use.
  video!.srcObject = (stream as MediaStreamWeb).htmlMediaStream;
}
```
