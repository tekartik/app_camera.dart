import 'dart:async';

import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  print('http://localhost:8061/raw/index.html');
  await shell.run('''
  
  pub global run webdev serve example:8061 --auto=refresh
  
  ''');
}
