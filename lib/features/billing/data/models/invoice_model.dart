import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:decimal/decimal.dart';

class InvoiceModel {
  const InvoiceModel({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.invoiceDate,
    this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.paymentStatus = 'pending',
    this.paymentMethod = 'cash',
    this.paymentDate,
    this.paidAmount,
    this.notes,
    this.isGstInvoice = true,
    this.placeOfSupply,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    // Additional fields for database operations
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerGstin,
    this.customerStateCode,
  });

  final int? id;
  final String invoiceNumber;
  final int? customerId;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final Decimal subtotal;
  final Decimal taxAmount;
  final Decimal discountAmount;
  final Decimal totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? paymentDate;
  final Decimal? paidAmount;
  final String? notes;
  final bool isGstInvoice;
  final String? placeOfSupply;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItemModel> items;
  // Database specific fields
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerGstin;
  final String? customerStateCode;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as int?,
      invoiceNumber: json['invoice_number'] as String,
      customerId: json['customer_id'] as int?,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      dueDate:
          json['due_date'] != null
              ? DateTime.parse(json['due_date'] as String)
              : null,
      subtotal: Decimal.parse(json['subtotal'].toString()),
      taxAmount: Decimal.parse(json['tax_amount'].toString()),
      discountAmount: Decimal.parse(json['discount_amount'].toString()),
      totalAmount: Decimal.parse(json['total_amount'].toString()),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentDate:
          json['payment_date'] != null
              ? DateTime.parse(json['payment_date'] as String)
              : null,
      paidAmount:
          json['paid_amount'] != null
              ? Decimal.parse(json['paid_amount'].toString())
              : null,
      notes: json['notes'] as String?,
      isGstInvoice: (json['is_gst_invoice'] as int? ?? 1) == 1,
      placeOfSupply: json['place_of_supply'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: [], // Items are loaded separately
      customerName: json['customer_name'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerGstin: json['customer_gstin'] as String?,
      customerStateCode: json['customer_state_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoice_number': invoiceNumber,
      if (customerId != null) 'customer_id': customerId,
      'invoice_date': invoiceDate.toIso8601String(),
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      'subtotal': subtotal.toString(),
      'tax_amount': taxAmount.toString(),
      'discount_amount': discountAmount.toString(),
      'total_amount': totalAmount.toString(),
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      if (paymentDate != null) 'payment_date': paymentDate!.toIso8601String(),
      if (paidAmount != null) 'paid_amount': paidAmount!.toString(),
      if (notes != null) 'notes': notes,
      'is_gst_invoice': isGstInvoice ? 1 : 0,
      if (placeOfSupply != null) 'place_of_supply': placeOfSupply,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to domain entity
  Invoice toDomain() {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      paidAmount: paidAmount,
      notes: notes,
      isGstInvoice: isGstInvoice,
      placeOfSupply: placeOfSupply,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items.map((item) => item.toDomain()).toList(),
    );
  }

  factory InvoiceModel.fromDomain(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      customerId: invoice.customerId,
      invoiceDate: invoice.invoiceDate,
      dueDate: invoice.dueDate,
      subtotal: invoice.subtotal,
      taxAmount: invoice.taxAmount,
      discountAmount: invoice.discountAmount,
      totalAmount: invoice.totalAmount,
      paymentStatus: invoice.paymentStatus,
      paymentMethod: invoice.paymentMethod,
      paymentDate: invoice.paymentDate,
      paidAmount: invoice.paidAmount,
      notes: invoice.notes,
      isGstInvoice: invoice.isGstInvoice,
      placeOfSupply: invoice.placeOfSupply,
      createdAt: invoice.createdAt,
      updatedAt: invoice.updatedAt,
      items:
          invoice.items
              .map((item) => InvoiceItemModel.fromDomain(item))
              .toList(),
    );
  }

  InvoiceModel copyWith({
    int? id,
    String? invoiceNumber,
    int? customerId,
    DateTime? invoiceDate,
    DateTime? dueDate,
    Decimal? subtotal,
    Decimal? taxAmount,
    Decimal? discountAmount,
    Decimal? totalAmount,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? paymentDate,
    Decimal? paidAmount,
    String? notes,
    bool? isGstInvoice,
    String? placeOfSupply,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItemModel>? items,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerGstin,
    String? customerStateCode,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      isGstInvoice: isGstInvoice ?? this.isGstInvoice,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerGstin: customerGstin ?? this.customerGstin,
      customerStateCode: customerStateCode ?? this.customerStateCode,
    );
  }
}

class InvoiceItemModel {
  const InvoiceItemModel({
    this.id,
    required this.invoiceId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.taxRate,
    required this.lineTotal,
    required this.createdAt,
    this.itemName,
    this.itemDescription,
    this.unit,
  });

  final int? id;
  final int invoiceId;
  final int itemId;
  final Decimal quantity;
  final Decimal unitPrice;
  final Decimal discountPercent;
  final Decimal taxRate;
  final Decimal lineTotal;
  final DateTime createdAt;
  final String? itemName;
  final String? itemDescription;
  final String? unit;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int,
      itemId: json['item_id'] as int,
      quantity: Decimal.parse(json['quantity'].toString()),
      unitPrice: Decimal.parse(json['unit_price'].toString()),
      discountPercent: Decimal.parse(json['discount_percent'].toString()),
      taxRate: Decimal.parse(json['tax_rate'].toString()),
      lineTotal: Decimal.parse(json['line_total'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      itemName: json['item_name'] as String?,
      itemDescription: json['item_description'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'quantity': quantity.toString(),
      'unit_price': unitPrice.toString(),
      'discount_percent': discountPercent.toString(),
      'tax_rate': taxRate.toString(),
      'line_total': lineTotal.toString(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert to domain entity
  InvoiceItem toDomain() {
    return InvoiceItem(
      id: id,
      invoiceId: invoiceId,
      itemId: itemId,
      quantity: quantity,
      unitPrice: unitPrice,
      discountPercent: discountPercent,
      taxRate: taxRate,
      lineTotal: lineTotal,
      createdAt: createdAt,
      itemName: itemName,
      itemDescription: itemDescription,
      unit: unit,
    );
  }

  factory InvoiceItemModel.fromDomain(InvoiceItem item) {
    return InvoiceItemModel(
      id: item.id,
      invoiceId: item.invoiceId,
      itemId: item.itemId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      discountPercent: item.discountPercent,
      taxRate: item.taxRate,
      lineTotal: item.lineTotal,
      createdAt: item.createdAt,
      itemName: item.itemName,
      itemDescription: item.itemDescription,
      unit: item.unit,
    );
  }
}
