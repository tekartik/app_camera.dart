import 'package:dev_build/package.dart';
import 'package:path/path.dart';

/// The packages of the workspace the CI checks (format, analyze, test), all
/// but this one.
const ciPackageDirs = <String>[
  'camera_web',
  'js_qr',
  'qrscan_flutter',
  'qrscan_flutter_example',
  'qrscan_flutter_mobile_scanner',
  'qrscan_flutter_web',
];

Future main() async {
  var topDir = join('..');
  for (var dir in ciPackageDirs) {
    await packageRunCi(join(topDir, dir));
  }
}
