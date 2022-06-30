
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../prividers/providers.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LoginBG(),
          BounceInLeft (
            child: Center(
              child: FormCard(loginProvider: loginProvider),
            ),
          ),
        ],
      ),
    );
  }
}
