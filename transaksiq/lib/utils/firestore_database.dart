import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaksiq/utils/model/user.dart';
import 'package:transaksiq/utils/model/transaction.dart' as transaction_model;

final _firestore = FirebaseFirestore.instance;

class FirestoreDatabase {
  // static Source source = Source.cache;

  static Future<void> addTransaction(
      String uid, transaction_model.Transaction transaction) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add({
      'type': transaction.type,
      'total': transaction.total,
      'note': transaction.note,
      'timeStamp': transaction.timestamp,
    });
  }

  static Future<void> deleteTransaction(String uid, String transactionId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  static Future<void> updateTransaction(
      String uid, transaction_model.Transaction transaction) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.id)
        .update({
      'total': transaction.total,
      'type': transaction.type,
      'note': transaction.note,
      'timeStamp': transaction.timestamp,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDataTransactions(
      String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  static Future<void> addUser(String uid, User user) {
    return _firestore.collection('users').doc(uid).set({
      'name': user.name,
      'phoneNumber': user.phoneNumber,
    });
  }

  static Future<void> updateUser(String uid, User user) {
    return _firestore.collection('users').doc(uid).update({
      'name': user.name,
      'phoneNumber': user.phoneNumber,
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }
}
