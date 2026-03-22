import 'package:flutter/material.dart';

/// 35+ professional audit-grade expense categories
enum ExpenseCategory {
  electricityBill('Electricity Bill', Icons.flash_on_rounded),
  waterBill('Water Bill', Icons.water_drop_rounded),
  municipalTax('Municipal Tax', Icons.account_balance_rounded),
  propertyTax('Property Tax', Icons.home_work_rounded),
  liftMaintenance('Lift Maintenance', Icons.elevator_rounded),
  generatorMaintenance('Generator Maintenance', Icons.power_rounded),
  cctvMaintenance('CCTV Maintenance', Icons.videocam_rounded),
  securityServices('Security Services', Icons.shield_rounded),
  housekeepingServices(
    'Housekeeping Services',
    Icons.cleaning_services_rounded,
  ),
  garbageCollection('Garbage Collection', Icons.delete_rounded),
  plumbingWork('Plumbing Work', Icons.plumbing_rounded),
  electricalRepair('Electrical Repair', Icons.lightbulb_rounded),
  carpentryWork('Carpentry Work', Icons.carpenter_rounded),
  paintingWork('Painting Work', Icons.format_paint_rounded),
  pestControl('Pest Control', Icons.pest_control_rounded),
  fireSafetyEquipment('Fire Safety Equipment', Icons.fire_extinguisher_rounded),
  amcContracts('AMC Contracts', Icons.handshake_rounded),
  internetBroadband('Internet / Broadband', Icons.wifi_rounded),
  societyOfficeExpenses('Society Office Expenses', Icons.business_rounded),
  stationery('Stationery', Icons.edit_note_rounded),
  legalFees('Legal Fees', Icons.gavel_rounded),
  accountingAuditFees('Accounting / Audit Fees', Icons.calculate_rounded),
  insurancePremium('Insurance Premium', Icons.assignment_rounded),
  structuralRepairs('Structural Repairs', Icons.construction_rounded),
  gardenLandscape('Garden / Landscape Maintenance', Icons.yard_rounded),
  parkingMaintenance('Parking Area Maintenance', Icons.local_parking_rounded),
  solarPanelMaintenance('Solar Panel Maintenance', Icons.solar_power_rounded),
  stpWtpMaintenance('STP / WTP Maintenance', Icons.water_rounded),
  commonAreaMaintenance('Common Area Maintenance', Icons.apartment_rounded),
  festivalExpenses('Festival Expenses', Icons.celebration_rounded),
  eventExpenses('Event Expenses', Icons.event_rounded),
  emergencyRepairs('Emergency Repairs', Icons.warning_rounded),
  contractorPayments('Contractor Payments', Icons.engineering_rounded),
  vendorPayments('Vendor Payments', Icons.store_rounded),
  other('Other', Icons.more_horiz_rounded);

  final String label;
  final IconData icon;
  const ExpenseCategory(this.label, this.icon);

