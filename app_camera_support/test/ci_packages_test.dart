@TestOn('vm')
library;

import 'package:dev_build/build_support.dart';
import 'package:test/test.dart';

import '../tool/basic_run_ci_flutter.dart';

void main() {
  test('the CI checks every package of the workspace', () async {
    var pubspec = await pathGetPubspecYamlMap('..');
    var workspace = (pubspec['workspace'] as List).cast<String>().toSet()
      ..remove('app_camera_support');
    expect(ciPackageDirs.toSet(), workspace);
  });
}
