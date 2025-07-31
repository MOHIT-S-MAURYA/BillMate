import 'package:billmate/features/reports/domain/entities/report.dart';

/// Repository interface for reports functionality
abstract class ReportsRepository {
  /// Generate a sales report for the given date range
  Future<SalesReport> generateSalesReport(DateRange dateRange);

  /// Generate an inventory report for the given date range
  Future<InventoryReport> generateInventoryReport(DateRange dateRange);

  /// Generate a payment report for the given date range
  Future<PaymentReport> generatePaymentReport(DateRange dateRange);

  /// Generate a business overview report for the given date range
  Future<BusinessReport> generateBusinessReport(DateRange dateRange);

  /// Get all available report types
  Future<List<ReportType>> getAvailableReportTypes();

  /// Export a report to different formats
  Future<String> exportReport(Report report, ExportFormat format);
}

/// Export format for reports
enum ExportFormat { pdf, csv, excel, json }
