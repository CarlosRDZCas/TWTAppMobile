import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'package:two_way_transfer/src/prividers/providers.dart';
import 'package:two_way_transfer/src/routes/routes.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartaPorteProvider()),
        ChangeNotifierProvider(create: (_) => MisCartasPorteProvider()),
        ChangeNotifierProvider(create: (_) => PermisionariosProvider()),
        ChangeNotifierProvider(create: (_) => PDFProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => LogLoggedProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Two Way Transfer',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        initialRoute: '/',
        onGenerateRoute: getRoutes(),
      ),
    );
  }
}
