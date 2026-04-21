import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../admin/widgets/admin_drawer.dart';
import '../../../core/utils/mock_data.dart';
import '../../auth/models/user_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../billing/models/maintenance_receipt_model.dart';
import '../../billing/services/penalty_service.dart';
import '../../../core/utils/session_manager.dart';

class EditMaintenanceScreen extends StatefulWidget {
  const EditMaintenanceScreen({super.key});

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final members = MockData.users.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.role == UserRole.member && (
             user.name.toLowerCase().contains(query) ||
             user.flatNumber.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Maintenance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Top Action Area
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                CustomButton(
                  text: 'Assign to All Members',
                  icon: Icons.group_add_rounded,
                  onPressed: () => _showAssignToAllModal(context),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: members.isEmpty
                ? const Center(child: Text('No members found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberCard(member);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppTextStyles.labelLarge),
                Text('Flat: ${user.flatNumber}', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            onPressed: () => _showEditLedgerModal(user),
          ),
        ],
      ),
    );
  }

  void _showAssignToAllModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AssignToAllForm(),
    );
  }

  void _showEditLedgerModal(UserModel user) {
    final controllers = {
      'Opening Balance': TextEditingController(text: user.openingBalance.toStringAsFixed(0)),
      'Sinking Fund': TextEditingController(text: user.sinkingFund.toStringAsFixed(0)),
      'Maintenance': TextEditingController(text: user.maintenanceAmount.toStringAsFixed(0)),
      'Municipal Tax': TextEditingController(text: user.municipalTax.toStringAsFixed(0)),
      'NOC': TextEditingController(text: user.noc.toStringAsFixed(0)),
      'Parking Charges': TextEditingController(text: user.parkingCharges.toStringAsFixed(0)),
      'Delay Charges': TextEditingController(text: user.delayCharges.toStringAsFixed(0)),
      'Building Fund': TextEditingController(text: user.buildingFund.toStringAsFixed(0)),
      'Room Transfer Fees': TextEditingController(text: user.roomTransferFees.toStringAsFixed(0)),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: AppTextStyles.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  ...controllers.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CustomTextField(
                          controller: e.value,
                          label: e.key,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.currency_rupee,
                        ),
                      )),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Save Ledger Changes',
                    onPressed: () {
                      final updatedUser = user.copyWith(
                        openingBalance: double.tryParse(controllers['Opening Balance']!.text) ?? 0,
                        sinkingFund: double.tryParse(controllers['Sinking Fund']!.text) ?? 0,
                        maintenanceAmount: double.tryParse(controllers['Maintenance']!.text) ?? 0,
                        municipalTax: double.tryParse(controllers['Municipal Tax']!.text) ?? 0,
                        noc: double.tryParse(controllers['NOC']!.text) ?? 0,
                        parkingCharges: double.tryParse(controllers['Parking Charges']!.text) ?? 0,
                        delayCharges: double.tryParse(controllers['Delay Charges']!.text) ?? 0,
                        buildingFund: double.tryParse(controllers['Building Fund']!.text) ?? 0,
                        roomTransferFees: double.tryParse(controllers['Room Transfer Fees']!.text) ?? 0,
                      );
                      MockData.updateUser(updatedUser);
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignToAllForm extends StatefulWidget {
  const AssignToAllForm({super.key});

  @override
  State<AssignToAllForm> createState() => _AssignToAllFormState();
}

class _AssignToAllFormState extends State<AssignToAllForm> {
  DateTime _periodFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _periodTo = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  final _sinkingFundController = TextEditingController(text: '0');
  final _maintenanceController = TextEditingController(text: '0');
  final _municipalTaxController = TextEditingController(text: '0');
  final _nocController = TextEditingController(text: '0');
  final _parkingController = TextEditingController(text: '0');
  final _miscController = TextEditingController(text: '0');
  final _buildingFundController = TextEditingController(text: '0');

  double get _total => (double.tryParse(_sinkingFundController.text) ?? 0) +
                       (double.tryParse(_maintenanceController.text) ?? 0) +
                       (double.tryParse(_municipalTaxController.text) ?? 0) +
                       (double.tryParse(_nocController.text) ?? 0) +
                       (double.tryParse(_parkingController.text) ?? 0) +
                       (double.tryParse(_miscController.text) ?? 0) +
                       (double.tryParse(_buildingFundController.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Maintenance to All', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            const Text('This will create a pending due for every member.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // Period
            const Text('Period', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker('From', _periodFrom, (d) => setState(() => _periodFrom = d))),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker('To', _periodTo, (d) => setState(() => _periodTo = d))),
              ],
            ),
            const SizedBox(height: 24),

            // Charges
            const Text('Charges Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildChargeField('Maintenance', _maintenanceController),
            _buildChargeField('Sinking Fund', _sinkingFundController),
            _buildChargeField('Municipal Tax', _municipalTaxController),
            _buildChargeField('Parking Charges', _parkingController),
            _buildChargeField('NOC', _nocController),
            _buildChargeField('Building Fund', _buildingFundController),
            _buildChargeField('Miscellaneous', _miscController),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('₹${_total.toStringAsFixed(0)}', style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Assign to All Members',
              onPressed: () {
                final allMembers = MockData.getMembers();
                final admin = SessionManager.currentUser;
                final now = DateTime.now();
                
                for (var member in allMembers) {
                  final receipt = MaintenanceReceiptModel(
                    id: 'mr_${now.millisecondsSinceEpoch}_${member.uid}',
                    memberId: member.uid,
                    flatOwnerName: member.name,
                    floor: PenaltyService.getFloorFromFlatNumber(member.flatNumber),
                    roomNo: member.flatNumber,
                    periodFrom: _periodFrom,
                    periodTo: _periodTo,
                    sinkingFund: double.tryParse(_sinkingFundController.text) ?? 0,
                    maintenance: double.tryParse(_maintenanceController.text) ?? 0,
                    municipalTax: double.tryParse(_municipalTaxController.text) ?? 0,
                    noc: double.tryParse(_nocController.text) ?? 0,
                    parkingCharges: double.tryParse(_parkingController.text) ?? 0,
                    miscellaneous: double.tryParse(_miscController.text) ?? 0,
                    buildingFund: double.tryParse(_buildingFundController.text) ?? 0,
                    penaltyAmount: 0,
                    lateMonths: 0,
                    totalAmount: _total,
                    receivedRupeesInWords: '',
                    paymentMode: 'Pending',
                    generatedBy: admin?.name ?? 'Admin',
                    generatedAt: now,
                    receiptNo: MockData.getNextMaintenanceReceiptNumber(),
                  );
                  MockData.addMaintenanceReceipt(receipt);
                }
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assigned successfully to all members'), backgroundColor: AppColors.success),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime current, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(2020), lastDate: DateTime(2100));
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
            Text(DateFormat('MMM yyyy').format(current), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
