import 'package:flutter/foundation.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Demo data service to populate the app with test data for development and testing
class DemoDataService {
  final DatabaseHelper _databaseHelper;

  DemoDataService(this._databaseHelper);

  /// Initialize the app with comprehensive demo data
  Future<void> initializeDemoData() async {
    final db = await _databaseHelper.database;

    // Clear existing data
    await _clearAllData(db);

    // Insert demo data in order
    await _insertCategories(db);
    await _insertCustomers(db);
    await _insertItems(db);
    await _insertInvoices(db);
    await _insertInvoiceItems(db);
    await _insertPayments(db);
    await _insertInventoryTransactions(db);

    debugPrint('Demo data initialized successfully!');
  }

  Future<void> _clearAllData(Database db) async {
    await db.execute('DELETE FROM payment_history');
    await db.execute('DELETE FROM inventory_transactions');
    await db.execute('DELETE FROM invoice_items');
    await db.execute('DELETE FROM invoices');
    await db.execute('DELETE FROM items');
    await db.execute('DELETE FROM customers');
    await db.execute('DELETE FROM categories');
  }

  Future<void> _insertCategories(Database db) async {
    final categories = [
      {
        'name': 'Electronics',
        'description': 'Electronic items and accessories',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Appliances',
        'description': 'Home and kitchen appliances',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Hardware',
        'description': 'Tools and hardware items',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Stationery',
        'description': 'Office and school supplies',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Mobile Accessories',
        'description': 'Mobile phone accessories and covers',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _insertCustomers(Database db) async {
    final customers = [
      {
        'name': 'ABC Electronics Store',
        'email': 'abc@electronics.com',
        'phone': '9876543210',
        'address': '123 Electronics Market, Nehru Place, Delhi - 110019',
        'gstin': '07AABCA1234A1Z5',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'XYZ Hardware Shop',
        'email': 'xyz@hardware.com',
        'phone': '9876543211',
        'address': '456 Hardware Street, Crawford Market, Mumbai - 400001',
        'gstin': '27BBBCB5678B2Z6',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Modern Tech Solutions',
        'email': 'info@moderntech.com',
        'phone': '9876543212',
        'address': '789 Tech Park, Electronic City, Bangalore - 560100',
        'gstin': '29CCCDC9012C3Z7',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Global Supplies Co.',
        'email': 'global@supplies.com',
        'phone': '9876543213',
        'address': '321 Supply Chain Road, T. Nagar, Chennai - 600017',
        'gstin': '33DDDDD3456D4Z8',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Quick Mart',
        'email': 'quick@mart.com',
        'phone': '9876543214',
        'address': '654 Quick Avenue, FC Road, Pune - 411005',
        'gstin': '27EEEEE6789E5Z9',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Smart Tech Hub',
        'email': 'smart@techhub.com',
        'phone': '9876543215',
        'address': '987 Innovation Drive, Cyber City, Gurgaon - 122002',
        'gstin': '06FFFFFF0123F6Z1',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Digital Solutions Inc.',
        'email': 'contact@digitalsol.com',
        'phone': '9876543216',
        'address': '111 Tech Tower, Salt Lake, Kolkata - 700091',
        'gstin': '19GGGGG4567G7Z2',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Retail Plus',
        'email': 'info@retailplus.com',
        'phone': '9876543217',
        'address': '222 Commercial Complex, Rajapark, Jaipur - 302004',
        'gstin': '08HHHHH7890H8Z3',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final customer in customers) {
      await db.insert('customers', customer);
    }
  }

  Future<void> _insertItems(Database db) async {
    final items = [
      // Electronics Category (ID: 1)
      {
        'name': 'LED Bulb 9W',
        'description': 'Energy efficient LED bulb 9 watts, cool daylight',
        'hsn_code': '9405',
        'unit': 'pcs',
        'selling_price': 250.0,
        'purchase_price': 180.0,
        'tax_rate': 18.0,
        'stock_quantity': 45,
        'low_stock_alert': 10,
        'category_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Switch Board 2-way',
        'description': '2-way electrical switch board with indicator',
        'hsn_code': '8536',
        'unit': 'pcs',
        'selling_price': 150.0,
        'purchase_price': 100.0,
        'tax_rate': 18.0,
        'stock_quantity': 2,
        'low_stock_alert': 10,
        'category_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Extension Cord 5m',
        'description':
            '5 meter heavy duty extension cord with multiple sockets',
        'hsn_code': '8544',
        'unit': 'pcs',
        'selling_price': 350.0,
        'purchase_price': 250.0,
        'tax_rate': 18.0,
        'stock_quantity': 0,
        'low_stock_alert': 5,
        'category_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'USB Cable Type-C',
        'description': 'Fast charging USB Type-C cable 1.5m',
        'hsn_code': '8544',
        'unit': 'pcs',
        'selling_price': 299.0,
        'purchase_price': 180.0,
        'tax_rate': 18.0,
        'stock_quantity': 25,
        'low_stock_alert': 15,
        'category_id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },

      // Appliances Category (ID: 2)
      {
        'name': 'Ceiling Fan 48"',
        'description': '48 inch ceiling fan with remote control and LED light',
        'hsn_code': '8414',
        'unit': 'pcs',
        'selling_price': 2500.0,
        'purchase_price': 1800.0,
        'tax_rate': 18.0,
        'stock_quantity': 8,
        'low_stock_alert': 5,
        'category_id': 2,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Table Fan',
        'description': 'Portable table fan 16 inch with speed control',
        'hsn_code': '8414',
        'unit': 'pcs',
        'selling_price': 1200.0,
        'purchase_price': 800.0,
        'tax_rate': 18.0,
        'stock_quantity': 12,
        'low_stock_alert': 3,
        'category_id': 2,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Water Purifier',
        'description': 'RO + UV water purifier 7 stage filtration',
        'hsn_code': '8421',
        'unit': 'pcs',
        'selling_price': 8500.0,
        'purchase_price': 6200.0,
        'tax_rate': 18.0,
        'stock_quantity': 3,
        'low_stock_alert': 2,
        'category_id': 2,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },

      // Hardware Category (ID: 3)
      {
        'name': 'Screwdriver Set',
        'description': 'Complete screwdriver set with magnetic tip and case',
        'hsn_code': '8205',
        'unit': 'set',
        'selling_price': 220.0,
        'purchase_price': 150.0,
        'tax_rate': 18.0,
        'stock_quantity': 15,
        'low_stock_alert': 5,
        'category_id': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Drill Machine',
        'description': '13mm chuck drill machine with reverse function',
        'hsn_code': '8467',
        'unit': 'pcs',
        'selling_price': 1850.0,
        'purchase_price': 1300.0,
        'tax_rate': 18.0,
        'stock_quantity': 6,
        'low_stock_alert': 3,
        'category_id': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },

      // Stationery Category (ID: 4)
      {
        'name': 'Notebook A4',
        'description': 'A4 size 200 pages ruled notebook',
        'hsn_code': '4820',
        'unit': 'pcs',
        'selling_price': 65.0,
        'purchase_price': 45.0,
        'tax_rate': 12.0,
        'stock_quantity': 25,
        'low_stock_alert': 10,
        'category_id': 4,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Pen Set',
        'description': 'Set of 10 blue ballpoint pens',
        'hsn_code': '9608',
        'unit': 'set',
        'selling_price': 50.0,
        'purchase_price': 35.0,
        'tax_rate': 12.0,
        'stock_quantity': 30,
        'low_stock_alert': 15,
        'category_id': 4,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Marker Set',
        'description': 'Permanent markers assorted colors pack of 12',
        'hsn_code': '9608',
        'unit': 'set',
        'selling_price': 180.0,
        'purchase_price': 120.0,
        'tax_rate': 12.0,
        'stock_quantity': 18,
        'low_stock_alert': 8,
        'category_id': 4,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },

      // Mobile Accessories Category (ID: 5)
      {
        'name': 'Phone Case iPhone',
        'description':
            'Transparent silicone case for iPhone with camera protection',
        'hsn_code': '3926',
        'unit': 'pcs',
        'selling_price': 399.0,
        'purchase_price': 250.0,
        'tax_rate': 18.0,
        'stock_quantity': 22,
        'low_stock_alert': 10,
        'category_id': 5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Wireless Earbuds',
        'description': 'Bluetooth 5.0 wireless earbuds with charging case',
        'hsn_code': '8518',
        'unit': 'pcs',
        'selling_price': 1299.0,
        'purchase_price': 850.0,
        'tax_rate': 18.0,
        'stock_quantity': 14,
        'low_stock_alert': 5,
        'category_id': 5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in items) {
      await db.insert('items', item);
    }
  }

  Future<void> _insertInvoices(Database db) async {
    final now = DateTime.now();
    final invoices = [
      {
        'invoice_number': 'INV-2025-001',
        'customer_id': 1,
        'invoice_date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'due_date': now.add(const Duration(days: 25)).toIso8601String(),
        'subtotal': 4200.0,
        'tax_rate': 18.0,
        'tax_amount': 756.0,
        'total_amount': 4956.0,
        'payment_status': 'paid',
        'payment_method': 'upi',
        'payment_date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'paid_amount': 4956.0,
        'notes': 'Bulk order for electronics - Regular customer',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-002',
        'customer_id': 2,
        'invoice_date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'due_date': now.add(const Duration(days: 26)).toIso8601String(),
        'subtotal': 2100.0,
        'tax_rate': 18.0,
        'tax_amount': 378.0,
        'total_amount': 2478.0,
        'payment_status': 'paid',
        'payment_method': 'cash',
        'payment_date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'paid_amount': 2478.0,
        'notes': 'Hardware supplies for workshop',
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-003',
        'customer_id': 3,
        'invoice_date': now.subtract(const Duration(days: 3)).toIso8601String(),
        'due_date': now.add(const Duration(days: 27)).toIso8601String(),
        'subtotal': 2500.0,
        'tax_rate': 18.0,
        'tax_amount': 450.0,
        'total_amount': 2950.0,
        'payment_status': 'paid',
        'payment_method': 'upi',
        'payment_date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'paid_amount': 2950.0,
        'notes': 'Tech equipment for office setup',
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-004',
        'customer_id': 4,
        'invoice_date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'due_date': now.add(const Duration(days: 28)).toIso8601String(),
        'subtotal': 1800.0,
        'tax_rate': 18.0,
        'tax_amount': 324.0,
        'total_amount': 2124.0,
        'payment_status': 'pending',
        'payment_method': 'credit',
        'payment_date': null,
        'paid_amount': 0.0,
        'notes': 'Office supplies - Credit terms 30 days',
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-005',
        'customer_id': 5,
        'invoice_date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'due_date': now.add(const Duration(days: 29)).toIso8601String(),
        'subtotal': 1200.0,
        'tax_rate': 18.0,
        'tax_amount': 216.0,
        'total_amount': 1416.0,
        'payment_status': 'partial',
        'payment_method': 'cash',
        'payment_date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'paid_amount': 700.0,
        'notes': 'Quick purchase - Partial payment received',
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-006',
        'customer_id': 1,
        'invoice_date':
            now.subtract(const Duration(days: 35)).toIso8601String(),
        'due_date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'subtotal': 3600.0,
        'tax_rate': 18.0,
        'tax_amount': 648.0,
        'total_amount': 4248.0,
        'payment_status': 'overdue',
        'payment_method': 'credit',
        'payment_date': null,
        'paid_amount': 2000.0,
        'notes': 'OVERDUE - Follow up required for payment',
        'created_at': now.subtract(const Duration(days: 35)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-007',
        'customer_id': 6,
        'invoice_date': now.toIso8601String(),
        'due_date': now.add(const Duration(days: 30)).toIso8601String(),
        'subtotal': 8500.0,
        'tax_rate': 18.0,
        'tax_amount': 1530.0,
        'total_amount': 10030.0,
        'payment_status': 'paid',
        'payment_method': 'bank_transfer',
        'payment_date': now.toIso8601String(),
        'paid_amount': 10030.0,
        'notes': 'Large appliance order - Same day payment',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'invoice_number': 'INV-2025-008',
        'customer_id': 7,
        'invoice_date':
            now.subtract(const Duration(hours: 2)).toIso8601String(),
        'due_date': now.add(const Duration(days: 15)).toIso8601String(),
        'subtotal': 2598.0,
        'tax_rate': 18.0,
        'tax_amount': 467.64,
        'total_amount': 3065.64,
        'payment_status': 'pending',
        'payment_method': 'upi',
        'payment_date': null,
        'paid_amount': 0.0,
        'notes': 'Mixed electronics order - Payment due in 15 days',
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    for (final invoice in invoices) {
      await db.insert('invoices', invoice);
    }
  }

  Future<void> _insertInvoiceItems(Database db) async {
    final invoiceItems = [
      // INV-2025-001 items (Total: 4200)
      {
        'invoice_id': 1,
        'item_id': 1,
        'quantity': 10,
        'unit_price': 250.0,
        'total_price': 2500.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 2950.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 1,
        'item_id': 4,
        'quantity': 5,
        'unit_price': 299.0,
        'total_price': 1495.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 1764.1, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 1,
        'item_id': 11,
        'quantity': 4,
        'unit_price': 50.0,
        'total_price': 200.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 236.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-002 items (Total: 2100)
      {
        'invoice_id': 2,
        'item_id': 2,
        'quantity': 12,
        'unit_price': 150.0,
        'total_price': 1800.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 2124.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 2,
        'item_id': 15,
        'quantity': 2,
        'unit_price': 150.0,
        'total_price': 300.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 354.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-003 items (Total: 2500)
      {
        'invoice_id': 3,
        'item_id': 3,
        'quantity': 5,
        'unit_price': 350.0,
        'total_price': 1750.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 2065.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 3,
        'item_id': 5,
        'quantity': 3,
        'unit_price': 250.0,
        'total_price': 750.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 885.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-004 items (Total: 1040)
      {
        'invoice_id': 4,
        'item_id': 6,
        'quantity': 8,
        'unit_price': 120.0,
        'total_price': 960.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 1132.8, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 4,
        'item_id': 10,
        'quantity': 2,
        'unit_price': 40.0,
        'total_price': 80.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 94.4, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-005 items (Total: 1400)
      {
        'invoice_id': 5,
        'item_id': 7,
        'quantity': 4,
        'unit_price': 350.0,
        'total_price': 1400.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 1652.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-006 items (Total: 3500)
      {
        'invoice_id': 6,
        'item_id': 8,
        'quantity': 10,
        'unit_price': 350.0,
        'total_price': 3500.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 4130.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-007 items (Total: 720)
      {
        'invoice_id': 7,
        'item_id': 9,
        'quantity': 12,
        'unit_price': 60.0,
        'total_price': 720.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 849.6, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },

      // INV-2025-008 items (Total: 2598)
      {
        'invoice_id': 8,
        'item_id': 4,
        'quantity': 6,
        'unit_price': 299.0,
        'total_price': 1794.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 2116.92, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 8,
        'item_id': 14,
        'quantity': 2,
        'unit_price': 399.0,
        'total_price': 798.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 941.64, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'invoice_id': 8,
        'item_id': 12,
        'quantity': 1,
        'unit_price': 50.0,
        'total_price': 50.0,
        'discount_percent': 0.0,
        'tax_rate': 18.0,
        'line_total': 59.0, // total_price + tax
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in invoiceItems) {
      await db.insert('invoice_items', item);
    }
  }

  Future<void> _insertPayments(Database db) async {
    final now = DateTime.now();
    final payments = [
      {
        'invoice_id': 1,
        'payment_amount': 4956.0,
        'payment_method': 'upi',
        'payment_date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'payment_reference': 'UPI123456789',
        'notes': 'Full payment via UPI - ABC Electronics',
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'invoice_id': 2,
        'payment_amount': 2478.0,
        'payment_method': 'cash',
        'payment_date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'payment_reference': 'CASH001',
        'notes': 'Cash payment in full - XYZ Hardware',
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'invoice_id': 3,
        'payment_amount': 2950.0,
        'payment_method': 'upi',
        'payment_date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'payment_reference': 'UPI987654321',
        'notes': 'UPI payment received - Modern Tech Solutions',
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'invoice_id': 5,
        'payment_amount': 700.0,
        'payment_method': 'cash',
        'payment_date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'payment_reference': 'CASH002',
        'notes': 'Partial payment received - Quick Mart',
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'invoice_id': 6,
        'payment_amount': 2000.0,
        'payment_method': 'cash',
        'payment_date':
            now.subtract(const Duration(days: 10)).toIso8601String(),
        'payment_reference': 'CASH003',
        'notes': 'Partial payment received - ABC Electronics (OVERDUE)',
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'invoice_id': 7,
        'payment_amount': 10030.0,
        'payment_method': 'bank_transfer',
        'payment_date': now.toIso8601String(),
        'payment_reference': 'NEFT202500156',
        'notes': 'Bank transfer - Smart Tech Hub',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];

    for (final payment in payments) {
      await db.insert('payment_history', payment);
    }
  }

  Future<void> _insertInventoryTransactions(Database db) async {
    final now = DateTime.now();
    final transactions = [
      // Stock movements for recent sales
      {
        'item_id': 1,
        'transaction_type': 'sale',
        'quantity_change': -10,
        'previous_quantity': 55,
        'new_quantity': 45,
        'invoice_id': 1,
        'notes': 'Sold via INV-2025-001',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'item_id': 6,
        'transaction_type': 'sale',
        'quantity_change': -1,
        'previous_quantity': 13,
        'new_quantity': 12,
        'invoice_id': 1,
        'notes': 'Sold via INV-2025-001',
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'item_id': 8,
        'transaction_type': 'sale',
        'quantity_change': -5,
        'previous_quantity': 20,
        'new_quantity': 15,
        'invoice_id': 2,
        'notes': 'Sold via INV-2025-002',
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'item_id': 5,
        'transaction_type': 'sale',
        'quantity_change': -1,
        'previous_quantity': 9,
        'new_quantity': 8,
        'invoice_id': 3,
        'notes': 'Sold via INV-2025-003',
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      // Stock replenishment
      {
        'item_id': 1,
        'transaction_type': 'purchase',
        'quantity_change': 20,
        'previous_quantity': 35,
        'new_quantity': 55,
        'invoice_id': null,
        'notes': 'Stock replenishment - Purchase order PO-001',
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'item_id': 4,
        'transaction_type': 'purchase',
        'quantity_change': 50,
        'previous_quantity': 0,
        'new_quantity': 50,
        'invoice_id': null,
        'notes': 'New stock arrival - Purchase order PO-002',
        'created_at': now.subtract(const Duration(days: 8)).toIso8601String(),
      },
      // Adjustments
      {
        'item_id': 2,
        'transaction_type': 'adjustment',
        'quantity_change': -8,
        'previous_quantity': 10,
        'new_quantity': 2,
        'invoice_id': null,
        'notes': 'Stock adjustment - Damaged items removed',
        'created_at': now.subtract(const Duration(days: 6)).toIso8601String(),
      },
      {
        'item_id': 3,
        'transaction_type': 'adjustment',
        'quantity_change': -5,
        'previous_quantity': 5,
        'new_quantity': 0,
        'invoice_id': null,
        'notes': 'Stock out - Items transferred to other branch',
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
      },
    ];

    for (final transaction in transactions) {
      await db.insert('inventory_transactions', transaction);
    }
  }

  /// Get statistics about the demo data
  Future<Map<String, dynamic>> getDemoDataStats() async {
    final db = await _databaseHelper.database;

    final stats = <String, dynamic>{};

    // Count records in each table
    final tables = [
      'customers',
      'categories',
      'items',
      'invoices',
      'invoice_items',
      'payment_history',
      'inventory_transactions',
    ];

    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = result.first['count'];
    }

    // Calculate totals
    final totalSales = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM invoices',
    );
    stats['total_sales'] = totalSales.first['total'] ?? 0.0;

    final totalPayments = await db.rawQuery(
      'SELECT SUM(payment_amount) as total FROM payment_history',
    );
    stats['total_payments'] = totalPayments.first['total'] ?? 0.0;

    return stats;
  }
}
