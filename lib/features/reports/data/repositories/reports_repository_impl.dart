import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';
import 'package:billmate/features/reports/data/datasources/reports_datasource.dart'
    as datasource;
import 'package:billmate/features/reports/data/models/report_models.dart';
import 'package:injectable/injectable.dart';
import 'package:decimal/decimal.dart';

/// Repository implementation for reports
@injectable
class ReportsRepositoryImpl implements ReportsRepository {
  final datasource.ReportsDataSource dataSource;

  ReportsRepositoryImpl(this.dataSource);

  @override
  Future<SalesReport> generateSalesReport(DateRange dateRange) async {
    try {
      final data = await dataSource.getSalesData(dateRange);

      return SalesReportModel.fromDatabase(
        dateRange: dateRange,
        salesStats: data['sales_stats'] as Map<String, dynamic>,
        dailyData: (data['daily_sales'] as List).cast<Map<String, dynamic>>(),
        topCustomersData:
            (data['top_customers'] as List).cast<Map<String, dynamic>>(),
        paymentMethodsData:
            (data['payment_methods'] as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      throw Exception('Failed to generate sales report: $e');
    }
  }

  @override
  Future<InventoryReport> generateInventoryReport(DateRange dateRange) async {
    try {
      final data = await dataSource.getInventoryData(dateRange);

      return InventoryReportModel.fromInventoryData(
        dateRange: dateRange,
        itemsData: (data['items'] as List).cast<Map<String, dynamic>>(),
        categoriesData:
            (data['categories'] as List).cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      throw Exception('Failed to generate inventory report: $e');
    }
  }

  @override
  Future<PaymentReport> generatePaymentReport(DateRange dateRange) async {
    try {
      final data = await dataSource.getPaymentData(dateRange);

      return _buildPaymentReport(dateRange, data);
    } catch (e) {
      throw Exception('Failed to generate payment report: $e');
    }
  }

  @override
  Future<BusinessReport> generateBusinessReport(DateRange dateRange) async {
    try {
      final data = await dataSource.getBusinessData(dateRange);

      return _buildBusinessReport(dateRange, data);
    } catch (e) {
      throw Exception('Failed to generate business report: $e');
    }
  }

  @override
  Future<List<ReportType>> getAvailableReportTypes() async {
    return [
      ReportType.sales,
      ReportType.inventory,
      ReportType.payments,
      ReportType.business,
    ];
  }

  @override
  Future<String> exportReport(Report report, ExportFormat format) async {
    try {
      Map<String, dynamic> data;

      if (report is SalesReportModel) {
        data = report.toJson();
      } else if (report is InventoryReportModel) {
        data = report.toJson();
      } else {
        // For other report types, create a basic data structure
        data = {
          'title': report.title,
          'type': report.type.toString(),
          'generated_at': report.generatedAt.toIso8601String(),
          'date_range': {
            'start': report.dateRange.start.toIso8601String(),
            'end': report.dateRange.end.toIso8601String(),
          },
        };
      }

      return await dataSource.exportToFormat(data, format);
    } catch (e) {
      throw Exception('Failed to export report: $e');
    }
  }

  PaymentReport _buildPaymentReport(
    DateRange dateRange,
    Map<String, dynamic> data,
  ) {
    final paymentStatusData =
        (data['payment_status'] as List).cast<Map<String, dynamic>>();
    final overdueInvoicesData =
        (data['overdue_invoices'] as List).cast<Map<String, dynamic>>();

    var totalCollected = Decimal.zero;
    var totalPending = Decimal.zero;
    var totalOverdue = Decimal.zero;
    var paidInvoices = 0;
    var pendingInvoices = 0;
    var overdueInvoices = 0;

    final statusBreakdown = <PaymentStatusBreakdown>[];
    var totalAmount = Decimal.zero;

    // Calculate totals first
    for (final status in paymentStatusData) {
      final amount = Decimal.parse(status['total_amount']?.toString() ?? '0');
      totalAmount += amount;
    }

    // Process payment status data
    for (final status in paymentStatusData) {
      final statusName = status['payment_status'] as String? ?? 'Unknown';
      final amount = Decimal.parse(status['total_amount']?.toString() ?? '0');
      final count = status['invoice_count'] as int? ?? 0;
      final percentage =
          totalAmount > Decimal.zero
              ? (amount * Decimal.fromInt(100) / totalAmount).toDouble()
              : 0.0;

      switch (statusName) {
        case 'paid':
          totalCollected += amount;
          paidInvoices += count;
          break;
        case 'pending':
          totalPending += amount;
          pendingInvoices += count;
          break;
        case 'partial':
          totalPending += amount;
          pendingInvoices += count;
          break;
      }

      statusBreakdown.add(
        PaymentStatusBreakdownModel(
          status: statusName,
          count: count,
          amount: amount,
          percentage: percentage,
        ),
      );
    }

    // Process overdue invoices
    final overdueInvoicesList = <OverdueInvoice>[];
    for (final overdue in overdueInvoicesData) {
      final amount = Decimal.parse(overdue['total_amount']?.toString() ?? '0');
      totalOverdue += amount;
      overdueInvoices++;

      overdueInvoicesList.add(
        OverdueInvoiceModel(
          invoiceId: overdue['id'] as int? ?? 0,
          invoiceNumber: overdue['invoice_number'] as String? ?? '',
          customerName: overdue['customer_name'] as String? ?? 'Unknown',
          amount: amount,
          dueDate:
              DateTime.tryParse(overdue['due_date']?.toString() ?? '') ??
              DateTime.now(),
          daysPastDue: overdue['days_past_due'] as int? ?? 0,
        ),
      );
    }

    // Calculate collection rate
    final totalInvoiceCount = paidInvoices + pendingInvoices + overdueInvoices;
    final collectionRate =
        totalInvoiceCount > 0
            ? (paidInvoices * 100.0) / totalInvoiceCount
            : 0.0;

    return PaymentReportModel(
      title: 'Payment Report - ${dateRange.formatted}',
      generatedAt: DateTime.now(),
      dateRange: dateRange,
      totalCollected: totalCollected,
      totalPending: totalPending,
      totalOverdue: totalOverdue,
      paidInvoices: paidInvoices,
      pendingInvoices: pendingInvoices,
      overdueInvoices: overdueInvoices,
      collectionRate: collectionRate,
      statusBreakdown: statusBreakdown,
      overdueInvoicesList: overdueInvoicesList,
    );
  }

  BusinessReport _buildBusinessReport(
    DateRange dateRange,
    Map<String, dynamic> data,
  ) {
    final revenueData = data['revenue'] as Map<String, dynamic>;
    final customerStatsData = data['customer_stats'] as Map<String, dynamic>;
    final monthlyGrowthData =
        (data['monthly_growth'] as List).cast<Map<String, dynamic>>();
    final categoryRevenueData =
        (data['category_revenue'] as List).cast<Map<String, dynamic>>();

    final totalRevenue = Decimal.parse(
      revenueData['total_revenue']?.toString() ?? '0',
    );
    final totalTax = Decimal.parse(revenueData['total_tax']?.toString() ?? '0');
    final totalCustomers = customerStatsData['total_customers'] as int? ?? 0;
    final newCustomers = customerStatsData['new_customers'] as int? ?? 0;

    // For now, assume profit is revenue minus tax (simplified)
    final totalProfit = totalRevenue - totalTax;
    final totalExpenses = totalTax; // Simplified
    final profitMargin =
        totalRevenue > Decimal.zero
            ? (totalProfit * Decimal.fromInt(100) / totalRevenue).toDouble()
            : 0.0;

    // Process monthly growth
    final monthlyGrowth = <MonthlyGrowth>[];
    for (int i = 0; i < monthlyGrowthData.length; i++) {
      final monthData = monthlyGrowthData[i];
      final month = DateTime.parse(monthData['month'] as String);
      final revenue = Decimal.parse(monthData['revenue']?.toString() ?? '0');
      final profit =
          revenue * Decimal.parse('0.8'); // Simplified profit calculation

      // Calculate growth rate compared to previous month
      var growthRate = 0.0;
      if (i > 0) {
        final prevRevenue = Decimal.parse(
          monthlyGrowthData[i - 1]['revenue']?.toString() ?? '0',
        );
        if (prevRevenue > Decimal.zero) {
          growthRate =
              ((revenue - prevRevenue) * Decimal.fromInt(100) / prevRevenue)
                  .toDouble();
        }
      }

      monthlyGrowth.add(
        MonthlyGrowthModel(
          month: month,
          revenue: revenue,
          profit: profit,
          growthRate: growthRate,
        ),
      );
    }

    // Process revenue by category
    final revenueByCategory = <String, Decimal>{};
    for (final categoryData in categoryRevenueData) {
      final categoryName =
          categoryData['category_name'] as String? ?? 'Unknown';
      final revenue = Decimal.parse(categoryData['revenue']?.toString() ?? '0');
      revenueByCategory[categoryName] = revenue;
    }

    return BusinessReportModel(
      title: 'Business Report - ${dateRange.formatted}',
      generatedAt: DateTime.now(),
      dateRange: dateRange,
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      totalExpenses: totalExpenses,
      totalCustomers: totalCustomers,
      newCustomers: newCustomers,
      profitMargin: profitMargin,
      monthlyGrowth: monthlyGrowth,
      revenueByCategory: revenueByCategory,
    );
  }
}

/// Model classes for missing entities

class PaymentReportModel extends PaymentReport {
  const PaymentReportModel({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required super.totalCollected,
    required super.totalPending,
    required super.totalOverdue,
    required super.paidInvoices,
    required super.pendingInvoices,
    required super.overdueInvoices,
    required super.collectionRate,
    required super.statusBreakdown,
    required super.overdueInvoicesList,
  });
}

class PaymentStatusBreakdownModel extends PaymentStatusBreakdown {
  const PaymentStatusBreakdownModel({
    required super.status,
    required super.count,
    required super.amount,
    required super.percentage,
  });
}

class OverdueInvoiceModel extends OverdueInvoice {
  const OverdueInvoiceModel({
    required super.invoiceId,
    required super.invoiceNumber,
    required super.customerName,
    required super.amount,
    required super.dueDate,
    required super.daysPastDue,
  });
}

class BusinessReportModel extends BusinessReport {
  const BusinessReportModel({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required super.totalRevenue,
    required super.totalProfit,
    required super.totalExpenses,
    required super.totalCustomers,
    required super.newCustomers,
    required super.profitMargin,
    required super.monthlyGrowth,
    required super.revenueByCategory,
  });
}

class MonthlyGrowthModel extends MonthlyGrowth {
  const MonthlyGrowthModel({
    required super.month,
    required super.revenue,
    required super.profit,
    required super.growthRate,
  });
}
