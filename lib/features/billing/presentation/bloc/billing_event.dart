part of 'billing_bloc.dart';

// Base event class
abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

// Invoice Events
class LoadAllInvoices extends BillingEvent {}

class LoadInvoiceById extends BillingEvent {
  final int id;

  const LoadInvoiceById(this.id);

  @override
  List<Object> get props => [id];
}

class LoadInvoiceByNumber extends BillingEvent {
  final String invoiceNumber;

  const LoadInvoiceByNumber(this.invoiceNumber);

  @override
  List<Object> get props => [invoiceNumber];
}

class LoadInvoicesByCustomer extends BillingEvent {
  final int customerId;

  const LoadInvoicesByCustomer(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class LoadInvoicesByDateRange extends BillingEvent {
  final DateTime start;
  final DateTime end;

  const LoadInvoicesByDateRange(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class SearchInvoices extends BillingEvent {
  final String query;

  const SearchInvoices(this.query);

  @override
  List<Object> get props => [query];
}

class CreateInvoice extends BillingEvent {
  final Invoice invoice;

  const CreateInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class UpdateInvoice extends BillingEvent {
  final Invoice invoice;

  const UpdateInvoice(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class DeleteInvoice extends BillingEvent {
  final int id;

  const DeleteInvoice(this.id);

  @override
  List<Object> get props => [id];
}

class UpdatePaymentStatus extends BillingEvent {
  final int invoiceId;
  final String status;

  const UpdatePaymentStatus(this.invoiceId, this.status);

  @override
  List<Object> get props => [invoiceId, status];
}

class UpdatePartialPayment extends BillingEvent {
  final int invoiceId;
  final String status;
  final double paidAmount;

  const UpdatePartialPayment(this.invoiceId, this.status, this.paidAmount);

  @override
  List<Object> get props => [invoiceId, status, paidAmount];
}

class ValidateInventory extends BillingEvent {
  final int itemId;
  final int requestedQuantity;

  const ValidateInventory(this.itemId, this.requestedQuantity);

  @override
  List<Object> get props => [itemId, requestedQuantity];
}

class GetAvailableStock extends BillingEvent {
  final int itemId;

  const GetAvailableStock(this.itemId);

  @override
  List<Object> get props => [itemId];
}

// Customer Events
class LoadAllCustomers extends BillingEvent {}

class LoadCustomerById extends BillingEvent {
  final int id;

  const LoadCustomerById(this.id);

  @override
  List<Object> get props => [id];
}

class SearchCustomers extends BillingEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object> get props => [query];
}

class CreateCustomer extends BillingEvent {
  final Customer customer;

  const CreateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class UpdateCustomer extends BillingEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object> get props => [customer];
}

class DeleteCustomer extends BillingEvent {
  final int id;

  const DeleteCustomer(this.id);

  @override
  List<Object> get props => [id];
}

// Analytics Events
class LoadBillingDashboardStats extends BillingEvent {
  final DateTime start;
  final DateTime end;

  const LoadBillingDashboardStats(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class LoadSalesReport extends BillingEvent {
  final DateTime start;
  final DateTime end;

  const LoadSalesReport(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class LoadPaymentReport extends BillingEvent {}

// Payment History Events
class CreatePaymentHistory extends BillingEvent {
  final PaymentHistory paymentHistory;

  const CreatePaymentHistory(this.paymentHistory);

  @override
  List<Object> get props => [paymentHistory];
}

class LoadPaymentHistoryByInvoice extends BillingEvent {
  final int invoiceId;

  const LoadPaymentHistoryByInvoice(this.invoiceId);

  @override
  List<Object> get props => [invoiceId];
}

class LoadAllPaymentHistory extends BillingEvent {}

class DeletePaymentHistory extends BillingEvent {
  final int id;

  const DeletePaymentHistory(this.id);

  @override
  List<Object> get props => [id];
}
