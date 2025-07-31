import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for generating sales reports
@injectable
class GenerateSalesReportUseCase {
  final ReportsRepository repository;

  GenerateSalesReportUseCase(this.repository);

  Future<SalesReport> call(DateRange dateRange) {
    return repository.generateSalesReport(dateRange);
  }
}

/// Use case for generating inventory reports
@injectable
class GenerateInventoryReportUseCase {
  final ReportsRepository repository;

  GenerateInventoryReportUseCase(this.repository);

  Future<InventoryReport> call(DateRange dateRange) {
    return repository.generateInventoryReport(dateRange);
  }
}

/// Use case for generating payment reports
@injectable
class GeneratePaymentReportUseCase {
  final ReportsRepository repository;

  GeneratePaymentReportUseCase(this.repository);

  Future<PaymentReport> call(DateRange dateRange) {
    return repository.generatePaymentReport(dateRange);
  }
}

/// Use case for generating business reports
@injectable
class GenerateBusinessReportUseCase {
  final ReportsRepository repository;

  GenerateBusinessReportUseCase(this.repository);

  Future<BusinessReport> call(DateRange dateRange) {
    return repository.generateBusinessReport(dateRange);
  }
}

/// Use case for getting available report types
@injectable
class GetAvailableReportTypesUseCase {
  final ReportsRepository repository;

  GetAvailableReportTypesUseCase(this.repository);

  Future<List<ReportType>> call() {
    return repository.getAvailableReportTypes();
  }
}

/// Use case for exporting reports
@injectable
class ExportReportUseCase {
  final ReportsRepository repository;

  ExportReportUseCase(this.repository);

  Future<String> call(Report report, ExportFormat format) {
    return repository.exportReport(report, format);
  }
}
