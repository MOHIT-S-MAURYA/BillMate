import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentAlertService {
  final BillingRepository _billingRepository;

  PaymentAlertService(this._billingRepository);

  /// Get all pending invoices that are overdue
  Future<List<Invoice>> getOverdueInvoices() async {
    final invoices = await _billingRepository.getAllInvoices();
    final now = DateTime.now();

    return invoices.where((invoice) {
      // Check if payment is pending or partial
      if (invoice.paymentStatus != 'pending' &&
          invoice.paymentStatus != 'partial') {
        return false;
      }

      // Check if due date has passed
      if (invoice.dueDate != null) {
        return invoice.dueDate!.isBefore(now);
      }

      // If no due date, consider overdue after 30 days from invoice date
      final thirtyDaysAfterInvoice = invoice.invoiceDate.add(
        const Duration(days: 30),
      );
      return thirtyDaysAfterInvoice.isBefore(now);
    }).toList();
  }

  /// Get pending invoices due within the next specified days
  Future<List<Invoice>> getInvoicesDueSoon({int daysAhead = 7}) async {
    final invoices = await _billingRepository.getAllInvoices();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));

    return invoices.where((invoice) {
      // Check if payment is pending or partial
      if (invoice.paymentStatus != 'pending' &&
          invoice.paymentStatus != 'partial') {
        return false;
      }

      // Check if due date is within the specified range
      if (invoice.dueDate != null) {
        return invoice.dueDate!.isAfter(now) &&
            invoice.dueDate!.isBefore(futureDate);
      }

      return false;
    }).toList();
  }

  /// Get all pending invoices
  Future<List<Invoice>> getPendingInvoices() async {
    final invoices = await _billingRepository.getAllInvoices();

    return invoices.where((invoice) {
      return invoice.paymentStatus == 'pending' ||
          invoice.paymentStatus == 'partial';
    }).toList();
  }

  /// Get payment statistics
  Future<PaymentStats> getPaymentStats() async {
    final invoices = await _billingRepository.getAllInvoices();
    final now = DateTime.now();

    int totalInvoices = invoices.length;
    int paidInvoices = 0;
    int pendingInvoices = 0;
    int overdueInvoices = 0;
    double totalAmount = 0;
    double paidAmount = 0;
    double pendingAmount = 0;
    double overdueAmount = 0;

    for (final invoice in invoices) {
      totalAmount += invoice.totalAmount.toDouble();

      switch (invoice.paymentStatus.toLowerCase()) {
        case 'paid':
          paidInvoices++;
          paidAmount += invoice.totalAmount.toDouble();
          break;
        case 'pending':
        case 'partial':
          pendingInvoices++;
          pendingAmount += invoice.totalAmount.toDouble();

          // Check if overdue
          bool isOverdue = false;
          if (invoice.dueDate != null) {
            isOverdue = invoice.dueDate!.isBefore(now);
          } else {
            final thirtyDaysAfterInvoice = invoice.invoiceDate.add(
              const Duration(days: 30),
            );
            isOverdue = thirtyDaysAfterInvoice.isBefore(now);
          }

          if (isOverdue) {
            overdueInvoices++;
            overdueAmount += invoice.totalAmount.toDouble();
          }
          break;
      }
    }

    return PaymentStats(
      totalInvoices: totalInvoices,
      paidInvoices: paidInvoices,
      pendingInvoices: pendingInvoices,
      overdueInvoices: overdueInvoices,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      overdueAmount: overdueAmount,
    );
  }

  /// Calculate days overdue for an invoice
  int getDaysOverdue(Invoice invoice) {
    final now = DateTime.now();

    if (invoice.paymentStatus == 'paid') {
      return 0;
    }

    DateTime overdueDate;
    if (invoice.dueDate != null) {
      overdueDate = invoice.dueDate!;
    } else {
      overdueDate = invoice.invoiceDate.add(const Duration(days: 30));
    }

    if (overdueDate.isBefore(now)) {
      return now.difference(overdueDate).inDays;
    }

    return 0;
  }

  /// Get alert message for dashboard
  Future<String?> getAlertMessage() async {
    final overdueInvoices = await getOverdueInvoices();
    final dueSoonInvoices = await getInvoicesDueSoon();

    if (overdueInvoices.isNotEmpty) {
      return '⚠️ ${overdueInvoices.length} invoice(s) are overdue!';
    }

    if (dueSoonInvoices.isNotEmpty) {
      return '📅 ${dueSoonInvoices.length} invoice(s) due within 7 days';
    }

    return null;
  }
}

class PaymentStats {
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final int overdueInvoices;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double overdueAmount;

  PaymentStats({
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.overdueAmount,
  });

  double get paidPercentage =>
      totalInvoices > 0 ? (paidInvoices / totalInvoices) * 100 : 0;
  double get pendingPercentage =>
      totalInvoices > 0 ? (pendingInvoices / totalInvoices) * 100 : 0;
  double get overduePercentage =>
      totalInvoices > 0 ? (overdueInvoices / totalInvoices) * 100 : 0;

  double get paidAmountPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;
  double get pendingAmountPercentage =>
      totalAmount > 0 ? (pendingAmount / totalAmount) * 100 : 0;
  double get overdueAmountPercentage =>
      totalAmount > 0 ? (overdueAmount / totalAmount) * 100 : 0;
}
