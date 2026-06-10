/// Media device info kind for video.
const String mediaDeviceInfoKindVideo = 'videoinput';

/// Facing mode environment constraint.
const String mediaVideoConstraintFacingModeEnvironment = 'environment';

/// Video constraint for user media.
class GetUserMediaVideoConstraint {
  /// Device identifier.
  final String? deviceId;

  /// Facing mode.
  final String? facingMode;

  /// Creates user media video constraints.
  GetUserMediaVideoConstraint({this.deviceId, this.facingMode});
}

/// Constraint for get user media.
class GetUserMediaConstraint {
  /// Video constraints.
  final GetUserMediaVideoConstraint? video;

  /// Creates user media constraints.
  GetUserMediaConstraint({this.video});
}

/// A Boolean value whose value is true if the facingMode constraint is
/// supported in the current environment.
abstract class MediaTrackSupportedConstraints {
  /// A Boolean value whose value is true if the facingMode constraint is
  /// supported in the current environment.
  bool get facingMode;

  /// Debug map
  Map<String, Object?> toDebugMap();
}

/// contains information that describes a single media input or output device.
abstract class MediaDeviceInfo {
  /// Identifier for the represented device that is persisted across sessions
  /// It is un-guessable by other applications and unique to the origin
  /// of the calling application. It is reset when the user clears cookies
  /// (for Private Browsing, a different identifier is used that is not persisted across sessions).
  String? get deviceId;

  /// Ggroup identifier. Two devices have the same group identifier
  /// if they belong to the same physical device — for example a monitor
  /// with both a built-in camera and a microphone.
  String? get groupId;

  ///  enumerated value that is either "videoinput", "audioinput" or "audiooutput".
  String? get kind;

  /// label describing this device (for example "External USB Webcam").
  String? get label;

  /// Debug map
  Map<String, Object?> toDebugMap();
}

/// Mixin for [MediaDeviceInfo].
mixin MediaDeviceInfoMixin implements MediaDeviceInfo {
  @override
  String toString() => toDebugMap().toString();

  @override
  Map<String, Object?> toDebugMap() {
    return <String, Object?>{
      if (deviceId != null) 'deviceId': deviceId,
      if (groupId != null) 'groupId': groupId,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
    };
  }
}

/// The MediaStream interface represents a stream of media content.
///
/// A stream consists of several tracks such as video or audio tracks.
/// Each track is specified as an instance of MediaStreamTrack.
abstract class MediaStream {
  /// Returns a list of all MediaStreamTrack objects stored in
  /// the MediaStream object, regardless of the value of the kind attribute
  List<MediaStreamTrack> getTracks();
}

/// Represents a single media track within a stream.
abstract class MediaStreamTrack {
  /// Stops playing the source associated to the track, both the source and
  /// the track are deassociated. The track state is set to ended.
  void stop();
}

/// The MediaDevices interface provides access to connected media input devices
/// like cameras and microphones, as well as screen sharing. In essence, it lets you obtain access to any hardware source of media data.
abstract class MediaDevices {
  /// Obtains an array of information about the media input and output devices
  /// available on the system.
  Future<List<MediaDeviceInfo>> enumerateDevices();

  /// With the user's permission through a prompt, turns on a camera and/or
  /// a microphone on the system and provides a MediaStream containing a video
  /// track and/or an audio track with the input.
  Future<MediaStream> getUserMedia(GetUserMediaConstraint constraint);

  /// dictionary listing the constraints supported by the user agent.
  /// Because only constraints supported by the user agent are included in the list, each of these Boolean properties has the value true.
  MediaTrackSupportedConstraints getSupportedConstraints();
}
