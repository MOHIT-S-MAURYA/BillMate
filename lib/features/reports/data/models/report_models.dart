import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:decimal/decimal.dart';

/// Model class for sales report data
class SalesReportModel extends SalesReport {
  const SalesReportModel({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required super.totalSales,
    required super.totalTax,
    required super.totalInvoices,
    required super.averageInvoiceValue,
    required super.dailySales,
    required super.topCustomers,
    required super.paymentMethods,
  });

  /// Create from raw database data
  factory SalesReportModel.fromDatabase({
    required DateRange dateRange,
    required Map<String, dynamic> salesStats,
    required List<Map<String, dynamic>> dailyData,
    required List<Map<String, dynamic>> topCustomersData,
    required List<Map<String, dynamic>> paymentMethodsData,
  }) {
    final totalSales = Decimal.parse(
      salesStats['total_sales']?.toString() ?? '0',
    );
    final totalTax = Decimal.parse(salesStats['total_tax']?.toString() ?? '0');
    final totalInvoices = salesStats['total_invoices'] as int? ?? 0;
    final averageInvoiceValue =
        totalInvoices > 0
            ? (totalSales / Decimal.fromInt(totalInvoices)) as Decimal
            : Decimal.zero;

    // Convert daily data
    final dailySales =
        dailyData.map((data) => DailySalesModel.fromDatabase(data)).toList();

    // Convert top customers
    final topCustomers =
        topCustomersData
            .map((data) => TopCustomerModel.fromDatabase(data))
            .toList();

    // Convert payment methods
    final paymentMethods = <String, PaymentMethodStats>{};
    for (final data in paymentMethodsData) {
      final method = data['payment_method'] as String? ?? 'Unknown';
      final amount = Decimal.parse(data['total_amount']?.toString() ?? '0');
      final count = data['transaction_count'] as int? ?? 0;
      final percentage =
          totalSales > Decimal.zero
              ? (amount * Decimal.fromInt(100) / totalSales).toDouble()
              : 0.0;

      paymentMethods[method] = PaymentMethodStatsModel(
        method: method,
        totalAmount: amount,
        transactionCount: count,
        percentage: percentage,
      );
    }

    return SalesReportModel(
      title: 'Sales Report - ${dateRange.formatted}',
      generatedAt: DateTime.now(),
      dateRange: dateRange,
      totalSales: totalSales,
      totalTax: totalTax,
      totalInvoices: totalInvoices,
      averageInvoiceValue: averageInvoiceValue,
      dailySales: dailySales,
      topCustomers: topCustomers,
      paymentMethods: paymentMethods,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'generated_at': generatedAt.toIso8601String(),
      'date_range': {
        'start': dateRange.start.toIso8601String(),
        'end': dateRange.end.toIso8601String(),
      },
      'total_sales': totalSales.toString(),
      'total_tax': totalTax.toString(),
      'total_invoices': totalInvoices,
      'average_invoice_value': averageInvoiceValue.toString(),
      'daily_sales':
          dailySales.map((d) => (d as DailySalesModel).toJson()).toList(),
      'top_customers':
          topCustomers.map((c) => (c as TopCustomerModel).toJson()).toList(),
      'payment_methods': paymentMethods.map(
        (k, v) => MapEntry(k, (v as PaymentMethodStatsModel).toJson()),
      ),
    };
  }
}

/// Model class for daily sales data
class DailySalesModel extends DailySales {
  const DailySalesModel({
    required super.date,
    required super.amount,
    required super.invoiceCount,
    required super.taxAmount,
  });

