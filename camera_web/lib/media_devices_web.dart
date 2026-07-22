import 'dart:js_interop';

import 'package:tekartik_camera_web/media_devices.dart';
import 'package:web/web.dart' as web;

/// Browser implementation of [MediaDeviceInfo].
class MediaDeviceInfoBrowser
    with MediaDeviceInfoMixin
    implements MediaDeviceInfo {
  final web.MediaDeviceInfo _nativeDeviceInfo;

  /// Creates a browser media device info.
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

/// Browser implementation of [MediaDevices].
class MediaDevicesBrowser implements MediaDevices {
  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var jsMediaDeviceInfos =
        (await web.window.navigator.mediaDevices.enumerateDevices().toDart)
            .toDart;

    return jsMediaDeviceInfos
        .map<MediaDeviceInfo>(
          (jsMediaDeviceInfo) => MediaDeviceInfoBrowser(jsMediaDeviceInfo),
        )
        .toList(growable: false);
  }

  @override
  Future<MediaStream> getUserMedia(GetUserMediaConstraint constraint) async {
    var webConstraints = web.MediaStreamConstraints();
    var trackConstraints = web.MediaTrackConstraints();
    webConstraints.video = web.MediaTrackConstraints();
    if (constraint.video!.deviceId != null) {
      trackConstraints.deviceId = constraint.video!.deviceId!.toJS;
    }
    if (constraint.video!.facingMode != null) {
      trackConstraints.facingMode = constraint.video!.facingMode!.toJS;
    }

    var webMediaStream = await web.window.navigator.mediaDevices
        .getUserMedia(webConstraints)
        .toDart;

    return MediaStreamWeb(
      webMediaStream,
    ); // await promiseToFuture(nativeUserMedia);
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    var webSupportedConstraints = web.window.navigator.mediaDevices
        .getSupportedConstraints();

    return MediaTrackSupportedConstraintsBrowser(webSupportedConstraints);
  }
}

/// Browser media devices singleton instance.
final mediaDevicesBrowser = MediaDevicesBrowser();

/// Browser implementation of [MediaTrackSupportedConstraints].
class MediaTrackSupportedConstraintsBrowser
    implements MediaTrackSupportedConstraints {
  final web.MediaTrackSupportedConstraints _nativeMap;

  /// Creates a browser media track supported constraints.
  MediaTrackSupportedConstraintsBrowser(this._nativeMap);

  @override
  bool get facingMode => _nativeMap.facingMode;

  @override
  String toString() => 'facingMode: $facingMode';

  @override
  Map<String, Object?> toDebugMap() =>
      (_nativeMap.dartify() as Map).cast<String, Object?>();
}

/// Web implementation of [MediaStreamTrack].
class MediaStreamTrackWeb implements MediaStreamTrack {
  final web.MediaStreamTrack _native;

  /// Creates a web media stream track.
  MediaStreamTrackWeb(this._native);

  @override
  void stop() {
    _native.stop();
  }
}

/// Web implementation of [MediaStream].
class MediaStreamWeb implements MediaStream {
  /// Native media stream.
  final web.MediaStream nativeMediaStream;

  /// HTML media stream getter.
  web.MediaStream get htmlMediaStream => nativeMediaStream;

  /// Creates a web media stream.
  MediaStreamWeb(this.nativeMediaStream);

  @override
  List<MediaStreamTrack> getTracks() {
    var jsTracks = nativeMediaStream.getTracks();
    return jsTracks.toDart
        .map((jsTrack) => MediaStreamTrackWeb(jsTrack))
        .toList(growable: false);
  }
}
