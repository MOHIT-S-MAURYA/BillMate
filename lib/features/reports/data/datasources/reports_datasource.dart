import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart'
    show ExportFormat;

/// Data source interface for reports
abstract class ReportsDataSource {
  /// Get sales data for report generation
  Future<Map<String, dynamic>> getSalesData(DateRange dateRange);

  /// Get inventory data for report generation
  Future<Map<String, dynamic>> getInventoryData(DateRange dateRange);

  /// Get payment data for report generation
  Future<Map<String, dynamic>> getPaymentData(DateRange dateRange);

  /// Get business data for report generation
  Future<Map<String, dynamic>> getBusinessData(DateRange dateRange);

  /// Export report data to string format
  Future<String> exportToFormat(Map<String, dynamic> data, ExportFormat format);
}
