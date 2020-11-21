import 'dart:io';

import 'package:args/args.dart';
import 'package:dev_test/package.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

Future main(List<String> arguments) async {
  var topDir = join('..');
  var parser = ArgParser();
  parser.addFlag('help', abbr: 'h');
  parser.addFlag('parallel', abbr: 'p', defaultsTo: false);

  var results = parser.parse(arguments);
  if (results['help'] as bool) {
    print(parser.usage);
    exit(0);
  }
  var parallel = results['parallel'] as bool;

  var shell = Shell().pushd(topDir);

  Future execute(Future Function() operation) async {
    var future = operation();
    if (parallel) {
      return Future.value();
    } else {
      return future;
    }
  }

  // Pure dart
  for (var dir in <String>['camera_web', 'js_qr']) {
    await execute(() => packageRunCi(join(topDir, dir)));
  }

  // Flutter test
  for (var dir in <String>[
    'qrscan_flutter_web',
    'qrscan_flutter_web_example'
  ]) {
    shell = shell.pushd(dir);
    await execute(() async {
      // Use custom ci if available
      var customCi = join(topDir, dir, 'tool', 'ci.dart');
      if (File(customCi).existsSync()) {
        await shell.run('''
    
flutter packages get
dart ${shellArgument(customCi)}

    ''');
      } else {
        await packageRunCi(join(topDir, dir));
      }
    });
    shell = shell.popd();
  }
}
