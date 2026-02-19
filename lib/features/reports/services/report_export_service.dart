import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_strings.dart';
import 'report_service.dart';

class ReportExportService {
  static Future<void> generateMemberSummaryPDF() async {
    final data = ReportService.getMemberPaymentSummary();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                AppStrings.societyName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                AppStrings.societyAddress,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Header(level: 0, text: 'Society Payment Summary'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Flat', 'Paid (₹)', 'Pending (₹)'],
                data: data
                    .map(
                      (m) => [
                        m['name'],
                        m['flat'],
                        m['paid'].toStringAsFixed(0),
                        m['pending'].toStringAsFixed(0),
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Member_Payment_Summary.pdf',
    );
  }
}
