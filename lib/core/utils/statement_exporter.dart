import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../constants/app_constants.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class StatementExporter {
  /// Generate and share PDF financial statement
  static Future<void> exportPdfStatement({
    required List<TransactionEntity> transactions,
    required AppSettings settings,
    String? title,
  }) async {
    final pdf = pw.Document();
    final currencySymbol = settings.currency.symbol;

    int totalIncome = 0;
    int totalExpense = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amountCents;
      } else {
        totalExpense += tx.amountCents;
      }
    }
    final netCashFlow = totalIncome - totalExpense;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Hisably - Financial Statement',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  DateFormatter.formatShortDate(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated via Hisably Expense Tracker',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        build: (context) => [
          // Financial Summary Box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      'Total Income',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      CurrencyFormatter.formatCents(
                        totalIncome,
                        currencySymbol: currencySymbol,
                      ),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'Total Expenses',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      CurrencyFormatter.formatCents(
                        totalExpense,
                        currencySymbol: currencySymbol,
                      ),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'Net Cash Flow',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      CurrencyFormatter.formatCents(
                        netCashFlow,
                        currencySymbol: currencySymbol,
                      ),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: netCashFlow >= 0
                            ? PdfColors.green700
                            : PdfColors.red700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Transactions Table
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Type', 'Category', 'Method', 'Amount', 'Note'],
            data: transactions.map((t) {
              final isInc = t.type == TransactionType.income;
              final amtStr =
                  '${isInc ? '+' : '-'}${CurrencyFormatter.formatCents(t.amountCents, currencySymbol: currencySymbol)}';
              return [
                DateFormatter.formatShortDate(t.date),
                t.type.nameCapitalized,
                t.category?.name ?? 'Uncategorized',
                t.paymentMethod.label,
                amtStr,
                t.note ?? '',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerLeft,
            },
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'hisably_statement_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Export transactions to Excel (.xlsx) file
  static Future<void> exportExcelStatement({
    required List<TransactionEntity> transactions,
    required AppSettings settings,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    // Header Row
    sheet.appendRow([
      TextCellValue('Transaction ID'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Payment Method'),
      TextCellValue('Amount (${settings.currency.symbol})'),
      TextCellValue('Note'),
    ]);

    for (final tx in transactions) {
      final isExpense = tx.type == TransactionType.expense;
      final amount = (isExpense ? -1 : 1) * (tx.amountCents / 100.0);

      sheet.appendRow([
        TextCellValue(tx.id),
        TextCellValue(DateFormatter.formatShortDate(tx.date)),
        TextCellValue(DateFormatter.formatTime(tx.date)),
        TextCellValue(tx.type.nameCapitalized),
        TextCellValue(tx.category?.name ?? 'Uncategorized'),
        TextCellValue(tx.paymentMethod.label),
        DoubleCellValue(amount),
        TextCellValue(tx.note ?? ''),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/hisably_statement_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(path);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Hisably Transaction History Statement (Excel)');
    }
  }
}
