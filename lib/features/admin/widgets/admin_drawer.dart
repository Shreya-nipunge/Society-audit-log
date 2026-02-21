import 'package:flutter/material.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/permission_manager.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
            accountName: Text(
              user?.name ?? 'Admin',
              style: AppTextStyles.h4.copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              user?.role.toString().split('.').last.toUpperCase() ?? 'ADMIN',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ),
          _buildDrawerItem(
            context,
            _dashboardLabel(),
            Icons.dashboard_outlined,
            _dashboardRoute(),
          ),
          _buildDrawerItem(
            context,
            'Members',
            Icons.people_alt_outlined,
            '/member-list',
          ),
          _buildDrawerItem(
            context,
            'Billing',
            Icons.receipt_long_outlined,
            '/generate-bills',
          ),
          _buildDrawerItem(
            context,
            'Reports',
            Icons.analytics_outlined,
            '/reports',
          ),
          if (!PermissionManager.isTreasurer())
            _buildDrawerItem(
              context,
              'Treasury',
              Icons.account_balance_outlined,
              '/treasurer-dashboard',
            ),
          _buildDrawerItem(
            context,
            'Expenses',
            Icons.receipt_long_outlined,
            '/record-expense',
          ),
          _buildDrawerItem(
            context,
            'Documents',
            Icons.folder_open_outlined,
            '/document-list',
          ),
          if (PermissionManager.isChairman() || PermissionManager.isSecretary())
            _buildDrawerItem(
              context,
              'Audit Logs',
              Icons.security_outlined,
              '/audit-logs',
            ),

          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: Text(
              'Logout',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.red),
            ),
            onTap: () {
              SessionManager().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  String _dashboardLabel() {
    if (PermissionManager.isChairman()) return 'Chairman Console';
    if (PermissionManager.isTreasurer()) return 'Treasurer Console';
    return 'Secretary Console';
  }

  String _dashboardRoute() {
    if (PermissionManager.isChairman()) return '/chairman-dashboard';
    if (PermissionManager.isTreasurer()) return '/treasurer-dashboard';
    return '/admin-dashboard';
  }
}
