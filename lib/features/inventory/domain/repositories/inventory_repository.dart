import 'package:billmate/features/inventory/domain/entities/item.dart';

abstract class InventoryRepository {
  // Item CRUD operations
  Future<List<Item>> getAllItems();
  Future<Item?> getItemById(int id);
  Future<List<Item>> getItemsByCategory(int categoryId);
  Future<List<Item>> searchItems(String query);
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(int id);

  // Stock management
  Future<void> updateStock(int itemId, int quantity);
  Future<void> reduceStock(
    int itemId,
    int quantity, {
    int? invoiceId,
    String? notes,
  });
  Future<void> increaseStock(
    int itemId,
    int quantity, {
    int? invoiceId,
    String? notes,
  });
  Future<bool> checkStockAvailability(int itemId, int requiredQuantity);
  Future<void> recordInventoryTransaction(
    int itemId,
    String transactionType,
    int quantityChange, {
    int? invoiceId,
    String? notes,
  });
  Future<List<Item>> getLowStockItems();
  Future<List<Item>> getOutOfStockItems();

  // Category operations
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);

  // Bulk operations
  Future<void> bulkUpdateStock(Map<int, int> stockUpdates);
  Future<void> bulkDeleteItems(List<int> itemIds);
}
