import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/models/user_model.dart';
import '../models/maintenance_receipt_model.dart';
import '../services/penalty_service.dart';

class GenerateBillsScreen extends StatefulWidget {
  const GenerateBillsScreen({super.key});

  @override
  State<GenerateBillsScreen> createState() => _GenerateBillsScreenState();
}

class _GenerateBillsScreenState extends State<GenerateBillsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Member selection
  UserModel? _selectedMember;

  // Auto-filled fields
  final _ownerNameController = TextEditingController();
  final _roomNoController = TextEditingController();
  String _selectedFloor = '1st Floor';
  final List<String> _floors = [
    'ALL',
    'Ground Floor',
    '1st Floor',
    '2nd Floor',
    '3rd Floor',
    '4th Floor',
  ];

  // Period
  DateTime _periodFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _periodTo = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  // Charge Controllers
  final _sinkingFundController = TextEditingController(text: '0');
  final _maintenanceController = TextEditingController(text: '0');
  final _municipalTaxController = TextEditingController(text: '0');
  final _nocController = TextEditingController(text: '0');
  final _parkingController = TextEditingController(text: '0');
  final _miscController = TextEditingController(text: '0');
  final _buildingFundController = TextEditingController(text: '0');

  // Payment Mode
  String _paymentMode = 'Cash';
  final List<String> _paymentModes = ['Cash', 'Cheque', 'UPI'];
  final _chequeNoController = TextEditingController();
  final _drawnOnController = TextEditingController();
  final _upiIdController = TextEditingController();

  // Calculated
  double _penaltyAmount = 0;
  int _lateMonths = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _roomNoController.dispose();
    _sinkingFundController.dispose();
    _maintenanceController.dispose();
    _municipalTaxController.dispose();
    _nocController.dispose();
    _parkingController.dispose();
    _miscController.dispose();
    _buildingFundController.dispose();
    _chequeNoController.dispose();
    _drawnOnController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _onMemberChanged(UserModel? member) {
    setState(() {
      _selectedMember = member;
      if (member != null) {
        _ownerNameController.text = member.name;
        _roomNoController.text = member.flatNumber;
        _selectedFloor =
            PenaltyService.getFloorFromFlatNumber(member.flatNumber);

        // Pre-fill from member's pending dues automatically
        final pendingReceipts = MockData.getUnresolvedPendingReceipts(member.id);
        double sMaint = 0, sSink = 0, sTax = 0, sNoc = 0, sPark = 0, sBuild = 0, sMisc = 0;
        for (var r in pendingReceipts) {
          sMaint += r.maintenance;
          sSink += r.sinkingFund;
          sTax += r.municipalTax;
          sNoc += r.noc;
          sPark += r.parkingCharges;
          sBuild += r.buildingFund;
          sMisc += r.miscellaneous;
        }

        _sinkingFundController.text = sSink.toStringAsFixed(0);
        _maintenanceController.text = sMaint.toStringAsFixed(0);
        _municipalTaxController.text = sTax.toStringAsFixed(0);
        _nocController.text = sNoc.toStringAsFixed(0);
        _parkingController.text = sPark.toStringAsFixed(0);
        _buildingFundController.text = sBuild.toStringAsFixed(0);
        _miscController.text = sMisc.toStringAsFixed(0);

        // Calculate penalty
        _calculatePenalty();
      } else {
        _ownerNameController.clear();
        _roomNoController.clear();
        _penaltyAmount = 0;
        _lateMonths = 0;
      }
    });
  }

  void _calculatePenalty() {
    if (_selectedMember == null) return;
    final unpaidMonths =
        MockData.getUnpaidMonthsForMember(_selectedMember!.id);
    _lateMonths = PenaltyService.countLateMonths(unpaidMonths: unpaidMonths);
    _penaltyAmount = PenaltyService.calculatePenalty(unpaidMonths: unpaidMonths);
  }

  double get _subtotal {
    return (double.tryParse(_sinkingFundController.text) ?? 0) +
        (double.tryParse(_maintenanceController.text) ?? 0) +
        (double.tryParse(_municipalTaxController.text) ?? 0) +
        (double.tryParse(_nocController.text) ?? 0) +
        (double.tryParse(_parkingController.text) ?? 0) +
        (double.tryParse(_miscController.text) ?? 0) +
        (double.tryParse(_buildingFundController.text) ?? 0);
  }

  double get _total => _subtotal + _penaltyAmount;

  String get _amountInWords => PenaltyService.numberToWords(_total);

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Maintenance Receipt?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member: ${_selectedMember!.name}'),
            Text('Room: ${_roomNoController.text}'),
            Text(
              'Period: ${DateFormat('dd MMM yyyy').format(_periodFrom)} - ${DateFormat('dd MMM yyyy').format(_periodTo)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${_total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (_penaltyAmount > 0)
              Text(
                '(includes ₹${_penaltyAmount.toStringAsFixed(0)} penalty)',
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final admin = SessionManager.currentUser;
      final receiptNo = MockData.getNextMaintenanceReceiptNumber();
      final receipt = MaintenanceReceiptModel(
        id: 'mr_${DateTime.now().millisecondsSinceEpoch}',
        memberId: _selectedMember!.uid,
        flatOwnerName: _ownerNameController.text,
        floor: _selectedFloor,
        roomNo: _roomNoController.text,
        periodFrom: _periodFrom,
        periodTo: _periodTo,
        sinkingFund: double.tryParse(_sinkingFundController.text) ?? 0,
        maintenance: double.tryParse(_maintenanceController.text) ?? 0,
        municipalTax: double.tryParse(_municipalTaxController.text) ?? 0,
        noc: double.tryParse(_nocController.text) ?? 0,
        parkingCharges: double.tryParse(_parkingController.text) ?? 0,
        miscellaneous: double.tryParse(_miscController.text) ?? 0,
        buildingFund: double.tryParse(_buildingFundController.text) ?? 0,
        penaltyAmount: _penaltyAmount,
        lateMonths: _lateMonths,
        totalAmount: _total,
        receivedRupeesInWords: _amountInWords,
        paymentMode: _paymentMode,
        chequeNo: _paymentMode == 'Cheque' ? _chequeNoController.text : null,
        drawnOn: _paymentMode == 'Cheque' ? _drawnOnController.text : null,
        upiId: _paymentMode == 'UPI' ? _upiIdController.text : null,
        generatedBy: admin?.name ?? 'Admin',
        generatedAt: DateTime.now(),
        receiptNo: receiptNo,
      );
      MockData.addMaintenanceReceipt(receipt);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt generated for ${_selectedMember!.name}'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = MockData.getMembers();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Receipt'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionHeader(
                'Generate Maintenance Receipt',
                'Fill in the details to generate a receipt for a society member.',
                Icons.receipt_long_rounded,
              ),
              const SizedBox(height: 24),

              // --- Member Selection ---
              _buildLabel('Select Member'),
              const SizedBox(height: 8),
              _buildMemberDropdown(members),
              const SizedBox(height: 20),

              // --- Member Details ---
              if (_selectedMember != null) ...[
                _buildMemberInfoCard(),
                const SizedBox(height: 20),

                // --- Period ---
                _buildLabel('Period'),
                const SizedBox(height: 8),
                _buildPeriodSelector(),
                const SizedBox(height: 24),

                // --- Charge Breakdown ---
                _buildLabel('Charge Breakdown'),
                const SizedBox(height: 4),
                Text(
                  'Enter the charges for each category',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 16),
                _buildChargeField('Sinking Fund', _sinkingFundController,
                    Icons.savings_rounded),
                _buildChargeField('Maintenance', _maintenanceController,
                    Icons.home_work_rounded),
                _buildChargeField('Municipal Tax', _municipalTaxController,
                    Icons.account_balance_rounded),
                _buildChargeField('NOC', _nocController,
                    Icons.description_rounded),
                _buildChargeField('Parking Charges', _parkingController,
                    Icons.local_parking_rounded),
                _buildChargeField('Miscellaneous', _miscController,
                    Icons.miscellaneous_services_rounded),
                _buildChargeField('Building Fund', _buildingFundController,
                    Icons.apartment_rounded),

                // --- Penalty (read-only) ---
                if (_penaltyAmount > 0) ...[
                  const SizedBox(height: 12),
                  _buildPenaltyCard(),
                ],

                const SizedBox(height: 16),

                // --- Total ---
                _buildTotalCard(),
                const SizedBox(height: 8),

                // --- Amount in Words ---
                _buildAmountInWordsCard(),
                const SizedBox(height: 24),

                // --- Payment Mode ---
                _buildLabel('Payment Mode'),
                const SizedBox(height: 8),
                _buildPaymentModeSelector(),
                const SizedBox(height: 16),

                // --- Conditional Fields ---
                if (_paymentMode == 'Cheque') ...[
                  CustomTextField(
                    controller: _chequeNoController,
                    label: 'Cheque No.',
                    hint: 'Enter cheque number',
                    prefixIcon: Icons.receipt_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Required for Cheque payment' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _drawnOnController,
                    label: 'Drawn On',
                    hint: 'Bank name',
                    prefixIcon: Icons.account_balance_rounded,
                  ),
                ],
                if (_paymentMode == 'UPI') ...[
                  CustomTextField(
                    controller: _upiIdController,
                    label: 'UPI ID',
                    hint: 'name@upi or phone number',
                    prefixIcon: Icons.phone_android_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'Required for UPI payment' : null,
                  ),
                ],

                const SizedBox(height: 40),

                // --- Generate Button ---
                CustomButton(
                  text: 'Generate Maintenance Receipt',
                  isLoading: _isLoading,
                  icon: Icons.receipt_long_rounded,
                  onPressed: _handleGenerate,
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMemberDropdown(List<UserModel> members) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserModel>(
          isExpanded: true,
          value: _selectedMember,
          hint: const Text('Choose a member'),
          items: members
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text('${m.name} (${m.flatNumber})'),
                ),
              )
              .toList(),
          onChanged: _onMemberChanged,
        ),
      ),
    );
  }

  Widget _buildMemberInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flat Owner\'s Name',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ownerNameController.text,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  'Floor',
                  _selectedFloor,
                  Icons.layers_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  'Room No.',
                  _roomNoController.text,
                  Icons.door_front_door_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Floor Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedFloor,
                items: _floors
                    .map(
                      (f) => DropdownMenuItem(value: f, child: Text(f)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedFloor = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 9, color: AppColors.textHint),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            'From',
            _periodFrom,
            (date) => setState(() => _periodFrom = date),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('to', style: TextStyle(color: AppColors.textHint)),
        ),
        Expanded(
          child: _buildDatePicker(
            'To',
            _periodTo,
            (date) => setState(() => _periodTo = date),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime current,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppColors.textHint),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(current),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Late Payment Penalty',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$_lateMonths month${_lateMonths > 1 ? 's' : ''} late × ₹25',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${_penaltyAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.secondary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL AMOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_penaltyAmount > 0)
                Text(
                  'Subtotal ₹${_subtotal.toStringAsFixed(0)} + Penalty ₹${_penaltyAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
          Text(
            '₹${_total.toStringAsFixed(0)}',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInWordsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Received Rupees (in words)',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _amountInWords,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _paymentModes.map((mode) {
          final isSelected = _paymentMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _paymentMode = mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mode == 'Cash'
                          ? Icons.money_rounded
                          : mode == 'Cheque'
                              ? Icons.receipt_rounded
                              : Icons.phone_android_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
