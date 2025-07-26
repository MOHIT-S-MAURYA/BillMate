import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/features/inventory/data/models/item_model.dart';
import 'package:injectable/injectable.dart';

abstract class InventoryLocalDataSource {
  Future<List<ItemModel>> getAllItems();
  Future<ItemModel?> getItemById(int id);
  Future<List<ItemModel>> getItemsByCategory(int categoryId);
  Future<List<ItemModel>> searchItems(String query);
  Future<void> createItem(ItemModel item);
  Future<void> updateItem(ItemModel item);
  Future<void> deleteItem(int id);
  Future<void> updateStock(int itemId, int quantity);
  Future<List<ItemModel>> getLowStockItems();
  Future<List<ItemModel>> getOutOfStockItems();
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(int id);
  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(int id);
}

@Injectable(as: InventoryLocalDataSource)
class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final DatabaseHelper databaseHelper;

  InventoryLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<ItemModel>> getAllItems() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemModel.fromJson(maps[i]);
    });
  }

  @override
  Future<ItemModel?> getItemById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'id = ? AND is_active = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return ItemModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<List<ItemModel>> getItemsByCategory(int categoryId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'category_id = ? AND is_active = ?',
      whereArgs: [categoryId, 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<ItemModel>> searchItems(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where:
          '(name LIKE ? OR description LIKE ? OR hsn_code LIKE ?) AND is_active = ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> createItem(ItemModel item) async {
    final db = await databaseHelper.database;
    await db.insert('items', item.toJson());
  }

  @override
  Future<void> updateItem(ItemModel item) async {
    final db = await databaseHelper.database;
    await db.update(
      'items',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteItem(int id) async {
    final db = await databaseHelper.database;
    await db.update(
      'items',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateStock(int itemId, int quantity) async {
    final db = await databaseHelper.database;
    await db.update(
      'items',
      {
        'stock_quantity': quantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  @override
  Future<List<ItemModel>> getLowStockItems() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM items WHERE stock_quantity <= low_stock_alert AND is_active = 1 ORDER BY name ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<ItemModel>> getOutOfStockItems() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'stock_quantity <= 0 AND is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ItemModel.fromJson(maps[i]);
    });
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromJson(maps[i]);
    });
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ? AND is_active = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    final db = await databaseHelper.database;
    await db.insert('categories', category.toJson());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final db = await databaseHelper.database;
    await db.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await databaseHelper.database;
    await db.update(
      'categories',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
