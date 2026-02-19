import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../auth/models/user_model.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/info_card.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Role Check
    if (SessionManager.currentUser == null) {
      return const _AccessDeniedScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          _buildRoleBadge(SessionManager.currentUser?.role),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AdminDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Society Overview', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 1200
                    ? 4
                    : (width > 600 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 4 : 2.5,
                  children: [
                    InfoCard(
                      title: 'Total Members',
                      value: MockData.getMembers().length.toString(),
                      icon: Icons.people_alt_outlined,
                      color: Colors.blue,
                    ),
                    InfoCard(
                      title: 'Maintenance Fund',
                      value:
                          '₹${MockData.getFundBalances()['Maintenance Fund']?.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.green,
                    ),
                    InfoCard(
                      title: 'Sinking Fund',
                      value:
                          '₹${MockData.getFundBalances()['Sinking Fund']?.toStringAsFixed(0)}',
                      icon: Icons.savings_outlined,
                      color: Colors.orange,
                    ),
                    InfoCard(
                      title: 'Outstanding Dues',
                      value:
                          '₹${MockData.getTotalOutstanding().toStringAsFixed(0)}',
                      icon: Icons.priority_high_outlined,
                      color: Colors.red,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            Text('Management Console', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: kIsWeb ? 4 : 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  'Members List',
                  Icons.people_alt_outlined,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/members'),
                ),
                _buildActionCard(
                  context,
                  'Record Payment',
                  Icons.add_card_outlined,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/record-payment'),
                ),
                _buildActionCard(
                  context,
                  'Reports & Audits',
                  Icons.analytics_outlined,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/reports'),
                ),
                _buildActionCard(
                  context,
                  'Society Documents',
                  Icons.folder_shared_outlined,
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/document-list'),
                ),
                _buildActionCard(
                  context,
                  'System Health',
                  Icons.health_and_safety_outlined,
                  Colors.redAccent,
                  () => Navigator.pushNamed(context, '/system-health'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (kIsWeb) ...[
              Text(
                'Advanced Operations (Web Console)',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Column(
                  children: [
                    _buildAdvancedTile(
                      context,
                      'Bulk Bill Generation',
                      'Generate maintenance notices for all members at once',
                      Icons.receipt_long_outlined,
                      () => Navigator.pushNamed(context, '/generate-bills'),
                    ),
                    const Divider(height: 32),
                    _buildAdvancedTile(
                      context,
                      'Bulk Member Import',
                      'Upload CSV/Excel to add members in bulk',
                      Icons.upload_file_outlined,
                      () => Navigator.pushNamed(context, '/bulk-import'),
                    ),
                    const Divider(height: 32),
                    _buildAdvancedTile(
                      context,
                      'Maintenance Allocation Editor',
                      'Configure fund segregation ratios for the society',
                      Icons.settings_suggest_outlined,
                      () => Navigator.pushNamed(context, '/allocation-editor'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Mobile-only message or simplified view
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Advanced operations (Bulk Billing, Imports, Ratios) are optimized for the Web Console.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
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
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
      title: Text(title, style: AppTextStyles.h4),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildRoleBadge(UserRole? role) {
    String label = 'Unknown';
    Color color = Colors.grey;

    switch (role) {
      case UserRole.chairman:
        label = 'Chairman';
        color = Colors.orange;
        break;
      case UserRole.secretary:
        label = 'Secretary';
        color = Colors.blue;
        break;
      case UserRole.treasurer:
        label = 'Treasurer';
        color = Colors.green;
        break;
      case UserRole.member:
        label = 'Member';
        color = Colors.teal;
        break;
      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Text(
          label.toUpperCase(),
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
