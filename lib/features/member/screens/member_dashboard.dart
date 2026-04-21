import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/models/user_model.dart';
import '../../billing/services/notification_service.dart';
import '../../billing/services/penalty_service.dart';

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

    // Get notifications
    final now = DateTime.now();
    final monthName = DateFormat('MMMM').format(now);
    final unpaidMonths = MockData.getUnpaidMonthsForMember(user?.id ?? '');
    final lateMonths = PenaltyService.countLateMonths(unpaidMonths: unpaidMonths);
    final notifications = NotificationService.getAllNotifications(
      outstandingAmount: outstanding,
      monthName: monthName,
      totalLateMonths: lateMonths,
    );


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
            const SizedBox(height: 20),

            // --- Notification Banners ---
            if (notifications.isNotEmpty) ...[
              ...notifications.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationBanner(n),
                ),
              ),
              const SizedBox(height: 8),
            ],

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
            _buildDuesCard(context, outstanding, lastPaymentStr, lateMonths),
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
                  'Notices',
                  Icons.campaign_rounded,
                  AppColors.secondary,
                  () => Navigator.pushNamed(context, '/notice-list'),
                ),
                _buildActionTile(
                  context,
                  'Receipts',
                  Icons.description_rounded,
                  const Color(0xFF6366F1),
                  () => Navigator.pushNamed(context, '/my-receipts'),
                ),
                _buildActionTile(
                  context,
                  'Profile',
                  Icons.person_outline_rounded,
                  const Color(0xFF0EA5E9),
                  () => Navigator.pushNamed(context, '/profile'),
                ),
                _buildActionTile(
                  context,
                  'Documents',
                  Icons.folder_rounded,
                  const Color(0xFF8B5CF6),
                  () => Navigator.pushNamed(context, '/document-list'),
                ),
                _buildActionTile(
                  context,
                  'Complaints',
                  Icons.report_problem_rounded,
                  const Color(0xFFEF4444),
                  () => Navigator.pushNamed(context, '/my-complaints'),
                ),
              ],
            ),
            const SizedBox(height: 32),
             
             // --- Society Audit / Ledger Section ---
            Text('Society Ledger (B-O)', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildSocietyLedger(user),
            
            const SizedBox(height: 32),
            
            // --- 3-column Charges Section ---
            Text('Charges Types', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildChargesTypes(user),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Notification Banner ---
  Widget _buildNotificationBanner(MaintenanceNotification notification) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notification.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              notification.icon,
              color: notification.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: notification.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSocietyLedger(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildLedgerRow('Opening Balance', user.openingBalance),
          _buildLedgerRow('Sinking Fund', user.sinkingFund),
          _buildLedgerRow('Maintenance Amount', user.maintenanceAmount),
          _buildLedgerRow('Municipal Tax', user.municipalTax),
          _buildLedgerRow('NOC', user.noc),
          _buildLedgerRow('Parking Charges', user.parkingCharges),
          _buildLedgerRow('Delay Charges', user.delayCharges),
          _buildLedgerRow('Building Fund', user.buildingFund),
          _buildLedgerRow('Room Transfer Fees', user.roomTransferFees),
          const Divider(height: 24),
          _buildLedgerRow('Total Receivable', user.totalReceivable, isBold: true),
          _buildLedgerRow('Total Received', user.totalReceived, color: AppColors.success, isBold: true),
          _buildLedgerRow('Closing Balance (Dues)', user.closingBalance, isBold: true, color: AppColors.error),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(String label, double value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${NumberFormat('#,##,##0').format(value)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesTypes(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        _buildChargeColumn('Fixed Monthly', user.fixedMonthlyCharges, AppColors.primary),
        const SizedBox(width: 12),
        _buildChargeColumn('Annual Charges', user.annualCharges, AppColors.secondary),
        const SizedBox(width: 12),
        _buildChargeColumn('Variable Charges', user.variableCharges, const Color(0xFF6366F1)),
      ],
    );
  }

  Widget _buildChargeColumn(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                '₹${NumberFormat('#,##0').format(value)}',
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
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
    int lateMonths,
  ) {
    bool isOverdue = outstanding > 0;
    final penalty = lateMonths * 25.0;

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

          // Penalty breakdown if applicable
          if (lateMonths > 0 && penalty > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Penalty: ₹${penalty.toStringAsFixed(0)} ($lateMonths month${lateMonths > 1 ? 's' : ''} × ₹25)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
