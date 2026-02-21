import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_drawer.dart';

class ChairmanDashboard extends StatelessWidget {
  const ChairmanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final totalCollected = MockData.getTotalCollected();
    final totalOutstanding = MockData.getTotalOutstanding();
    final totalExpenses = MockData.expenses.fold<double>(
      0,
      (sum, e) => sum + e.totalAmount,
    );
    final fundBalances = MockData.getFundBalances();
    final totalFunds = fundBalances.values.fold<double>(0, (sum, v) => sum + v);
    final memberCount = MockData.getMembers().length;
    final expenseCount = MockData.expenses.length;
    final verifiedExpenses = MockData.expenses
        .where((e) => e.verifiedBy != null)
        .length;
    final approvedExpenses = MockData.expenses
        .where((e) => e.approvedBy != null)
        .length;

    // Audit health score (0-100)
    final auditScore = expenseCount > 0
        ? ((verifiedExpenses + approvedExpenses) / (expenseCount * 2) * 100)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chairman Console'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [_buildRoleBadge(), const SizedBox(width: 16)],
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Governance Header
            _buildGovernanceHeader(auditScore),
            const SizedBox(height: 28),

            // Financial Overview Cards
            Text('Financial Overview', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.6,
              children: [
                _buildMetricCard(
                  'Total Funds',
                  '₹${_formatNum(totalFunds)}',
                  Icons.account_balance_wallet_rounded,
                  AppColors.primary,
                ),
                _buildMetricCard(
                  'Collections',
                  '₹${_formatNum(totalCollected)}',
                  Icons.trending_up_rounded,
                  AppColors.success,
                ),
                _buildMetricCard(
                  'Expenses',
                  '₹${_formatNum(totalExpenses)}',
                  Icons.trending_down_rounded,
                  AppColors.warning,
                ),
                _buildMetricCard(
                  'Outstanding',
                  '₹${_formatNum(totalOutstanding)}',
                  Icons.pending_actions_rounded,
                  AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Compliance & Governance
            Text('Governance Controls', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            _buildGovernanceGrid(context),
            const SizedBox(height: 28),

            // Audit Compliance
            Text('Audit Compliance', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            _buildComplianceChecklist(
              expenseCount,
              verifiedExpenses,
              approvedExpenses,
              memberCount,
            ),
            const SizedBox(height: 28),

            // Recent Activity
            Text('Recent Activity', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            _buildRecentActivity(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernanceHeader(int auditScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF1A3050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1628).withValues(alpha: 0.3),
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
                        Icons.gavel_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Governance Control',
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Society operations dashboard for oversight, approvals, and compliance monitoring',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: auditScore > 70
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auditScore > 70 ? '● System Healthy' : '● Needs Attention',
                    style: TextStyle(
                      color: auditScore > 70
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Audit Health Score ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: auditScore / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      auditScore > 70 ? AppColors.success : AppColors.warning,
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
                        fontSize: 18,
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

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_outward_rounded,
                color: AppColors.textHint,
                size: 14,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: AppTextStyles.h4.copyWith(fontSize: 18),
                ),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        _buildGovCard(
          context,
          'Role Management',
          'Assign & manage roles',
          Icons.admin_panel_settings_rounded,
          AppColors.primary,
          '/member-list',
        ),
        _buildGovCard(
          context,
          'Audit Logs',
          'View all system actions',
          Icons.security_rounded,
          const Color(0xFF6366F1),
          '/audit-logs',
        ),
        _buildGovCard(
          context,
          'Record Expense',
          'Log society expenses',
          Icons.receipt_long_rounded,
          AppColors.warning,
          '/record-expense',
        ),
        _buildGovCard(
          context,
          'Reports',
          'Financial & audit reports',
          Icons.analytics_rounded,
          AppColors.success,
          '/reports',
        ),
        _buildGovCard(
          context,
          'Documents',
          'Society legal documents',
          Icons.folder_shared_rounded,
          const Color(0xFF8B5CF6),
          '/document-list',
        ),
        _buildGovCard(
          context,
          'Add Member',
          'Issue new credentials',
          Icons.person_add_rounded,
          const Color(0xFF0EA5E9),
          '/add-member',
        ),
        _buildGovCard(
          context,
          'Generate Bills',
          'Monthly demand notices',
          Icons.receipt_rounded,
          AppColors.secondary,
          '/generate-bills',
        ),
        _buildGovCard(
          context,
          'Treasury',
          'Fund balances & ledger',
          Icons.account_balance_rounded,
          const Color(0xFF0891B2),
          '/treasurer-dashboard',
        ),
      ],
    );
  }

  Widget _buildGovCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String route,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplianceChecklist(
    int totalExpenses,
    int verified,
    int approved,
    int members,
  ) {
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
          _buildComplianceRow(
            Icons.receipt_long_rounded,
            'Expenses Recorded',
            '$totalExpenses entries',
            true,
          ),
          const SizedBox(height: 10),
          _buildComplianceRow(
            Icons.verified_rounded,
            'Verified Expenses',
            '$verified / $totalExpenses',
            verified == totalExpenses && totalExpenses > 0,
          ),
          const SizedBox(height: 10),
          _buildComplianceRow(
            Icons.approval_rounded,
            'Approved Expenses',
            '$approved / $totalExpenses',
            approved == totalExpenses && totalExpenses > 0,
          ),
          const SizedBox(height: 10),
          _buildComplianceRow(
            Icons.people_rounded,
            'Active Members',
            '$members registered',
            members > 0,
          ),
          const SizedBox(height: 10),
          _buildComplianceRow(
            Icons.lock_rounded,
            'Audit Trail',
            'Immutable logs active',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(
    IconData icon,
    String label,
    String status,
    bool isGood,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (isGood ? AppColors.success : AppColors.warning).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isGood ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isGood ? AppColors.success : AppColors.warning,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
              ),
              Text(
                status,
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

  Widget _buildRecentActivity() {
    final recentExpenses = MockData.expenses.take(3).toList();
    if (recentExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text('No recent activity', style: AppTextStyles.caption),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: recentExpenses.asMap().entries.map((entry) {
          final e = entry.value;
          final isLast = entry.key == recentExpenses.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    e.category.icon,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                title: Text(
                  e.displayCategory,
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${e.recordedBy} • ${DateFormat('dd MMM').format(e.timestamp)}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                trailing: Text(
                  '₹${_formatNum(e.totalAmount)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'CHAIRMAN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _formatNum(double n) {
    return NumberFormat('#,##,##0', 'en_IN').format(n);
  }
}
