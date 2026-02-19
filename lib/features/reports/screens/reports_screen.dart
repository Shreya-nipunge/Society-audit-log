import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/csv_exporter.dart';
import '../services/report_service.dart';
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
      await ReportExportService.generateMemberSummaryPDF();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _exportExcel() {
    final data = ReportService.getMemberPaymentSummary();
    final csv = CSVExporter.exportToCSV(data);

    // In a real app, this would save a file. Here we mock it via console and notification.
    debugPrint('Generating Excel for ${AppStrings.societyName}...');
    debugPrint('CSV Data: ${csv.substring(0, 50)}...');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report exported as CSV (View Console/Logs for output)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCollected = MockData.getTotalCollected();
    final totalPending = MockData.getTotalOutstanding();
    final fundBalances = MockData.getFundBalances();
    final members = MockData.getMembers();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _exportExcel,
            icon: const Icon(Icons.table_view_outlined, size: 18),
            label: const Text('Excel'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('PDF'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Collected',
                    '₹${totalCollected.toStringAsFixed(0)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Total Pending',
                    '₹${totalPending.toStringAsFixed(0)}',
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fund Breakdown
            const Text(
              'Fund Balances',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = fundBalances.entries.elementAt(index);
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Member-wise Summary
            const Text(
              'Member-wise Payment Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Member')),
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
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text('₹${paid.toStringAsFixed(0)}')),
                        DataCell(
                          Text(
                            '₹${dues.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: dues > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (dues > 0 ? Colors.orange : Colors.green)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dues > 0 ? 'Partial/Pending' : 'Clear',
                              style: TextStyle(
                                fontSize: 13, // Increased from 10
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18, // Increased from 13
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32, // Increased from 24
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
