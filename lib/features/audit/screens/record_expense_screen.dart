import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/expense_model.dart';
import '../services/audit_service.dart';

class RecordExpenseScreen extends StatefulWidget {
  const RecordExpenseScreen({super.key});

  @override
  State<RecordExpenseScreen> createState() => _RecordExpenseScreenState();
}

class _RecordExpenseScreenState extends State<RecordExpenseScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Category
  ExpenseCategory? _selectedCategory;
  String? _selectedSubCategory;
  final _customCategoryController = TextEditingController();

  // Step 2: Details
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _vendorContactController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _workOrderRefController = TextEditingController();

  // Step 3: Payment
  ExpensePaymentMode _paymentMode = ExpensePaymentMode.cash;
  final _bankAccountController = TextEditingController();
  ApprovalAuthority? _approvalAuthority;
  DateTime _dateOfWork = DateTime.now();
  DateTime? _dateOfPayment;
  final _referenceController = TextEditingController();

  // Step 4: Financial
  final _amountController = TextEditingController();
  final _taxController = TextEditingController();
  FundType? _fundAllocation;
  final _customFundController = TextEditingController();

  // Step 5: Proof
  File? _invoiceImage;
  File? _paymentProof;
  File? _workCompletionProof;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _customCategoryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _vendorNameController.dispose();
    _vendorContactController.dispose();
    _invoiceNumberController.dispose();
    _workOrderRefController.dispose();
    _bankAccountController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _customFundController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isWorkDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isWorkDate
          ? _dateOfWork
          : (_dateOfPayment ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isWorkDate) {
          _dateOfWork = picked;
        } else {
          _dateOfPayment = picked;
        }
      });
    }
  }

  Future<void> _pickImage(String type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upload $type', style: AppTextStyles.h4),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceButton(
                      ctx,
                      Icons.camera_alt_rounded,
                      'Camera',
                      ImageSource.camera,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceButton(
                      ctx,
                      Icons.photo_library_rounded,
                      'Gallery',
                      ImageSource.gallery,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          switch (type) {
            case 'Invoice / Bill':
              _invoiceImage = File(file.path);
              break;
            case 'Payment Proof':
              _paymentProof = File(file.path);
              break;
            case 'Work Completion':
              _workCompletionProof = File(file.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSourceButton(
    BuildContext ctx,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(ctx, source),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedCategory == null) {
      _showError('Please select an expense category');
      return;
    }
    if (_currentStep == 1 && _descriptionController.text.trim().isEmpty) {
      _showError('Please enter a description');
      return;
    }
    if (_currentStep == 3) {
      final amt = double.tryParse(_amountController.text.trim());
      if (amt == null || amt <= 0) {
        _showError('Please enter a valid amount');
        return;
      }
    }
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _submitExpense() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      final expense = ExpenseModel(
        id: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
        category: _selectedCategory!,
        customCategory: _selectedCategory == ExpenseCategory.other
            ? _customCategoryController.text.trim()
            : null,
        subCategory: _selectedSubCategory,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        vendorName: _vendorNameController.text.trim().isEmpty
            ? null
            : _vendorNameController.text.trim(),
        vendorContact: _vendorContactController.text.trim().isEmpty
            ? null
            : _vendorContactController.text.trim(),
        invoiceNumber: _invoiceNumberController.text.trim().isEmpty
            ? null
            : _invoiceNumberController.text.trim(),
        workOrderRef: _workOrderRefController.text.trim().isEmpty
            ? null
            : _workOrderRefController.text.trim(),
        paymentMode: _paymentMode,
        bankAccountUsed: _bankAccountController.text.trim().isEmpty
            ? null
            : _bankAccountController.text.trim(),
        approvalAuthority: _approvalAuthority,
        date: _dateOfWork,
        dateOfPayment: _dateOfPayment,
        referenceNumber: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        taxAmount: _taxController.text.trim().isEmpty
            ? null
            : double.tryParse(_taxController.text.trim()),
        fundAllocation: _fundAllocation,
        customFund: _fundAllocation == FundType.other
            ? _customFundController.text.trim()
            : null,
        proofImagePath: _invoiceImage?.path,
        paymentProofPath: _paymentProof?.path,
        workCompletionProofPath: _workCompletionProof?.path,
        recordedBy: SessionManager.currentUser?.name ?? 'Unknown',
        auditTrailId: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
      );

      MockData.expenses.add(expense);
      AuditService.logAction(
        actionType: 'RECORD_EXPENSE',
        targetEntity:
            '${expense.displayCategory} — ₹${expense.amount.toStringAsFixed(0)}',
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '₹${expense.amount.toStringAsFixed(0)} expense recorded',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(key: _formKey, child: _buildCurrentStep()),
            ),
          ),
          // Navigation buttons
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      'Category',
      'Details',
      'Payment',
      'Amount',
      'Proof',
      'Review',
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone || isActive
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isActive
                            ? AppColors.primary
                            : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppColors.success
                              : isActive
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textHint,
                                ),
                              ),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? AppColors.primary : AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.textHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2Details();
      case 2:
        return _buildStep3Payment();
      case 3:
        return _buildStep4Financial();
      case 4:
        return _buildStep5Proof();
      case 5:
        return _buildStep6Review();
      default:
        return const SizedBox();
    }
  }

  // ── STEP 1: CATEGORY ──────────────────────────────────
  Widget _buildStep1Category() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Select Expense Category',
          'Choose the type of expense being recorded',
        ),
        const SizedBox(height: 16),
        _buildLabel('Category', isRequired: true),
        const SizedBox(height: 8),
        _buildDropdownCard<ExpenseCategory>(
          value: _selectedCategory,
          hint: 'Select expense category',
          icon: _selectedCategory?.icon ?? Icons.category_rounded,
          items: ExpenseCategory.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          c.label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _selectedCategory = v;
            _selectedSubCategory = null;
          }),
        ),
        if (_selectedCategory == ExpenseCategory.other) ...[
          const SizedBox(height: 12),
          _buildTextField(
            _customCategoryController,
            'Specify Category',
            'e.g. Annual Maintenance Contract',
            Icons.edit_rounded,
          ),
        ],
        if (_selectedCategory != null &&
            _selectedCategory!.subCategories.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildLabel('Sub-Category'),
          const SizedBox(height: 8),
          _buildDropdownCard<String>(
            value: _selectedSubCategory,
            hint: 'Select sub-category',
            icon: Icons.subdirectory_arrow_right_rounded,
            items: _selectedCategory!.subCategories
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedSubCategory = v),
          ),
        ],
      ],
    );
  }

  // ── STEP 2: DETAILS ──────────────────────────────────
  Widget _buildStep2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Expense Details',
          'Provide work details and vendor information',
        ),
        const SizedBox(height: 16),
        _buildLabel('Description', isRequired: true),
        const SizedBox(height: 8),
        _buildTextField(
          _descriptionController,
          'Description',
          'What work was done...',
          Icons.description_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildLabel('Location'),
        const SizedBox(height: 8),
        _buildTextField(
          _locationController,
          'Location',
          'Wing A / Flat 101 / Common Area',
          Icons.location_on_rounded,
        ),
        const SizedBox(height: 16),
        _buildLabel('Vendor / Payee Name'),
        const SizedBox(height: 8),
        _buildTextField(
          _vendorNameController,
          'Vendor',
          'e.g. ABC Plumbing Services',
          Icons.store_rounded,
        ),
        const SizedBox(height: 16),
        _buildLabel('Vendor Contact'),
        const SizedBox(height: 8),
        _buildTextField(
          _vendorContactController,
          'Contact',
          '+91 XXXXX XXXXX',
          Icons.phone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Invoice No.'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _invoiceNumberController,
                    'Invoice',
                    'INV-001',
                    Icons.receipt_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Work Order Ref'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _workOrderRefController,
                    'Work Order',
                    'WO-001',
                    Icons.assignment_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── STEP 3: PAYMENT ──────────────────────────────────
  Widget _buildStep3Payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Payment Details',
          'Specify payment mode, dates, and authority',
        ),
        const SizedBox(height: 16),
        _buildLabel('Payment Mode', isRequired: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExpensePaymentMode.values.map((m) {
            final sel = _paymentMode == m;
            return GestureDetector(
              onTap: () => setState(() => _paymentMode = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : AppColors.border.withValues(alpha: 0.5),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      m.icon,
                      size: 16,
                      color: sel ? AppColors.primary : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m.label,
                      style: AppTextStyles.caption.copyWith(
                        color: sel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildLabel('Bank Account (if applicable)'),
        const SizedBox(height: 8),
        _buildTextField(
          _bankAccountController,
          'Bank Account',
          'Society HDFC A/C - XXXX1234',
          Icons.account_balance_rounded,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Date of Work'),
                  const SizedBox(height: 8),
                  _buildDateCard(
                    _dateOfWork,
                    () => _pickDate(isWorkDate: true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Date of Payment'),
                  const SizedBox(height: 8),
                  _buildDateCard(
                    _dateOfPayment ?? DateTime.now(),
                    () => _pickDate(isWorkDate: false),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('Reference / Receipt No.'),
        const SizedBox(height: 8),
        _buildTextField(
          _referenceController,
          'Reference',
          'Cheque No. / UPI Ref',
          Icons.tag_rounded,
        ),
        const SizedBox(height: 16),
        _buildLabel('Approval Authority'),
        const SizedBox(height: 8),
        _buildDropdownCard<ApprovalAuthority>(
          value: _approvalAuthority,
          hint: 'Select approving authority',
          icon: Icons.verified_user_rounded,
          items: ApprovalAuthority.values
              .map(
                (a) => DropdownMenuItem(
                  value: a,
                  child: Text(
                    a.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _approvalAuthority = v),
        ),
      ],
    );
  }

  // ── STEP 4: FINANCIAL ──────────────────────────────────
  Widget _buildStep4Financial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Financial Details',
          'Enter amount, tax, and fund allocation',
        ),
        const SizedBox(height: 16),
        _buildLabel('Amount (₹)', isRequired: true),
        const SizedBox(height: 8),
        _buildTextField(
          _amountController,
          'Amount',
          '0.00',
          Icons.currency_rupee_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('GST / Tax Amount'),
        const SizedBox(height: 8),
        _buildTextField(
          _taxController,
          'Tax',
          '0.00',
          Icons.receipt_long_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabel('Fund Allocation'),
        const SizedBox(height: 8),
        _buildDropdownCard<FundType>(
          value: _fundAllocation,
          hint: 'Allocate to fund',
          icon: Icons.account_balance_wallet_rounded,
          items: FundType.values
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(
                    f.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _fundAllocation = v),
        ),
        if (_fundAllocation == FundType.other) ...[
          const SizedBox(height: 12),
          _buildTextField(
            _customFundController,
            'Custom Fund',
            'e.g. Corpus Fund',
            Icons.edit_rounded,
          ),
        ],
        const SizedBox(height: 24),
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Base Amount',
                '₹${_amountController.text.isEmpty ? "0" : _amountController.text}',
              ),
              if (_taxController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSummaryRow('Tax (GST)', '₹${_taxController.text}'),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              _buildSummaryRow(
                'Total',
                '₹${((double.tryParse(_amountController.text) ?? 0) + (double.tryParse(_taxController.text) ?? 0)).toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── STEP 5: PROOF UPLOAD ──────────────────────────────────
  Widget _buildStep5Proof() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Upload Proof Documents',
          'Attach invoices, receipts, and work completion photos',
        ),
        const SizedBox(height: 16),
        _buildProofTile(
          'Invoice / Bill',
          _invoiceImage,
          Icons.receipt_rounded,
          true,
        ),
        const SizedBox(height: 12),
        _buildProofTile(
          'Payment Proof',
          _paymentProof,
          Icons.payment_rounded,
          false,
        ),
        const SizedBox(height: 12),
        _buildProofTile(
          'Work Completion',
          _workCompletionProof,
          Icons.camera_alt_rounded,
          false,
        ),
      ],
    );
  }

  Widget _buildProofTile(
    String label,
    File? file,
    IconData icon,
    bool isRequired,
  ) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: () => _pickImage(label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_rounded : icon,
                color: hasFile ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
                      ),
                      if (isRequired)
                        Text(
                          ' *',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    hasFile ? 'File attached ✓' : 'Tap to upload',
                    style: AppTextStyles.caption.copyWith(
                      color: hasFile ? AppColors.success : AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.swap_horiz_rounded : Icons.cloud_upload_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 6: REVIEW ──────────────────────────────────
  Widget _buildStep6Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Review & Submit',
          'Verify all details before recording this expense',
        ),
        const SizedBox(height: 16),
        _buildReviewSection('Category', [
          _buildReviewItem('Type', _selectedCategory?.label ?? 'N/A'),
          if (_selectedSubCategory != null)
            _buildReviewItem('Sub-category', _selectedSubCategory!),
        ]),
        _buildReviewSection('Details', [
          _buildReviewItem(
            'Description',
            _descriptionController.text.isEmpty
                ? 'N/A'
                : _descriptionController.text,
          ),
          if (_locationController.text.isNotEmpty)
            _buildReviewItem('Location', _locationController.text),
          if (_vendorNameController.text.isNotEmpty)
            _buildReviewItem('Vendor', _vendorNameController.text),
        ]),
        _buildReviewSection('Payment', [
          _buildReviewItem('Mode', _paymentMode.label),
          _buildReviewItem(
            'Date of Work',
            DateFormat('dd MMM yyyy').format(_dateOfWork),
          ),
          if (_approvalAuthority != null)
            _buildReviewItem('Approved by', _approvalAuthority!.label),
        ]),
        _buildReviewSection('Financial', [
          _buildReviewItem(
            'Amount',
            '₹${_amountController.text.isEmpty ? "0" : _amountController.text}',
          ),
          if (_taxController.text.isNotEmpty)
            _buildReviewItem('Tax', '₹${_taxController.text}'),
          if (_fundAllocation != null)
            _buildReviewItem('Fund', _fundAllocation!.label),
        ]),
        _buildReviewSection('Proof', [
          _buildReviewItem(
            'Invoice',
            _invoiceImage != null ? 'Attached ✓' : 'Not uploaded',
          ),
          _buildReviewItem(
            'Payment Proof',
            _paymentProof != null ? 'Attached ✓' : 'Not uploaded',
          ),
          _buildReviewItem(
            'Work Photo',
            _workCompletionProof != null ? 'Attached ✓' : 'Not uploaded',
          ),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recorded by: ${SessionManager.currentUser?.name ?? "Unknown"}\nAudit Trail ID will be auto-generated',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ──────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  isOutlined: true,
                  useGradient: false,
                  onPressed: _prevStep,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: _currentStep == 5
                  ? CustomButton(
                      text: 'Submit Expense',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitExpense,
                    )
                  : CustomButton(
                      text: 'Continue',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _nextStep,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SHARED WIDGETS ──────────────────────────────────
  Widget _buildStepHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(text, style: AppTextStyles.labelMedium.copyWith(fontSize: 14)),
        if (isRequired)
          Text(' *', style: TextStyle(color: AppColors.error, fontSize: 14)),
      ],
    );
  }

  Widget _buildDropdownCard<T>({
    T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppColors.cardShadow,
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  Widget _buildDateCard(DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DateFormat('dd MMM yy').format(date),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
