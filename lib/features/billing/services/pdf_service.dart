import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice(
    Invoice invoice, {
    String? customerName,
    String? customerEmail,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Invoice Info and Customer Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildInvoiceInfo(invoice)),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: _buildCustomerInfo(customerName, customerEmail),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              _buildItemsTable(invoice),
              pw.SizedBox(height: 20),

              // Summary
              _buildSummary(invoice),
              pw.SizedBox(height: 20),

              // Payment Info
              _buildPaymentInfo(invoice),

              // Footer
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BillMate',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Custom Billing Software',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.blue700),
              ),
            ],
          ),
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Invoice Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Invoice Number:', invoice.invoiceNumber),
          _buildInfoRow(
            'Invoice Date:',
            DateFormat('dd/MM/yyyy').format(invoice.invoiceDate),
          ),
          if (invoice.dueDate != null)
            _buildInfoRow(
              'Due Date:',
              DateFormat('dd/MM/yyyy').format(invoice.dueDate!),
            ),
          _buildInfoRow('Payment Status:', invoice.paymentStatus.toUpperCase()),
          _buildInfoRow('Payment Method:', invoice.paymentMethod.toUpperCase()),
          if (invoice.paymentDate != null)
            _buildInfoRow(
              'Payment Date:',
              DateFormat('dd/MM/yyyy').format(invoice.paymentDate!),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(
    String? customerName,
    String? customerEmail,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bill To',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          if (customerName != null && customerName.isNotEmpty)
            pw.Text(customerName, style: pw.TextStyle(fontSize: 12)),
          if (customerEmail != null && customerEmail.isNotEmpty)
            pw.Text(customerEmail, style: pw.TextStyle(fontSize: 12)),
          if ((customerName == null || customerName.isEmpty) &&
              (customerEmail == null || customerEmail.isEmpty))
            pw.Text(
              'Walk-in Customer',
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Item', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Rate', isHeader: true),
            _buildTableCell('Discount', isHeader: true),
            _buildTableCell('Tax', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Items
        ...invoice.items.map(
          (item) => pw.TableRow(
            children: [
              _buildTableCell(item.itemName ?? 'Item ${item.itemId}'),
              _buildTableCell(item.quantity.toString()),
              _buildTableCell('₹${item.unitPrice.toStringAsFixed(2)}'),
              _buildTableCell('${item.discountPercent.toStringAsFixed(1)}%'),
              _buildTableCell('${item.taxRate.toStringAsFixed(1)}%'),
              _buildTableCell('₹${item.lineTotal.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildSummary(Invoice invoice) {
    return pw.Row(
      children: [
        pw.Spacer(),
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _buildSummaryRow(
                'Subtotal:',
                '₹${invoice.subtotal.toStringAsFixed(2)}',
              ),
              _buildSummaryRow(
                'Tax:',
                '₹${invoice.taxAmount.toStringAsFixed(2)}',
              ),
              if (invoice.discountAmount.toDouble() > 0)
                _buildSummaryRow(
                  'Discount:',
                  '-₹${invoice.discountAmount.toStringAsFixed(2)}',
                ),
              pw.Divider(),
              _buildSummaryRow(
                'Total:',
                '₹${invoice.totalAmount.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentInfo(Invoice invoice) {
    PdfColor statusColor;
    switch (invoice.paymentStatus.toLowerCase()) {
      case 'paid':
        statusColor = PdfColors.green;
        break;
      case 'pending':
        statusColor = PdfColors.orange;
        break;
      case 'overdue':
        statusColor = PdfColors.red;
        break;
      default:
        statusColor = PdfColors.grey;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Payment Status: ${invoice.paymentStatus.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: statusColor,
            ),
          ),
          pw.Text(
            'Method: ${invoice.paymentMethod.toUpperCase()}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generated by BillMate - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
