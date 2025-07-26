import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetBillingDashboardStatsUseCase {
  final BillingRepository repository;

  GetBillingDashboardStatsUseCase(this.repository);

  Future<Map<String, dynamic>> call(DateTime start, DateTime end) {
    return repository.getDashboardStats(start, end);
  }
}

@injectable
class GetSalesReportUseCase {
  final BillingRepository repository;

  GetSalesReportUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(DateTime start, DateTime end) {
    return repository.getSalesReport(start, end);
  }
}

@injectable
class GetPaymentReportUseCase {
  final BillingRepository repository;

  GetPaymentReportUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getPaymentReport();
  }
}
