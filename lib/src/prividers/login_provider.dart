import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class LoginProvider extends ChangeNotifier {
  bool loading = false;
  bool isLogged = false;
  String _baseUrl = 'twowaytransfer-c8f27-default-rtdb.firebaseio.com';
  GlobalKey<FormState> frmKey = GlobalKey<FormState>();
  String? log;
  String? remision;
  List<Log> logs = [];

  LoginProvider() {
    cargarLogs();
  }

  Future cargarLogs() async {
    final url = Uri.https(_baseUrl, '/Logs.json');
    final resp = await http.get(url);
    final Map<String, dynamic> logsMap = json.decode(resp.body);
    logsMap.forEach((key, value) {
      final log = Log.fromMap(value);
      logs.add(log);
    });
  }

  bool isValidForm() {
    return frmKey.currentState!.validate();
  }

  Log? login() {
    loading = true;
    if (logs.any((element) => element.log == int.parse(log!))) {
      isLogged = true;
      loading = false;
      Log logLogged =
          logs.firstWhere((element) => element.log == int.parse(log!));
      return logLogged;
    } else {
      isLogged = false;
      loading = false;
      return null;
    }
  }
}
