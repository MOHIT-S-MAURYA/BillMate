import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';

abstract class BillingRepository {
  // Invoice operations
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice?> getInvoiceById(int id);
  Future<Invoice?> getInvoiceByNumber(String invoiceNumber);
  Future<List<Invoice>> getInvoicesByCustomer(int customerId);
  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end);
  Future<List<Invoice>> searchInvoices(String query);
  Future<Invoice> createInvoice(Invoice invoice);
  Future<void> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(int id);
  Future<void> updatePaymentStatus(int invoiceId, String status);
  Future<void> updatePartialPayment(
    int invoiceId,
    String status,
    double paidAmount,
  );
  Future<bool> validateInventoryQuantity(int itemId, int requestedQuantity);
  Future<int> getAvailableStock(int itemId);

  // Customer operations
  Future<List<Customer>> getAllCustomers();
  Future<Customer?> getCustomerById(int id);
  Future<List<Customer>> searchCustomers(String query);
  Future<Customer> createCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int id);

  // Analytics
  Future<Map<String, dynamic>> getDashboardStats(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getSalesReport(
    DateTime start,
    DateTime end,
  );
  Future<List<Map<String, dynamic>>> getPaymentReport();
}
