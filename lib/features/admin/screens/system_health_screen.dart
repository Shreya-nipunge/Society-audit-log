import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/app_mode.dart';
import '../../../core/widgets/info_card.dart';
import '../../audit/services/audit_service.dart';

class SystemHealthScreen extends StatefulWidget {
  const SystemHealthScreen({super.key});

  @override
  State<SystemHealthScreen> createState() => _SystemHealthScreenState();
}

class _SystemHealthScreenState extends State<SystemHealthScreen> {
  @override
  Widget build(BuildContext context) {
    final memberCount = MockData.getMembers().length;
    final transactionCount = MockData.getTransactions().length;
    final billCount = MockData.getDemandNotices().length;
    final logCount = AuditService.auditLogs.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('System Health & Metrics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safe Mode Toggle Card
            _buildSafeModeToggle(),
            const SizedBox(height: 32),

            Text('Technical Overview', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            const Text(
              'Real-time metrics from the mock data orchestrator.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                InfoCard(
                  title: 'Total Members',
                  value: memberCount.toString(),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
                InfoCard(
                  title: 'Bills Generated',
                  value: billCount.toString(),
                  icon: Icons.description_outlined,
                  color: Colors.orange,
                ),
                InfoCard(
                  title: 'Recorded Trans.',
                  value: transactionCount.toString(),
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                ),
                InfoCard(
                  title: 'Audit Events',
                  value: logCount.toString(),
                  icon: Icons.security_outlined,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text('System Status', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            _buildStatusTile(
              'Mock Data Engine',
              AppConfig.isReadOnly ? 'Read-Only' : 'Operational',
              AppConfig.isReadOnly ? Colors.orange : Colors.green,
            ),
            _buildStatusTile(
              'PDF Generation Service',
              'Operational',
              Colors.green,
            ),
            _buildStatusTile('CSV Export Utility', 'Operational', Colors.green),
            _buildStatusTile(
              'Identity Management',
              'Operational',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeModeToggle() {
    bool isReadOnly = AppConfig.isReadOnly;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isReadOnly
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReadOnly ? Colors.orange : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isReadOnly ? Icons.lock_outline : Icons.lock_open_outlined,
                color: isReadOnly ? Colors.orange : Colors.green,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Security Mode',
                      style: AppTextStyles.h4.copyWith(
                        color: isReadOnly
                            ? Colors.orange[900]
                            : Colors.green[900],
                      ),
                    ),
                    Text(
                      isReadOnly
                          ? 'SAFE MODE ACTIVE: Data modification is disabled.'
                          : 'NORMAL MODE: All operations are available.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: isReadOnly,
                activeThumbColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    AppConfig.toggleMode();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'System entered Safe Mode (Read-Only)'
                            : 'System restored to Normal Mode',
                      ),
                      backgroundColor: val ? Colors.orange : Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String service, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
