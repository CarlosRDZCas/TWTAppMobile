import 'dart:convert';

class Log {
  Log({
    required this.fechaLayout,
    required this.log,
    required this.remision,
  });

  DateTime fechaLayout;
  int log;
  String remision;

  factory Log.fromJson(String str) => Log.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Log.fromMap(Map<String, dynamic> json) => Log(
        fechaLayout: DateTime.parse(json["FechaLayout"]),
        log: json["Log"],
        remision: json["Remision"],
      );

  Map<String, dynamic> toMap() => {
        "FechaLayout": fechaLayout.toIso8601String(),
        "Log": log,
        "Remision": remision,
      };
}
