import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/features/billing/data/models/invoice_model.dart';
import 'package:billmate/features/billing/data/models/customer_model.dart';
import 'package:injectable/injectable.dart';

abstract class BillingLocalDataSource {
  // Invoice operations
  Future<List<InvoiceModel>> getAllInvoices();
  Future<InvoiceModel?> getInvoiceById(int id);
  Future<InvoiceModel?> getInvoiceByNumber(String invoiceNumber);
  Future<List<InvoiceModel>> getInvoicesByCustomer(int customerId);
  Future<List<InvoiceModel>> getInvoicesByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<InvoiceModel>> searchInvoices(String query);
  Future<int> createInvoice(InvoiceModel invoice);
  Future<void> updateInvoice(InvoiceModel invoice);
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
  Future<List<CustomerModel>> getAllCustomers();
  Future<CustomerModel?> getCustomerById(int id);
  Future<List<CustomerModel>> searchCustomers(String query);
  Future<int> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(int id);

  // Analytics
  Future<Map<String, dynamic>> getDashboardStats(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getSalesReport(
    DateTime start,
    DateTime end,
  );
  Future<List<Map<String, dynamic>>> getPaymentReport();
}

@Injectable(as: BillingLocalDataSource)
class BillingLocalDataSourceImpl implements BillingLocalDataSource {
  final DatabaseHelper databaseHelper;

  BillingLocalDataSourceImpl(this.databaseHelper);

  // Invoice operations
  @override
  Future<List<InvoiceModel>> getAllInvoices() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      ORDER BY i.created_at DESC
    ''');

    final invoices = <InvoiceModel>[];
    for (final map in maps) {
      final invoice = InvoiceModel.fromJson(map);
      final itemsMap = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );
      final items =
          itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
      invoices.add(invoice.copyWith(items: items));
    }
    return invoices;
  }

  @override
  Future<InvoiceModel?> getInvoiceById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.id = ?
    ''',
      [id],
    );

    if (maps.isEmpty) return null;

