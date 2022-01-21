import 'package:flutter/material.dart';
import 'package:two_way_transfer/args/page_args.dart';
import 'package:two_way_transfer/src/components/appbar.dart';
import 'package:two_way_transfer/src/components/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> datos = <String>[];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    datos.add(args.log);
    datos.add(args.remision);
    return Scaffold(
      appBar: AdvancedAppBar(
        datos: datos[0],
      ),
      drawer: MainDrawer(
        datos: datos,
      ),
      body: Center(child: Text("Home")),
    );
  }
}
