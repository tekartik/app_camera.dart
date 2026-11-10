@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element_web.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('media_devices_web', () {
    test('getUserMedia sends the video constraints', () async {
      // No camera needed: the browser getUserMedia is replaced by one
      // recording what it is asked.
      var mediaDevices = web.window.navigator.mediaDevices as JSObject;
      Object? sent;
      mediaDevices['getUserMedia'] = ((JSAny? constraints) {
        sent = constraints.dartify();
        return Future<web.MediaStream>.value(web.MediaStream()).toJS;
      }).toJS;
      try {
        var stream = await mediaDevicesBrowser.getUserMedia(
          GetUserMediaConstraint(
            video: GetUserMediaVideoConstraint(
              deviceId: 'my_camera',
              facingMode: mediaVideoConstraintFacingModeEnvironment,
            ),
          ),
        );
        expect(stream.getTracks(), isEmpty);
        expect(sent, {
          'video': {'deviceId': 'my_camera', 'facingMode': 'environment'},
        });
        await mediaDevicesBrowser.getUserMedia(
          GetUserMediaConstraint(video: GetUserMediaVideoConstraint()),
        );
        expect(sent, {'video': <String, Object?>{}});
      } finally {
        // Back to the one of the prototype
        mediaDevices.delete('getUserMedia'.toJS);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('autoplay', () {
      var video = VideoElementWeb()..autoplay = false;
      expect(video.nativeVideoElement.autoplay, isFalse);
      video.autoplay = true;
      expect(video.nativeVideoElement.autoplay, isTrue);
    });
  });
}
