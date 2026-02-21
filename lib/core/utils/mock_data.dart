import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/payments/models/fund_allocation.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/audit/models/document_model.dart';
import '../../features/audit/models/expense_model.dart';

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
      password: '123456',
      mobile: '9876543210',
      flatNumber: 'A-001',
      role: UserRole.chairman,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(
      id: 'admin_2',
      name: 'Alice Secretary',
      email: 'secretary@society.com',
      password: '123456',
      mobile: '9876543211',
      flatNumber: 'A-002',
      role: UserRole.secretary,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(
      id: 'admin_3',
      name: 'Bob Treasurer',
      email: 'treasurer@society.com',
      password: '123456',
      mobile: '9876543212',
      flatNumber: 'A-003',
      role: UserRole.treasurer,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(
      id: 'member_1',
      name: 'Member One',
      email: 'member1@gmail.com',
      password: '123456',
      mobile: '1234567890',
      flatNumber: 'A-101',
      role: UserRole.member,
      societyId: 'society_123',
      createdBy: 'admin_1',
    ),
    UserModel(
      id: 'member_2',
      name: 'Member Two',
      email: 'a102@society.com',
      password: '123456',
      mobile: '1234567891',
      flatNumber: 'A-102',
      role: UserRole.member,
      societyId: 'society_123',
      createdBy: 'admin_2',
    ),
    UserModel(
      id: 'member_3',
      name: 'Member Three',
      email: 'a103@society.com',
      password: '123456',
      mobile: '1234567892',
      flatNumber: 'A-103',
      role: UserRole.member,
      societyId: 'society_123',
      createdBy: 'admin_2',
    ),
    UserModel(
      id: 'member_4',
      name: 'Member Four',
      email: 'a104@society.com',
      password: '123456',
      mobile: '1234567893',
      flatNumber: 'A-104',
      role: UserRole.member,
      societyId: 'society_123',
      createdBy: 'admin_1',
    ),
    UserModel(
      id: 'member_5',
      name: 'Member Five',
      email: 'a105@society.com',
      password: '123456',
      mobile: '1234567894',
      flatNumber: 'A-105',
      role: UserRole.member,
      societyId: 'society_123',
      createdBy: 'admin_1',
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

  // Expenses
  static List<ExpenseModel> expenses = [
    ExpenseModel(
      id: 'EXP-001',
      category: ExpenseCategory.electricityBill,
      description: 'Common area electricity bill for January 2025',
      amount: 8500,
      date: DateTime(2025, 1, 15),
      paymentMode: ExpensePaymentMode.bankTransfer,
      vendorName: 'MSEDCL',
      referenceNumber: 'ELEC-2025-001',
      fundAllocation: FundType.maintenance,
      approvalAuthority: ApprovalAuthority.treasurer,
      recordedBy: 'Alice Secretary',
      verifiedBy: 'Bob Treasurer',
      auditTrailId: 'AUD-001',
      timestamp: DateTime(2025, 1, 15, 10, 30),
    ),
    ExpenseModel(
      id: 'EXP-002',
      category: ExpenseCategory.plumbingWork,
      subCategory: 'Pipe Leakage',
      description: 'Underground water tank repair and pipe leakage fix',
      location: 'Common Area - Basement',
      amount: 12000,
      date: DateTime(2025, 1, 20),
      paymentMode: ExpensePaymentMode.cash,
      vendorName: 'Sharma Plumbing Services',
      vendorContact: '9876543210',
      fundAllocation: FundType.repair,
      approvalAuthority: ApprovalAuthority.secretary,
      recordedBy: 'Alice Secretary',
      auditTrailId: 'AUD-002',
      timestamp: DateTime(2025, 1, 20, 14, 0),
    ),
    ExpenseModel(
      id: 'EXP-003',
      category: ExpenseCategory.securityServices,
      subCategory: 'Monthly Salary',
      description: 'Security guard salary for January 2025',
      amount: 15000,
      date: DateTime(2025, 1, 31),
      paymentMode: ExpensePaymentMode.upi,
      vendorName: 'Rajesh Kumar (Watchman)',
      referenceNumber: 'UPI-20250131-789',
      fundAllocation: FundType.maintenance,
      approvalAuthority: ApprovalAuthority.chairman,
      recordedBy: 'Bob Treasurer',
      verifiedBy: 'Alice Secretary',
      approvedBy: 'Charlie Chairman',
      auditTrailId: 'AUD-003',
      timestamp: DateTime(2025, 1, 31, 18, 0),
    ),
    ExpenseModel(
      id: 'EXP-004',
      category: ExpenseCategory.pestControl,
      subCategory: 'Quarterly Treatment',
      description: 'Quarterly pest control treatment for all floors',
      amount: 6500,
      taxAmount: 1170,
      date: DateTime(2025, 2, 5),
      paymentMode: ExpensePaymentMode.cheque,
      vendorName: 'PestFree Solutions Pvt Ltd',
      invoiceNumber: 'PFS-2025-089',
      referenceNumber: 'CHQ-445566',
      fundAllocation: FundType.maintenance,
      recordedBy: 'Alice Secretary',
      auditTrailId: 'AUD-004',
      timestamp: DateTime(2025, 2, 5, 11, 0),
    ),
    ExpenseModel(
      id: 'EXP-005',
      category: ExpenseCategory.liftMaintenance,
      subCategory: 'Annual Contract',
      description: 'Lift AMC payment Q1 2025 - 2 lifts',
      amount: 25000,
      taxAmount: 4500,
      date: DateTime(2025, 2, 10),
      paymentMode: ExpensePaymentMode.bankTransfer,
      vendorName: 'ThyssenKrupp Elevator India',
      invoiceNumber: 'TKE-INV-4521',
      fundAllocation: FundType.sinking,
      approvalAuthority: ApprovalAuthority.chairman,
      recordedBy: 'Alice Secretary',
      verifiedBy: 'Bob Treasurer',
      approvedBy: 'Charlie Chairman',
      auditTrailId: 'AUD-005',
      timestamp: DateTime(2025, 2, 10, 9, 0),
    ),
  ];

  static UserModel? login(String email, String password) {
    debugPrint('MOCK_AUTH: Checking Email: "$email"');

    try {
      final user = users.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() && user.isActive,
      );

      if (user.password != password) {
        debugPrint('MOCK_AUTH: Password mismatch for ${user.email}');
        return null;
      }

      debugPrint(
        'MOCK_AUTH: Success! Found user ${user.name} (${user.role.label})',
      );
      return user;
    } catch (e) {
      debugPrint('MOCK_AUTH: User not found for email "$email"');
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

  static List<Map<String, String>> notices = [
    {
      'id': '1',
      'title': 'Annual General Meeting',
      'date': '25 Mar 2026',
      'category': 'General',
      'status': 'Published',
      'content':
          'The Annual General Meeting of the society will be held on 25th March 2026 at the Society Clubhouse. All members are requested to attend.\n\nAgenda:\n1. Minutes of previous meeting.\n2. Approval of financial statements.\n3. Election of committee members.',
    },
    {
      'id': 'd1',
      'title': 'Republic Day Celebration (Draft)',
      'date': '26 Jan 2026',
      'category': 'Event',
      'status': 'Draft',
      'content':
          'Planning for Republic Day celebration. Flag hoisting at 8:00 AM.',
    },
    {
      'id': 'd2',
      'title': 'Lift Painting Schedule (Draft)',
      'date': '10 Mar 2026',
      'category': 'Maintenance',
      'status': 'Draft',
      'content':
          'Lifts will be painted on 10th and 11th March. Please use stairs.',
    },
    {
      'id': '2',
      'title': 'Water Supply Maintenance',
      'date': '22 Feb 2026',
      'category': 'Maintenance',
      'status': 'Published',
      'content':
          'The water supply will be suspended on 22nd February 2026 from 10:00 AM to 4:00 PM for cleaning and maintenance of the overhead tanks.\n\nPlease store sufficient water for your daily needs.',
    },
    {
      'id': '3',
      'title': 'Security Drill Notification',
      'date': '05 Mar 2026',
      'category': 'Security',
      'status': 'Published',
      'content':
          'A fire safety drill is scheduled for 5th March 2026 at 11:00 AM. This drill is mandatory for all residents to understand the evacuation protocol. Please gather near the main gate upon hearing the alarm.',
    },
  ];
  static void addNotice(Map<String, String> notice) {
    notices.insert(0, notice);
  }
}
