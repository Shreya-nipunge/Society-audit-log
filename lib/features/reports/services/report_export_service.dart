import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_strings.dart';
import 'report_service.dart';
import '../../auth/models/user_model.dart';

class ReportExportService {
  static const PdfColor _primaryColor = PdfColors.indigo900;
  static const PdfColor _accentColor = PdfColors.amber700;

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
                  letterSpacing: 1.0,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _accentColor, thickness: 2),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Authorized Business Report', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.TableBorder _professionalTableBorder() {
    return const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 1),
      bottom: pw.BorderSide(color: _primaryColor, width: 1.5),
      top: pw.BorderSide(color: _primaryColor, width: 1.5),
    );
  }

  static Future<void> generateMemberSummaryPDF() async {
    final data = ReportService.getMemberPaymentSummary();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader('MEMBER PAYMENT SUMMARY'),
        footer: _buildFooter,
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: [
              'Member Name',
              'Flat No',
              'Paid Amount (Rs.)',
              'Pending Dues (Rs.)',
            ],
            data: data
                .map(
                  (m) => [
                    m['name'],
                    m['flat'],
                    NumberFormat('#,##,###.00').format(m['paid']),
                    NumberFormat('#,##,###.00').format(m['pending']),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            border: _professionalTableBorder(),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Society_Member_Summary.pdf',
    );
  }

  static Future<void> generateFinancialReportPDF() async {
    final fundBalances = ReportService.getFundBalances();
    final expenses = ReportService.getExpenseSummary();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader('SOCIETY FINANCIAL REPORT'),
        footer: _buildFooter,
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Text(
            'CURRENT FUND BALANCES',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
              letterSpacing: 1.0,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Fund Name', 'Balance (Rs.)'],
            data: fundBalances.entries
                .map((e) => [e.key, NumberFormat('#,##,###.00').format(e.value)])
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            border: _professionalTableBorder(),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 35),
          pw.Text(
            'DETAILED EXPENSE LOG',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
              letterSpacing: 1.0,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Vendor', 'Amount (Rs.)', 'Status'],
            data: expenses
                .map(
                  (e) => [
                    e['date'],
                    e['category'],
                    e['vendor'],
                    NumberFormat('#,##,###.00').format(e['amount']),
                    e['status'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            border: _professionalTableBorder(),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Society_Financial_Report.pdf',
    );
  }

  static Future<void> _shareFile(List<int>? bytes, String fileName) async {
    if (bytes == null) return;
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName').create();
    await file.writeAsBytes(bytes);
    // ignore: deprecated_member_use
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Society Report: $fileName');
  }

  static Future<void> generateMemberSummaryExcel() async {
    final data = ReportService.getMemberPaymentSummary();
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Member Summary'];
    excel.delete('Sheet1');

    // Add Headers
    sheet.appendRow([
      TextCellValue('Member Name'),
      TextCellValue('Flat Number'),
      TextCellValue('Total Paid (INR)'),
      TextCellValue('Pending Dues (INR)'),
    ]);

    // Add Data
    for (var m in data) {
      sheet.appendRow([
        TextCellValue(m['name'] ?? ''),
        m['flat'] != null ? TextCellValue(m['flat']!) : TextCellValue(''),
        DoubleCellValue(m['paid']?.toDouble() ?? 0.0),
        DoubleCellValue(m['pending']?.toDouble() ?? 0.0),
      ]);
    }

    final bytes = excel.encode();
    await _shareFile(bytes, 'Society_Member_Summary.xlsx');
  }

  static Future<void> generateFinancialReportExcel() async {
    final fundBalances = ReportService.getFundBalances();
    final expenses = ReportService.getExpenseSummary();
    final excel = Excel.createExcel();

    // Sheet 1: Fund Balances
    final Sheet fundSheet = excel['Fund Balances'];
    excel.delete('Sheet1');
    fundSheet.appendRow([
      TextCellValue('Fund Name'),
      TextCellValue('Balance (INR)'),
    ]);
    for (var entry in fundBalances.entries) {
      fundSheet.appendRow([
        TextCellValue(entry.key),
        DoubleCellValue(entry.value),
      ]);
    }

    // Sheet 2: Expenses
    final Sheet expenseSheet = excel['Expense Log'];
    expenseSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Vendor'),
      TextCellValue('Amount (INR)'),
      TextCellValue('Status'),
    ]);

    for (var e in expenses) {
      expenseSheet.appendRow([
        TextCellValue(e['date'] ?? ''),
        TextCellValue(e['category'] ?? ''),
        TextCellValue(e['vendor'] ?? ''),
        DoubleCellValue(e['amount']?.toDouble() ?? 0.0),
        TextCellValue(e['status'] ?? ''),
      ]);
    }

    final bytes = excel.encode();
    await _shareFile(bytes, 'Society_Financial_Report.xlsx');
  }

  static Future<void> generateOverallLedgerPDF(List<UserModel> users) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        header: (_) => _buildHeader('OVERALL SOCIETY LEDGER'),
        footer: _buildFooter,
        build: (context) {
          return [
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: [
                'Flat', 
                'Member Name', 
                'Maint.(Rs)', 
                'S.Fund(Rs)', 
                'Tax(Rs)', 
                'Park(Rs)', 
                'Due(Rs)', 
                'Paid(Rs)', 
                'Balance(Rs)'
              ],
              data: users.map((u) => [
                u.flatNumber,
                u.name,
                NumberFormat('#,##,###').format(u.maintenanceAmount),
                NumberFormat('#,##,###').format(u.sinkingFund),
                NumberFormat('#,##,###').format(u.municipalTax),
                NumberFormat('#,##,###').format(u.parkingCharges),
                NumberFormat('#,##,###').format(u.totalReceivable),
                NumberFormat('#,##,###').format(u.totalReceived),
                NumberFormat('#,##,###').format(u.closingBalance),
              ]).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: _primaryColor),
              border: _professionalTableBorder(),
              cellHeight: 22,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Society_Overall_Ledger.pdf',
    );
  }

  static Future<void> generateOverallLedgerExcel(List<UserModel> users) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Overall Ledger'];
    excel.delete('Sheet1');

    sheet.appendRow([TextCellValue('Society Audit Log - Complete Ledger Dump')]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([
      TextCellValue('Flat Number'),
      TextCellValue('Member Name'),
      TextCellValue('Opening Balance'),
      TextCellValue('Sinking Fund'),
      TextCellValue('Maintenance Amount'),
      TextCellValue('Municipal Tax'),
      TextCellValue('NOC'),
      TextCellValue('Parking Charges'),
      TextCellValue('Delay Charges'),
      TextCellValue('Building Fund'),
      TextCellValue('Room Transfer Fees'),
      TextCellValue('Fixed Monthly Charges'),
      TextCellValue('Annual Charges'),
      TextCellValue('Variable Charges'),
      TextCellValue('Total Receivable'),
      TextCellValue('Total Received'),
      TextCellValue('Closing Balance'),
    ]);
    
    for (var u in users) {
      sheet.appendRow([
        TextCellValue(u.flatNumber),
        TextCellValue(u.name),
        DoubleCellValue(u.openingBalance),
        DoubleCellValue(u.sinkingFund),
        DoubleCellValue(u.maintenanceAmount),
        DoubleCellValue(u.municipalTax),
        DoubleCellValue(u.noc),
        DoubleCellValue(u.parkingCharges),
        DoubleCellValue(u.delayCharges),
        DoubleCellValue(u.buildingFund),
        DoubleCellValue(u.roomTransferFees),
        DoubleCellValue(u.fixedMonthlyCharges),
        DoubleCellValue(u.annualCharges),
        DoubleCellValue(u.variableCharges),
        DoubleCellValue(u.totalReceivable),
        DoubleCellValue(u.totalReceived),
        DoubleCellValue(u.closingBalance),
      ]);
    }

    final bytes = excel.encode();
    await _shareFile(bytes, 'Overall_Society_Ledger_${DateFormat('MMM_yyyy').format(DateTime.now())}.xlsx');
  }
}
