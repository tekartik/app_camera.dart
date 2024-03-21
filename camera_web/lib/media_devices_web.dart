@JS('window.navigator')
library tekartik_media_devices_js;

import 'dart:html' as js;

import 'package:js/js_util.dart' as js_util;
import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_camera_web/media_devices.dart';

@JS()
@anonymous
class _MediaDevices {
  external bool get responsive;

  /// Promise<List<MediaDeviceInfo>>
  external dynamic enumerateDevices();

  /// Promise<List<MediaDeviceInfo>>
  external dynamic getUserMedia(dynamic constraint);
}

class MediaDeviceInfoBrowser
    with MediaDeviceInfoMixin
    implements MediaDeviceInfo {
  final js.MediaDeviceInfo _nativeDeviceInfo;

  MediaDeviceInfoBrowser(this._nativeDeviceInfo);

  @override
  String? get deviceId => _nativeDeviceInfo.deviceId;

  @override
  String? get groupId => _nativeDeviceInfo.groupId;

  @override
  String? get kind => _nativeDeviceInfo.kind;

  @override
  String? get label => _nativeDeviceInfo.label;
}

@JS('mediaDevices')
external _MediaDevices get _mediaDevices;

class MediaDevicesBrowser implements MediaDevices {
  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var jsMediaDeviceInfos =
        //await window.navigator.mediaDevices.enumerateDevices();
        await js.promiseToFuture<Object?>(
            js_util.callMethod(_mediaDevices, 'enumerateDevices', [])
                as Object) as List;
    return jsMediaDeviceInfos
        .map<MediaDeviceInfo>((jsMediaDeviceInfo) =>
            MediaDeviceInfoBrowser(jsMediaDeviceInfo as js.MediaDeviceInfo))
        .toList(growable: false);
  }

  @override
  Future<MediaStream> getUserMedia(GetUserMediaConstraint constraint) async {
    var map = {
      if (constraint.video != null)
        'video': {
          if (constraint.video!.deviceId != null)
            'deviceId': constraint.video!.deviceId,
          if (constraint.video!.facingMode != null)
            'facingMode': constraint.video!.facingMode,
        }
    };
    var nativeMediaStream =
        // await promiseToFuture(_mediaDevices.getUserMedia(js_util.jsify(map)))
        await js.promiseToFuture<Object?>(js_util
                .callMethod(_mediaDevices, 'getUserMedia', [js_util.jsify(map)])
            as Object) as js.MediaStream;
    return MediaStreamWeb(
        nativeMediaStream); // await promiseToFuture(nativeUserMedia);
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    var nativeMap = js.window.navigator.mediaDevices!.getSupportedConstraints();
    return MediaTrackSupportedConstraintsBrowser(nativeMap);
  }
}

final mediaDevicesBrowser = MediaDevicesBrowser();

class MediaTrackSupportedConstraintsBrowser
    implements MediaTrackSupportedConstraints {
  final Map _nativeMap;

  MediaTrackSupportedConstraintsBrowser(this._nativeMap);

  @override
  bool get facingMode => _nativeMap['facingMode'] == true;

  @override
  String toString() => _nativeMap.toString();

  @override
  Map<String, Object?> toDebugMap() => _nativeMap.cast<String, Object?>();
}

class MediaStreamTrackWeb implements MediaStreamTrack {
  final js.MediaStreamTrack _native;

  MediaStreamTrackWeb(this._native);

  @override
  void stop() {
    _native.stop();
  }
}

class MediaStreamWeb implements MediaStream {
  final js.MediaStream nativeMediaStream;

  js.MediaStream get htmlMediaStream => nativeMediaStream;

  MediaStreamWeb(this.nativeMediaStream);

  @override
  List<MediaStreamTrack> getTracks() {
    var jsTracks = nativeMediaStream.getTracks();
    return jsTracks
        .map((jsTrack) => MediaStreamTrackWeb(jsTrack))
        .toList(growable: false);
  }
}
