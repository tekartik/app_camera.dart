import 'package:flutter/material.dart';
import 'package:tekartik_qrscan_flutter_web/src/scan_page.dart';

Future<String?> scanQrCode(BuildContext context, {String? title}) {
  return Navigator.of(context)
      .push(MaterialPageRoute<String>(builder: (BuildContext context) {
    return ScanPage(title: title);
  }));
}
