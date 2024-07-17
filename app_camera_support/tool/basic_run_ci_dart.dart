import 'package:dev_build/package.dart';
import 'package:path/path.dart';

Future main() async {
  var topDir = join('..');
  // Pure dart
  for (var dir in <String>[
    'camera_web',
    'js_qr',
  ]) {
    await packageRunCi(join(topDir, dir));
  }
}
