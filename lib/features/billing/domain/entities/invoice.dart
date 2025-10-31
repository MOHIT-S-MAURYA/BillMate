import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    int? id,
    required String invoiceNumber,
    int? customerId,
    String? customerName, // Store customer name directly in invoice
    String? customerEmail, // Store customer email directly in invoice
    required DateTime invoiceDate,
    DateTime? dueDate,
    required Decimal subtotal,
    required Decimal taxAmount,
    required Decimal discountAmount,
    required Decimal totalAmount,
    @Default('pending') String paymentStatus,
    @Default('cash') String paymentMethod,
    DateTime? paymentDate,
    Decimal? paidAmount, // New field for partial payments
    String? notes,
    @Default(true) bool isGstInvoice,
    @Default(true)
    bool showTaxOnBill, // New field to control tax display on PDF
    String? placeOfSupply,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<InvoiceItem> items,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    int? id,
    required int invoiceId,
    required int itemId,
    required Decimal quantity,
    required Decimal unitPrice,
    required Decimal discountPercent,
    required Decimal taxRate,
    required Decimal lineTotal,
    required DateTime createdAt,
    // Navigation properties
    String? itemName,
    String? itemDescription,
    String? unit,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);
}
