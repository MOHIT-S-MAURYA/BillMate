import 'package:billmate/features/reports/data/datasources/reports_datasource.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';

/// Mock data source for reports when no real data is available
class MockReportsDataSource implements ReportsDataSource {
  @override
  Future<Map<String, dynamic>> getSalesData(DateRange dateRange) async {
    // Simulate some delay
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'sales_stats': {
        'total_invoices': 5,
        'total_sales': '15750.00',
        'total_tax': '2837.50',
        'average_invoice_value': '3150.00',
      },
      'daily_sales': [
        {
          'date':
              DateTime.now()
                  .subtract(const Duration(days: 4))
                  .toIso8601String(),
          'invoice_count': 1,
          'total_amount': '2500.00',
          'tax_amount': '450.00',
        },
        {
          'date':
              DateTime.now()
                  .subtract(const Duration(days: 3))
                  .toIso8601String(),
          'invoice_count': 2,
          'total_amount': '4200.00',
          'tax_amount': '756.00',
        },
        {
          'date':
              DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
          'invoice_count': 1,
          'total_amount': '3150.00',
          'tax_amount': '567.00',
        },
        {
          'date':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
          'invoice_count': 1,
          'total_amount': '5900.00',
          'tax_amount': '1062.00',
        },
      ],
      'top_customers': [
        {
          'id': 1,
          'name': 'ABC Electronics Store',
          'invoice_count': 2,
          'total_amount': '8400.00',
        },
        {
          'id': 2,
          'name': 'XYZ Hardware Shop',
          'invoice_count': 2,
          'total_amount': '4650.00',
        },
        {
          'id': 3,
          'name': 'Modern Tech Solutions',
          'invoice_count': 1,
          'total_amount': '2700.00',
        },
      ],
      'payment_methods': [
        {
          'payment_method': 'cash',
          'transaction_count': 3,
          'total_amount': '8550.00',
        },
        {
          'payment_method': 'upi',
          'transaction_count': 2,
          'total_amount': '7200.00',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getInventoryData(DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'items': [
        {
          'id': 1,
          'name': 'LED Bulb 9W',
          'description': 'Energy efficient LED bulb',
          'stock_quantity': 45,
          'selling_price': '250.00',
          'purchase_price': '180.00',
          'low_stock_alert': 10,
          'category_name': 'Electronics',
        },
        {
          'id': 2,
          'name': 'Ceiling Fan',
          'description': '48 inch ceiling fan',
          'stock_quantity': 8,
          'selling_price': '2500.00',
          'purchase_price': '1800.00',
          'low_stock_alert': 5,
          'category_name': 'Appliances',
        },
        {
          'id': 3,
          'name': 'Switch Board',
          'description': '2-way switch board',
          'stock_quantity': 2,
          'selling_price': '150.00',
          'purchase_price': '100.00',
          'low_stock_alert': 10,
          'category_name': 'Electronics',
        },
        {
          'id': 4,
          'name': 'Extension Cord',
          'description': '5 meter extension cord',
          'stock_quantity': 0,
          'selling_price': '350.00',
          'purchase_price': '250.00',
          'low_stock_alert': 5,
          'category_name': 'Electronics',
        },
      ],
      'categories': [
        {
          'name': 'Electronics',
          'item_count': 3,
          'total_value': '19550.00',
          'low_stock_count': 2,
        },
        {
          'name': 'Appliances',
          'item_count': 1,
          'total_value': '20000.00',
          'low_stock_count': 0,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getPaymentData(DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'payment_stats': {
        'total_collected': '12500.00',
        'total_pending': '3250.00',
        'total_overdue': '1500.00',
        'paid_invoices': 3,
        'pending_invoices': 2,
        'overdue_invoices': 1,
      },
      'status_breakdown': [
        {'status': 'paid', 'count': 3, 'amount': '12500.00'},
        {'status': 'pending', 'count': 2, 'amount': '3250.00'},
        {'status': 'overdue', 'count': 1, 'amount': '1500.00'},
      ],
      'overdue_invoices': [
        {
          'invoice_id': 101,
          'invoice_number': 'INV-001',
          'customer_name': 'Late Payment Customer',
          'amount': '1500.00',
          'due_date':
              DateTime.now()
                  .subtract(const Duration(days: 15))
                  .toIso8601String(),
          'days_past_due': 15,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getBusinessData(DateRange dateRange) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'business_stats': {
        'total_revenue': '15750.00',
        'total_profit': '4725.00',
        'total_expenses': '11025.00',
        'total_customers': 8,
        'new_customers': 3,
        'profit_margin': 30.0,
      },
      'monthly_growth': [
        {
          'month':
              DateTime.now()
                  .subtract(const Duration(days: 60))
                  .toIso8601String(),
          'revenue': '12000.00',
          'profit': '3600.00',
          'growth_rate': 15.0,
        },
        {
          'month':
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String(),
          'revenue': '15750.00',
          'profit': '4725.00',
          'growth_rate': 31.25,
        },
      ],
      'revenue_by_category': {
        'Electronics': '8950.00',
        'Appliances': '6800.00',
      },
    };
  }

  @override
  Future<String> exportToFormat(
    Map<String, dynamic> data,
    ExportFormat format,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    switch (format) {
      case ExportFormat.json:
        return '/mock/exports/report.json';
      case ExportFormat.csv:
        return '/mock/exports/report.csv';
      case ExportFormat.pdf:
        return '/mock/exports/report.pdf';
      case ExportFormat.excel:
        return '/mock/exports/report.xlsx';
    }
  }
}
