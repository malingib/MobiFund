import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

// Report generation dependencies - these add to bundle size but enable PDF/Excel export
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

class ReportService {
  static final _kesFormat =
      NumberFormat.currency(symbol: 'KES ', decimalDigits: 0);

  // ─────────────────────────────────────────
  // PDF GENERATION: Financial Statement
  // ─────────────────────────────────────────
  static Future<void> generateFinancialStatement({
    required String orgName,
    required List<Contribution> contributions,
    required List<Expense> expenses,
  }) async {
    final pdf = pw.Document();

    final totalContributions =
        contributions.fold(0.0, (sum, c) => sum + c.amount);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalContributions - totalExpenses;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(orgName, 'Financial Statement'),
          pw.SizedBox(height: 20),
          _buildSummarySection(totalContributions, totalExpenses, balance),
          pw.SizedBox(height: 30),
          pw.Text('Contributions',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildContributionsTable(contributions),
          pw.SizedBox(height: 30),
          pw.Text('Expenses',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildExpensesTable(expenses),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${orgName.replaceAll(' ', '_')}_Financial_Statement.pdf',
    );
  }

  // ─────────────────────────────────────────
  // EXCEL/CSV GENERATION: Raw Data
  // ─────────────────────────────────────────
  static Future<void> exportToExcel({
    required String orgName,
    required List<Contribution> contributions,
    required List<Expense> expenses,
    required List<OrgMember> members,
  }) async {
    final excel = Excel.createExcel();

    // Contributions Sheet
    final sheet = excel['Contributions'];
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Member'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
    ]);

    for (final c in contributions) {
      final memberName = members
          .firstWhere((m) => m.userId == c.userId,
              orElse: () => OrgMember(orgId: '', userId: '', name: 'Unknown'))
          .name;
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format(c.date)),
        TextCellValue(memberName),
        DoubleCellValue(c.amount),
        TextCellValue(c.note ?? ''),
      ]);
    }

    // Expenses Sheet
    final expenseSheet = excel['Expenses'];
    expenseSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Amount'),
      TextCellValue('Description'),
    ]);

    for (final e in expenses) {
      expenseSheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format(e.date)),
        TextCellValue(e.type),
        DoubleCellValue(e.amount),
        TextCellValue(e.description ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${orgName.replaceAll(' ', '_')}_Records.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'MobiFund Export for $orgName',
        ),
      );
    }
  }

  // ─────────────────────────────────────────
  // PRIVATE BUILDERS
  // ─────────────────────────────────────────
  static pw.Widget _buildHeader(String orgName, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(orgName.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900)),
        pw.Text(title,
            style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSummarySection(
      double contributions, double expenses, double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem('Total Income', contributions, PdfColors.green900),
          _summaryItem('Total Expenses', expenses, PdfColors.red900),
          _summaryItem('Net Balance', balance,
              balance >= 0 ? PdfColors.blue900 : PdfColors.red900),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, double amount, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text(_kesFormat.format(amount),
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _buildContributionsTable(List<Contribution> contributions) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Amount', 'Note'],
      data: contributions
          .map((c) => [
                DateFormat('dd MMM yyyy').format(c.date),
                _kesFormat.format(c.amount),
                c.note ?? '',
              ])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildExpensesTable(List<Expense> expenses) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Type', 'Amount', 'Description'],
      data: expenses
          .map((e) => [
                DateFormat('dd MMM yyyy').format(e.date),
                e.type,
                _kesFormat.format(e.amount),
                e.description ?? '',
              ])
          .toList(),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerLeft,
      },
    );
  }
}
