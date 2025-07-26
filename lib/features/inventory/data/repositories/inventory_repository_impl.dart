import 'package:billmate/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:billmate/features/inventory/data/models/item_model.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl(this.localDataSource);

  @override
  Future<List<Item>> getAllItems() async {
    final itemModels = await localDataSource.getAllItems();
    return itemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Item?> getItemById(int id) async {
    final itemModel = await localDataSource.getItemById(id);
    return itemModel?.toEntity();
  }

  @override
  Future<List<Item>> getItemsByCategory(int categoryId) async {
    final itemModels = await localDataSource.getItemsByCategory(categoryId);
    return itemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Item>> searchItems(String query) async {
    final itemModels = await localDataSource.searchItems(query);
    return itemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createItem(Item item) async {
    final itemModel = ItemModel.fromEntity(item);
    await localDataSource.createItem(itemModel);
  }

  @override
  Future<void> updateItem(Item item) async {
    final itemModel = ItemModel.fromEntity(item);
    await localDataSource.updateItem(itemModel);
  }

  @override
  Future<void> deleteItem(int id) async {
    await localDataSource.deleteItem(id);
  }

  @override
  Future<void> updateStock(int itemId, int quantity) async {
    await localDataSource.updateStock(itemId, quantity);
  }

  @override
  Future<List<Item>> getLowStockItems() async {
    final itemModels = await localDataSource.getLowStockItems();
    return itemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Item>> getOutOfStockItems() async {
    final itemModels = await localDataSource.getOutOfStockItems();
    return itemModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final categoryModels = await localDataSource.getAllCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    final categoryModel = await localDataSource.getCategoryById(id);
    return categoryModel?.toEntity();
  }

  @override
  Future<void> createCategory(Category category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await localDataSource.createCategory(categoryModel);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await localDataSource.updateCategory(categoryModel);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<void> bulkUpdateStock(Map<int, int> stockUpdates) async {
    for (final entry in stockUpdates.entries) {
      await updateStock(entry.key, entry.value);
    }
  }

  @override
  Future<void> bulkDeleteItems(List<int> itemIds) async {
    for (final id in itemIds) {
      await deleteItem(id);
    }
  }
}
