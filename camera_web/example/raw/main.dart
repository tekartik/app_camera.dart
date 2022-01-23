import 'package:tekartik_browser_utils/browser_utils_import.dart';
import 'package:tekartik_camera_web/media_devices.dart';
import 'package:tekartik_camera_web/media_devices_web.dart';

String? _existing;

void write(Object msg) {
  var text = msg.toString();

  if (_existing == null) {
    _existing = text;
  } else {
    _existing = [_existing, text].join('\n');
  }
  querySelector('#output')!.text = _existing;
}

var mediaDevices = mediaDevicesBrowser;

Future main() async {
  write('Running video 2');

  var video = document.querySelector('#videoElement') as VideoElement?;

  var constraints = mediaDevices.getSupportedConstraints();
  write(constraints);
  try {
    var devices = await mediaDevices.enumerateDevices();
    write('got devices');
    write('devices: $devices');
    late MediaDeviceInfo deviceInfo;
    for (var device in devices) {
      // Find first device
      write('device kind: ${device.kind}');
      if (device.kind == mediaDeviceInfoKindVideo) {
        deviceInfo = device;
        break;
      }
    }

    write('getting stream deviceId ${deviceInfo.deviceId}');
    var stream = await mediaDevices.getUserMedia(GetUserMediaConstraint(
        video: GetUserMediaVideoConstraint(deviceId: deviceInfo.deviceId)));
    write('got stream');
    video!.srcObject = (stream as MediaStreamWeb).htmlMediaStream;
  } on String catch (e) {
    write('error enumerating devices $e');
  }
}
