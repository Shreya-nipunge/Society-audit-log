import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/payments/models/transaction_model.dart';
import '../../features/billing/models/demand_notice_model.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/billing/models/maintenance_receipt_model.dart';
import '../../features/audit/models/document_model.dart';
import '../../features/audit/models/expense_model.dart';
import '../../features/complaints/models/complaint_model.dart';
import '../services/firestore_service.dart';
import '../../features/notices/models/notice_model.dart';
import 'session_manager.dart';
import 'real_society_data.dart';

class MockData {
  static final FirestoreService _firestore = FirestoreService();

  // Use a modifiable list to support CRUD in the mock environment
  static Map<String, double> allocationRatios = {
    'Maintenance': 0.60,
    'Sinking Fund': 0.15,
    'Repairs Fund': 0.10,
    'Building Fund': 0.10,
    'Municipal Tax': 0.05,
  };

  static List<UserModel> users = RealSocietyData.users.map((m) => UserModel.fromMap(m)).toList();
  static List<TransactionModel> transactions = [];
  static List<DemandNoticeModel> demandNotices = [];
  static List<BillModel> bills = [];
  static List<MaintenanceReceiptModel> maintenanceReceipts = [];
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

    _firestore.getDocuments().listen((updatedDocs) {
      societyDocuments = updatedDocs.map((d) => DocumentModel.fromMap(d, d['id'] ?? '')).toList();
      debugPrint('SYNC: Updated ${societyDocuments.length} documents');
    });

