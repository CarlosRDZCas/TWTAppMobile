import 'package:cloud_firestore/cloud_firestore.dart';

class ListenerObj {
  final String remision;
  final String log;
  final String nomOp;

  ListenerObj({
    required this.remision,
    required this.log,
    required this.nomOp,
  });

  factory ListenerObj.fromJson(DocumentChange doc) {
    return ListenerObj(
      remision: doc.doc['Remision'],
      log: doc.doc['Log'],
      nomOp: doc.doc['NombreOperador'],
    );
  }
}
