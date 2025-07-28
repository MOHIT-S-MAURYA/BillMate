part of 'billing_bloc.dart';

// Base state class
abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

// Initial state
class BillingInitial extends BillingState {}

// Loading state
class BillingLoading extends BillingState {}

// Success state
class BillingSuccess extends BillingState {
  final String message;

  const BillingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Error state
class BillingError extends BillingState {
  final String message;

  const BillingError(this.message);

  @override
  List<Object> get props => [message];
}

// Invoice States
class InvoicesLoaded extends BillingState {
  final List<Invoice> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object> get props => [invoices];
}

class InvoiceLoaded extends BillingState {
  final Invoice invoice;

  const InvoiceLoaded(this.invoice);

  @override
  List<Object> get props => [invoice];
}

class InvoiceCreated extends BillingState {
  final Invoice invoice;

  const InvoiceCreated(this.invoice);

  @override
  List<Object> get props => [invoice];
}

// Customer States
class CustomersLoaded extends BillingState {
  final List<Customer> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class CustomerLoaded extends BillingState {
  final Customer customer;

  const CustomerLoaded(this.customer);

  @override
  List<Object> get props => [customer];
}

class CustomerCreated extends BillingState {
  final Customer customer;

  const CustomerCreated(this.customer);

  @override
  List<Object> get props => [customer];
}

class CustomerUpdated extends BillingState {
  final Customer customer;

  const CustomerUpdated(this.customer);

  @override
  List<Object> get props => [customer];
}

// Analytics States
class BillingDashboardStatsLoaded extends BillingState {
  final Map<String, dynamic> stats;

  const BillingDashboardStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class SalesReportLoaded extends BillingState {
  final List<Map<String, dynamic>> report;

  const SalesReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class PaymentReportLoaded extends BillingState {
  final List<Map<String, dynamic>> report;

  const PaymentReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

// Inventory States
class InventoryValidated extends BillingState {
  final bool isValid;
  final int availableStock;

  const InventoryValidated(this.isValid, this.availableStock);

  @override
  List<Object> get props => [isValid, availableStock];
}

class StockQuantityLoaded extends BillingState {
  final int stockQuantity;

  const StockQuantityLoaded(this.stockQuantity);

  @override
  List<Object> get props => [stockQuantity];
}

// Payment States
class PartialPaymentUpdated extends BillingState {
  final String message;

  const PartialPaymentUpdated(this.message);

  @override
  List<Object> get props => [message];
}

// Payment History States
class PaymentHistoryCreated extends BillingState {
  final PaymentHistory paymentHistory;

  const PaymentHistoryCreated(this.paymentHistory);

  @override
  List<Object> get props => [paymentHistory];
}

class PaymentHistoryLoaded extends BillingState {
  final List<PaymentHistory> paymentHistory;

  const PaymentHistoryLoaded(this.paymentHistory);

  @override
  List<Object> get props => [paymentHistory];
}
