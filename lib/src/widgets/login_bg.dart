import 'package:flutter/material.dart';

class LoginBG extends StatelessWidget {
  const LoginBG({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Transform.translate(
            offset: Offset(-20, 10),
            child: Image.asset("assets/images/twt.png", scale: 1.8),
          ),
        ],
      ),
    );
  }
}
