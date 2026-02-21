import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/mock_data.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/demand_notice_model.dart';
import '../services/billing_service.dart';

class GenerateBillsScreen extends StatefulWidget {
  const GenerateBillsScreen({super.key});

  @override
  State<GenerateBillsScreen> createState() => _GenerateBillsScreenState();
}

class _GenerateBillsScreenState extends State<GenerateBillsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _maintenanceController = TextEditingController(text: '3000');
  final _waterController = TextEditingController(text: '500');
  final _otherController = TextEditingController(text: '0');

  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _maintenanceController.dispose();
    _waterController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Group Bills?'),
        content: Text(
          'This will generate Maintenance Demand Notices for all members for ${DateFormat('MMMM yyyy').format(_selectedMonth)}.\n\n'
          'Total per member: ₹${(double.parse(_maintenanceController.text) + double.parse(_waterController.text) + double.parse(_otherController.text)).toStringAsFixed(0)}',
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
      final members = MockData.getMembers();
      final maintenance = double.parse(_maintenanceController.text);
      final water = double.parse(_waterController.text);
      final other = double.parse(_otherController.text);
      final monthName = DateFormat('MMMM').format(_selectedMonth);
      final year = _selectedMonth.year;

      for (var member in members) {
        final notice = DemandNoticeModel(
          id: 'dn_${member.id}_${monthName}_$year',
          memberId: member.id,
          month: monthName,
          year: year,
          maintenance: maintenance,
          waterCharges: water,
          otherCharges: other,
          dueDate: DateTime(
            year,
            _selectedMonth.month,
            25,
          ), // 25th of the month
          generatedAt: DateTime.now(),
        );
        MockData.addDemandNotice(notice);
      }

      // Also generate BillModel entries for the new "My Dues" feature
      BillingService.generateMonthlyBills(
        month: DateFormat('MMMM yyyy').format(_selectedMonth),
        maintenance: maintenance,
        water: water,
        other: other,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully generated bills for ${members.length} members',
          ),
        ),
      );
      Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Demand Notice'),
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
              const Text(
                'Generate Monthly Bills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Specify the charges to be applied to all registered society members.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Month Selection
              const Text(
                'Select Billing Month',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(
                      () =>
                          _selectedMonth = DateTime(picked.year, picked.month),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Charges
              const Text(
                'Billing Components',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _maintenanceController,
                label: 'Monthly Maintenance',
                hint: '0.00',
                prefixIcon: Icons.home_work_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _waterController,
                label: 'Water Charges',
                hint: '0.00',
                prefixIcon: Icons.water_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _otherController,
                label: 'Other Charges',
                hint: '0.00',
                prefixIcon: Icons.miscellaneous_services_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 48),
              CustomButton(
                text: 'Generate Bills for All Members',
                isLoading: _isLoading,
                icon: Icons.auto_awesome_outlined,
                onPressed: _handleGenerate,
              ),
              const SizedBox(height: 16),
              if (kIsWeb) ...[
                const SizedBox(height: 48),
                const Text(
                  'Billing Preview (Web Only)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildPreviewTable(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    final members = MockData.getMembers();
    final maintenance = double.tryParse(_maintenanceController.text) ?? 0;
    final water = double.tryParse(_waterController.text) ?? 0;
    final other = double.tryParse(_otherController.text) ?? 0;
    final totalPerMember = maintenance + water + other;
    final projectedTotal = totalPerMember * members.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Member Name')),
                DataColumn(label: Text('Maintenance')),
                DataColumn(label: Text('Water')),
                DataColumn(label: Text('Other')),
                DataColumn(label: Text('Total')),
              ],
              rows: members
                  .take(5)
                  .map(
                    (m) => DataRow(
                      cells: [
                        DataCell(Text(m.name)),
                        DataCell(Text('₹${maintenance.toStringAsFixed(0)}')),
                        DataCell(Text('₹${water.toStringAsFixed(0)}')),
                        DataCell(Text('₹${other.toStringAsFixed(0)}')),
                        DataCell(Text('₹${totalPerMember.toStringAsFixed(0)}')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          if (members.length > 5)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '... and ${members.length - 5} more members',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projected Total Collection',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${projectedTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
