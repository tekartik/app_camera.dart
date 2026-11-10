// Run with `flutter test --platform chrome`.
@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_qrscan_flutter_web/src/scan_page.dart';
import 'package:web/web.dart' as web;

/// The browser media devices with a fake `getUserMedia`.
class _FakeMediaDevices extends MediaDevicesBrowser {
  _FakeMediaDevices(this.onGetUserMedia);

  final Future<MediaStream> Function() onGetUserMedia;

  @override
  Future<MediaStream> getUserMedia(GetUserMediaConstraint constraint) =>
      onGetUserMedia();
}

void main() {
  final browserMediaDevices = mediaDevices;
  tearDown(() => mediaDevices = browserMediaDevices);

  testWidgets('a refused camera is reported', (tester) async {
    // What the browser throws when the permission is denied.
    mediaDevices = _FakeMediaDevices(() async {
      // Once the user answered the permission prompt.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      throw web.DOMException('denied', 'NotAllowedError');
    });
    await tester.pumpWidget(const MaterialApp(home: ScanPage()));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('error getting user Media'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('a refused camera in a package:flutter/material app', (
    tester,
  ) async {
    mediaDevices = _FakeMediaDevices(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      throw web.DOMException('denied', 'NotAllowedError');
    });
    // No package:material_ui ScaffoldMessenger there: nothing shown, no
    // error.
    await tester.pumpWidget(
      const flutter_material.MaterialApp(home: ScanPage()),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('a page closed before the camera opened stops it', (
    tester,
  ) async {
    final userMedia = Completer<MediaStream>();
    mediaDevices = _FakeMediaDevices(() => userMedia.future);
    await tester.pumpWidget(const MaterialApp(home: ScanPage()));
    // Closed (back, timeout) while the permission prompt is still open.
    await tester.pumpWidget(const SizedBox());
    // A live camera stream, as the browser gives once allowed.
    final stream =
        (web.HTMLCanvasElement()
              ..width = 8
              ..height = 8)
            .captureStream();
    final track = stream.getVideoTracks().toDart.single;
    expect(track.readyState, 'live');
    userMedia.complete(MediaStreamWeb(stream));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(track.readyState, 'ended');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