    _firestore.getMaintenanceReceipts().listen((updatedReceipts) {
      maintenanceReceipts = updatedReceipts.map((r) => MaintenanceReceiptModel.fromMap(r)).toList();
      debugPrint('SYNC: Updated ${maintenanceReceipts.length} maintenance receipts');
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
    // Persist to Firestore so the user survives app restarts
    _firestore.createMember(user);
  }

  static void updateUser(UserModel updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      
      // Sync with session if the updated user is the currently logged-in user
      if (SessionManager.currentUser?.id == updatedUser.id) {
        SessionManager.currentUser = updatedUser;
      }

      // Persist to Firestore
      _firestore.createMember(updatedUser);
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
    
    // Update the user's ledger fields in real-time
    final userIndex = users.indexWhere((u) => _idMatches(u.uid, transaction.memberId));
    if (userIndex != -1) {
      final user = users[userIndex];
      users[userIndex] = user.copyWith(
        maintenanceAmount: user.maintenanceAmount + transaction.allocation.maintenance,
        sinkingFund: user.sinkingFund + transaction.allocation.sinkingFund,
        buildingFund: user.buildingFund + transaction.allocation.buildingFund,
        municipalTax: user.municipalTax + transaction.allocation.municipalTax,
        variableCharges: user.variableCharges + transaction.allocation.other,
        totalReceived: user.totalReceived + transaction.amount,
        closingBalance: user.totalReceivable - (user.totalReceived + transaction.amount),
      );
    }
  }

  static String getNextReceiptNumber() {
    return 'SAL/25/${(transactions.length + 1).toString().padLeft(4, '0')}';
  }

  static List<TransactionModel> getTransactions() {
    return List.unmodifiable(transactions);
  }

  static bool _idMatches(String id1, String id2) {
    if (id1 == id2) return true;
    final clean1 = id1.replaceFirst('web_', '').trim();
    final clean2 = id2.replaceFirst('web_', '').trim();
    return clean1 == clean2;
  }

  static List<TransactionModel> getTransactionsForMember(String memberId) {
    return transactions.where((t) => _idMatches(t.memberId, memberId)).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // --- Billing & Demand Notice Methods ---

  static void addDemandNotice(DemandNoticeModel notice) {
    demandNotices.add(notice);
    _firestore.createDemandNotice(notice.toMap());
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
    return bills.where((b) => _idMatches(b.memberId, memberId) && !b.isPaid).toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  static double getOutstandingAmount(String memberId) {
    final user = users.firstWhere((u) => _idMatches(u.uid, memberId), orElse: () => users.first);
    return user.closingBalance;
  }

  // --- Document Storage Methods ---

  static void addDocument(DocumentModel document) {
    societyDocuments.add(document);
    _firestore.createDocument(document.toMap());
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
    double maintenance = 0, sinking = 0, repairs = 0, building = 0, tax = 0, others = 0;

    for (var t in transactions) {
      if (t.allocation.total == 0 && t.amount > 0) {
        // Apply default ratios if no explicit allocation exists
        maintenance += t.amount * (allocationRatios['Maintenance'] ?? 0.60);
        sinking += t.amount * (allocationRatios['Sinking Fund'] ?? 0.15);
        repairs += t.amount * (allocationRatios['Repairs Fund'] ?? 0.10);
        building += t.amount * (allocationRatios['Building Fund'] ?? 0.10);
        tax += t.amount * (allocationRatios['Municipal Tax'] ?? 0.05);
      } else {
        maintenance += t.allocation.maintenance;
        sinking += t.allocation.sinkingFund;
        repairs += t.allocation.repairsFund;
        building += t.allocation.buildingFund;
        tax += t.allocation.municipalTax;
        others += t.allocation.other;
      }
    }

    for (var r in maintenanceReceipts) {
      if (r.paymentMode != 'Pending') {
        maintenance += r.maintenance;
        sinking += r.sinkingFund;
        building += r.buildingFund;
        tax += r.municipalTax;
        others += r.noc + r.parkingCharges + r.miscellaneous + r.penaltyAmount;
      }
    }

    return {
      'Maintenance': maintenance,
      'Sinking Fund': sinking,
      'Repairs Fund': repairs,
      'Building Fund': building,
      'Municipal Tax': tax,
      'Other Charges': others,
    };
  }

  static Map<String, double> getMemberContributions(String memberId) {
    double maintenance = 0, sinking = 0, repairs = 0, building = 0, tax = 0, noc = 0, parking = 0, other = 0, delay = 0, transfer = 0, totalPaid = 0;

    for (var t in transactions.where((t) => _idMatches(t.memberId, memberId))) {
       totalPaid += t.amount;
       if (t.allocation.total == 0 && t.amount > 0) {
         maintenance += t.amount * (allocationRatios['Maintenance'] ?? 0.60);
         sinking += t.amount * (allocationRatios['Sinking Fund'] ?? 0.15);
         repairs += t.amount * (allocationRatios['Repairs Fund'] ?? 0.10);
         building += t.amount * (allocationRatios['Building Fund'] ?? 0.10);
         tax += t.amount * (allocationRatios['Municipal Tax'] ?? 0.05);
       } else {
         maintenance += t.allocation.maintenance;
         sinking += t.allocation.sinkingFund;
         repairs += t.allocation.repairsFund;
         building += t.allocation.buildingFund;
         tax += t.allocation.municipalTax;
         other += t.allocation.other;
       }
    }

    for (var r in maintenanceReceipts.where((r) => _idMatches(r.memberId, memberId))) {
      if (r.paymentMode != 'Pending') {
        totalPaid += r.totalAmount;
        maintenance += r.maintenance;
        sinking += r.sinkingFund;
        building += r.buildingFund;
        tax += r.municipalTax;
        noc += r.noc;
        parking += r.parkingCharges;
        other += r.miscellaneous;
        delay += r.penaltyAmount;
      }
    }

    return {
      'Maintenance': maintenance,
      'Sinking Fund': sinking,
      'Repairs Fund': repairs,
      'Building Fund': building,
      'Municipal Tax': tax,
      'NOC': noc,
      'Parking Charges': parking,
      'Other Charges': other,
      'Delay Charges': delay,
      'Room Transfer Fees': transfer,
      'Total Paid': totalPaid,
    };
  }


  static void addNotice(NoticeModel notice) {
    notices.insert(0, notice);
  }

  // --- Maintenance Receipt Methods ---

  static void addMaintenanceReceipt(MaintenanceReceiptModel receipt) {
    maintenanceReceipts.insert(0, receipt);
    _firestore.createMaintenanceReceipt(receipt.toMap());

    // Update the user's ledger fields in real-time (As Is Data)
    if (receipt.paymentMode != 'Pending') {
      final userIndex = users.indexWhere((u) => _idMatches(u.uid, receipt.memberId));
      if (userIndex != -1) {
        final user = users[userIndex];
        users[userIndex] = user.copyWith(
          maintenanceAmount: user.maintenanceAmount + receipt.maintenance,
          sinkingFund: user.sinkingFund + receipt.sinkingFund,
          municipalTax: user.municipalTax + receipt.municipalTax,
          noc: user.noc + receipt.noc,
          parkingCharges: user.parkingCharges + receipt.parkingCharges,
          delayCharges: user.delayCharges + receipt.penaltyAmount,
          buildingFund: user.buildingFund + receipt.buildingFund,
          roomTransferFees: user.roomTransferFees + (receipt.miscellaneous > 1000 ? receipt.miscellaneous : 0), // heuristics for mockup
          totalReceived: user.totalReceived + receipt.totalAmount,
          closingBalance: user.totalReceivable - (user.totalReceived + receipt.totalAmount),
        );
      }
    }
  }

  static List<MaintenanceReceiptModel> getReceiptsForMember(String memberId) {
    return maintenanceReceipts
        .where((r) => _idMatches(r.memberId, memberId))
        .toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  static MaintenanceReceiptModel? getLatestReceiptForMember(String memberId) {
    final receipts = getReceiptsForMember(memberId);
    return receipts.isNotEmpty ? receipts.first : null;
  }

  static List<MaintenanceReceiptModel> getUnresolvedPendingReceipts(String memberId) {
    final receipts = getReceiptsForMember(memberId);
    final paidReceipts = receipts.where((r) => r.paymentMode != 'Pending').toList();

    return receipts.where((r) {
      if (r.paymentMode != 'Pending') return false;
      final isPaid = paidReceipts.any((p) =>
          p.periodFrom.year == r.periodFrom.year &&
          p.periodFrom.month == r.periodFrom.month &&
          p.periodTo.year == r.periodTo.year &&
          p.periodTo.month == r.periodTo.month);
      return !isPaid;
    }).toList();
  }

  static String getNextMaintenanceReceiptNumber() {
    return 'MR/25/${(maintenanceReceipts.length + 1).toString().padLeft(4, '0')}';
  }

  static List<DateTime> getUnpaidMonthsForMember(String memberId) {
    final now = DateTime.now();
    final paidMonths = <String>{};
    final billedMonths = <DateTime>[];

    // Collect paid months from receipts, and add Pending to billed
    for (final receipt in maintenanceReceipts) {
      if (_idMatches(receipt.memberId, memberId)) {
        if (receipt.paymentMode == 'Pending') {
          billedMonths.add(DateTime(receipt.periodFrom.year, receipt.periodFrom.month, 1));
        } else {
          final key = '${receipt.periodFrom.year}-${receipt.periodFrom.month}';
          paidMonths.add(key);
        }
      }
    }

    // Also check transactions as paid
    for (final tx in transactions) {
      if (_idMatches(tx.memberId, memberId)) {
        final key = '${tx.date.year}-${tx.date.month}';
        paidMonths.add(key);
      }
    }

    // Check demand notices for which months bills were generated
    for (final dn in demandNotices) {
      if (_idMatches(dn.memberId, memberId)) {
        // Parse month name to get actual month
        final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'];
        final monthIndex = monthNames.indexOf(dn.month) + 1;
        if (monthIndex > 0) {
          billedMonths.add(DateTime(dn.year, monthIndex, 1));
        }
      }
    }

    // Find months that are billed but not paid
    final unpaid = <DateTime>[];
    for (final month in billedMonths) {
      final key = '${month.year}-${month.month}';
      if (!paidMonths.contains(key) && month.isBefore(now)) {
        final isDuplicate = unpaid.any((d) => d.year == month.year && d.month == month.month);
        if (!isDuplicate) {
          unpaid.add(month);
        }
      }
    }

    return unpaid;
  }
}
