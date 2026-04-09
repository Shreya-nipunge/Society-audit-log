import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/audit/models/document_model.dart';
import '../../features/audit/models/expense_model.dart';
import '../../features/complaints/models/complaint_model.dart';
import '../services/firestore_service.dart';
import '../../features/notices/models/notice_model.dart';
import 'real_society_data.dart';

class MockData {
  static final FirestoreService _firestore = FirestoreService();

  // Use a modifiable list to support CRUD in the mock environment
  static Map<String, double> allocationRatios = {
    'Maintenance': 0.70,
    'Sinking Fund': 0.20,
    'Repairs Fund': 0.10,
  };

  static List<UserModel> users = RealSocietyData.users.map((m) => UserModel.fromMap(m)).toList();
  static List<TransactionModel> transactions = [];
  static List<DemandNoticeModel> demandNotices = [];
  static List<BillModel> bills = [];
  static List<ExpenseModel> expenses = [];
  static List<NoticeModel> notices = [];

  static void syncWithFirestore() {
    final adminEmails = RealSocietyData.users
        .where((u) => u['uid'].toString().startsWith('admin_'))
        .map((u) => u['email'].toString().toLowerCase())
        .toSet();

    _firestore.getMembers().listen((updatedUsers) {
      // Filter out any Firestore users whose email clashes with admin proxies
      final filteredUsers = updatedUsers
          .where((u) => !adminEmails.contains(u.email.toLowerCase()))
          .toList();

      final memberList = filteredUsers.map((u) {
        final orig = RealSocietyData.users.firstWhere(
            (r) => r['uid'] == u.uid || r['uid'] == u.uid.replaceFirst('web_', ''), 
            orElse: () => <String, dynamic>{});
            
        final Map<String, dynamic> merged = Map<String, dynamic>.from(orig);
        merged['uid'] = u.uid;
        merged['name'] = u.name;
        merged['email'] = u.email;
        merged['role'] = u.role.name;
        merged['status'] = u.status;
        merged['password'] = orig['password'] ?? u.flatNumber;
        
        return UserModel.fromMap(merged);
      }).toList();
      
      final defaultAdmins = RealSocietyData.users
          .where((u) => u['uid'].toString().startsWith('admin_'))
          .map((m) => UserModel.fromMap(m))
          .toList();
          
      users = [...defaultAdmins, ...memberList];
      
      debugPrint('SYNC: Updated ${users.length} members (${defaultAdmins.length} admins + ${memberList.length} members)');
    });

    _firestore.getTransactions().listen((updatedTx) {
      transactions = updatedTx;
      debugPrint('SYNC: Updated ${transactions.length} transactions');
    });

    _firestore.getDemandNotices().listen((updatedBills) {
      demandNotices = updatedBills;
      debugPrint('SYNC: Updated ${demandNotices.length} bills');
    });

    _firestore.getExpenses().listen((updatedExp) {
      expenses = updatedExp;
      debugPrint('SYNC: Updated ${expenses.length} expenses');
    });

    _firestore.getNotices().listen((updatedNotices) {
      notices = updatedNotices.map((n) => NoticeModel(
        id: n['id'] ?? '',
        title: n['title'] ?? '',
        body: n['body'] ?? '',
        author: n['postedBy'] ?? '',
        date: (n['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
        status: n['status'] ?? 'Published',
      )).toList();
      debugPrint('SYNC: Updated ${notices.length} notices');
    });
  }





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


  static UserModel? login(String email, String password) {
    debugPrint('MOCK_AUTH: Checking Email: "$email"');
    debugPrint('MOCK_AUTH: Total users in memory: ${users.length}');
    
    // Log first few users for debugging
    for (var i = 0; i < users.length && i < 5; i++) {
        debugPrint('MOCK_AUTH: User[$i]: ${users[i].email}, Role: ${users[i].role}, Status: ${users[i].status}, isActive: ${users[i].isActive}');
    }

    try {
      final user = users.firstWhere(
        (u) =>
            u.email.toLowerCase().trim() == email.toLowerCase().trim() && u.isActive,
      );

      if (user.password != password) {
        debugPrint('MOCK_AUTH: Password mismatch for ${user.email}. Expected: ${user.password}, Got: $password');
        return null;
      }

      debugPrint(
        'MOCK_AUTH: Success! Found user ${user.name} (${user.role.label})',
      );
      return user;
    } catch (e) {
      debugPrint('MOCK_AUTH: User not found for email "$email". Error: $e');
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
      if (t.allocation.total == 0 && t.amount > 0) {
        // Apply default ratios if no explicit allocation exists
        maintenance += t.amount * (allocationRatios['Maintenance'] ?? 0.70);
        sinking += t.amount * (allocationRatios['Sinking Fund'] ?? 0.20);
        repairs += t.amount * (allocationRatios['Repairs Fund'] ?? 0.10);
      } else {
        maintenance += t.allocation.maintenance;
        sinking += t.allocation.sinkingFund;
        repairs += t.allocation.repairsFund;
        water += t.allocation.waterCharges;
        others += t.allocation.other;
      }
    }

    return {
      'Maintenance': maintenance,
      'Sinking Fund': sinking,
      'Repairs Fund': repairs,
      'Water Charges': water,
      'Other Charges': others,
    };
  }


  static void addNotice(NoticeModel notice) {
    notices.insert(0, notice);
  }
}
