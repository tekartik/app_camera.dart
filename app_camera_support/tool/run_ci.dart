import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

Future dartCi(Shell shell) async {
  await shell.run('''
    
pub get

dartanalyzer --fatal-warnings --fatal-infos .
# Check formatting
dartfmt -n --set-exit-if-changed .
pub run test
    ''');
}

Future flutterCi(Shell shell) async {
  await shell.run('''
    
flutter packages get
flutter analyze
# Check formatting
flutter format -n --set-exit-if-changed .

flutter test
    ''');
}

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
    shell = shell.pushd(dir);
    await execute(() => dartCi(shell));
    shell = shell.popd();
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
        await flutterCi(shell);
      }
    });
    shell = shell.popd();
  }
}
