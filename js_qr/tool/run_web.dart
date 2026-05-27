import 'dart:async';
import 'package:process_run/shell_run.dart';
import 'package:process_run/stdio.dart';

Future main() async {
  stdout.writeln('http://localhost:8081/js/index.html');
  await run('webdev serve example:8081');
}
