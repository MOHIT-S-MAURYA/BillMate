import 'package:flutter/foundation.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/core/database/demo_data_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Database reset utility for development and testing
class DatabaseResetService {
  /// Reset database by deleting the file and recreating with demo data
  static Future<void> resetDatabaseWithDemoData() async {
    try {
      // Get database file path
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, 'billmate.db');

      // Close any existing connections and reset
      await DatabaseHelper().resetConnection();

      // Delete the database file
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Old database file deleted');
      }

      // Initialize fresh database
      final databaseHelper = DatabaseHelper();
      await databaseHelper.database;
      debugPrint('✅ Fresh database created');

      // Initialize demo data
      final demoDataService = DemoDataService(databaseHelper);
      await demoDataService.initializeDemoData();

      final stats = await demoDataService.getDemoDataStats();
      debugPrint('✅ Demo data initialized: $stats');
    } catch (e) {
      debugPrint('❌ Database reset error: $e');
      rethrow;
    }
  }

  /// Just reset the database without demo data
  static Future<void> resetDatabaseOnly() async {
    try {
      // Get database file path
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, 'billmate.db');

      // Close any existing connections and reset
      await DatabaseHelper().resetConnection();

      // Delete the database file
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Database file deleted');
      }

      // Initialize fresh database - this will create new tables
      final databaseHelper = DatabaseHelper();
      await databaseHelper.database;
      debugPrint('✅ Fresh database created without demo data');
    } catch (e) {
      debugPrint('❌ Database reset error: $e');
      rethrow;
    }
  }

  /// Check database version and schema
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await DatabaseHelper().database;

      // Get version
      final version = await db.getVersion();

      // Get tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );

      final tableNames = tables.map((table) => table['name']).toList();

      // Get column info for invoices table
      final invoicesColumns = await db.rawQuery("PRAGMA table_info(invoices)");

      return {
        'version': version,
        'tables': tableNames,
        'invoices_columns': invoicesColumns.map((col) => col['name']).toList(),
      };
    } catch (e) {
      debugPrint('❌ Database info error: $e');
      return {'error': e.toString()};
    }
  }
}