  /// Dynamic sub-categories based on main category
  List<String> get subCategories {
    switch (this) {
      case ExpenseCategory.plumbingWork:
        return [
          'Pipe Leakage',
          'Motor Repair',
          'Tank Cleaning',
          'Valve Replacement',
          'Drainage Work',
          'Other',
        ];
      case ExpenseCategory.electricalRepair:
        return [
          'Wiring Repair',
          'Panel Repair',
          'Switch/Socket',
          'MCB/Fuse',
          'Earthing',
          'Other',
        ];
      case ExpenseCategory.liftMaintenance:
        return [
          'Annual Contract',
          'Breakdown Repair',
          'Oil Change',
          'Safety Inspection',
          'Parts Replacement',
          'Other',
        ];
      case ExpenseCategory.generatorMaintenance:
        return [
          'Diesel Purchase',
          'Oil Change',
          'Battery Replacement',
          'Servicing',
          'Repair',
          'Other',
        ];
      case ExpenseCategory.cctvMaintenance:
        return [
          'Camera Replacement',
          'DVR/NVR Repair',
          'Cable Work',
          'Annual Contract',
          'New Installation',
          'Other',
        ];
      case ExpenseCategory.securityServices:
        return [
          'Monthly Salary',
          'Overtime',
          'Uniform',
          'Equipment',
          'Agency Payment',
          'Other',
        ];
      case ExpenseCategory.housekeepingServices:
        return [
          'Monthly Salary',
          'Cleaning Supplies',
          'Deep Cleaning',
          'Overtime',
          'Agency Payment',
          'Other',
        ];
      case ExpenseCategory.paintingWork:
        return [
          'Interior Painting',
          'Exterior Painting',
          'Waterproofing',
          'Touch-up Work',
          'Other',
        ];
      case ExpenseCategory.carpentryWork:
        return [
          'Door Repair',
          'Window Repair',
          'Furniture Repair',
          'New Installation',
          'Other',
        ];
      case ExpenseCategory.pestControl:
        return [
          'Quarterly Treatment',
          'Annual Contract',
          'Termite Control',
          'Mosquito Fogging',
          'Rodent Control',
          'Other',
        ];
      case ExpenseCategory.fireSafetyEquipment:
        return [
          'Fire Extinguisher Refill',
          'Hose Reel Service',
          'Alarm System',
          'Sprinkler Maintenance',
          'Safety Audit',
          'Other',
        ];
      case ExpenseCategory.structuralRepairs:
        return [
          'Wall Cracks',
          'Slab Repair',
          'Column Repair',
          'Waterproofing',
          'Foundation',
          'Other',
        ];
      case ExpenseCategory.gardenLandscape:
        return [
          'Gardener Salary',
          'Plants & Seeds',
          'Fertilizer',
          'Equipment',
          'Landscaping Work',
          'Other',
        ];
      case ExpenseCategory.stpWtpMaintenance:
        return [
          'Chemical Treatment',
          'Motor Repair',
          'Filter Cleaning',
          'Annual Contract',
          'Other',
        ];
      case ExpenseCategory.commonAreaMaintenance:
        return [
          'Lobby Cleaning',
          'Staircase Repair',
          'Terrace Maintenance',
          'Corridor Lighting',
          'Other',
        ];
      case ExpenseCategory.amcContracts:
        return [
          'Lift AMC',
          'Generator AMC',
          'CCTV AMC',
          'Fire System AMC',
          'Pump AMC',
          'Other',
        ];
      case ExpenseCategory.insurancePremium:
        return [
          'Building Insurance',
          'Lift Insurance',
          'Fire Insurance',
          'Liability Insurance',
          'Other',
        ];
      default:
        return [];
    }
  }
}

/// Payment mode for expenses
enum ExpensePaymentMode {
  cash('Cash', Icons.payments_rounded),
  cheque('Cheque', Icons.money_rounded),
  upi('UPI', Icons.qr_code_rounded),
  bankTransfer('Bank Transfer', Icons.account_balance_rounded),
  online('Online Payment', Icons.language_rounded);

  final String label;
  final IconData icon;
  const ExpensePaymentMode(this.label, this.icon);
}

/// Fund types for expense allocation
enum FundType {
  maintenance('Maintenance Fund'),
  sinking('Sinking Fund'),
  repair('Repair Fund'),
  majorRepair('Major Repair Fund'),
  emergency('Emergency Fund'),
  other('Other Fund');

  final String label;
  const FundType(this.label);
}

/// Approval authority
enum ApprovalAuthority {
  secretary('Secretary'),
  treasurer('Treasurer'),
  chairman('Chairman');

  final String label;
  const ApprovalAuthority(this.label);
}

/// Model for audit-grade society expense entry
class ExpenseModel {
  final String id;
  // Step 1: Category
  final ExpenseCategory category;
  final String? customCategory;
  final String? subCategory;
  // Step 2: Details
  final String description;
  final String? location; // Wing/Flat/Common Area
  final String? vendorName;
  final String? vendorContact;
  final String? invoiceNumber;
  final String? workOrderRef;
  // Step 3: Payment
  final ExpensePaymentMode paymentMode;
  final String? bankAccountUsed;
  final ApprovalAuthority? approvalAuthority;
  final DateTime date; // Date of work
  final DateTime? dateOfPayment;
  final String? referenceNumber;
  // Step 4: Financial
  final double amount;
  final double? taxAmount;
  final FundType? fundAllocation;
  final String? customFund;
  // Step 5: Proof
  final String? proofImagePath;
  final String? paymentProofPath;
  final String? workCompletionProofPath;
  final String? vendorQuotationPath;
  // Step 6: Compliance
  final String recordedBy;
  final String? verifiedBy;
  final String? approvedBy;
  final DateTime timestamp;
  final String? auditTrailId;

