import 'dart:html' as html;

import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';
import 'package:tekartik_camera_web/video_element.dart';

class VideoElementWeb implements VideoElement {
  late html.VideoElement _nativeVideoElement;
  html.VideoElement get nativeVideoElement => _nativeVideoElement;

  VideoElementWeb() {
    _nativeVideoElement = html.VideoElement();
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
    _nativeVideoElement.attributes['playsinline'] = 'true';
  }

  @override
  Future play() {
    return _nativeVideoElement.play();
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
      _nativeVideoElement.readyState == html.MediaElement.HAVE_ENOUGH_DATA;
}
