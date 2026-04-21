import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final fundBalances = MockData.getFundBalances();
    final totalFunds = fundBalances.values.fold<double>(0, (sum, v) => sum + v);
    final totalExpenses = MockData.expenses.fold<double>(
      0,
      (s, e) => s + e.totalAmount,
    );
    final unverifiedCount = MockData.expenses
        .where((e) => e.verifiedBy == null)
        .length;
    final pendingApproval = MockData.expenses
        .where((e) => e.approvedBy == null)
        .length;
    final auditScore = MockData.expenses.isNotEmpty
        ? (MockData.expenses
                      .where(
                        (e) => e.verifiedBy != null && e.approvedBy != null,
                      )
                      .length /
                  MockData.expenses.length *
                  100)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Treasurer Console'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TREASURER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Finance Header
            _buildFinanceHeader(totalFunds, auditScore),
            const SizedBox(height: 24),

            // Income vs Expense
            Text('Income vs Expense', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildIncomeExpenseCard(monthlyCollection, totalExpenses),
            const SizedBox(height: 24),

            // Fund Balances
            Text('Fund Balances', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildFundCards(fundBalances),
            const SizedBox(height: 24),

            // Quick Finance Actions
            Text('Finance Actions', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildFinanceActions(context),
            const SizedBox(height: 24),

            // Pending Approvals
            Text('Verification Queue', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildVerificationQueue(context, unverifiedCount, pendingApproval),
            const SizedBox(height: 24),

            // Risk Flags
            Text('Risk & Compliance', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildRiskFlags(totalPending, unverifiedCount),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceHeader(double totalFunds, int auditScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Finance Control',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Total Funds',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${_fmt(totalFunds)}',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: auditScore / 100,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      auditScore > 70 ? const Color(0xFF34D399) : Colors.amber,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$auditScore%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Audit',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCard(double income, double expenses) {
    final total = income + expenses;
    final incomeRatio = total > 0 ? income / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Income',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_fmt(income)}',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 16,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expenses',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_fmt(expenses)}',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (incomeRatio * 100).round(),
                    child: Container(color: AppColors.success),
                  ),
                  Flexible(
                    flex: ((1 - incomeRatio) * 100).round(),
                    child: Container(
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net: ₹${_fmt(income - expenses)}',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  color: income >= expenses
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              Text(
                '${(incomeRatio * 100).toStringAsFixed(0)}% income ratio',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFundCards(Map<String, double> fundBalances) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      const Color(0xFF6366F1),
      AppColors.warning,
      const Color(0xFF0EA5E9),
    ];
    final entries = fundBalances.entries.toList();
    return Column(
      children: entries.asMap().entries.map((entry) {
        final fundName = entry.value.key;
        final fundBalance = entry.value.value;
        final color = colors[entry.key % colors.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  fundName,
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
                ),
              ),
              Text(
                '₹${_fmt(fundBalance)}',
                style: AppTextStyles.h4.copyWith(fontSize: 15),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinanceActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            context,
            'Record\nExpense',
            Icons.receipt_long_rounded,
            AppColors.warning,
            '/record-expense',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            context,
            'View\nReports',
            Icons.analytics_rounded,
            AppColors.primary,
            '/reports',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            context,
            'Edit\nMaintenance',
            Icons.edit_calendar_rounded,
            const Color(0xFF6366F1),
            '/edit-maintenance',
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationQueue(
    BuildContext context,
    int unverified,
    int pendingApproval,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildQueueTile(
            Icons.pending_actions_rounded,
            'Unverified Expenses',
            '$unverified requiring verification',
            AppColors.warning,
            () => Navigator.pushNamed(context, '/audit-logs'),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildQueueTile(
            Icons.approval_rounded,
            'Pending Approvals',
            '$pendingApproval awaiting approval',
            AppColors.error,
            () => Navigator.pushNamed(context, '/audit-logs'),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildQueueTile(
            Icons.receipt_rounded,
            'Unreconciled Payments',
            '0 items',
            AppColors.textHint,
            () => Navigator.pushNamed(context, '/record-payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          color: AppColors.textHint,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildRiskFlags(double pendingDues, int unverified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildRiskRow(
            Icons.warning_rounded,
            'Outstanding Dues',
            '₹${_fmt(pendingDues)} pending collection',
            pendingDues > 0 ? AppColors.error : AppColors.success,
            pendingDues > 0,
          ),
          const SizedBox(height: 10),
          _buildRiskRow(
            Icons.verified_user_rounded,
            'Unverified Transactions',
            '$unverified expenses not verified',
            unverified > 0 ? AppColors.warning : AppColors.success,
            unverified > 0,
          ),
          const SizedBox(height: 10),
          _buildRiskRow(
            Icons.lock_rounded,
            'Audit Trail Integrity',
            'All logs immutable & tamper-proof',
            AppColors.success,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskRow(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isRisk,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isRisk ? icon : Icons.check_circle_rounded,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(double n) => NumberFormat('#,##,##0', 'en_IN').format(n);
}