  ExpenseModel({
    required this.id,
    required this.category,
    this.customCategory,
    this.subCategory,
    required this.description,
    this.location,
    this.vendorName,
    this.vendorContact,
    this.invoiceNumber,
    this.workOrderRef,
    required this.paymentMode,
    this.bankAccountUsed,
    this.approvalAuthority,
    required this.date,
    this.dateOfPayment,
    this.referenceNumber,
    required this.amount,
    this.taxAmount,
    this.fundAllocation,
    this.customFund,
    this.proofImagePath,
    this.paymentProofPath,
    this.workCompletionProofPath,
    this.vendorQuotationPath,
    required this.recordedBy,
    this.verifiedBy,
    this.approvedBy,
    required this.timestamp,
    this.auditTrailId,
  });

  /// Display name (uses custom category if "Other")
  String get displayCategory =>
      category == ExpenseCategory.other && customCategory != null
      ? customCategory!
      : category.label;

  /// Total amount including tax
  double get totalAmount => amount + (taxAmount ?? 0);

  /// Compliance status
  String get complianceStatus {
    if (approvedBy != null && verifiedBy != null && proofImagePath != null) {
      return 'Fully Compliant';
    } else if (proofImagePath != null) {
      return 'Pending Verification';
    }
    return 'Incomplete';
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'expenseType': displayCategory,
      'amount': totalAmount,
      'description': description,
      'paymentMethod': paymentMode.label,
      'transactionId': referenceNumber,
      // Local / Legacy UI fields
      'id': id,
      'category': category.name,
      'customCategory': customCategory,
      'subCategory': subCategory,
      'location': location,
      'vendorName': vendorName,
      'vendorContact': vendorContact,
      'invoiceNumber': invoiceNumber,
      'workOrderRef': workOrderRef,
      'internalPaymentMode': paymentMode.name,
      'bankAccountUsed': bankAccountUsed,
      'approvalAuthority': approvalAuthority?.name,
      'dateOfPayment': dateOfPayment?.toIso8601String(),
      'taxAmount': taxAmount,
      'fundAllocation': fundAllocation?.name,
      'customFund': customFund,
      'proofImagePath': proofImagePath,
      'paymentProofPath': paymentProofPath,
      'workCompletionProofPath': workCompletionProofPath,
      'vendorQuotationPath': vendorQuotationPath,
      'recordedBy': recordedBy,
      'verifiedBy': verifiedBy,
      'approvedBy': approvedBy,
      'timestamp': timestamp.toIso8601String(),
      'auditTrailId': auditTrailId,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'] || e.label == map['expenseType'],
        orElse: () => ExpenseCategory.other,
      ),
      customCategory: map['customCategory'],
      subCategory: map['subCategory'],
      description: map['description'] ?? '',
      location: map['location'],
      vendorName: map['vendorName'],
      vendorContact: map['vendorContact'],
      invoiceNumber: map['invoiceNumber'],
      workOrderRef: map['workOrderRef'],
      paymentMode: ExpensePaymentMode.values.firstWhere(
        (e) => e.label == map['paymentMethod'] || e.name == map['internalPaymentMode'],
        orElse: () => ExpensePaymentMode.cash,
      ),
      bankAccountUsed: map['bankAccountUsed'],
      approvalAuthority: ApprovalAuthority.values.firstWhere(
        (e) => e.name == map['approvalAuthority'],
        orElse: () => ApprovalAuthority.secretary,
      ),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      dateOfPayment: map['dateOfPayment'] != null ? DateTime.parse(map['dateOfPayment']) : null,
      referenceNumber: map['transactionId'] ?? map['referenceNumber'],
      amount: (map['amount'] ?? 0.0).toDouble() - (map['taxAmount'] ?? 0.0).toDouble(), // Reverse engineering the totalAmount 
      taxAmount: map['taxAmount']?.toDouble(),
      fundAllocation: FundType.values.firstWhere(
        (e) => e.name == map['fundAllocation'],
        orElse: () => FundType.maintenance,
      ),
      customFund: map['customFund'],
      proofImagePath: map['proofImagePath'],
      paymentProofPath: map['paymentProofPath'],
      workCompletionProofPath: map['workCompletionProofPath'],
      vendorQuotationPath: map['vendorQuotationPath'],
      recordedBy: map['recordedBy'] ?? 'System',
      verifiedBy: map['verifiedBy'],
      approvedBy: map['approvedBy'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      auditTrailId: map['auditTrailId'],
    );
  }
}
