import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../admin/widgets/admin_drawer.dart';
import '../../../core/utils/mock_data.dart';
import '../../auth/models/user_model.dart';
import '../../reports/services/report_export_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter users by search query
    final members = MockData.users.where((user) {
      final query = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
             user.flatNumber.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Member Ledgers (Audit)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download Overall Ledger PDF',
            onPressed: () => ReportExportService.generateOverallLedgerPDF(members),
          ),
          IconButton(
            icon: const Icon(Icons.table_view),
            tooltip: 'Download Overall Ledger Excel',
            onPressed: () => ReportExportService.generateOverallLedgerExcel(members),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name, Flat, or Email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Member Ledger List
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No members found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberLedgerCard(member);
                    },
                  ),
          ),
        ],
      ),
    );
  }



  Widget _buildMemberLedgerCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.table_chart_outlined, color: AppColors.primary, size: 20),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Flat: ${user.flatNumber} | Outstanding: ₹${NumberFormat('#,##,###').format(user.closingBalance)}',
          style: const TextStyle(fontSize: 12, color: AppColors.error),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
          onPressed: () => _showEditMemberBottomSheet(user),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOCIETY LEDGER (B-O)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Opening Balance (1-Apr)', user.openingBalance),
                      _buildInfoRow('Sinking Fund', user.sinkingFund),
                      _buildInfoRow('Maintenance', user.maintenanceAmount),
                      _buildInfoRow('Municipal Tax', user.municipalTax),
                      _buildInfoRow('NOC', user.noc),
                      _buildInfoRow('Parking Charges', user.parkingCharges),
                      _buildInfoRow('Delay Charges', user.delayCharges),
                      _buildInfoRow('Building Fund', user.buildingFund),
                      _buildInfoRow('Room Transfer Fees', user.roomTransferFees),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.border),
                      ),
                      _buildInfoRow('Total Receivable', user.totalReceivable, isBold: true, color: AppColors.primary),
                      _buildInfoRow('Total Received', user.totalReceived, isBold: true, color: Colors.green.shade700),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.border),
                      ),
                      _buildInfoRow('Closing Balance (31-Mar)', user.closingBalance, isBold: true, color: AppColors.error),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'CHARGES TYPES (Q-S)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     _buildChargeBox('Fixed Monthly', user.fixedMonthlyCharges, AppColors.primary),
                     const SizedBox(width: 8),
                     _buildChargeBox('Annual Fees', user.annualCharges, Colors.orange.shade700),
                     const SizedBox(width: 8),
                     _buildChargeBox('Variable', user.variableCharges, Colors.indigo.shade500),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeBox(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${NumberFormat('#,##,###').format(value)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, double value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '₹${NumberFormat('#,##,###').format(value)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditMemberBottomSheet(UserModel user) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit ${user.name}\'s Ledger',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    ...controllers.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: entry.value,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: entry.key,
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final updatedUser = UserModel(
                          uid: user.uid,
                          name: user.name,
                          email: user.email,
                          phone: user.phone,
                          password: user.password,
                          flatNumber: user.flatNumber,
                          role: user.role,
                          societyId: user.societyId,
                          status: user.status,
                          createdBy: user.createdBy,
                          createdAt: user.createdAt,
                          openingBalance: double.tryParse(controllers['Opening Balance']!.text) ?? 0,
                          sinkingFund: double.tryParse(controllers['Sinking Fund']!.text) ?? 0,
                          maintenanceAmount: double.tryParse(controllers['Maintenance']!.text) ?? 0,
                          municipalTax: double.tryParse(controllers['Municipal Tax']!.text) ?? 0,
                          noc: double.tryParse(controllers['NOC']!.text) ?? 0,
                          parkingCharges: double.tryParse(controllers['Parking Charges']!.text) ?? 0,
                          delayCharges: double.tryParse(controllers['Delay Charges']!.text) ?? 0,
                          buildingFund: double.tryParse(controllers['Building Fund']!.text) ?? 0,
                          roomTransferFees: double.tryParse(controllers['Room Transfer Fees']!.text) ?? 0,
                          // Recalculate totals if necessary
                          totalReceivable: (double.tryParse(controllers['Opening Balance']!.text) ?? 0) +
                              (double.tryParse(controllers['Sinking Fund']!.text) ?? 0) +
                              (double.tryParse(controllers['Maintenance']!.text) ?? 0) +
                              (double.tryParse(controllers['Municipal Tax']!.text) ?? 0) +
                              (double.tryParse(controllers['NOC']!.text) ?? 0) +
                              (double.tryParse(controllers['Parking Charges']!.text) ?? 0) +
                              (double.tryParse(controllers['Delay Charges']!.text) ?? 0) +
                              (double.tryParse(controllers['Building Fund']!.text) ?? 0) +
                              (double.tryParse(controllers['Room Transfer Fees']!.text) ?? 0),
                          totalReceived: user.totalReceived,
                        );
                        
                        // Closing balance = Receivable - Received

                        
                        MockData.updateUser(updatedUser);
                        setState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ledger updated successfully')),
                        );
                      },
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
