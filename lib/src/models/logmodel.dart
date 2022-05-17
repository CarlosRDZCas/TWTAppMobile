// To parse this JSON data, do
//
//     final logModel = logModelFromMap(jsonString);

import 'dart:convert';

class LogModel {
    LogModel({
        required this.id,
        required this.log,
        required this.lugar,
        required this.talon,
    });

    String id;
    int log;
    String lugar;
    int talon;

    factory LogModel.fromJson(String str) => LogModel.fromMap(json.decode(str)); 

    factory LogModel.fromMap(Map<String, dynamic> json) => LogModel(
        id: json["\u0024id"],
        log: json["log"],
        lugar: json["Lugar"],
        talon: json["Talon"],
    );

   
}
