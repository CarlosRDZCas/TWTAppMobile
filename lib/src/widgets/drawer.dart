import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_way_transfer/args/page_args.dart';

import '../prividers/providers.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _getDrawer(context);
  }

  Widget _getDrawer(BuildContext context) {
    final loglogged = Provider.of<LogLoggedProvider>(context);
    return Drawer(
      child: Material(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.teal, Colors.black87],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              accountName: Text(
                "Bienvenido!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(loglogged.log.toString()),
              currentAccountPicture: Transform.translate(
                offset: Offset(-12, -42),
                child: Image.asset("assets/images/twt.png"),
              ),
              currentAccountPictureSize: Size.square(150),
            ),
            drawerItem(
              text: "Enviar Carta Porte",
              icon: Icons.send,
              onClicked: () => selectedItem(context, 1),
            ),
            drawerItem(
              text: "Mis Cartas Porte",
              icon: Icons.file_copy,
              onClicked: () => selectedItem(context, 2),
            ),
            drawerItem(
                text: "Permisionarios",
                icon: Icons.commute,
                onClicked: () => selectedItem(context, 4)),
            drawerItem(
              text: "Cerrar Sesion",
              icon: Icons.exit_to_app,
              onClicked: () => selectedItem(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(
      {required String text, required IconData icon, VoidCallback? onClicked}) {
    final color = Colors.teal;
    final hoverColor = Colors.tealAccent;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: Colors.black)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "home");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, 'enviarcartaporte');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, 'miscartasporte');
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
            context, "/", (route) => route == null);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, 'permisionarios');
    }
  }
}
