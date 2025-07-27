import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Database helper class for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'billmate.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add payment_method and payment_date columns to invoices table
      await db.execute('''
        ALTER TABLE invoices ADD COLUMN payment_method TEXT DEFAULT 'cash'
      ''');
      await db.execute('''
        ALTER TABLE invoices ADD COLUMN payment_date TEXT
      ''');
    }
    if (oldVersion < 3) {
      // Add paid_amount column to invoices table
      await db.execute('''
        ALTER TABLE invoices ADD COLUMN paid_amount REAL DEFAULT 0
      ''');
    }
    if (oldVersion < 4) {
      // Add inventory_transactions table for tracking stock changes
      await db.execute('''
        CREATE TABLE inventory_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id INTEGER NOT NULL,
          transaction_type TEXT NOT NULL,
          quantity_change INTEGER NOT NULL,
          previous_quantity INTEGER NOT NULL,
          new_quantity INTEGER NOT NULL,
          invoice_id INTEGER,
          notes TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (item_id) REFERENCES items (id),
          FOREIGN KEY (invoice_id) REFERENCES invoices (id)
        )
      ''');
    }
  }

  Future<void> _createTables(Database db) async {
    // Create Items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        hsn_code TEXT,
        unit TEXT NOT NULL,
        selling_price REAL NOT NULL,
        purchase_price REAL,
        tax_rate REAL NOT NULL,
        stock_quantity INTEGER DEFAULT 0,
        low_stock_alert INTEGER DEFAULT 10,
        category_id INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create Customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        gstin TEXT,
        state_code TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create Invoices table
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        customer_id INTEGER,
        invoice_date TEXT NOT NULL,
        due_date TEXT,
        subtotal REAL NOT NULL,
        tax_amount REAL NOT NULL,
        discount_amount REAL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_status TEXT DEFAULT 'pending',
        payment_method TEXT DEFAULT 'cash',
        payment_date TEXT,
        paid_amount REAL DEFAULT 0,
        notes TEXT,
        is_gst_invoice INTEGER DEFAULT 1,
        place_of_supply TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Create Invoice Items table
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        discount_percent REAL DEFAULT 0,
        tax_rate REAL NOT NULL,
        line_total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Create Settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create Inventory Transactions table
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        quantity_change INTEGER NOT NULL,
        previous_quantity INTEGER NOT NULL,
        new_quantity INTEGER NOT NULL,
        invoice_id INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id),
        FOREIGN KEY (invoice_id) REFERENCES invoices (id)
      )
    ''');

    // Insert default settings
    await _insertDefaultSettings(db);
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final now = DateTime.now().toIso8601String();

    final defaultSettings = [
      {
        'key': 'business_name',
        'value': 'Your Business Name',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'business_address',
        'value': 'Your Business Address',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'business_phone',
        'value': 'Your Phone Number',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'business_email',
        'value': 'your@email.com',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'business_gstin',
        'value': 'Your GSTIN',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'state_code',
        'value': '07',
        'created_at': now,
        'updated_at': now,
      }, // Delhi by default
      {
        'key': 'invoice_prefix',
        'value': 'INV',
        'created_at': now,
        'updated_at': now,
      },
      {
        'key': 'next_invoice_number',
        'value': '1',
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (final setting in defaultSettings) {
      await db.insert('settings', setting);
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
