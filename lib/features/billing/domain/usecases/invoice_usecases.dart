import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllInvoicesUseCase {
  final BillingRepository repository;

  GetAllInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() {
    return repository.getAllInvoices();
  }
}

@injectable
class GetInvoiceByIdUseCase {
  final BillingRepository repository;

  GetInvoiceByIdUseCase(this.repository);

  Future<Invoice?> call(int id) {
    return repository.getInvoiceById(id);
  }
}

@injectable
class GetInvoiceByNumberUseCase {
  final BillingRepository repository;

  GetInvoiceByNumberUseCase(this.repository);

  Future<Invoice?> call(String invoiceNumber) {
    return repository.getInvoiceByNumber(invoiceNumber);
  }
}

@injectable
class GetInvoicesByCustomerUseCase {
  final BillingRepository repository;

  GetInvoicesByCustomerUseCase(this.repository);

  Future<List<Invoice>> call(int customerId) {
    return repository.getInvoicesByCustomer(customerId);
  }
}

@injectable
class GetInvoicesByDateRangeUseCase {
  final BillingRepository repository;

  GetInvoicesByDateRangeUseCase(this.repository);

  Future<List<Invoice>> call(DateTime start, DateTime end) {
    return repository.getInvoicesByDateRange(start, end);
  }
}

@injectable
class SearchInvoicesUseCase {
  final BillingRepository repository;

  SearchInvoicesUseCase(this.repository);

  Future<List<Invoice>> call(String query) {
    return repository.searchInvoices(query);
  }
}

@injectable
class CreateInvoiceUseCase {
  final BillingRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Invoice> call(Invoice invoice) {
    return repository.createInvoice(invoice);
  }
}

@injectable
class UpdateInvoiceUseCase {
  final BillingRepository repository;

  UpdateInvoiceUseCase(this.repository);

  Future<void> call(Invoice invoice) {
    return repository.updateInvoice(invoice);
  }
}

@injectable
class DeleteInvoiceUseCase {
  final BillingRepository repository;

  DeleteInvoiceUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteInvoice(id);
  }
}

@injectable
class UpdatePaymentStatusUseCase {
  final BillingRepository repository;

  UpdatePaymentStatusUseCase(this.repository);

  Future<void> call(int invoiceId, String status) {
    return repository.updatePaymentStatus(invoiceId, status);
  }
}

@injectable
class UpdatePartialPaymentUseCase {
  final BillingRepository repository;

  UpdatePartialPaymentUseCase(this.repository);

  Future<void> call(int invoiceId, String status, double paidAmount) {
    return repository.updatePartialPayment(invoiceId, status, paidAmount);
  }
}

@injectable
class ValidateInventoryQuantityUseCase {
  final BillingRepository repository;

  ValidateInventoryQuantityUseCase(this.repository);

  Future<bool> call(int itemId, int requestedQuantity) {
    return repository.validateInventoryQuantity(itemId, requestedQuantity);
  }
}

@injectable
class GetAvailableStockUseCase {
  final BillingRepository repository;

  GetAvailableStockUseCase(this.repository);

  Future<int> call(int itemId) {
    return repository.getAvailableStock(itemId);
  }
}
