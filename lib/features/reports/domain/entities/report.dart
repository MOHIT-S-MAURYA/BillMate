import 'package:decimal/decimal.dart';

/// Base class for all report types
abstract class Report {
  final String title;
  final DateTime generatedAt;
  final ReportType type;
  final DateRange dateRange;

  const Report({
    required this.title,
    required this.generatedAt,
    required this.type,
    required this.dateRange,
  });
}

/// Enum for different report types
enum ReportType { sales, inventory, payments, customers, dashboard, business }

/// Date range for reports
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// Create a date range for today
  factory DateRange.today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateRange(
      start: today,
      end: today
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1)),
    );
  }

  /// Create a date range for this week
  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    return DateRange(
      start: startOfWeek,
      end: startOfWeek
          .add(const Duration(days: 7))
          .subtract(const Duration(milliseconds: 1)),
    );
  }

  /// Create a date range for this month
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));
    return DateRange(start: startOfMonth, end: endOfMonth);
  }

  /// Create a date range for this year
  factory DateRange.thisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(
      now.year + 1,
      1,
      1,
    ).subtract(const Duration(milliseconds: 1));
    return DateRange(start: startOfYear, end: endOfYear);
  }

  /// Create a custom date range
  factory DateRange.custom(DateTime start, DateTime end) {
    return DateRange(start: start, end: end);
  }

  /// Get a formatted string representation
  String get formatted {
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Today';
    }

    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Sales report entity
class SalesReport extends Report {
  final Decimal totalSales;
  final Decimal totalTax;
  final int totalInvoices;
  final Decimal averageInvoiceValue;
  final List<DailySales> dailySales;
  final List<TopCustomer> topCustomers;
  final Map<String, PaymentMethodStats> paymentMethods;

  const SalesReport({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required this.totalSales,
    required this.totalTax,
    required this.totalInvoices,
    required this.averageInvoiceValue,
    required this.dailySales,
    required this.topCustomers,
    required this.paymentMethods,
  }) : super(type: ReportType.sales);
}

/// Daily sales data
class DailySales {
  final DateTime date;
  final Decimal amount;
  final int invoiceCount;
  final Decimal taxAmount;

  const DailySales({
    required this.date,
    required this.amount,
    required this.invoiceCount,
    required this.taxAmount,
  });
}

/// Top customer data
class TopCustomer {
  final int customerId;
  final String customerName;
  final Decimal totalAmount;
  final int invoiceCount;

  const TopCustomer({
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.invoiceCount,
  });
}

/// Payment method statistics
class PaymentMethodStats {
  final String method;
  final Decimal totalAmount;
  final int transactionCount;
  final double percentage;

  const PaymentMethodStats({
    required this.method,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });
}

/// Inventory report entity
class InventoryReport extends Report {
  final int totalItems;
  final Decimal totalValue;
  final int lowStockItems;
  final int outOfStockItems;
  final List<TopValueItem> topValueItems;
  final List<LowStockItem> lowStockItemsList;
  final List<StockMovement> stockMovements;
  final Map<String, CategoryStats> categoryStats;

  const InventoryReport({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required this.totalItems,
    required this.totalValue,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.topValueItems,
    required this.lowStockItemsList,
    required this.stockMovements,
    required this.categoryStats,
  }) : super(type: ReportType.inventory);
}

/// Top value item data
class TopValueItem {
  final int itemId;
  final String itemName;
  final int stockQuantity;
  final Decimal unitPrice;
  final Decimal totalValue;

  const TopValueItem({
    required this.itemId,
    required this.itemName,
    required this.stockQuantity,
    required this.unitPrice,
    required this.totalValue,
  });
}

/// Low stock item data
class LowStockItem {
  final int itemId;
  final String itemName;
  final int currentStock;
  final int lowStockAlert;
  final String unit;

  const LowStockItem({
    required this.itemId,
    required this.itemName,
    required this.currentStock,
    required this.lowStockAlert,
    required this.unit,
  });
}

/// Stock movement data
class StockMovement {
  final int itemId;
  final String itemName;
  final String movementType; // 'in' or 'out'
  final int quantity;
  final DateTime date;
  final String? reason;

  const StockMovement({
    required this.itemId,
    required this.itemName,
    required this.movementType,
    required this.quantity,
    required this.date,
    this.reason,
  });
}

/// Category statistics
class CategoryStats {
  final String categoryName;
  final int itemCount;
  final Decimal totalValue;
  final int lowStockCount;

  const CategoryStats({
    required this.categoryName,
    required this.itemCount,
    required this.totalValue,
    required this.lowStockCount,
  });
}

/// Payment report entity
class PaymentReport extends Report {
  final Decimal totalCollected;
  final Decimal totalPending;
  final Decimal totalOverdue;
  final int paidInvoices;
  final int pendingInvoices;
  final int overdueInvoices;
  final double collectionRate;
  final List<PaymentStatusBreakdown> statusBreakdown;
  final List<OverdueInvoice> overdueInvoicesList;

  const PaymentReport({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required this.totalCollected,
    required this.totalPending,
    required this.totalOverdue,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.collectionRate,
    required this.statusBreakdown,
    required this.overdueInvoicesList,
  }) : super(type: ReportType.payments);
}

/// Payment status breakdown
class PaymentStatusBreakdown {
  final String status;
  final int count;
  final Decimal amount;
  final double percentage;

  const PaymentStatusBreakdown({
    required this.status,
    required this.count,
    required this.amount,
    required this.percentage,
  });
}

/// Overdue invoice data
class OverdueInvoice {
  final int invoiceId;
  final String invoiceNumber;
  final String customerName;
  final Decimal amount;
  final DateTime dueDate;
  final int daysPastDue;

  const OverdueInvoice({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.daysPastDue,
  });
}

/// Business overview report entity
class BusinessReport extends Report {
  final Decimal totalRevenue;
  final Decimal totalProfit;
  final Decimal totalExpenses;
  final int totalCustomers;
  final int newCustomers;
  final double profitMargin;
  final List<MonthlyGrowth> monthlyGrowth;
  final Map<String, Decimal> revenueByCategory;

  const BusinessReport({
    required super.title,
    required super.generatedAt,
    required super.dateRange,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalExpenses,
    required this.totalCustomers,
    required this.newCustomers,
    required this.profitMargin,
    required this.monthlyGrowth,
    required this.revenueByCategory,
  }) : super(type: ReportType.business);
}

/// Monthly growth data
class MonthlyGrowth {
  final DateTime month;
  final Decimal revenue;
  final Decimal profit;
  final double growthRate;

  const MonthlyGrowth({
    required this.month,
    required this.revenue,
    required this.profit,
    required this.growthRate,
  });
}
