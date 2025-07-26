import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/domain/usecases/invoice_usecases.dart';
import 'package:billmate/features/billing/domain/usecases/customer_usecases.dart';
import 'package:billmate/features/billing/domain/usecases/analytics_usecases.dart';
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

  final GetAllCustomersUseCase getAllCustomersUseCase;
  final GetCustomerByIdUseCase getCustomerByIdUseCase;
  final SearchCustomersUseCase searchCustomersUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  final GetBillingDashboardStatsUseCase getBillingDashboardStatsUseCase;
  final GetSalesReportUseCase getSalesReportUseCase;
  final GetPaymentReportUseCase getPaymentReportUseCase;

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
    required this.getAllCustomersUseCase,
    required this.getCustomerByIdUseCase,
    required this.searchCustomersUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.getBillingDashboardStatsUseCase,
    required this.getSalesReportUseCase,
    required this.getPaymentReportUseCase,
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
      final invoice = await createInvoiceUseCase(event.invoice);
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
      await deleteInvoiceUseCase(event.id);
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
      emit(const BillingSuccess('Customer updated successfully'));
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
}
