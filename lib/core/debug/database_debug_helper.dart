import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class DatabaseDebugHelper {
  static Future<void> printDatabaseStatus() async {
    try {
      final db = await DatabaseHelper().database;

      // Check how many items are in the database
      final itemCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM items WHERE is_active = 1',
      );
      final count = itemCount.first['count'] as int;

      debugPrint('📊 Items in database: $count');

      if (count == 0) {
        debugPrint('⚠️ No items found! Database is empty.');
        debugPrint('🔧 Consider adding sample items.');
      } else {
        // Get all items
        final items = await db.query(
          'items',
          where: 'is_active = ?',
          whereArgs: [1],
        );
        debugPrint('📦 Items found:');
        for (final item in items) {
          debugPrint(
            '  - ${item['name']} (ID: ${item['id']}, Stock: ${item['stock_quantity']})',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Database error: $e');
    }
  }

  static Future<void> addSampleItems() async {
    try {
      final db = await DatabaseHelper().database;
      final now = DateTime.now().toIso8601String();

      // Check if items already exist
      final existing = await db.query('items', limit: 1);
      if (existing.isNotEmpty) {
        debugPrint('✅ Items already exist in database');
        return;
      }

      final sampleItems = [
        {
          'name': 'LED Bulb 9W',
          'description': 'Energy efficient LED bulb',
          'hsn_code': '85395',
          'unit': 'pcs',
          'selling_price': 250.0,
          'purchase_price': 180.0,
          'tax_rate': 18.0,
          'stock_quantity': 50,
          'low_stock_alert': 10,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'name': 'Wire 2.5mm²',
          'description': 'Copper electrical wire',
          'hsn_code': '85441',
          'unit': 'meter',
          'selling_price': 45.0,
          'purchase_price': 32.0,
          'tax_rate': 18.0,
          'stock_quantity': 500,
          'low_stock_alert': 50,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'name': 'Switch 16A',
          'description': 'Modular switch 16 amp',
          'hsn_code': '85363',
          'unit': 'pcs',
          'selling_price': 120.0,
          'purchase_price': 85.0,
          'tax_rate': 18.0,
          'stock_quantity': 25,
          'low_stock_alert': 5,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'name': 'MCB 32A',
          'description': 'Miniature Circuit Breaker',
          'hsn_code': '85362',
          'unit': 'pcs',
          'selling_price': 450.0,
          'purchase_price': 320.0,
          'tax_rate': 18.0,
          'stock_quantity': 20,
          'low_stock_alert': 5,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
        {
          'name': 'PVC Pipe 1 inch',
          'description': 'PVC electrical conduit pipe',
          'hsn_code': '39172',
          'unit': 'meter',
          'selling_price': 65.0,
          'purchase_price': 48.0,
          'tax_rate': 18.0,
          'stock_quantity': 100,
          'low_stock_alert': 20,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
      ];

      for (final item in sampleItems) {
        await db.insert('items', item);
      }

      debugPrint('✅ Added ${sampleItems.length} sample items to database');
    } catch (e) {
      debugPrint('❌ Error adding sample items: $e');
    }
  }
}
