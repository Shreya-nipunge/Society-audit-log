import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/audit_log_model.dart';
import '../services/audit_service.dart';
import '../../admin/widgets/admin_drawer.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Members', 'Payments', 'Reports'];

  @override
  Widget build(BuildContext context) {
    final logs = AuditService.getLogsByFilter(_selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security Audit Logs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                              }
                            },
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Log List
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No audit logs found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildLogCard(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(AuditLogModel log) {
    final color = _getLogColor(log.actionType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(_getLogIcon(log.actionType), color: color, size: 20),
        ),
        title: Text(
          log.actionType.replaceAll('_', ' '),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'By ${log.performedBy} (${log.role.name}) • ${DateFormat('HH:mm, dd MMM').format(log.timestamp)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Target', log.targetEntity),
                if (log.oldValue != null)
                  _buildInfoRow('Old Value', log.oldValue!),
                if (log.newValue != null)
                  _buildInfoRow('New Value', log.newValue!),
                const SizedBox(height: 8),
                Text(
                  'Log ID: ${log.id}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Color _getLogColor(String action) {
    if (action.contains('ADD')) return Colors.green;
    if (action.contains('DELETE')) return Colors.red;
    if (action.contains('RECORD')) return AppColors.primary;
    return Colors.blue;
  }

  IconData _getLogIcon(String action) {
    if (action.contains('MEMBER')) return Icons.person_outline;
    if (action.contains('PAYMENT')) return Icons.receipt_long_outlined;
    if (action.contains('REPORT')) return Icons.analytics_outlined;
    return Icons.settings_outlined;
  }
}
