import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/payments/models/fund_allocation.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/audit/models/document_model.dart';

class MockData {
  // Use a modifiable list to support CRUD in the mock environment
  static Map<String, double> allocationRatios = {
    'Maintenance': 0.70,
    'Sinking Fund': 0.20,
    'Repairs Fund': 0.10,
  };

  static List<UserModel> users = [
    UserModel(
      id: 'admin_1',
      name: 'John Chairman',
      email: 'chairman@society.com',
      mobile: '9876543210',
      role: UserRole.chairman,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'admin_2',
      name: 'Alice Secretary',
      email: 'secretary@society.com',
      mobile: '9876543211',
      role: UserRole.secretary,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'admin_3',
      name: 'Bob Treasurer',
      email: 'treasurer@society.com',
      mobile: '9876543212',
      role: UserRole.treasurer,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'member_1',
      name: 'Member One',
      email: 'member1@gmail.com',
      mobile: '1234567890',
      role: UserRole.member,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'member_2',
      name: 'Member Two',
      email: 'member2@gmail.com',
      mobile: '1234567891',
      role: UserRole.member,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'member_3',
      name: 'Member Three',
      email: 'member3@gmail.com',
      mobile: '1234567892',
      role: UserRole.member,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'member_4',
      name: 'Member Four',
      email: 'member4@gmail.com',
      mobile: '1234567893',
      role: UserRole.member,
      societyId: 'society_123',
    ),
    UserModel(
      id: 'member_5',
      name: 'Member Five',
      email: 'member5@gmail.com',
      mobile: '1234567894',
      role: UserRole.member,
      societyId: 'society_123',
    ),
  ];

  static List<TransactionModel> transactions = [
    TransactionModel(
      id: 'tx_seed_1',
      memberId: 'member_1',
      memberName: 'Member One',
      flatNo: 'A-101',
      amount: 4500.0,
      paymentMode: 'UPI',
      referenceNo: 'upi_123456789',
      allocation: FundAllocation(
        maintenance: 3000,
        sinkingFund: 500,
        repairsFund: 500,
        waterCharges: 500,
      ),
      receiptNo: 'SAL/25/0001',
      recordedBy: 'admin_3',
      recordedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  static List<DemandNoticeModel> demandNotices = [
    // Seed one previous demand notice for member_1 to match tx_seed_1
    DemandNoticeModel(
      id: 'dn_seed_1',
      memberId: 'member_1',
      month: 'January',
      year: 2025,
      maintenance: 3000,
      waterCharges: 500,
      otherCharges: 1000,
      dueDate: DateTime(2025, 1, 25),
      generatedAt: DateTime(2025, 1, 1),
    ),
  ];

  static List<BillModel> bills = []; // New bill storage

  static List<DocumentModel> societyDocuments = [
    DocumentModel(
      id: 'doc_1',
      title: 'Annual General Meeting 2024 - Minutes',
      category: 'AGM Minutes',
      fileName: 'AGM_2024_Minutes.pdf',
      uploadedBy: 'Secretary',
      uploadedAt: DateTime(2024, 7, 15),
      visibility: 'member',
    ),
  ];

  static const String mockPassword = '123456';

  static UserModel? login(String email, String password) {
    debugPrint('MOCK_AUTH: Checking Email: "$email", PWD: "$password"');
    debugPrint('MOCK_AUTH: Mock Password is: "$mockPassword"');
    if (password != mockPassword) {
      debugPrint('MOCK_AUTH: Password Mismatch!');
      return null;
    }

    try {
      final user = users.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() && user.isActive,
      );
      debugPrint('MOCK_AUTH: Success! Found user ${user.name}');
      return user;
    } catch (e) {
      debugPrint('MOCK_AUTH: User not found for email "$email"');
      debugPrint(
        'MOCK_AUTH: Available emails: ${users.map((u) => u.email).toList()}',
      );
      return null;
    }
  }

  // --- Member Management Methods ---

  static void addUser(UserModel user) {
    users.add(user);
  }

  static void updateUser(UserModel updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
    }
  }

  static void deleteUser(String id) {
    final index = users.indexWhere((u) => u.id == id);
    if (index != -1) {
      users[index] = users[index].copyWith(isActive: false);
    }
  }

  static List<UserModel> getMembers() {
    return users.where((u) => u.role == UserRole.member && u.isActive).toList();
  }

  // --- Payment & Transaction Methods ---

  static void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
  }

  static String getNextReceiptNumber() {
    return 'SAL/25/${(transactions.length + 1).toString().padLeft(4, '0')}';
  }

  static List<TransactionModel> getTransactions() {
    return List.unmodifiable(transactions);
  }

  static List<TransactionModel> getTransactionsForMember(String memberId) {
    return transactions.where((t) => t.memberId == memberId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // --- Billing & Demand Notice Methods ---

  static void addDemandNotice(DemandNoticeModel notice) {
    demandNotices.add(notice);
  }

  static List<DemandNoticeModel> getDemandNotices() {
    return List.unmodifiable(demandNotices);
  }

  static List<DemandNoticeModel> getDemandNoticesForMember(String memberId) {
    return demandNotices.where((dn) => dn.memberId == memberId).toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  // --- New Bill Management ---
  static void addBill(BillModel bill) {
    bills.add(bill);
  }

  static List<BillModel> getUnpaidBillsForMember(String memberId) {
    return bills.where((b) => b.memberId == memberId && !b.isPaid).toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  static double getOutstandingAmount(String memberId) {
    // Total Dues from Demand Notices
    final totalBilled = demandNotices
        .where((dn) => dn.memberId == memberId)
        .fold(0.0, (sum, dn) => sum + dn.total);

    // Total Paid from Transactions
    final totalPaid = transactions
        .where((t) => t.memberId == memberId)
        .fold(0.0, (sum, t) => sum + t.amount);

    return totalBilled - totalPaid;
  }

  // --- Document Storage Methods ---

  static void addDocument(DocumentModel document) {
    societyDocuments.add(document);
  }

  static List<DocumentModel> getDocuments(UserRole role) {
    if (role == UserRole.member) {
      return societyDocuments
          .where((doc) => doc.visibility == 'member')
          .toList();
    }
    return societyDocuments;
  }

  // --- Financial Aggregation Methods (Reports) ---

  static double getTotalCollected() {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getTotalOutstanding() {
    return users
        .where((u) => u.role == UserRole.member)
        .fold(0.0, (sum, u) => sum + getOutstandingAmount(u.id));
  }

  static Map<String, double> getFundBalances() {
    double maintenance = 0, sinking = 0, repairs = 0, water = 0, others = 0;

    for (var t in transactions) {
      maintenance += t.allocation.maintenance;
      sinking += t.allocation.sinkingFund;
      repairs += t.allocation.repairsFund;
      water += t.allocation.waterCharges;
      others += t.allocation.other;
    }

    return {
      'Maintenance': maintenance,
      'Sinking Fund': sinking,
      'Repairs Fund': repairs,
      'Water Charges': water,
      'Other Charges': others,
    };
  }
}
