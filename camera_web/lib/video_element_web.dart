import 'dart:js_interop';

import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element.dart';
import 'package:web/web.dart' as web;

class VideoElementWeb implements VideoElement {
  late web.HTMLVideoElement _nativeVideoElement;

  web.HTMLVideoElement get nativeVideoElement => _nativeVideoElement;

  VideoElementWeb() {
    _nativeVideoElement = web.HTMLVideoElement();
  }

  @override
  int get videoHeight => _nativeVideoElement.videoHeight;

  @override
  set src(String src) {
    _nativeVideoElement.src = src;
  }

  @override
  set autoplay(bool autoplay) {
    _nativeVideoElement.autoplay = true;
  }

  @override
  set srcObject(MediaStream mediaStream) {
    _nativeVideoElement.srcObject =
        (mediaStream as MediaStreamWeb).nativeMediaStream;
  }

  @override
  void allowPlayInline() {
    _nativeVideoElement.playsInline = true;
  }

  @override
  Future play() {
    return _nativeVideoElement.play().toDart;
  }

  @override
  void pause() {
    _nativeVideoElement.pause();
  }

  @override
  void remove() {
    _nativeVideoElement.remove();
  }

  @override
  int get videoWidth => _nativeVideoElement.videoWidth;

  @override
  bool get hasEnoughData =>
      _nativeVideoElement.readyState == web.HTMLMediaElement.HAVE_ENOUGH_DATA;
}
