import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../payments/services/payment_service.dart';
import '../widgets/admin_drawer.dart';

class TreasurerDashboard extends StatelessWidget {
  const TreasurerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final monthlyCollection = PaymentService.getMonthlyCollection();
    final totalPending = PaymentService.getPendingDues();
    final receiptCount = MockData.transactions.length;
    final fundBalances = MockData.getFundBalances();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Treasurer Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Summary', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            // Stats Row
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Monthly Collection',
                  '₹${monthlyCollection.toStringAsFixed(0)}',
                  Icons.account_balance_wallet_outlined,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Pending Dues',
                  '₹${totalPending.toStringAsFixed(0)}',
                  Icons.pending_actions_outlined,
                  AppColors.error,
                ),
                _buildStatCard(
                  'Receipts Issued',
                  receiptCount.toString(),
                  Icons.receipt_long_outlined,
                  AppColors.primary,
                ),
                _buildStatCard(
                  'Active Members',
                  MockData.getMembers().length.toString(),
                  Icons.people_outline,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text('Fund Balances', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Column(
                children: fundBalances.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.bodyLarge),
                        Text(
                          '₹${entry.value.toStringAsFixed(0)}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/reports'),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('View Detailed Reports'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
