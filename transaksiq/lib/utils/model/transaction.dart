import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  Transaction(
      {this.id,
      required this.type,
      required this.total,
      required this.note,
      required this.timestamp});

  String? id;
  String type;
  double total;
  String note;
  Timestamp timestamp;
}
