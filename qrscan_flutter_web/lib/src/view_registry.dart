import 'dart:html';
import 'dart:ui' as ui;

void registerViewFactoryWeb(
        String viewType, Element Function(int viewId) factory) =>
    ui.platformViewRegistry.registerViewFactory(viewType, factory);

// In a separate file excluded from lint to avoid IDE warnings...
// If you get a warning, just close this file and restart analyzed.
