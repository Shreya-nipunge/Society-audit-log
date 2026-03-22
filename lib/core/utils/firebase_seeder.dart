import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'mock_data.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> pushMockDataToFirestore() async {
    try {
      debugPrint('Starting Firestore data seeding...');
      
      // 1. Users
      final usersBatch = _firestore.batch();
      for (var user in MockData.users) {
        final docRef = _firestore.collection('users').doc(user.id);
        usersBatch.set(docRef, user.toMap());
      }
      await usersBatch.commit();
      debugPrint('Seeded Users collection.');

      // 2. Bills
      final billsBatch = _firestore.batch();
      for (var bill in MockData.bills) {
        final docRef = _firestore.collection('bills').doc(bill.id);
        billsBatch.set(docRef, bill.toMap());
      }
      await billsBatch.commit();
      debugPrint('Seeded Bills collection.');

      // 3. Transactions
      final txnBatch = _firestore.batch();
      for (var txn in MockData.transactions) {
        final docRef = _firestore.collection('transactions').doc(txn.id);
        txnBatch.set(docRef, txn.toMap());
      }
      await txnBatch.commit();
      debugPrint('Seeded Transactions collection.');

      // 4. Expenses
      final expBatch = _firestore.batch();
      for (var exp in MockData.expenses) {
        final docRef = _firestore.collection('expenses').doc(exp.id);
        expBatch.set(docRef, exp.toMap());
      }
      await expBatch.commit();
      debugPrint('Seeded Expenses collection.');

      // 5. Notices
      final noticeBatch = _firestore.batch();
      for (var notice in MockData.notices) {
        final docRef = _firestore.collection('notices').doc(notice.id);
        noticeBatch.set(docRef, notice.toMap());
      }
      await noticeBatch.commit();
      debugPrint('Seeded Notices collection.');

      // 6. Documents
      final docBatch = _firestore.batch();
      for (var document in MockData.societyDocuments) {
        final docRef = _firestore.collection('documents').doc(document.id);
        docBatch.set(docRef, document.toMap());
      }
      await docBatch.commit();
      debugPrint('Seeded Documents collection.');

      debugPrint('Firestore data seeding completed successfully!');
    } catch (e) {
      debugPrint('Error while seeding Firestore data: \$e');
      rethrow;
    }
  }
}
