import 'package:flutter/cupertino.dart';

import 'package:two_way_transfer/src/pages/enviar_carta_porte.dart';

import 'package:two_way_transfer/src/pages/login_page.dart';
import 'package:two_way_transfer/src/pages/mis_cartas_porte.dart';
import 'package:two_way_transfer/src/pages/pdfview.dart';

getRoutes() {
  return (RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(
            builder: (_) => LoginPage(), settings: settings);
      case 'enviarcartaporte':
        return CupertinoPageRoute(
            builder: (_) => EnviarCartaPorte(), settings: settings);
      case 'miscartasporte':
        return CupertinoPageRoute(
            builder: (_) => MisCartasPorte(), settings: settings);
      case 'pdfview':
        return CupertinoPageRoute(
            builder: (_) => PDFViewPage(), settings: settings);
    }
  };
}
