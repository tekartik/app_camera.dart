import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  var topDir = join('..');
  // Pure dart
  for (var dir in <String>[
    'camera_web',
    'js_qr',
    'qrscan_flutter_web',
    'qrscan_flutter_web_example'
  ]) {
    await packageRunCi(join(topDir, dir));
  }
}
