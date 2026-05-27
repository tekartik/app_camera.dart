import 'dart:async';

import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';

Future main() async {
  var shell = Shell();

  stdout.writeln('http://localhost:8061/raw/index.html');
  await shell.run('''
  
  dart pub global run webdev serve example:8061 --auto=refresh
  
  ''');
}
