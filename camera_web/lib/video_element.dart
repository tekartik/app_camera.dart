import 'package:tekartik_camera_web/media_devices.dart';

abstract class VideoElement {
  /// Check ready state for HAVE_ENOUGH_DATA.
  bool get hasEnoughData;

  /// Play the media.
  Future play();

  /// Pause the media.
  void pause();

  /// Needed for Safari to allow capture not in full screen
  void allowPlayInline();

  /// Set for autoplay.
  set autoplay(bool autoplay);

  /// Set the stream object.
  set srcObject(MediaStream mediaStream);

  /// Set the media source.
  set src(String src);

  /// Remove the element.
  void remove();

  /// height.
  int get videoHeight;

  /// width.
  int get videoWidth;
}
