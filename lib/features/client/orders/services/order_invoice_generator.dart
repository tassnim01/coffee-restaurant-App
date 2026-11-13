import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../admin/orders/models/restaurant_order.dart';

class OrderInvoiceGenerator {
  const OrderInvoiceGenerator._();

  static Future<Uint8List> generate(RestaurantOrder order) async {
    final document = pw.Document();
    final bold = pw.Font.helveticaBold();
    final regular = pw.Font.helvetica();
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Text('ADDITION', style: pw.TextStyle(font: bold, fontSize: 22)),
          pw.SizedBox(height: 8),
          pw.Text('Commande ${order.code}'),
          pw.Text('Date : ${_dateTime(order.createdAt)}'),
          pw.SizedBox(height: 16),
          pw.Text('Client : ${order.clientName}'),
          pw.Text('Telephone : ${order.clientPhone}'),
          pw.Text('Table : ${order.tableNumber ?? '-'}'),
          pw.SizedBox(height: 24),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              bottom: pw.BorderSide(color: PdfColors.grey600),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('Article', bold: true),
                  _cell('Qte', bold: true),
                  _cell('Prix unit.', bold: true),
                  _cell('Total', bold: true),
                ],
              ),
              ...order.items.map(
                (item) => pw.TableRow(
                  children: [
                    _cell(
                      item.supplements.isEmpty
                          ? item.name
                          : '${item.name}\n+ ${item.supplements.map((s) => s.name).join(', ')}',
                    ),
                    _cell('${item.quantity}'),
                    _cell(_money(item.unitPrice + item.supplementsTotal)),
                    _cell(_money(item.lineTotal)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _totalRow('Sous-total', order.subtotal),
          if (order.vatPercent > 0) ...[
            _totalRow('TVA (${_percent(order.vatPercent)} %)', order.vat),
          ],
          pw.Divider(),
          _totalRow('TOTAL', order.total, bold: true),
          pw.SizedBox(height: 20),
          pw.Text('Paiement en especes a la caisse.'),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  static pw.Widget _totalRow(String label, double value, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              _money(value),
              style: pw.TextStyle(
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  static String _money(double value) => '${value.toStringAsFixed(3)} DT';

  static String _percent(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  static String _dateTime(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
