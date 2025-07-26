import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllItemsUseCase {
  final InventoryRepository repository;

  GetAllItemsUseCase(this.repository);

  Future<List<Item>> call() async {
    return await repository.getAllItems();
  }
}

@injectable
class GetItemByIdUseCase {
  final InventoryRepository repository;

  GetItemByIdUseCase(this.repository);

  Future<Item?> call(int id) async {
    return await repository.getItemById(id);
  }
}

@injectable
class SearchItemsUseCase {
  final InventoryRepository repository;

  SearchItemsUseCase(this.repository);

  Future<List<Item>> call(String query) async {
    return await repository.searchItems(query);
  }
}

@injectable
class CreateItemUseCase {
  final InventoryRepository repository;

  CreateItemUseCase(this.repository);

  Future<void> call(Item item) async {
    return await repository.createItem(item);
  }
}

@injectable
class UpdateItemUseCase {
  final InventoryRepository repository;

  UpdateItemUseCase(this.repository);

  Future<void> call(Item item) async {
    return await repository.updateItem(item);
  }
}

@injectable
class DeleteItemUseCase {
  final InventoryRepository repository;

  DeleteItemUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteItem(id);
  }
}

@injectable
class UpdateStockUseCase {
  final InventoryRepository repository;

  UpdateStockUseCase(this.repository);

  Future<void> call(int itemId, int quantity) async {
    return await repository.updateStock(itemId, quantity);
  }
}

@injectable
class GetLowStockItemsUseCase {
  final InventoryRepository repository;

  GetLowStockItemsUseCase(this.repository);

  Future<List<Item>> call() async {
    return await repository.getLowStockItems();
  }
}

@injectable
class GetAllCategoriesUseCase {
  final InventoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  Future<List<Category>> call() async {
    return await repository.getAllCategories();
  }
}

@injectable
class CreateCategoryUseCase {
  final InventoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.createCategory(category);
  }
}

@injectable
class UpdateCategoryUseCase {
  final InventoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.updateCategory(category);
  }
}

@injectable
class DeleteCategoryUseCase {
  final InventoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(int categoryId) async {
    return await repository.deleteCategory(categoryId);
  }
}
