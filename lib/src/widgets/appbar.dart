import 'package:flutter/material.dart';

class AdvancedAppBar extends StatefulWidget implements PreferredSizeWidget {
  AdvancedAppBar({Key? key, required this.acciones}) : super(key: key);

  List<Widget>? acciones = <Widget>[];

  @override
  _AdvancedAppBarState createState() => _AdvancedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AdvancedAppBarState extends State<AdvancedAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.translate(
            offset: Offset(-15, 0),
            child: Container(
              height: 90,
              width: 90,
              child: Image(
                image: AssetImage(
                  "assets/images/twt.png",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text("Two Way Transfer",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      actions: widget.acciones,
    );
  }
}
