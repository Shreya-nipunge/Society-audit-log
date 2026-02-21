import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../services/report_export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = false;

  Future<void> _exportPdf() async {
    setState(() => _isLoading = true);
    try {
      // Generate the comprehensive financial report
      await ReportExportService.generateFinancialReportPDF();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _isLoading = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing professional Excel report...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await ReportExportService.generateFinancialReportExcel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating Excel: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final totalCollected = MockData.getTotalCollected();
    final totalPending = MockData.getTotalOutstanding();
    final fundBalances = MockData.getFundBalances();
    final members = MockData.getMembers();
    final totalExpenses = MockData.expenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final collectionRate = (totalCollected + totalPending) > 0
        ? (totalCollected / (totalCollected + totalPending) * 100)
        : 0.0;

    // Group expenses by category
    final expenseByCategory = <String, double>{};
    for (final e in MockData.expenses) {
      final key = e.displayCategory;
      expenseByCategory[key] = (expenseByCategory[key] ?? 0) + e.amount;
    }
    final sortedExpenses = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _exportExcel,
            icon: const Icon(
              Icons.table_view_outlined,
              size: 18,
              color: Colors.white70,
            ),
            label: const Text('Excel', style: TextStyle(color: Colors.white70)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _exportPdf,
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: const Text('PDF', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Metrics Row 1 ──
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Collected',
                    '₹${_fmt(totalCollected)}',
                    AppColors.success,
                    Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Pending',
                    '₹${_fmt(totalPending)}',
                    AppColors.error,
                    Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Top Metrics Row 2 ──
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Expenses',
                    '₹${_fmt(totalExpenses)}',
                    const Color(0xFF6366F1),
                    Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Collection Rate',
                    '${collectionRate.toStringAsFixed(1)}%',
                    collectionRate >= 80 ? AppColors.success : Colors.orange,
                    Icons.speed_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Fund Balances ──
            Text('Fund Balances', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fundBalances.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final entry = fundBalances.entries.elementAt(index);
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Text(
                      '₹${_fmt(entry.value)}',
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // ── Expense Breakdown ──
            Text('Expense Breakdown', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              '${MockData.expenses.length} expenses across ${expenseByCategory.length} categories',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            if (sortedExpenses.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No expenses recorded yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedExpenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final e = sortedExpenses[index];
                    final pct = totalExpenses > 0
                        ? (e.value / totalExpenses * 100)
                        : 0.0;
                    return ListTile(
                      title: Text(e.key, style: const TextStyle(fontSize: 14)),
                      subtitle: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          backgroundColor: AppColors.border.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF6366F1),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${_fmt(e.value)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 28),

            // ── Member-wise Summary ──
            Text('Member-wise Payment Summary', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Member')),
                    DataColumn(label: Text('Flat')),
                    DataColumn(label: Text('Paid')),
                    DataColumn(label: Text('Pending')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: members.map((m) {
                    final paid = MockData.transactions
                        .where((t) => t.memberId == m.id)
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final dues = MockData.getOutstandingAmount(m.id);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            m.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            m.flatNumber.isNotEmpty ? m.flatNumber : '—',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${paid.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${dues.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: dues > 0 ? Colors.red : Colors.green,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (dues > 0 ? Colors.orange : Colors.green)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dues > 0 ? 'Pending' : 'Clear',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: dues > 0 ? Colors.orange : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
