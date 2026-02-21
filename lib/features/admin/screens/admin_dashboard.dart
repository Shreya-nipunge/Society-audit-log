import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../auth/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    if (SessionManager.currentUser == null) {
      return const _AccessDeniedScreen();
    }

    final totalCollected = MockData.getTotalCollected();
    final totalOutstanding = MockData.getTotalOutstanding();
    final memberCount = MockData.getMembers().length;
    final recentExpenses = MockData.expenses.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Secretary Console'),
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
              'SECRETARY',
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
            // Operations Header
            _buildOpsHeader(SessionManager.currentUser),
            const SizedBox(height: 20),

            // Quick Actions Bar
            Text('Quick Actions', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildQuickAction(
                    context,
                    'Record\nPayment',
                    Icons.add_card_rounded,
                    AppColors.success,
                    '/record-payment',
                  ),
                  _buildQuickAction(
                    context,
                    'Record\nExpense',
                    Icons.receipt_long_rounded,
                    AppColors.warning,
                    '/record-expense',
                  ),
                  _buildQuickAction(
                    context,
                    'Add\nMember',
                    Icons.person_add_rounded,
                    AppColors.primary,
                    '/add-member',
                  ),
                  _buildQuickAction(
                    context,
                    'Upload\nDocument',
                    Icons.upload_file_rounded,
                    const Color(0xFF8B5CF6),
                    '/upload-document',
                  ),
                  _buildQuickAction(
                    context,
                    'Generate\nBills',
                    Icons.receipt_rounded,
                    const Color(0xFF0EA5E9),
                    '/generate-bills',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            Text('Today\'s Overview', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Members',
                    '$memberCount',
                    Icons.people_rounded,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Collected',
                    '₹${_fmt(totalCollected)}',
                    Icons.trending_up_rounded,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Dues',
                    '₹${_fmt(totalOutstanding)}',
                    Icons.pending_rounded,
                    AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Operations Grid
            Text('Operations Console', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: kIsWeb ? 4 : 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _buildOpsCard(
                  context,
                  'Members',
                  Icons.people_alt_rounded,
                  AppColors.primary,
                  '/member-list',
                ),
                _buildOpsCard(
                  context,
                  'Payments',
                  Icons.payments_rounded,
                  AppColors.success,
                  '/record-payment',
                ),
                _buildOpsCard(
                  context,
                  'Expenses',
                  Icons.receipt_long_rounded,
                  AppColors.warning,
                  '/record-expense',
                ),
                _buildOpsCard(
                  context,
                  'Documents',
                  Icons.folder_shared_rounded,
                  const Color(0xFF8B5CF6),
                  '/document-list',
                ),
                _buildOpsCard(
                  context,
                  'Reports',
                  Icons.analytics_rounded,
                  const Color(0xFF0EA5E9),
                  '/reports',
                ),
                _buildOpsCard(
                  context,
                  'Audit Logs',
                  Icons.security_rounded,
                  const Color(0xFF6366F1),
                  '/audit-logs',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending Tasks
            Text('Pending Tasks', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildPendingSection(context),
            const SizedBox(height: 24),

            // Recent Expenses
            Text('Recent Expenses', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildRecentExpensesList(context, recentExpenses),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOpsHeader(UserModel? user) {
    return Container(
      width: double.infinity,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations Hub',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage daily operations, billing & records',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '● ACTIVE',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.h4.copyWith(fontSize: 15)),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpsCard(
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingSection(BuildContext context) {
    final unverified = MockData.expenses
        .where((e) => e.verifiedBy == null)
        .length;
    final unapproved = MockData.expenses
        .where((e) => e.approvedBy == null)
        .length;

    final draftsCount = MockData.notices
        .where((n) => n['status'] == 'Draft')
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildPendingTile(
            context,
            Icons.verified_rounded,
            'Unverified Expenses',
            '$unverified pending',
            AppColors.warning,
            '/audit-logs',
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildPendingTile(
            context,
            Icons.approval_rounded,
            'Pending Approvals',
            '$unapproved awaiting',
            AppColors.error,
            '/audit-logs',
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildPendingTile(
            context,
            Icons.receipt_long_rounded,
            'Draft Notices',
            '$draftsCount drafts',
            AppColors.textHint,
            '/notice-list',
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String? route,
  ) {
    return ListTile(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
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
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildRecentExpensesList(BuildContext context, List expenses) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text('No expenses recorded yet', style: AppTextStyles.caption),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: expenses.asMap().entries.map((entry) {
          final e = entry.value;
          final isLast = entry.key == expenses.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: () => Navigator.pushNamed(context, '/audit-logs'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    e.category.icon,
                    color: AppColors.warning,
                    size: 18,
                  ),
                ),
                title: Text(
                  e.displayCategory,
                  style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(e.date),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_fmt(e.totalAmount)}',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      e.complianceStatus,
                      style: TextStyle(
                        fontSize: 9,
                        color: e.approvedBy != null
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
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

  String _fmt(double n) => NumberFormat('#,##,##0', 'en_IN').format(n);
}

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Access Denied', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            const Text('You do not have permission to view this page.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
