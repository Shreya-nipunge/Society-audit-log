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

class ReportExportService {
  static const PdfColor _primaryColor = PdfColors.indigo900;
  static const PdfColor _accentColor = PdfColors.amber700;

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  AppStrings.societyName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  AppStrings.societyAddress,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'Reg No: MAH/2024/CHS/1234',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Divider(color: _accentColor, thickness: 2),
        pw.SizedBox(height: 15),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.Text(
          'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  static Future<void> generateMemberSummaryPDF() async {
    final data = ReportService.getMemberPaymentSummary();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _buildHeader('Member-wise Payment Summary'),
        footer: _buildFooter,
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Member Name',
              'Flat No',
              'Paid Amount (INR)',
              'Pending Dues (INR)',
            ],
            data: data
                .map(
                  (m) => [
                    m['name'],
                    m['flat'],
                    NumberFormat('#,##,###').format(m['paid']),
                    NumberFormat('#,##,###').format(m['pending']),
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
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
        header: (_) => _buildHeader('Society Financial Report'),
        footer: _buildFooter,
        build: (context) => [
          pw.Text(
            'Current Fund Balances',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Fund Name', 'Balance (INR)'],
            data: fundBalances.entries
                .map((e) => [e.key, NumberFormat('#,##,###').format(e.value)])
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Detailed Expense Log',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Vendor', 'Amount', 'Status'],
            data: expenses
                .map(
                  (e) => [
                    e['date'],
                    e['category'],
                    e['vendor'],
                    NumberFormat('#,##,###').format(e['amount']),
                    e['status'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
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
}
