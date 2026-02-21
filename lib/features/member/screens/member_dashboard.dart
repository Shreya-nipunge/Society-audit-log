import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/models/user_model.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    final double outstanding = MockData.getOutstandingAmount(user?.id ?? '');
    final transactions = MockData.getTransactionsForMember(user?.id ?? '');
    final lastPayment = transactions.isNotEmpty
        ? transactions.first.recordedAt
        : null;
    final lastPaymentStr = lastPayment != null
        ? DateFormat('dd MMM yyyy').format(lastPayment)
        : 'No payments yet';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          _buildRoleBadge(user?.role),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () {
              SessionManager().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(user),
            const SizedBox(height: 32),

            // Dues Summary Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Financial Status', style: AppTextStyles.h3),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/my-dues'),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDuesCard(context, outstanding, lastPaymentStr),
            const SizedBox(height: 32),

            // Quick Actions Section
            Text('Quick Services', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildActionTile(
                  context,
                  'My Dues',
                  Icons.account_balance_wallet_rounded,
                  AppColors.primary,
                  () => Navigator.pushNamed(context, '/my-dues'),
                ),
                _buildActionTile(
                  context,
                  'Payments',
                  Icons.receipt_long_rounded,
                  AppColors.secondary,
                  () => Navigator.pushNamed(context, '/payment-history'),
                ),
                _buildActionTile(
                  context,
                  'Documents',
                  Icons.description_rounded,
                  const Color(0xFF6366F1),
                  () => Navigator.pushNamed(context, '/document-list'),
                ),
                _buildActionTile(
                  context,
                  'Profile',
                  Icons.person_outline_rounded,
                  const Color(0xFF0EA5E9),
                  () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Notices Section
            Text('Recent Notices', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            ...MockData.notices
                .take(2)
                .map(
                  (notice) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNoticeCard(
                      title: notice['title'] ?? '',
                      date: notice['date'] ?? '',
                      type: notice['category'] ?? '',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/notice-detail',
                        arguments: notice,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.account_balance_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Day,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.name ?? 'Member',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_rounded,
                      color: AppColors.secondaryLight,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unit: ${user?.flatNumber ?? 'N/A'}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuesCard(
    BuildContext context,
    double outstanding,
    String lastPaymentDate,
  ) {
    bool isOverdue = outstanding > 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding Balance', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '₹${NumberFormat('#,##,##0').format(outstanding)}',
                    style: AppTextStyles.cardValue.copyWith(
                      color: isOverdue ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOverdue ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverdue
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  size: 32,
                  color: isOverdue ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.textHint.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text('Last payment on ', style: AppTextStyles.caption),
              Text(
                lastPaymentDate,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isOverdue) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Clear Dues Now',
              icon: Icons.payment_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment gateway opening...')),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(label, style: AppTextStyles.labelMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeCard({
    required String title,
    required String date,
    required String type,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(date, style: AppTextStyles.caption),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole? role) {
    String label = 'MEMBER';

    if (role != null) {
      label = role.name.toUpperCase();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
