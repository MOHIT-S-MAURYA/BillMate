import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:billmate/features/billing/domain/usecases/invoice_usecases.dart';
import 'package:billmate/features/billing/domain/usecases/customer_usecases.dart';
import 'package:billmate/features/billing/domain/usecases/analytics_usecases.dart';
import 'package:billmate/features/billing/domain/usecases/payment_history_usecases.dart';
import 'package:billmate/features/inventory/domain/usecases/inventory_management_usecases.dart';
import 'package:injectable/injectable.dart';

part 'billing_event.dart';
part 'billing_state.dart';

@injectable
class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetAllInvoicesUseCase getAllInvoicesUseCase;
  final GetInvoiceByIdUseCase getInvoiceByIdUseCase;
  final GetInvoiceByNumberUseCase getInvoiceByNumberUseCase;
  final GetInvoicesByCustomerUseCase getInvoicesByCustomerUseCase;
  final GetInvoicesByDateRangeUseCase getInvoicesByDateRangeUseCase;
  final SearchInvoicesUseCase searchInvoicesUseCase;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final UpdateInvoiceUseCase updateInvoiceUseCase;
  final DeleteInvoiceUseCase deleteInvoiceUseCase;
  final UpdatePaymentStatusUseCase updatePaymentStatusUseCase;
  final UpdatePartialPaymentUseCase updatePartialPaymentUseCase;
  final ValidateInventoryQuantityUseCase validateInventoryQuantityUseCase;
  final GetAvailableStockUseCase getAvailableStockUseCase;

  final GetAllCustomersUseCase getAllCustomersUseCase;
  final GetCustomerByIdUseCase getCustomerByIdUseCase;
  final SearchCustomersUseCase searchCustomersUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  final GetBillingDashboardStatsUseCase getBillingDashboardStatsUseCase;
  final GetSalesReportUseCase getSalesReportUseCase;
  final GetPaymentReportUseCase getPaymentReportUseCase;

  // Payment history use cases
  final CreatePaymentHistoryUseCase createPaymentHistoryUseCase;
  final GetPaymentHistoryByInvoiceUseCase getPaymentHistoryByInvoiceUseCase;
  final GetAllPaymentHistoryUseCase getAllPaymentHistoryUseCase;
  final DeletePaymentHistoryUseCase deletePaymentHistoryUseCase;

  // Inventory management use cases
  final ReduceStockForInvoiceUseCase reduceStockForInvoiceUseCase;
  final RestoreStockForCancelledInvoiceUseCase
  restoreStockForCancelledInvoiceUseCase;
  final CheckStockAvailabilityUseCase checkStockAvailabilityUseCase;

  BillingBloc({
    required this.getAllInvoicesUseCase,
    required this.getInvoiceByIdUseCase,
    required this.getInvoiceByNumberUseCase,
    required this.getInvoicesByCustomerUseCase,
    required this.getInvoicesByDateRangeUseCase,
    required this.searchInvoicesUseCase,
    required this.createInvoiceUseCase,
    required this.updateInvoiceUseCase,
    required this.deleteInvoiceUseCase,
    required this.updatePaymentStatusUseCase,
    required this.updatePartialPaymentUseCase,
    required this.validateInventoryQuantityUseCase,
    required this.getAvailableStockUseCase,
    required this.getAllCustomersUseCase,
    required this.getCustomerByIdUseCase,
    required this.searchCustomersUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.getBillingDashboardStatsUseCase,
    required this.getSalesReportUseCase,
    required this.getPaymentReportUseCase,
    required this.createPaymentHistoryUseCase,
    required this.getPaymentHistoryByInvoiceUseCase,
    required this.getAllPaymentHistoryUseCase,
    required this.deletePaymentHistoryUseCase,
    required this.reduceStockForInvoiceUseCase,
    required this.restoreStockForCancelledInvoiceUseCase,
    required this.checkStockAvailabilityUseCase,
  }) : super(BillingInitial()) {
    // Invoice events
    on<LoadAllInvoices>(_onLoadAllInvoices);
    on<LoadInvoiceById>(_onLoadInvoiceById);
    on<LoadInvoiceByNumber>(_onLoadInvoiceByNumber);
    on<LoadInvoicesByCustomer>(_onLoadInvoicesByCustomer);
    on<LoadInvoicesByDateRange>(_onLoadInvoicesByDateRange);
    on<SearchInvoices>(_onSearchInvoices);
    on<CreateInvoice>(_onCreateInvoice);
    on<UpdateInvoice>(_onUpdateInvoice);
    on<DeleteInvoice>(_onDeleteInvoice);
    on<UpdatePaymentStatus>(_onUpdatePaymentStatus);
    on<UpdatePartialPayment>(_onUpdatePartialPayment);
    on<ValidateInventory>(_onValidateInventory);
    on<GetAvailableStock>(_onGetAvailableStock);

    // Customer events
    on<LoadAllCustomers>(_onLoadAllCustomers);
    on<LoadCustomerById>(_onLoadCustomerById);
    on<SearchCustomers>(_onSearchCustomers);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);

    // Analytics events
    on<LoadBillingDashboardStats>(_onLoadBillingDashboardStats);
    on<LoadSalesReport>(_onLoadSalesReport);
    on<LoadPaymentReport>(_onLoadPaymentReport);

    // Payment history events
    on<CreatePaymentHistory>(_onCreatePaymentHistory);
    on<LoadPaymentHistoryByInvoice>(_onLoadPaymentHistoryByInvoice);
    on<LoadAllPaymentHistory>(_onLoadAllPaymentHistory);
    on<DeletePaymentHistory>(_onDeletePaymentHistory);
  }

  // Invoice event handlers
  Future<void> _onLoadAllInvoices(
    LoadAllInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoices = await getAllInvoicesUseCase();
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceById(
    LoadInvoiceById event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoice = await getInvoiceByIdUseCase(event.id);
      if (invoice != null) {
        emit(InvoiceLoaded(invoice));
      } else {
        emit(const BillingError('Invoice not found'));
      }
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceByNumber(
    LoadInvoiceByNumber event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoice = await getInvoiceByNumberUseCase(event.invoiceNumber);
      if (invoice != null) {
        emit(InvoiceLoaded(invoice));
      } else {
        emit(const BillingError('Invoice not found'));
      }
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadInvoicesByCustomer(
    LoadInvoicesByCustomer event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoices = await getInvoicesByCustomerUseCase(event.customerId);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadInvoicesByDateRange(
    LoadInvoicesByDateRange event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoices = await getInvoicesByDateRangeUseCase(
        event.start,
        event.end,
      );
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onSearchInvoices(
    SearchInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoices = await searchInvoicesUseCase(event.query);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onCreateInvoice(
    CreateInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      // First, check stock availability for all items
      final itemQuantities = <int, int>{};
      for (final item in event.invoice.items) {
        final itemId = item.itemId;
        final requiredQuantity = item.quantity.toBigInt().toInt();

        // Add to the map (handle multiple entries of same item)
        itemQuantities[itemId] =
            (itemQuantities[itemId] ?? 0) + requiredQuantity;
      }

      // Check stock availability for all items
      for (final entry in itemQuantities.entries) {
        final isAvailable = await checkStockAvailabilityUseCase(
          entry.key,
          entry.value,
        );
        if (!isAvailable) {
          emit(const BillingError('Insufficient stock for one or more items'));
          return;
        }
      }

      // Create the invoice
      final invoice = await createInvoiceUseCase(event.invoice);

      // Reduce stock for all items
      await reduceStockForInvoiceUseCase(itemQuantities, invoice.id!);

      // Create payment history record if there's an initial payment
      if (event.invoice.paidAmount != null &&
          event.invoice.paidAmount! > Decimal.zero) {
        final paymentHistory = PaymentHistory(
          invoiceId: invoice.id!,
          paymentAmount: event.invoice.paidAmount!,
          paymentMethod: event.invoice.paymentMethod,
          paymentDate: event.invoice.paymentDate ?? DateTime.now(),
          paymentReference: null, // Could be enhanced to include reference
          notes:
              event.invoice.paymentStatus == 'paid'
                  ? 'Full payment at time of purchase'
                  : 'Partial payment at time of purchase',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createPaymentHistoryUseCase(paymentHistory);
      }

      emit(InvoiceCreated(invoice));
      add(LoadAllInvoices());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      await updateInvoiceUseCase(event.invoice);
      emit(const BillingSuccess('Invoice updated successfully'));
      add(LoadAllInvoices());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onDeleteInvoice(
    DeleteInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      // Get invoice details before deleting to restore stock
      final invoice = await getInvoiceByIdUseCase(event.id);
      if (invoice != null) {
        // Prepare item quantities for stock restoration
        final itemQuantities = <int, int>{};
        for (final item in invoice.items) {
          final itemId = item.itemId;
          final quantity = item.quantity.toBigInt().toInt();
          itemQuantities[itemId] = (itemQuantities[itemId] ?? 0) + quantity;
        }

        // Delete the invoice
        await deleteInvoiceUseCase(event.id);

        // Restore stock for all items
        await restoreStockForCancelledInvoiceUseCase(itemQuantities, event.id);
      } else {
        await deleteInvoiceUseCase(event.id);
      }

      emit(const BillingSuccess('Invoice deleted successfully'));
      add(LoadAllInvoices());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatus event,
    Emitter<BillingState> emit,
  ) async {
    try {
      await updatePaymentStatusUseCase(event.invoiceId, event.status);
      emit(const BillingSuccess('Payment status updated successfully'));
      add(LoadAllInvoices());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onUpdatePartialPayment(
    UpdatePartialPayment event,
    Emitter<BillingState> emit,
  ) async {
    try {
      await updatePartialPaymentUseCase(
        event.invoiceId,
        event.status,
        event.paidAmount,
      );
      emit(const PartialPaymentUpdated('Partial payment updated successfully'));
      add(LoadAllInvoices());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onValidateInventory(
    ValidateInventory event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final isValid = await validateInventoryQuantityUseCase(
        event.itemId,
        event.requestedQuantity,
      );
      final availableStock = await getAvailableStockUseCase(event.itemId);
      emit(InventoryValidated(isValid, availableStock));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onGetAvailableStock(
    GetAvailableStock event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final stockQuantity = await getAvailableStockUseCase(event.itemId);
      emit(StockQuantityLoaded(stockQuantity));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  // Customer event handlers
  Future<void> _onLoadAllCustomers(
    LoadAllCustomers event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final customers = await getAllCustomersUseCase();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadCustomerById(
    LoadCustomerById event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final customer = await getCustomerByIdUseCase(event.id);
      if (customer != null) {
        emit(CustomerLoaded(customer));
      } else {
        emit(const BillingError('Customer not found'));
      }
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final customers = await searchCustomersUseCase(event.query);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final customer = await createCustomerUseCase(event.customer);
      emit(CustomerCreated(customer));
      add(LoadAllCustomers());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      await updateCustomerUseCase(event.customer);
      emit(CustomerUpdated(event.customer));
      add(LoadAllCustomers());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      await deleteCustomerUseCase(event.id);
      emit(const BillingSuccess('Customer deleted successfully'));
      add(LoadAllCustomers());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  // Analytics event handlers
  Future<void> _onLoadBillingDashboardStats(
    LoadBillingDashboardStats event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final stats = await getBillingDashboardStatsUseCase(
        event.start,
        event.end,
      );
      emit(BillingDashboardStatsLoaded(stats));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadSalesReport(
    LoadSalesReport event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final report = await getSalesReportUseCase(event.start, event.end);
      emit(SalesReportLoaded(report));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentReport(
    LoadPaymentReport event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final report = await getPaymentReportUseCase();
      emit(PaymentReportLoaded(report));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  // Payment history event handlers
  Future<void> _onCreatePaymentHistory(
    CreatePaymentHistory event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final createdPaymentHistory = await createPaymentHistoryUseCase(
        event.paymentHistory,
      );
      emit(PaymentHistoryCreated(createdPaymentHistory));

      // Load all payment history for this invoice to calculate total paid
      final allPayments = await getPaymentHistoryByInvoiceUseCase(
        event.paymentHistory.invoiceId,
      );

      // Calculate total paid amount
      final totalPaidAmount = allPayments.fold<Decimal>(
        Decimal.zero,
        (sum, payment) => sum + payment.paymentAmount,
      );

      // Get the current invoice to check total amount
      final invoice = await getInvoiceByIdUseCase(
        event.paymentHistory.invoiceId,
      );
      if (invoice != null) {
        // Determine payment status based on total paid vs total amount
        String newPaymentStatus;
        if (totalPaidAmount >= invoice.totalAmount) {
          newPaymentStatus = 'paid';
        } else if (totalPaidAmount > Decimal.zero) {
          newPaymentStatus = 'partial';
        } else {
          newPaymentStatus = 'pending';
        }

        // Update payment status if it has changed
        if (invoice.paymentStatus != newPaymentStatus) {
          await updatePaymentStatusUseCase(invoice.id!, newPaymentStatus);

          // Reload invoices to reflect the updated status
          add(LoadAllInvoices());
        }
      }

      add(LoadPaymentHistoryByInvoice(event.paymentHistory.invoiceId));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentHistoryByInvoice(
    LoadPaymentHistoryByInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final paymentHistory = await getPaymentHistoryByInvoiceUseCase(
        event.invoiceId,
      );
      emit(PaymentHistoryLoaded(paymentHistory));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onLoadAllPaymentHistory(
    LoadAllPaymentHistory event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final paymentHistory = await getAllPaymentHistoryUseCase();
      emit(PaymentHistoryLoaded(paymentHistory));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onDeletePaymentHistory(
    DeletePaymentHistory event,
    Emitter<BillingState> emit,
  ) async {
    try {
      await deletePaymentHistoryUseCase(event.id);
      emit(const BillingSuccess('Payment history deleted successfully'));
      add(LoadAllPaymentHistory());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }
}
