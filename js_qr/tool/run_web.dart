import 'dart:async';
import 'package:process_run/shell_run.dart';

Future main() async {
  print('http://localhost:8081/js/index.html');
  await run('webdev serve example:8081');
}
