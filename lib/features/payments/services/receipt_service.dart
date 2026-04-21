import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../billing/models/maintenance_receipt_model.dart';

class ReceiptService {
  static const PdfColor _primaryColor = PdfColors.indigo900;
  static const PdfColor _secondaryColor = PdfColors.grey800;
  static const PdfColor _accentColor = PdfColors.amber700;

  static Future<Uint8List> generateReceiptPdf(
    TransactionModel transaction,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy').format(transaction.date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('PAYMENT RECEIPT'),
                  pw.SizedBox(height: 20),

                  // Receipt Meta Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfMetaRow('Receipt No:', transaction.receiptNo),
                          _pdfMetaRow('Payment Mode:', transaction.paymentMethod),
                          if (transaction.referenceId != null)
                            _pdfMetaRow('Ref No:', transaction.referenceId!),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _pdfMetaRow('Date:', dateStr),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Received From
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Received with thanks from:', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                              pw.SizedBox(height: 4),
                              pw.Text(transaction.memberName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('Flat No', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                            pw.SizedBox(height: 4),
                            pw.Text(transaction.flatNo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Charge Table
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Table Header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: _primaryColor),
                          children: [
                            _paddedText('Description', isBold: true, color: PdfColors.white),
                            _paddedText('Amount (Rs.)', isBold: true, align: pw.TextAlign.right, color: PdfColors.white),
                          ],
                        ),
                        _fundRow('Maintenance Charges', transaction.allocation.maintenance, isLight: true),
                        _fundRow('Sinking Fund', transaction.allocation.sinkingFund, isLight: false),
                        _fundRow('Repairs Fund', transaction.allocation.repairsFund, isLight: true),
                        _fundRow('Building Fund', transaction.allocation.buildingFund, isLight: false),
                        _fundRow('Municipal Tax', transaction.allocation.municipalTax, isLight: true),
                        _fundRow('Other Charges', transaction.allocation.other, isLight: false),
                        
                        // Total Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 2)),
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text('TOTAL AMOUNT PAID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'Rs. ${transaction.amount.toStringAsFixed(2)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: _primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),

                  pw.Spacer(),

                  // Signatures
                  _buildSignatures(),
                  pw.SizedBox(height: 16),
                  pw.Center(
                    child: pw.Text(
                      'This is a computer-generated receipt. A physical copy will be provided shortly on request.',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateMaintenanceReceiptPdf(
    MaintenanceReceiptModel receipt,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy').format(receipt.generatedAt);
    final periodFromStr = DateFormat('MMM yyyy').format(receipt.periodFrom);
    final periodToStr = DateFormat('MMM yyyy').format(receipt.periodTo);
    final isPaid = receipt.paymentMode != 'Pending';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader('MAINTENANCE BILL / RECEIPT'),
                  pw.SizedBox(height: 20),

                  // Receipt Meta Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfMetaRow('Receipt No:', receipt.receiptNo),
                          _pdfMetaRow('Period:', '$periodFromStr - $periodToStr'),
                          _pdfMetaRow('Status:', receipt.paymentMode, highlight: true),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _pdfMetaRow('Date:', dateStr),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Member Details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Billed To:', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                              pw.SizedBox(height: 4),
                              pw.Text(receipt.flatOwnerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                              pw.SizedBox(height: 2),
                              pw.Text('Room No. ${receipt.roomNo}, ${receipt.floor}', style: const pw.TextStyle(fontSize: 10, color: _secondaryColor)),
                            ],
                          ),
                        ),
                        if (isPaid)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Payment Mode', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                              pw.SizedBox(height: 4),
                              pw.Text(receipt.paymentMode, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              if (receipt.paymentMode == 'Cheque' && receipt.chequeNo != null)
                                pw.Text('Chq: ${receipt.chequeNo}', style: const pw.TextStyle(fontSize: 9)),
                              if (receipt.paymentMode == 'UPI' && receipt.upiId != null)
                                pw.Text('UPI: ${receipt.upiId}', style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Charge Breakdown Table
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: _primaryColor),
                          children: [
                            _paddedText('Particulars', isBold: true, color: PdfColors.white),
                            _paddedText('Amount (Rs.)', isBold: true, align: pw.TextAlign.right, color: PdfColors.white),
                          ],
                        ),
                        _fundRow('Sinking Fund', receipt.sinkingFund, isLight: true),
                        _fundRow('Maintenance', receipt.maintenance, isLight: false),
                        _fundRow('Municipal Tax', receipt.municipalTax, isLight: true),
                        if (receipt.noc > 0) _fundRow('NOC', receipt.noc, isLight: false),
                        if (receipt.parkingCharges > 0) _fundRow('Parking Charges', receipt.parkingCharges, isLight: true),
                        if (receipt.miscellaneous > 0) _fundRow('Miscellaneous', receipt.miscellaneous, isLight: false),
                        _fundRow('Building Fund', receipt.buildingFund, isLight: true),
                        if (receipt.penaltyAmount > 0)
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(color: PdfColors.red50),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  'Late Payment Penalty (${receipt.lateMonths} month${receipt.lateMonths > 1 ? 's' : ''} × Rs. 25)',
                                  style: pw.TextStyle(color: PdfColors.red900),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  receipt.penaltyAmount.toStringAsFixed(2),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(color: PdfColors.red900),
                                ),
                              ),
                            ],
                          ),
                        // Total Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 2)),
                          ),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text('TOTAL PAYABLE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                'Rs. ${receipt.totalAmount.toStringAsFixed(2)}',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: _primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Amount in Words
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber50,
                      border: pw.Border(left: const pw.BorderSide(color: _accentColor, width: 3)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Amount in words:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Rupees ${receipt.receivedRupeesInWords}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // Signatures
                  _buildSignatures(),
                  pw.SizedBox(height: 16),
                  pw.Center(
                    child: pw.Text(
                      'This is a computer-generated document. Generated by: ${receipt.generatedBy}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- UI Helpers ---

  static pw.Widget _buildHeader(String documentTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  AppStrings.societyName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  AppStrings.societyAddress,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Reg No: MAH/2024/CHS/1234',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _primaryColor, width: 1.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                documentTitle,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: _accentColor, thickness: 2),
      ],
    );
  }

  static pw.Widget _pdfMetaRow(String label, String value, {bool highlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text(
            '$label ',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10, 
              fontWeight: pw.FontWeight.bold,
              color: highlight && value == 'Pending' ? PdfColors.red700 : highlight ? PdfColors.green700 : _secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _paddedText(
    String text, {
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : null,
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  static pw.TableRow _fundRow(String label, double amount, {required bool isLight}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isLight ? PdfColors.white : PdfColors.grey50,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10), 
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            amount.toStringAsFixed(2),
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          children: [
            pw.Container(
              width: 140,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500)),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Member Signature', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(
              width: 140,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey500)),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Authorized Signatory', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
            pw.Text('(Treasurer / Chairman)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }
}
