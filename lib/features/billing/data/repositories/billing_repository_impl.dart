import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:billmate/features/billing/data/datasources/billing_local_datasource.dart';
import 'package:billmate/features/billing/data/models/invoice_model.dart';
import 'package:billmate/features/billing/data/models/customer_model.dart';
import 'package:billmate/features/billing/data/models/payment_history_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BillingRepository)
class BillingRepositoryImpl implements BillingRepository {
  final BillingLocalDataSource localDataSource;

  BillingRepositoryImpl(this.localDataSource);

  // Invoice operations
  @override
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final invoiceModels = await localDataSource.getAllInvoices();
      return invoiceModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }

  @override
  Future<Invoice?> getInvoiceById(int id) async {
    try {
      final invoiceModel = await localDataSource.getInvoiceById(id);
      return invoiceModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get invoice by id: $e');
    }
  }

  @override
  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) async {
    try {
      final invoiceModel = await localDataSource.getInvoiceByNumber(
        invoiceNumber,
      );
      return invoiceModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get invoice by number: $e');
    }
  }

  @override
  Future<List<Invoice>> getInvoicesByCustomer(int customerId) async {
    try {
      final invoiceModels = await localDataSource.getInvoicesByCustomer(
        customerId,
      );
      return invoiceModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by customer: $e');
    }
  }

  @override
  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final invoiceModels = await localDataSource.getInvoicesByDateRange(
        start,
        end,
      );
      return invoiceModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get invoices by date range: $e');
    }
  }

  @override
  Future<List<Invoice>> searchInvoices(String query) async {
    try {
      final invoiceModels = await localDataSource.searchInvoices(query);
      return invoiceModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to search invoices: $e');
    }
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final invoiceModel = InvoiceModel.fromDomain(invoice);
      final id = await localDataSource.createInvoice(invoiceModel);
      final createdInvoice = await localDataSource.getInvoiceById(id);
      if (createdInvoice == null) {
        throw Exception('Failed to retrieve created invoice');
      }
      return createdInvoice.toDomain();
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    try {
      final invoiceModel = InvoiceModel.fromDomain(invoice);
      await localDataSource.updateInvoice(invoiceModel);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  @override
  Future<void> deleteInvoice(int id) async {
    try {
      await localDataSource.deleteInvoice(id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  @override
  Future<void> updatePaymentStatus(int invoiceId, String status) async {
    try {
      await localDataSource.updatePaymentStatus(invoiceId, status);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> updatePartialPayment(
    int invoiceId,
    String status,
    double paidAmount,
  ) async {
    try {
      await localDataSource.updatePartialPayment(invoiceId, status, paidAmount);
    } catch (e) {
      throw Exception('Failed to update partial payment: $e');
    }
  }

  @override
  Future<bool> validateInventoryQuantity(
    int itemId,
    int requestedQuantity,
  ) async {
    try {
      return await localDataSource.validateInventoryQuantity(
        itemId,
        requestedQuantity,
      );
    } catch (e) {
      throw Exception('Failed to validate inventory quantity: $e');
    }
  }

  @override
  Future<int> getAvailableStock(int itemId) async {
    try {
      return await localDataSource.getAvailableStock(itemId);
    } catch (e) {
      throw Exception('Failed to get available stock: $e');
    }
  }

  // Customer operations
  @override
  Future<List<Customer>> getAllCustomers() async {
    try {
      final customerModels = await localDataSource.getAllCustomers();
      return customerModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get customers: $e');
    }
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    try {
      final customerModel = await localDataSource.getCustomerById(id);
      return customerModel?.toDomain();
    } catch (e) {
      throw Exception('Failed to get customer by id: $e');
    }
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final customerModels = await localDataSource.searchCustomers(query);
      return customerModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromDomain(customer);
      final id = await localDataSource.createCustomer(customerModel);
      final createdCustomer = await localDataSource.getCustomerById(id);
      if (createdCustomer == null) {
        throw Exception('Failed to retrieve created customer');
      }
      return createdCustomer.toDomain();
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromDomain(customer);
      await localDataSource.updateCustomer(customerModel);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    try {
      await localDataSource.deleteCustomer(id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Analytics
  @override
  Future<Map<String, dynamic>> getDashboardStats(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await localDataSource.getDashboardStats(start, end);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesReport(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await localDataSource.getSalesReport(start, end);
    } catch (e) {
      throw Exception('Failed to get sales report: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentReport() async {
    try {
      return await localDataSource.getPaymentReport();
    } catch (e) {
      throw Exception('Failed to get payment report: $e');
    }
  }

  // Payment history operations
  @override
  Future<PaymentHistory> createPaymentHistory(
    PaymentHistory paymentHistory,
  ) async {
    try {
      final paymentHistoryModel = PaymentHistoryModel.fromDomain(
        paymentHistory,
      );
      final id = await localDataSource.createPaymentHistory(
        paymentHistoryModel,
      );
      return paymentHistory.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create payment history: $e');
    }
  }

  @override
  Future<List<PaymentHistory>> getPaymentHistoryByInvoice(int invoiceId) async {
    try {
      final paymentHistoryModels = await localDataSource
          .getPaymentHistoryByInvoice(invoiceId);
      return paymentHistoryModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get payment history by invoice: $e');
    }
  }

  @override
  Future<List<PaymentHistory>> getAllPaymentHistory() async {
    try {
      final paymentHistoryModels = await localDataSource.getAllPaymentHistory();
      return paymentHistoryModels.map((model) => model.toDomain()).toList();
    } catch (e) {
      throw Exception('Failed to get all payment history: $e');
    }
  }

  @override
  Future<void> deletePaymentHistory(int id) async {
    try {
      await localDataSource.deletePaymentHistory(id);
    } catch (e) {
      throw Exception('Failed to delete payment history: $e');
    }
  }
}