  factory DailySalesModel.fromDatabase(Map<String, dynamic> data) {
    return DailySalesModel(
      date: DateTime.parse(data['date'] as String),
      amount: Decimal.parse(data['total_amount']?.toString() ?? '0'),
      invoiceCount: data['invoice_count'] as int? ?? 0,
      taxAmount: Decimal.parse(data['tax_amount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount.toString(),
      'invoice_count': invoiceCount,
      'tax_amount': taxAmount.toString(),
    };
  }
}

/// Model class for top customer data
class TopCustomerModel extends TopCustomer {
  const TopCustomerModel({
    required super.customerId,
    required super.customerName,
    required super.totalAmount,
    required super.invoiceCount,
  });

  factory TopCustomerModel.fromDatabase(Map<String, dynamic> data) {
    return TopCustomerModel(
      customerId: data['id'] as int? ?? 0,
      customerName: data['name'] as String? ?? 'Unknown',
      totalAmount: Decimal.parse(data['total_amount']?.toString() ?? '0'),
      invoiceCount: data['invoice_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount.toString(),
      'invoice_count': invoiceCount,
    };
  }
}

/// Model class for payment method statistics
class PaymentMethodStatsModel extends PaymentMethodStats {
  const PaymentMethodStatsModel({
    required super.method,
    required super.totalAmount,
    required super.transactionCount,
    required super.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'total_amount': totalAmount.toString(),
      'transaction_count': transactionCount,
      'percentage': percentage,
    };
  }
}

/// Model class for inventory report data
class InventoryReportModel extends InventoryReport {
  const InventoryReportModel({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required super.totalItems,
    required super.totalValue,
    required super.lowStockItems,
    required super.outOfStockItems,
    required super.topValueItems,
    required super.lowStockItemsList,
    required super.stockMovements,
    required super.categoryStats,
  });

  /// Create from inventory data
  factory InventoryReportModel.fromInventoryData({
    required DateRange dateRange,
    required List<Map<String, dynamic>> itemsData,
    required List<Map<String, dynamic>> categoriesData,
  }) {
    var totalValue = Decimal.zero;
    var lowStockCount = 0;
    var outOfStockCount = 0;
    final topValueItemsList = <TopValueItemModel>[];
    final lowStockItemsList = <LowStockItemModel>[];

    // Process items data
    for (final itemData in itemsData) {
      final stockQuantity = itemData['stock_quantity'] as int? ?? 0;
      final sellingPrice = Decimal.parse(
        itemData['selling_price']?.toString() ?? '0',
      );
      final lowStockAlert = itemData['low_stock_alert'] as int? ?? 0;
      final itemValue = sellingPrice * Decimal.fromInt(stockQuantity);

      totalValue += itemValue;

      if (stockQuantity <= 0) {
        outOfStockCount++;
      } else if (stockQuantity <= lowStockAlert) {
        lowStockCount++;
        lowStockItemsList.add(LowStockItemModel.fromDatabase(itemData));
      }

      // Add to top value items list
      topValueItemsList.add(TopValueItemModel.fromDatabase(itemData));
    }

    // Sort top value items by total value
    topValueItemsList.sort((a, b) => b.totalValue.compareTo(a.totalValue));

    // Process category stats
    final categoryStatsMap = <String, CategoryStats>{};
    for (final categoryData in categoriesData) {
      final categoryName = categoryData['name'] as String? ?? 'Unknown';
      final categoryId = categoryData['id'] as int?;

      // Count items and calculate stats for this category
      var itemCount = 0;
      var categoryValue = Decimal.zero;
      var categoryLowStockCount = 0;

      for (final itemData in itemsData) {
        if (itemData['category_id'] == categoryId) {
          itemCount++;
          final stockQuantity = itemData['stock_quantity'] as int? ?? 0;
          final sellingPrice = Decimal.parse(
            itemData['selling_price']?.toString() ?? '0',
          );
          final lowStockAlert = itemData['low_stock_alert'] as int? ?? 0;

          categoryValue += sellingPrice * Decimal.fromInt(stockQuantity);

          if (stockQuantity > 0 && stockQuantity <= lowStockAlert) {
            categoryLowStockCount++;
          }
        }
      }

      if (itemCount > 0) {
        categoryStatsMap[categoryName] = CategoryStatsModel(
          categoryName: categoryName,
          itemCount: itemCount,
          totalValue: categoryValue,
          lowStockCount: categoryLowStockCount,
        );
      }
    }

    return InventoryReportModel(
      title: 'Inventory Report - ${dateRange.formatted}',
      generatedAt: DateTime.now(),
      dateRange: dateRange,
      totalItems: itemsData.length,
      totalValue: totalValue,
      lowStockItems: lowStockCount,
      outOfStockItems: outOfStockCount,
      topValueItems: topValueItemsList.take(10).toList(),
      lowStockItemsList: lowStockItemsList,
      stockMovements:
          [], // Note: Stock movements would require separate tracking system
      categoryStats: categoryStatsMap,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'generated_at': generatedAt.toIso8601String(),
      'date_range': {
        'start': dateRange.start.toIso8601String(),
        'end': dateRange.end.toIso8601String(),
      },
      'total_items': totalItems,
      'total_value': totalValue.toString(),
      'low_stock_items': lowStockItems,
      'out_of_stock_items': outOfStockItems,
      'top_value_items':
          topValueItems.map((i) => (i as TopValueItemModel).toJson()).toList(),
      'low_stock_items_list':
          lowStockItemsList
              .map((i) => (i as LowStockItemModel).toJson())
              .toList(),
      'category_stats': categoryStats.map(
        (k, v) => MapEntry(k, (v as CategoryStatsModel).toJson()),
      ),
    };
  }
}

/// Model class for top value item data
class TopValueItemModel extends TopValueItem {
  const TopValueItemModel({
    required super.itemId,
    required super.itemName,
    required super.stockQuantity,
    required super.unitPrice,
    required super.totalValue,
  });

  factory TopValueItemModel.fromDatabase(Map<String, dynamic> data) {
    final stockQuantity = data['stock_quantity'] as int? ?? 0;
    final unitPrice = Decimal.parse(data['selling_price']?.toString() ?? '0');

    return TopValueItemModel(
      itemId: data['id'] as int? ?? 0,
      itemName: data['name'] as String? ?? 'Unknown',
      stockQuantity: stockQuantity,
      unitPrice: unitPrice,
      totalValue: unitPrice * Decimal.fromInt(stockQuantity),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'stock_quantity': stockQuantity,
      'unit_price': unitPrice.toString(),
      'total_value': totalValue.toString(),
    };
  }
}

/// Model class for low stock item data
class LowStockItemModel extends LowStockItem {
  const LowStockItemModel({
    required super.itemId,
    required super.itemName,
    required super.currentStock,
    required super.lowStockAlert,
    required super.unit,
  });

  factory LowStockItemModel.fromDatabase(Map<String, dynamic> data) {
    return LowStockItemModel(
      itemId: data['id'] as int? ?? 0,
      itemName: data['name'] as String? ?? 'Unknown',
      currentStock: data['stock_quantity'] as int? ?? 0,
      lowStockAlert: data['low_stock_alert'] as int? ?? 0,
      unit: data['unit'] as String? ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'current_stock': currentStock,
      'low_stock_alert': lowStockAlert,
      'unit': unit,
    };
  }
}

/// Model class for category statistics
class CategoryStatsModel extends CategoryStats {
  const CategoryStatsModel({
    required super.categoryName,
    required super.itemCount,
    required super.totalValue,
    required super.lowStockCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'item_count': itemCount,
      'total_value': totalValue.toString(),
      'low_stock_count': lowStockCount,
    };
  }
}
