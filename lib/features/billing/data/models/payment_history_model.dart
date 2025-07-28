import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:decimal/decimal.dart';

class PaymentHistoryModel {
  final int? id;
  final int invoiceId;
  final Decimal paymentAmount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? paymentReference;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentHistoryModel({
    this.id,
    required this.invoiceId,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentDate,
    this.paymentReference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id'] as int?,
      invoiceId: json['invoice_id'] as int,
      paymentAmount: Decimal.parse(json['payment_amount'].toString()),
      paymentMethod: json['payment_method'] as String,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentReference: json['payment_reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoice_id': invoiceId,
      'payment_amount': paymentAmount.toString(),
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'payment_reference': paymentReference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentHistory toDomain() {
    return PaymentHistory(
      id: id,
      invoiceId: invoiceId,
      paymentAmount: paymentAmount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      paymentReference: paymentReference,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PaymentHistoryModel.fromDomain(PaymentHistory paymentHistory) {
    return PaymentHistoryModel(
      id: paymentHistory.id,
      invoiceId: paymentHistory.invoiceId,
      paymentAmount: paymentHistory.paymentAmount,
      paymentMethod: paymentHistory.paymentMethod,
      paymentDate: paymentHistory.paymentDate,
      paymentReference: paymentHistory.paymentReference,
      notes: paymentHistory.notes,
      createdAt: paymentHistory.createdAt,
      updatedAt: paymentHistory.updatedAt,
    );
  }
}
