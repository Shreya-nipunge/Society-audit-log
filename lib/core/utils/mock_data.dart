import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/payments/models/fund_allocation.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/audit/models/document_model.dart';
import '../../features/audit/models/expense_model.dart';
import '../../features/complaints/models/complaint_model.dart';
import '../../features/notices/models/notice_model.dart';

class MockData {
  // Use a modifiable list to support CRUD in the mock environment
  static Map<String, double> allocationRatios = {
    'Maintenance': 0.70,
    'Sinking Fund': 0.20,
    'Repairs Fund': 0.10,
  };

  static List<UserModel> users = [
    UserModel(
      uid: 'admin_1',
      name: 'John Chairman',
      email: 'chairman@society.com',
      password: '123456',
      phone: '9876543210',
      flatNumber: 'A-001',
      role: UserRole.chairman,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(
      uid: 'admin_2',
      name: 'Alice Secretary',
      email: 'secretary@society.com',
      password: '123456',
      phone: '9876543211',
      flatNumber: 'A-002',
      role: UserRole.secretary,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(
      uid: 'admin_3',
      name: 'Bob Treasurer',
      email: 'treasurer@society.com',
      password: '123456',
      phone: '9876543212',
      flatNumber: 'A-003',
      role: UserRole.treasurer,
      societyId: 'society_123',
      createdBy: 'System',
    ),
    UserModel(uid: 'member_1', name: 'Rajesh Sharma', email: 'rajesh.sharma@gmail.com', password: '123456', phone: '9823456701', flatNumber: 'A-101', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_2', name: 'Priya Mehta', email: 'priya.mehta@gmail.com', password: '123456', phone: '9823456702', flatNumber: 'A-102', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
    UserModel(uid: 'member_3', name: 'Suresh Patil', email: 'suresh.patil@gmail.com', password: '123456', phone: '9823456703', flatNumber: 'A-103', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
    UserModel(uid: 'member_4', name: 'Anita Desai', email: 'anita.desai@gmail.com', password: '123456', phone: '9823456704', flatNumber: 'A-104', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_5', name: 'Vikram Joshi', email: 'vikram.joshi@gmail.com', password: '123456', phone: '9823456705', flatNumber: 'B-101', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_6', name: 'Kavita Nair', email: 'kavita.nair@gmail.com', password: '123456', phone: '9823456706', flatNumber: 'B-102', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
    UserModel(uid: 'member_7', name: 'Amit Kulkarni', email: 'amit.kulkarni@gmail.com', password: '123456', phone: '9823456707', flatNumber: 'B-103', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_8', name: 'Sunita Rao', email: 'sunita.rao@gmail.com', password: '123456', phone: '9823456708', flatNumber: 'B-104', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
    UserModel(uid: 'member_9', name: 'Deepak Verma', email: 'deepak.verma@gmail.com', password: '123456', phone: '9823456709', flatNumber: 'C-101', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_10', name: 'Pooja Iyer', email: 'pooja.iyer@gmail.com', password: '123456', phone: '9823456710', flatNumber: 'C-102', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
    UserModel(uid: 'member_11', name: 'Rahul Gupta', email: 'rahul.gupta@gmail.com', password: '123456', phone: '9823456711', flatNumber: 'C-103', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_1'),
    UserModel(uid: 'member_12', name: 'Meena Pillai', email: 'meena.pillai@gmail.com', password: '123456', phone: '9823456712', flatNumber: 'C-104', role: UserRole.member, societyId: 'society_123', createdBy: 'admin_2'),
  ];

  static List<TransactionModel> transactions = [
    TransactionModel(
      id: 'tx_seed_1',
      memberId: 'member_1',
      memberName: 'Member One',
      flatNo: 'A-101',
      amount: 4500.0,
      paymentMethod: 'UPI',
      referenceId: 'upi_123456789',
      date: DateTime.now().subtract(const Duration(days: 45)),
      transactionType: 'Maintenance',
      status: 'Success',
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

  // --- Complaints ---
  static List<ComplaintModel> complaints = [
    ComplaintModel(id: 'cmp_1', memberId: 'member_1', memberName: 'Rajesh Sharma', flatNumber: 'A-101', category: ComplaintCategory.water, title: 'Low water pressure in morning', description: 'Water pressure is very low between 6 AM to 9 AM. It is difficult to fill water for daily use.', status: ComplaintStatus.inProgress, createdAt: DateTime.now().subtract(const Duration(days: 5)), updatedAt: DateTime.now().subtract(const Duration(days: 2)), adminRemarks: 'Plumber has been called, will be fixed by this weekend.'),
    ComplaintModel(id: 'cmp_2', memberId: 'member_2', memberName: 'Priya Mehta', flatNumber: 'A-102', category: ComplaintCategory.noise, title: 'Loud music from flat A-201', description: 'Residents of A-201 play loud music late at night, disturbing sleep. This has been happening for the past 2 weeks.', status: ComplaintStatus.pending, createdAt: DateTime.now().subtract(const Duration(days: 3)), updatedAt: DateTime.now().subtract(const Duration(days: 3))),
    ComplaintModel(id: 'cmp_3', memberId: 'member_3', memberName: 'Suresh Patil', flatNumber: 'A-103', category: ComplaintCategory.parking, title: 'Unauthorized vehicle in my parking slot', description: 'An unknown vehicle with number MH-12-AB-1234 is regularly parked in my designated slot P-23.', status: ComplaintStatus.resolved, createdAt: DateTime.now().subtract(const Duration(days: 10)), updatedAt: DateTime.now().subtract(const Duration(days: 7)), adminRemarks: 'Vehicle owner has been warned. Issue resolved.', resolvedBy: 'Rajendra Joshi'),
    ComplaintModel(id: 'cmp_4', memberId: 'member_5', memberName: 'Vikram Joshi', flatNumber: 'B-101', category: ComplaintCategory.maintenance, title: 'Lift not working on 3rd floor', description: 'The lift door does not open properly on the 3rd floor. It requires multiple attempts. Senior citizens are facing difficulty.', status: ComplaintStatus.pending, createdAt: DateTime.now().subtract(const Duration(days: 1)), updatedAt: DateTime.now().subtract(const Duration(days: 1))),
    ComplaintModel(id: 'cmp_5', memberId: 'member_7', memberName: 'Amit Kulkarni', flatNumber: 'B-103', category: ComplaintCategory.cleanliness, title: 'Garbage not collected from B wing', description: 'Garbage has not been collected from B wing staircase for 3 days. It is causing bad smell and hygiene issues.', status: ComplaintStatus.inProgress, createdAt: DateTime.now().subtract(const Duration(days: 2)), updatedAt: DateTime.now().subtract(const Duration(hours: 12)), adminRemarks: 'Housekeeping staff notified.'),
  ];

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
      users[index] = users[index].copyWith(status: 'inactive');
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

  // --- Complaint Methods ---
  static void addComplaint(ComplaintModel complaint) {
    complaints.insert(0, complaint);
  }

  static List<ComplaintModel> getAllComplaints() {
    return List.from(complaints)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<ComplaintModel> getComplaintsForMember(String memberId) {
    return complaints.where((c) => c.memberId == memberId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  static List<NoticeModel> notices = [
    NoticeModel(
      id: '1',
      title: 'Annual General Meeting',
      date: DateTime(2026, 3, 25),
      status: 'Published',
      body:
          'The Annual General Meeting of the society will be held on 25th March 2026 at the Society Clubhouse. All members are requested to attend.\n\nAgenda:\n1. Minutes of previous meeting.\n2. Approval of financial statements.\n3. Election of committee members.',
      author: 'Secretary',
    ),
    NoticeModel(
      id: 'd1',
      title: 'Republic Day Celebration (Draft)',
      date: DateTime(2026, 1, 26),
      status: 'Draft',
      body: 'Flag hoisting ceremony will be held at 9 AM in the main ground.',
      author: 'Chairman',
    ),
    NoticeModel(
      id: 'd2',
      title: 'Lift Painting Schedule',
      date: DateTime(2026, 3, 10),
      status: 'Draft',
      body: 'Lifts will be painted on 10th and 11th March. Please use stairs.',
      author: 'Maintenance Manager',
    ),
    NoticeModel(
      id: '2',
      title: 'Water Supply Maintenance',
      date: DateTime(2026, 2, 22),
      status: 'Published',
      body:
          'The water supply will be suspended on 22nd February 2026 from 10:00 AM to 4:00 PM for cleaning and maintenance of the overhead tanks.\n\nPlease store sufficient water for your daily needs.',
      author: 'Secretary',
    ),
    NoticeModel(
      id: '3',
      title: 'Security Drill Notification',
      date: DateTime(2026, 3, 5),
      status: 'Published',
      body:
          'A fire safety drill is scheduled for 5th March 2026 at 11:00 AM. This drill is mandatory for all residents to understand the evacuation protocol. Please gather near the main gate upon hearing the alarm.',
      author: 'Security Chief',
    ),
  ];
  static void addNotice(NoticeModel notice) {
    notices.insert(0, notice);
  }
}
