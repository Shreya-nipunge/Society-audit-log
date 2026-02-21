import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/fund_allocation.dart';
import '../models/transaction_model.dart';
import '../services/receipt_service.dart';
import '../../audit/services/audit_service.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  UserModel? _selectedMember;
  double _outstandingAmount = 0.0;

  final _amountController = TextEditingController();
  final _maintenanceController = TextEditingController(text: '0');
  final _sinkingController = TextEditingController(text: '0');
  final _repairsController = TextEditingController(text: '0');
  final _waterController = TextEditingController(text: '0');
  final _otherController = TextEditingController(text: '0');
  final _referenceController = TextEditingController();

  String _paymentMode = 'Cash';
  final List<String> _paymentModes = ['Cash', 'UPI', 'Cheque', 'Bank Transfer'];

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _maintenanceController.dispose();
    _sinkingController.dispose();
    _repairsController.dispose();
    _waterController.dispose();
    _otherController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _onMemberChanged(UserModel? member) {
    setState(() {
      _selectedMember = member;
      if (member != null) {
        _outstandingAmount = MockData.getOutstandingAmount(member.id);
      } else {
        _outstandingAmount = 0.0;
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    final totalAllocated =
        double.parse(_maintenanceController.text) +
        double.parse(_sinkingController.text) +
        double.parse(_repairsController.text) +
        double.parse(_waterController.text) +
        double.parse(_otherController.text);

    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;

    if ((totalAllocated - totalAmount).abs() > 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Allocation total ($totalAllocated) must match amount ($totalAmount)',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String receiptNo = MockData.getNextReceiptNumber();
      final admin = SessionManager.currentUser!;

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: _selectedMember!.id,
        memberName: _selectedMember!.name,
        flatNo:
            'N/A', // We could fetch this from UserModel if we added it, using 'N/A' for now
        amount: totalAmount,
        paymentMode: _paymentMode,
        referenceNo: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        allocation: FundAllocation(
          maintenance: double.parse(_maintenanceController.text),
          sinkingFund: double.parse(_sinkingController.text),
          repairsFund: double.parse(_repairsController.text),
          waterCharges: double.parse(_waterController.text),
          other: double.parse(_otherController.text),
        ),
        receiptNo: receiptNo,
        recordedBy: admin.id,
        recordedAt: DateTime.now(),
      );

      MockData.addTransaction(transaction);

      // Trigger Audit Log
      AuditService.logAction(
        actionType: 'RECORD_PAYMENT',
        targetEntity: receiptNo,
        newValue: 'Amount: ₹$totalAmount, Member: ${_selectedMember!.name}',
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Recorded'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receipt No: $receiptNo'),
              const SizedBox(height: 8),
              Text('Amount: ₹$totalAmount'),
              const SizedBox(height: 8),
              Text('Member: ${_selectedMember!.name}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                nav.pop(); // Close dialog
                final pdfBytes = await ReceiptService.generateReceiptPdf(
                  transaction,
                );
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: 'Receipt_${transaction.receiptNo}',
                );
                if (!mounted) return;
                nav.pop(); // Go back
              },
              child: const Text('View Receipt'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = MockData.getMembers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Selection
              const Text(
                'Select Member',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UserModel>(
                    isExpanded: true,
                    value: _selectedMember,
                    hint: const Text('Choose Member'),
                    items: members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text('${m.name} (${m.email})'),
                          ),
                        )
                        .toList(),
                    onChanged: _onMemberChanged,
                  ),
                ),
              ),
              if (_selectedMember != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Outstanding: ₹$_outstandingAmount',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Payment Details
              const Text(
                'Payment Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _amountController,
                label: 'Total Amount Received',
                hint: '0.00',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Enter valid amount'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mode',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _paymentMode,
                              items: _paymentModes
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _paymentMode = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _referenceController,
                      label: 'Ref. No / UPI ID',
                      hint: 'Optional',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Fund Allocation
              const Text(
                'Fund Allocation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Break down the total amount into funds',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildAllocationField('Maintenance', _maintenanceController),
              _buildAllocationField('Sinking Fund', _sinkingController),
              _buildAllocationField('Repairs Fund', _repairsController),
              _buildAllocationField('Water Charges', _waterController),
              _buildAllocationField('Other', _otherController),

              const SizedBox(height: 40),
              CustomButton(
                text: 'Confirm & Generate Receipt',
                isLoading: _isLoading,
                icon: Icons.receipt_long_outlined,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '₹ ',
                ),
                onChanged: (v) {
                  if (v.isEmpty) controller.text = '0';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
