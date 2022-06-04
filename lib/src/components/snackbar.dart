import 'package:flutter/material.dart';

class ShowSnackBar {
  ShowSnackBar(BuildContext context, String text, int time, Color? color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 6),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
