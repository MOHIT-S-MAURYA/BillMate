import 'package:billmate/features/reports/data/datasources/reports_datasource.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';

/// Local data source implementation for reports
@injectable
class ReportsLocalDataSource implements ReportsDataSource {
  final DatabaseHelper databaseHelper;

  ReportsLocalDataSource(this.databaseHelper);

  @override
  Future<Map<String, dynamic>> getSalesData(DateRange dateRange) async {
    final db = await databaseHelper.database;

    // Get sales statistics
    final salesStatsResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_invoices,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COALESCE(AVG(total_amount), 0) as average_invoice_value
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ?
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get daily sales data
    final dailySalesResult = await db.rawQuery(
      '''
      SELECT 
        DATE(invoice_date) as date,
        COUNT(*) as invoice_count,
        COALESCE(SUM(total_amount), 0) as total_amount,
        COALESCE(SUM(tax_amount), 0) as tax_amount
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ?
      GROUP BY DATE(invoice_date)
      ORDER BY date ASC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get top customers
    final topCustomersResult = await db.rawQuery(
      '''
      SELECT 
        c.id,
        c.name,
        COUNT(i.id) as invoice_count,
        COALESCE(SUM(i.total_amount), 0) as total_amount
      FROM customers c
      INNER JOIN invoices i ON c.id = i.customer_id
      WHERE i.invoice_date BETWEEN ? AND ?
      GROUP BY c.id, c.name
      ORDER BY total_amount DESC
      LIMIT 10
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get payment method statistics
    final paymentMethodsResult = await db.rawQuery(
      '''
      SELECT 
        payment_method,
        COUNT(*) as transaction_count,
        COALESCE(SUM(total_amount), 0) as total_amount
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ? AND payment_status != 'pending'
      GROUP BY payment_method
      ORDER BY total_amount DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return {
      'sales_stats': salesStatsResult.isNotEmpty ? salesStatsResult.first : {},
      'daily_sales': dailySalesResult,
      'top_customers': topCustomersResult,
      'payment_methods': paymentMethodsResult,
    };
  }

  @override
  Future<Map<String, dynamic>> getInventoryData(DateRange dateRange) async {
    final db = await databaseHelper.database;

    // Get all items data
    final itemsResult = await db.rawQuery('''
      SELECT 
        id,
        name,
        description,
        stock_quantity,
        selling_price,
        low_stock_alert,
        unit,
        category_id,
        created_at,
        updated_at
      FROM items 
      WHERE is_active = 1
      ORDER BY name ASC
    ''');

    // Get categories data
    final categoriesResult = await db.rawQuery('''
      SELECT 
        id,
        name,
        description
      FROM categories 
      WHERE is_active = 1
      ORDER BY name ASC
    ''');

    // Get stock movement history (if needed for trends)
    final stockMovementsResult = await db.rawQuery(
      '''
      SELECT 
        item_id,
        old_quantity,
        new_quantity,
        quantity_changed,
        transaction_type,
        reference_id,
        notes,
        created_at
      FROM inventory_transactions 
      WHERE created_at BETWEEN ? AND ?
      ORDER BY created_at DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return {
      'items': itemsResult,
      'categories': categoriesResult,
      'stock_movements': stockMovementsResult,
    };
  }

  @override
  Future<Map<String, dynamic>> getPaymentData(DateRange dateRange) async {
    final db = await databaseHelper.database;

    // Get payment status breakdown
    final paymentStatusResult = await db.rawQuery(
      '''
      SELECT 
        payment_status,
        COUNT(*) as invoice_count,
        COALESCE(SUM(total_amount), 0) as total_amount
      FROM invoices
      WHERE invoice_date BETWEEN ? AND ?
      GROUP BY payment_status
      ORDER BY total_amount DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get overdue invoices
    final overdueInvoicesResult = await db.rawQuery(
      '''
      SELECT 
        i.id,
        i.invoice_number,
        i.total_amount,
        i.due_date,
        c.name as customer_name,
        CASE 
          WHEN i.due_date IS NULL THEN 0
          ELSE CAST((julianday('now') - julianday(i.due_date)) AS INTEGER)
        END as days_past_due
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.payment_status IN ('pending', 'partial') 
        AND i.invoice_date BETWEEN ? AND ?
        AND (i.due_date IS NULL OR i.due_date < date('now'))
      ORDER BY days_past_due DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get payment history details
    final paymentHistoryResult = await db.rawQuery(
      '''
      SELECT 
        ph.payment_amount,
        ph.payment_method,
        ph.payment_date,
        i.invoice_number,
        c.name as customer_name
      FROM payment_history ph
      INNER JOIN invoices i ON ph.invoice_id = i.id
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE ph.payment_date BETWEEN ? AND ?
      ORDER BY ph.payment_date DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return {
      'payment_status': paymentStatusResult,
      'overdue_invoices': overdueInvoicesResult,
      'payment_history': paymentHistoryResult,
    };
  }

  @override
  Future<Map<String, dynamic>> getBusinessData(DateRange dateRange) async {
    final db = await databaseHelper.database;

    // Get revenue data
    final revenueResult = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COUNT(*) as total_transactions
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ? AND payment_status = 'paid'
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get customer statistics
    final customerStatsResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(DISTINCT id) as total_customers,
        COUNT(DISTINCT CASE WHEN created_at BETWEEN ? AND ? THEN id END) as new_customers
      FROM customers
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Get monthly growth data (last 12 months)
    final monthlyGrowthResult = await db.rawQuery('''
      SELECT 
        DATE(invoice_date, 'start of month') as month,
        COALESCE(SUM(total_amount), 0) as revenue,
        COUNT(*) as transaction_count
      FROM invoices 
      WHERE invoice_date >= date('now', '-12 months')
        AND payment_status = 'paid'
      GROUP BY DATE(invoice_date, 'start of month')
      ORDER BY month ASC
    ''');

    // Get revenue by category (approximate)
    final categoryRevenueResult = await db.rawQuery(
      '''
      SELECT 
        c.name as category_name,
        COALESCE(SUM(ii.line_total), 0) as revenue
      FROM invoice_items ii
      INNER JOIN items i ON ii.item_id = i.id
      INNER JOIN categories c ON i.category_id = c.id
      INNER JOIN invoices inv ON ii.invoice_id = inv.id
      WHERE inv.invoice_date BETWEEN ? AND ? AND inv.payment_status = 'paid'
      GROUP BY c.name
      ORDER BY revenue DESC
    ''',
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return {
      'revenue': revenueResult.isNotEmpty ? revenueResult.first : {},
      'customer_stats':
          customerStatsResult.isNotEmpty ? customerStatsResult.first : {},
      'monthly_growth': monthlyGrowthResult,
      'category_revenue': categoryRevenueResult,
    };
  }

  @override
  Future<String> exportToFormat(
    Map<String, dynamic> data,
    ExportFormat format,
  ) async {
    switch (format) {
      case ExportFormat.json:
        return _exportToJson(data);
      case ExportFormat.csv:
        return _exportToCsv(data);
      case ExportFormat.pdf:
        return _exportToPdf(data);
      case ExportFormat.excel:
        return _exportToExcel(data);
    }
  }

  String _exportToJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  String _exportToCsv(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln('Report Type,Field,Value');

    // Add data rows
    void addDataRecursively(String prefix, dynamic value) {
      if (value is Map<String, dynamic>) {
        value.forEach((key, val) {
          addDataRecursively('$prefix.$key', val);
        });
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          addDataRecursively('$prefix[$i]', value[i]);
        }
      } else {
        buffer.writeln('"$prefix","${value?.toString() ?? ''}"');
      }
    }

    data.forEach((key, value) {
      addDataRecursively(key, value);
    });

    return buffer.toString();
  }

  String _exportToPdf(Map<String, dynamic> data) {
    // For now, return a formatted text representation
    // In a real implementation, you would use a PDF library
    final buffer = StringBuffer();
    buffer.writeln('PDF REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln();

    void addDataRecursively(String prefix, dynamic value, int indent) {
      final indentStr = '  ' * indent;
      if (value is Map<String, dynamic>) {
        buffer.writeln('$indentStr$prefix:');
        value.forEach((key, val) {
          addDataRecursively(key, val, indent + 1);
        });
      } else if (value is List) {
        buffer.writeln('$indentStr$prefix:');
        for (int i = 0; i < value.length; i++) {
          addDataRecursively('Item ${i + 1}', value[i], indent + 1);
        }
      } else {
        buffer.writeln('$indentStr$prefix: ${value?.toString() ?? 'N/A'}');
      }
    }

    data.forEach((key, value) {
      addDataRecursively(key, value, 0);
      buffer.writeln();
    });

    return buffer.toString();
  }

  String _exportToExcel(Map<String, dynamic> data) {
    // For now, return CSV format (compatible with Excel)
    // In a real implementation, you would use an Excel library
    return _exportToCsv(data);
  }
}
