import 'package:decimal/decimal.dart';

class PaymentHistory {
  final int? id;
  final int invoiceId;
  final Decimal paymentAmount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? paymentReference; // Reference number for cheque, UPI, etc.
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentHistory({
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

  PaymentHistory copyWith({
    int? id,
    int? invoiceId,
    Decimal? paymentAmount,
    String? paymentMethod,
    DateTime? paymentDate,
    String? paymentReference,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentHistory(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          invoiceId == other.invoiceId &&
          paymentAmount == other.paymentAmount &&
          paymentMethod == other.paymentMethod &&
          paymentDate == other.paymentDate &&
          paymentReference == other.paymentReference &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    paymentAmount,
    paymentMethod,
    paymentDate,
    paymentReference,
    notes,
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'PaymentHistory(id: $id, invoiceId: $invoiceId, paymentAmount: $paymentAmount, paymentMethod: $paymentMethod, paymentDate: $paymentDate, paymentReference: $paymentReference, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
