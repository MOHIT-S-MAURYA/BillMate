import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/settings/domain/repositories/settings_repository.dart';
import 'package:billmate/core/di/injection_container.dart';

class PdfService {
  static Future<void> generateAndPrintInvoice(
    Invoice invoice, {
    String? customerName,
    String? customerEmail,
    bool showTax = true,
    bool showAddress = true,
    bool showPhone = true,
    bool showEmail = true,
    bool showGstin = true,
  }) async {
    try {
      // Get business name from settings for issuer information
      final settingsRepo = getIt<SettingsRepository>();
      final businessName = await settingsRepo.getBusinessName();
      final businessAddress = await settingsRepo.getBusinessAddress();
      final businessPhone = await settingsRepo.getBusinessPhone();
      final businessEmail = await settingsRepo.getBusinessEmail();
      final businessGstin = await settingsRepo.getBusinessGstin();

      final issuerName = businessName ?? 'BillMate';

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return [
              // Professional Header with company branding
              _buildModernHeader(
                issuerName,
                showAddress ? businessAddress : null,
                showPhone ? businessPhone : null,
                showEmail ? businessEmail : null,
                showGstin ? businessGstin : null,
              ),
              pw.SizedBox(height: 30),

              // Invoice title and details row
              _buildInvoiceTitleSection(invoice),
              pw.SizedBox(height: 25),

              // Bill to and payment info
              _buildPartyDetails(customerName, customerEmail, invoice),
              pw.SizedBox(height: 30),

              // Items table
              _buildProfessionalItemsTable(invoice, showTax: showTax),
              pw.SizedBox(height: 25),

              // Summary and notes section
              _buildSummarySection(invoice, showTax: showTax),
            ];
          },
          footer: (pw.Context context) {
            return _buildModernFooter(context);
          },
        ),
      );

      // For macOS/desktop platforms, use sharePdf which provides better support
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'Invoice_${invoice.invoiceNumber}.pdf',
        );
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      rethrow;
    }
  }

  // Modern Header with gradient and professional styling
  static pw.Widget _buildModernHeader(
    String issuerName,
    String? address,
    String? phone,
    String? email,
    String? gstin,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.blue800, PdfColors.blue900],
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company Info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  issuerName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                if (address != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    address,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                ],
                if (phone != null || email != null) pw.SizedBox(height: 5),
                if (phone != null)
                  pw.Text(
                    'Phone: $phone',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                if (email != null)
                  pw.Text(
                    'Email: $email',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                if (gstin != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'GSTIN: $gstin',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // BillMate Branding
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
            ),
            child: pw.Text(
              'BillMate',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Invoice title with number and dates
  static pw.Widget _buildInvoiceTitleSection(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              '#${invoice.invoiceNumber}',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _buildInfoRow(
              'Invoice Date',
              invoice.invoiceDate.toString().split(' ')[0],
            ),
            pw.SizedBox(height: 3),
            if (invoice.dueDate != null)
              _buildInfoRow(
                'Due Date',
                invoice.dueDate.toString().split(' ')[0],
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
        ),
      ],
    );
  }

  // Bill to and payment info section
  static pw.Widget _buildPartyDetails(
    String? customerName,
    String? customerEmail,
    Invoice invoice,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: PdfColors.grey50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  customerName ?? 'Walk-in Customer',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                if (customerEmail != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    customerEmail,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: PdfColors.grey50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT INFO',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildPaymentDetailRow(
                  'Method',
                  invoice.paymentMethod.toUpperCase(),
                ),
                pw.SizedBox(height: 4),
                _buildPaymentDetailRow(
                  'Status',
                  invoice.paymentStatus.toUpperCase(),
                  valueColor:
                      invoice.paymentStatus.toLowerCase() == 'paid'
                          ? PdfColors.green700
                          : PdfColors.orange700,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentDetailRow(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: valueColor ?? PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  // Professional items table
  static pw.Widget _buildProfessionalItemsTable(
    Invoice invoice, {
    bool showTax = true,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths:
          showTax
              ? {
                0: const pw.FlexColumnWidth(0.6), // Sr. No.
                1: const pw.FlexColumnWidth(3), // Item
                2: const pw.FlexColumnWidth(1), // Qty
                3: const pw.FlexColumnWidth(1.5), // Rate
                4: const pw.FlexColumnWidth(1.2), // Disc%
                5: const pw.FlexColumnWidth(1), // Tax%
                6: const pw.FlexColumnWidth(1.5), // Amount
              }
              : {
                0: const pw.FlexColumnWidth(0.6), // Sr. No.
                1: const pw.FlexColumnWidth(3), // Item
                2: const pw.FlexColumnWidth(1), // Qty
                3: const pw.FlexColumnWidth(1.5), // Rate
                4: const pw.FlexColumnWidth(1.5), // Disc%
                5: const pw.FlexColumnWidth(1.5), // Amount
              },
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          children: [
            _buildTableHeader('SR.\nNO.'),
            _buildTableHeader('ITEM'),
            _buildTableHeader('QTY'),
            _buildTableHeader('RATE'),
            _buildTableHeader('DISC%'),
            if (showTax) _buildTableHeader('TAX%'),
            _buildTableHeader('AMOUNT'),
          ],
        ),
        // Item Rows
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isOdd = index % 2 == 1;
          final srNo = (index + 1).toString(); // Serial number starting from 1

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isOdd ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              _buildTableData(srNo), // Sr. No.
              _buildTableData(
                item.itemName ?? 'Item ${item.itemId}',
                isLeft: true,
              ),
              _buildTableData(item.quantity.toString()),
              _buildTableData('Rs. ${item.unitPrice.toStringAsFixed(2)}'),
              _buildTableData('${item.discountPercent.toStringAsFixed(1)}%'),
              if (showTax)
                _buildTableData('${item.taxRate.toStringAsFixed(1)}%'),
              _buildTableData(
                'Rs. ${item.lineTotal.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableData(
    String text, {
    bool isLeft = false,
    bool isBold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.grey900,
        ),
        textAlign: isLeft ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
  }

  // Summary section with totals
  static pw.Widget _buildSummarySection(
    Invoice invoice, {
    bool showTax = true,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Notes section (if available)
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: PdfColors.grey50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NOTES',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  invoice.notes?.isNotEmpty == true
                      ? invoice.notes!
                      : 'Thank you for your business!',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        // Summary totals
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              children: [
                _buildSummaryRow(
                  'Subtotal',
                  'Rs. ${invoice.subtotal.toStringAsFixed(2)}',
                ),
                pw.SizedBox(height: 8),
                if (invoice.discountAmount.toDouble() > 0) ...[
                  _buildSummaryRow(
                    'Discount',
                    '-Rs. ${invoice.discountAmount.toStringAsFixed(2)}',
                    color: PdfColors.red700,
                  ),
                  pw.SizedBox(height: 8),
                ],
                if (showTax) ...[
                  _buildSummaryRow(
                    'Tax',
                    'Rs. ${invoice.taxAmount.toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 8),
                ],
                pw.Divider(thickness: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                _buildSummaryRow(
                  'TOTAL',
                  'Rs. ${invoice.totalAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    PdfColor? color,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? (isTotal ? PdfColors.blue900 : PdfColors.grey800),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTotal ? 12 : 10,
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? (isTotal ? PdfColors.blue900 : PdfColors.grey900),
          ),
        ),
      ],
    );
  }

  // Modern footer
  static pw.Widget _buildModernFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.symmetric(vertical: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by BillMate',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
