import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreatePaymentHistoryUseCase {
  final BillingRepository repository;

  CreatePaymentHistoryUseCase(this.repository);

  Future<PaymentHistory> call(PaymentHistory paymentHistory) {
    return repository.createPaymentHistory(paymentHistory);
  }
}

@injectable
class GetPaymentHistoryByInvoiceUseCase {
  final BillingRepository repository;

  GetPaymentHistoryByInvoiceUseCase(this.repository);

  Future<List<PaymentHistory>> call(int invoiceId) {
    return repository.getPaymentHistoryByInvoice(invoiceId);
  }
}

@injectable
class GetAllPaymentHistoryUseCase {
  final BillingRepository repository;

  GetAllPaymentHistoryUseCase(this.repository);

  Future<List<PaymentHistory>> call() {
    return repository.getAllPaymentHistory();
  }
}

@injectable
class DeletePaymentHistoryUseCase {
  final BillingRepository repository;

  DeletePaymentHistoryUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deletePaymentHistory(id);
  }
}