    final invoice = InvoiceModel.fromJson(maps.first);
    final itemsMap = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [id],
    );
    final items =
        itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
    return invoice.copyWith(items: items);
  }

  @override
  Future<InvoiceModel?> getInvoiceByNumber(String invoiceNumber) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.invoice_number = ?
    ''',
      [invoiceNumber],
    );

    if (maps.isEmpty) return null;

    final invoice = InvoiceModel.fromJson(maps.first);
    final itemsMap = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoice.id],
    );
    final items =
        itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
    return invoice.copyWith(items: items);
  }

  @override
  Future<List<InvoiceModel>> getInvoicesByCustomer(int customerId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.customer_id = ?
      ORDER BY i.created_at DESC
    ''',
      [customerId],
    );

    final invoices = <InvoiceModel>[];
    for (final map in maps) {
      final invoice = InvoiceModel.fromJson(map);
      final itemsMap = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );
      final items =
          itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
      invoices.add(invoice.copyWith(items: items));
    }
    return invoices;
  }

  @override
  Future<List<InvoiceModel>> getInvoicesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.invoice_date BETWEEN ? AND ?
      ORDER BY i.created_at DESC
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final invoices = <InvoiceModel>[];
    for (final map in maps) {
      final invoice = InvoiceModel.fromJson(map);
      final itemsMap = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );
      final items =
          itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
      invoices.add(invoice.copyWith(items: items));
    }
    return invoices;
  }

  @override
  Future<List<InvoiceModel>> searchInvoices(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.*, c.name as customer_name, c.email as customer_email,
             c.phone as customer_phone, c.gstin as customer_gstin,
             c.state_code as customer_state_code
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.invoice_number LIKE ? OR c.name LIKE ? OR i.notes LIKE ?
      ORDER BY i.created_at DESC
    ''',
      ['%$query%', '%$query%', '%$query%'],
    );

    final invoices = <InvoiceModel>[];
    for (final map in maps) {
      final invoice = InvoiceModel.fromJson(map);
      final itemsMap = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );
      final items =
          itemsMap.map((item) => InvoiceItemModel.fromJson(item)).toList();
      invoices.add(invoice.copyWith(items: items));
    }
    return invoices;
  }

  @override
  Future<int> createInvoice(InvoiceModel invoice) async {
    final db = await databaseHelper.database;
    return await db.transaction((txn) async {
      // Insert invoice
      final invoiceId = await txn.insert('invoices', invoice.toJson());

      // Insert invoice items
      for (final item in invoice.items) {
        await txn.insert('invoice_items', {
          ...item.toJson(),
          'invoice_id': invoiceId,
        });
      }

      return invoiceId;
    });
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      // Update invoice
      await txn.update(
        'invoices',
        invoice.toJson(),
        where: 'id = ?',
        whereArgs: [invoice.id],
      );

      // Delete existing items
      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );

      // Insert updated items
      for (final item in invoice.items) {
        await txn.insert('invoice_items', {
          ...item.toJson(),
          'invoice_id': invoice.id,
        });
      }
    });
  }

  @override
  Future<void> deleteInvoice(int id) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );
      await txn.delete('invoices', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> updatePaymentStatus(int invoiceId, String status) async {
    final db = await databaseHelper.database;
    await db.update(
      'invoices',
      {
        'payment_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  @override
  Future<void> updatePartialPayment(
    int invoiceId,
    String status,
    double paidAmount,
  ) async {
    final db = await databaseHelper.database;
    await db.update(
      'invoices',
      {
        'payment_status': status,
        'paid_amount': paidAmount,
        'payment_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  @override
  Future<bool> validateInventoryQuantity(
    int itemId,
    int requestedQuantity,
  ) async {
    final availableStock = await getAvailableStock(itemId);
    return availableStock >= requestedQuantity;
  }

  @override
  Future<int> getAvailableStock(int itemId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      'items',
      columns: ['stock_quantity'],
      where: 'id = ? AND is_active = ?',
      whereArgs: [itemId, 1],
    );

    if (result.isNotEmpty) {
      return (result.first['stock_quantity'] as int?) ?? 0;
    }
    return 0;
  }

  // Customer operations
  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }

  @override
  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ? AND is_active = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return CustomerModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where:
          '(name LIKE ? OR email LIKE ? OR phone LIKE ? OR gstin LIKE ?) AND is_active = ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return CustomerModel.fromJson(maps[i]);
    });
  }

  @override
  Future<int> createCustomer(CustomerModel customer) async {
    final db = await databaseHelper.database;
    return await db.insert('customers', customer.toJson());
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await databaseHelper.database;
    await db.update(
      'customers',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<void> deleteCustomer(int id) async {
    final db = await databaseHelper.database;
    await db.update(
      'customers',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics
  @override
  Future<Map<String, dynamic>> getDashboardStats(
    DateTime start,
    DateTime end,
  ) async {
    final db = await databaseHelper.database;

    final salesResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_invoices,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COALESCE(AVG(total_amount), 0) as average_invoice_value
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final paymentResult = await db.rawQuery(
      '''
      SELECT 
        payment_status,
        COUNT(*) as count,
        COALESCE(SUM(total_amount), 0) as amount
      FROM invoices 
      WHERE invoice_date BETWEEN ? AND ?
      GROUP BY payment_status
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

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
      LIMIT 5
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    return {
      'sales_stats': salesResult.isNotEmpty ? salesResult.first : {},
      'payment_stats': paymentResult,
      'top_customers': topCustomersResult,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesReport(
    DateTime start,
    DateTime end,
  ) async {
    final db = await databaseHelper.database;
    return await db.rawQuery(
      '''
      SELECT 
        DATE(i.invoice_date) as date,
        COUNT(i.id) as invoice_count,
        COALESCE(SUM(i.subtotal), 0) as subtotal,
        COALESCE(SUM(i.tax_amount), 0) as tax_amount,
        COALESCE(SUM(i.total_amount), 0) as total_amount
      FROM invoices i
      WHERE i.invoice_date BETWEEN ? AND ?
      GROUP BY DATE(i.invoice_date)
      ORDER BY date DESC
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentReport() async {
    final db = await databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        payment_status,
        COUNT(*) as invoice_count,
        COALESCE(SUM(total_amount), 0) as total_amount
      FROM invoices
      GROUP BY payment_status
      ORDER BY total_amount DESC
    ''');
  }
}
