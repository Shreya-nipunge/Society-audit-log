import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';
import '../../../core/constants/app_strings.dart';

class ReceiptService {
  static Future<Uint8List> generateReceiptPdf(
    TransactionModel transaction,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd-MMM-yyyy').format(transaction.recordedAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        AppStrings.societyName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Reg. No: BOM/HSG/1234/1990',
                      ), // Placeholder until provided
                      pw.Text(
                        AppStrings.societyAddress,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 2),
                        ),
                        child: pw.Text(
                          'MAINTENANCE RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                // Receipt Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Receipt No: ${transaction.receiptNo}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Date: $dateStr'),
                  ],
                ),
                pw.SizedBox(height: 16),

                pw.Text('Received with thanks from:'),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 16, top: 4),
                  child: pw.Text(
                    transaction.memberName,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Row(
                  children: [
                    pw.Text('Flat No: '),
                    pw.Text(
                      transaction.flatNo,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Fund Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _paddedText('Description', isBold: true),
                        _paddedText(
                          'Amount (INR)',
                          isBold: true,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    ),
                    _fundRow(
                      'Maintenance Charges',
                      transaction.allocation.maintenance,
                    ),
                    _fundRow(
                      'Sinking Fund',
                      transaction.allocation.sinkingFund,
                    ),
                    _fundRow(
                      'Repairs Fund',
                      transaction.allocation.repairsFund,
                    ),
                    _fundRow(
                      'Water Charges',
                      transaction.allocation.waterCharges,
                    ),
                    _fundRow('Other Charges', transaction.allocation.other),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'TOTAL',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            transaction.amount.toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Payment Info
                pw.Text('Payment Mode: ${transaction.paymentMode}'),
                if (transaction.referenceNo != null)
                  pw.Text('Ref No: ${transaction.referenceNo}'),

                pw.Spacer(),

                // Signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 120,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide()),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Member Signature'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 120,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide()),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Treasurer Signature'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'This is a computer-generated receipt.',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _paddedText(
    String text, {
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null),
      ),
    );
  }

  static pw.TableRow _fundRow(String label, double amount) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            amount.toStringAsFixed(2),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
}
