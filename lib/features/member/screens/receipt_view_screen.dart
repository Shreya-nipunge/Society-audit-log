import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../billing/models/maintenance_receipt_model.dart';
import '../../payments/services/receipt_service.dart';

class ReceiptViewScreen extends StatelessWidget {
  final MaintenanceReceiptModel receipt;

  const ReceiptViewScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Receipt'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Download PDF',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Receipt Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  _buildReceiptHeader(),
                  
                  // Receipt Info
                  _buildReceiptInfo(),
                  
                  // Member Details
                  _buildMemberDetails(),
                  
                  // Charge Breakdown Table
                  _buildChargeBreakdown(),
                  
                  // Total Section
                  _buildTotalSection(),
                  
                  // Amount in Words
                  _buildAmountInWords(),
                  
                  // Payment Details
                  _buildPaymentDetails(),
                  
                  // Footer
                  _buildReceiptFooter(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Download PDF Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.societyName.toUpperCase(),
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.societyAddress,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              'MAINTENANCE RECEIPT',
              style: TextStyle(
                color: AppColors.secondaryLight,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Receipt No.',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                receipt.receiptNo,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM yyyy').format(receipt.generatedAt),
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildDetailRow('Flat Owner', receipt.flatOwnerName),
          _buildDetailRow('Floor', receipt.floor),
          _buildDetailRow('Room No.', receipt.roomNo),
          _buildDetailRow(
            'Period',
            '${DateFormat('dd MMM yyyy').format(receipt.periodFrom)} to ${DateFormat('dd MMM yyyy').format(receipt.periodTo)}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charge Breakdown',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildChargeRow('Sinking Fund', receipt.sinkingFund),
          _buildChargeRow('Maintenance', receipt.maintenance),
          _buildChargeRow('Municipal Tax', receipt.municipalTax),
          if (receipt.noc > 0)
            _buildChargeRow('NOC', receipt.noc),
          if (receipt.parkingCharges > 0)
            _buildChargeRow('Parking Charges', receipt.parkingCharges),
          if (receipt.miscellaneous > 0)
            _buildChargeRow('Miscellaneous', receipt.miscellaneous),
          _buildChargeRow('Building Fund', receipt.buildingFund),
          if (receipt.penaltyAmount > 0) ...[
            const Divider(height: 16),
            _buildChargeRow(
              'Late Penalty (${receipt.lateMonths} month${receipt.lateMonths > 1 ? 's' : ''} × ₹25)',
              receipt.penaltyAmount,
              isHighlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChargeRow(String label, double amount, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlight ? AppColors.error : AppColors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlight ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TOTAL AMOUNT',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '₹${receipt.totalAmount.toStringAsFixed(0)}',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInWords() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Received Rupees (in words)',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              receipt.receivedRupeesInWords,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildDetailRow('Payment Mode', receipt.paymentMode),
            if (receipt.paymentMode == 'Cheque') ...[
              if (receipt.chequeNo != null && receipt.chequeNo!.isNotEmpty)
                _buildDetailRow('Cheque No.', receipt.chequeNo!),
              if (receipt.drawnOn != null && receipt.drawnOn!.isNotEmpty)
                _buildDetailRow('Drawn On', receipt.drawnOn!),
            ],
            if (receipt.paymentMode == 'UPI')
              if (receipt.upiId != null && receipt.upiId!.isNotEmpty)
                _buildDetailRow('UPI ID', receipt.upiId!),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 1,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member Signature',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 1,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Treasurer Signature',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This is a computer-generated receipt. A physical copy will be provided shortly.',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdfBytes = await ReceiptService.generateMaintenanceReceiptPdf(receipt);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Receipt_${receipt.receiptNo}',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
}
