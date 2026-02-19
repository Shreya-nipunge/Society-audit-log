import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/mock_data.dart';
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
        title: const Text('My Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          _buildRoleBadge(user?.role),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              SessionManager().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(user),
            const SizedBox(height: 24),

            // Dues Summary
            const Text(
              'Maintenance Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDuesCard(outstanding, lastPaymentStr),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3, // Larger tiles
              children: [
                _buildActionTile(
                  context,
                  'My Dues',
                  Icons.account_balance_wallet_outlined,
                  AppColors.primary,
                  () => Navigator.pushNamed(context, '/my-dues'),
                ),
                _buildActionTile(
                  context,
                  'Payment History',
                  Icons.history_outlined,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/payment-history'),
                ),
                _buildActionTile(
                  context,
                  'Notices',
                  Icons.notifications_none_outlined,
                  Colors.blue,
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notices coming soon!')),
                  ),
                ),
                _buildActionTile(
                  context,
                  'Documents',
                  Icons.folder_open_outlined,
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/document-list'),
                ),
              ],
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
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            user?.name ?? 'Member',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30, // Larger
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Flat: ${user?.societyId == 'society_123' ? "A-101" : "N/A"}', // Mock flat mapping
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuesCard(double outstanding, String lastPaymentDate) {
    bool isOverdue = outstanding > 0;
    return Container(
      padding: const EdgeInsets.all(20),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outstanding Dues',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${outstanding.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 40, // Very large for visibility
                      fontWeight: FontWeight.bold,
                      color: isOverdue ? Colors.red : AppColors.success,
                    ),
                  ),
                ],
              ),
              Icon(
                isOverdue ? Icons.error_outline : Icons.check_circle_outline,
                size: 48,
                color: isOverdue
                    ? Colors.red.withValues(alpha: 0.2)
                    : AppColors.success.withValues(alpha: 0.2),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Last Payment: ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              Text(
                lastPaymentDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40), // Larger icons
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole? role) {
    String label = 'Member';
    Color color = Colors.teal;

    if (role != null) {
      label = role.name.toUpperCase();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
