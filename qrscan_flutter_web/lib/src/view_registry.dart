import 'package:web/web.dart' as web;
import 'dart:ui' as ui;

void registerViewFactoryWeb(
        String viewType, web.Element Function(int viewId) factory) =>
    ui.platformViewRegistry.registerViewFactory(viewType, factory);

// In a separate file excluded from lint to avoid IDE warnings...
// If you get a warning, just close this file and restart analyzed.
