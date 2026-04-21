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

  // Real-time stream of documents
  Stream<List<Map<String, dynamic>>> getDocuments() {
    return _db.collection('documents').orderBy('uploadedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    });
  }
  
  // Update member data
  Future<void> updateMember(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Create document in Firestore
  Future<void> createDocument(Map<String, dynamic> doc) async {
    await _db.collection('documents').doc(doc['id']).set(doc);
  }

  // Create maintenance receipt in Firestore
  Future<void> createMaintenanceReceipt(Map<String, dynamic> receipt) async {
    await _db.collection('maintenance_receipts').doc(receipt['receiptNo'].replaceAll('/', '_')).set(receipt);
  }

  // Create demand notice in Firestore
  Future<void> createDemandNotice(Map<String, dynamic> notice) async {
    await _db.collection('bills').doc(notice['id']).set(notice);
  }

  // Real-time stream of maintenance receipts
  Stream<List<Map<String, dynamic>>> getMaintenanceReceipts() {
    return _db.collection('maintenance_receipts').orderBy('generatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Create a new member in Firestore (persists across app restarts)
  Future<void> createMember(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'flatNumber': user.flatNumber,
        'role': user.role.name,
        'status': user.status,
        'societyId': user.societyId,
        'createdBy': user.createdBy,
        'createdAt': DateTime.now().toIso8601String(),
        'password': user.password,
        'openingBalance': user.openingBalance,
        'sinkingFund': user.sinkingFund,
        'maintenanceAmount': user.maintenanceAmount,
        'municipalTax': user.municipalTax,
        'noc': user.noc,
        'parkingCharges': user.parkingCharges,
        'delayCharges': user.delayCharges,
        'buildingFund': user.buildingFund,
        'roomTransferFees': user.roomTransferFees,
        'totalReceivable': user.totalReceivable,
        'totalReceived': user.totalReceived,
        'closingBalance': user.closingBalance,
        'fixedMonthlyCharges': user.fixedMonthlyCharges,
        'annualCharges': user.annualCharges,
        'variableCharges': user.variableCharges,
      });
    } catch (e) {
      // ignore: avoid_print
      print('FirestoreService: Error creating member: $e');
    }
  }
}
