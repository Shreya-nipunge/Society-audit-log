import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/audit/models/expense_model.dart';
import '../../features/auth/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time stream of members
  Stream<List<UserModel>> getMembers() {
    return _db.collection('users').orderBy('flatNumber').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({...data, 'uid': doc.id});
      }).toList();
    });
  }

  // Real-time stream of transactions
  Stream<List<TransactionModel>> getTransactions() {
    return _db.collection('transactions').orderBy('paidAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Real-time stream of demand notices (bills)
  Stream<List<DemandNoticeModel>> getDemandNotices() {
    return _db.collection('bills').orderBy('dueDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DemandNoticeModel.fromMap({...doc.data(), 'id': doc.id})).toList();
    });
  }

  // Real-time stream of society expenses
  Stream<List<ExpenseModel>> getExpenses() {
    return _db.collection('expenses').orderBy('expenseDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Real-time stream of notices
  Stream<List<Map<String, dynamic>>> getNotices() {
    return _db.collection('notices').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    });
  }
  
  // Update member data
  Future<void> updateMember(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
