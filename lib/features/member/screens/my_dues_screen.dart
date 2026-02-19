import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../billing/models/bill_model.dart';

class MyDuesScreen extends StatelessWidget {
  const MyDuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionManager.currentUser;
    final unpaidBills = currentUser != null
        ? MockData.getUnpaidBillsForMember(currentUser.id)
        : <BillModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Outstanding Dues'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Outstanding',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${unpaidBills.fold(0.0, (sum, b) => sum + b.total).toStringAsFixed(0)}',
                      style: AppTextStyles.h3.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: unpaidBills.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: unpaidBills.length,
                    itemBuilder: (context, index) {
                      final bill = unpaidBills[index];
                      return _buildBillCard(bill);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending dues!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            'All your bills are currently paid.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillModel bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bill.month, style: AppTextStyles.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Unpaid',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildAmountRow('Maintenance', bill.maintenanceAmount),
          _buildAmountRow('Water Charges', bill.waterCharges),
          _buildAmountRow('Other Charges', bill.otherCharges),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${bill.total.toStringAsFixed(0)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
