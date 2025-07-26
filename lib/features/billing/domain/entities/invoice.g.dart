// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: (json['id'] as num?)?.toInt(),
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: (json['customerId'] as num?)?.toInt(),
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      dueDate:
          json['dueDate'] == null
              ? null
              : DateTime.parse(json['dueDate'] as String),
      subtotal: Decimal.fromJson(json['subtotal'] as String),
      taxAmount: Decimal.fromJson(json['taxAmount'] as String),
      discountAmount: Decimal.fromJson(json['discountAmount'] as String),
      totalAmount: Decimal.fromJson(json['totalAmount'] as String),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      paymentDate:
          json['paymentDate'] == null
              ? null
              : DateTime.parse(json['paymentDate'] as String),
      paidAmount:
          json['paidAmount'] == null
              ? null
              : Decimal.fromJson(json['paidAmount'] as String),
      notes: json['notes'] as String?,
      isGstInvoice: json['isGstInvoice'] as bool? ?? true,
      placeOfSupply: json['placeOfSupply'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceNumber': instance.invoiceNumber,
      'customerId': instance.customerId,
      'invoiceDate': instance.invoiceDate.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'subtotal': instance.subtotal,
      'taxAmount': instance.taxAmount,
      'discountAmount': instance.discountAmount,
      'totalAmount': instance.totalAmount,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'paidAmount': instance.paidAmount,
      'notes': instance.notes,
      'isGstInvoice': instance.isGstInvoice,
      'placeOfSupply': instance.placeOfSupply,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'items': instance.items,
    };

_$InvoiceItemImpl _$$InvoiceItemImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceItemImpl(
      id: (json['id'] as num?)?.toInt(),
      invoiceId: (json['invoiceId'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      quantity: Decimal.fromJson(json['quantity'] as String),
      unitPrice: Decimal.fromJson(json['unitPrice'] as String),
      discountPercent: Decimal.fromJson(json['discountPercent'] as String),
      taxRate: Decimal.fromJson(json['taxRate'] as String),
      lineTotal: Decimal.fromJson(json['lineTotal'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      itemName: json['itemName'] as String?,
      itemDescription: json['itemDescription'] as String?,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$InvoiceItemImplToJson(_$InvoiceItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'itemId': instance.itemId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'discountPercent': instance.discountPercent,
      'taxRate': instance.taxRate,
      'lineTotal': instance.lineTotal,
      'createdAt': instance.createdAt.toIso8601String(),
      'itemName': instance.itemName,
      'itemDescription': instance.itemDescription,
      'unit': instance.unit,
    };
