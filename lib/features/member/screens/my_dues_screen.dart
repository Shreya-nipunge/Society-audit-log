import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../core/utils/session_manager.dart';
import '../../billing/models/bill_model.dart';
import '../../billing/models/maintenance_receipt_model.dart';
import '../../billing/services/penalty_service.dart';

class MyDuesScreen extends StatelessWidget {
  const MyDuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionManager.currentUser;
    final unpaidBills = currentUser != null
        ? MockData.getUnpaidBillsForMember(currentUser.id)
        : <BillModel>[];

    final receipts = currentUser != null
        ? MockData.getReceiptsForMember(currentUser.id)
        : <MaintenanceReceiptModel>[];

    final paidReceipts =
        receipts.where((r) => r.paymentMode != 'Pending').toList();

    final pendingReceipts = receipts.where((r) {
      if (r.paymentMode != 'Pending') return false;
      // If there's a paid receipt for the same period, this pending one is resolved
      final isPaid = paidReceipts.any((p) =>
          p.periodFrom.year == r.periodFrom.year &&
          p.periodFrom.month == r.periodFrom.month &&
          p.periodTo.year == r.periodTo.year &&
          p.periodTo.month == r.periodTo.month);
      return !isPaid;
    }).toList();

    // Calculate penalty info
    final unpaidMonths = currentUser != null
        ? MockData.getUnpaidMonthsForMember(currentUser.id)
        : <DateTime>[];
    final lateMonths =
        PenaltyService.countLateMonths(unpaidMonths: unpaidMonths);
    final penaltyAmount =
        PenaltyService.calculatePenalty(unpaidMonths: unpaidMonths);

    final totalReceiptDues =
        pendingReceipts.fold(0.0, (sum, r) => sum + r.totalAmount);
    final totalDues =
        unpaidBills.fold(0.0, (sum, b) => sum + b.totalAmount) +
        totalReceiptDues +
        penaltyAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Outstanding Dues'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
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
                          'Total Outstanding',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalDues.toStringAsFixed(0)}',
                          style:
                              AppTextStyles.h3.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ],
                ),

                // Penalty Breakdown
                if (penaltyAmount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Late Payment Penalty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$lateMonths month${lateMonths > 1 ? 's' : ''} × ₹${PenaltyService.penaltyPerMonth.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${penaltyAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Timeline of due dates
                        ...unpaidMonths.where((m) {
                          return PenaltyService.isPaymentLate(
                              m.month, m.year);
                        }).map((m) {
                          final monthName = DateFormat('MMMM yyyy').format(m);
                          final dueDate = PenaltyService.getDueDate(
                              m.month, m.year);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$monthName — Due: ${DateFormat('dd MMM').format(dueDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+₹25',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Due date info
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pay between 1st - 10th of every month to avoid ₹25 late penalty.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bills & Pending Receipts List
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unpaidBills.isNotEmpty || pendingReceipts.isNotEmpty) ...[
                    Text('Pending Payments', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    ...unpaidBills.map((bill) => _buildBillCard(bill)),
                    ...pendingReceipts
                        .map((receipt) => _buildMaintenanceReceiptCard(context, receipt)),
                  ] else if (penaltyAmount == 0) ...[
                    _buildEmptyState(),
                  ],

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pending dues!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            'All your bills are currently paid.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(BillModel bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Text(bill.monthString, style: AppTextStyles.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Unpaid',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildAmountRow('Maintenance', bill.maintenanceAmount),
          _buildAmountRow('Building Fund', bill.buildingFund),
          _buildAmountRow('Municipal Tax', bill.municipalTax),
          _buildAmountRow('Other Charges', bill.otherCharges),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${bill.totalAmount.toStringAsFixed(0)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceReceiptCard(
      BuildContext context, MaintenanceReceiptModel receipt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Maintenance Bill', style: AppTextStyles.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildAmountRow('Receipt No.', 0, text: receipt.receiptNo),
          _buildAmountRow(
            'Period',
            0,
            text:
                '${DateFormat('MMM yyyy').format(receipt.periodFrom)} - ${DateFormat('MMM yyyy').format(receipt.periodTo)}',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${receipt.totalAmount.toStringAsFixed(0)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAmountRow(String label, double amount, {String? text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            text ?? '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
