import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:billmate/core/events/inventory_events.dart' as events;
import 'package:injectable/injectable.dart';

// Events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadAllItems extends InventoryEvent {}

class LoadItemsByCategory extends InventoryEvent {
  final int categoryId;

  const LoadItemsByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class SearchItems extends InventoryEvent {
  final String query;

  const SearchItems(this.query);

  @override
  List<Object> get props => [query];
}

class CreateItem extends InventoryEvent {
  final Item item;

  const CreateItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateItem extends InventoryEvent {
  final Item item;

  const UpdateItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteItem extends InventoryEvent {
  final int itemId;

  const DeleteItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class UpdateStock extends InventoryEvent {
  final int itemId;
  final int quantity;

  const UpdateStock(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}

class LoadLowStockItems extends InventoryEvent {}

class LoadAllCategories extends InventoryEvent {}

class CreateCategory extends InventoryEvent {
  final Category category;

  const CreateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateCategory extends InventoryEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategory extends InventoryEvent {
  final int categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

// States
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class ItemsLoaded extends InventoryState {
  final List<Item> items;
  final List<Category> categories;

  const ItemsLoaded({required this.items, required this.categories});

  @override
  List<Object> get props => [items, categories];
}

class LowStockItemsLoaded extends InventoryState {
  final List<Item> lowStockItems;

  const LowStockItemsLoaded(this.lowStockItems);

  @override
  List<Object> get props => [lowStockItems];
}

class CategoriesLoaded extends InventoryState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class InventorySuccess extends InventoryState {
  final String message;

  const InventorySuccess(this.message);

  @override
  List<Object> get props => [message];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object> get props => [message];
}

@injectable
// InventoryBloc
@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetAllItemsUseCase getAllItemsUseCase;
  final SearchItemsUseCase searchItemsUseCase;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;
  final UpdateStockUseCase updateStockUseCase;
  final GetLowStockItemsUseCase getLowStockItemsUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  InventoryBloc({
    required this.getAllItemsUseCase,
    required this.searchItemsUseCase,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
    required this.updateStockUseCase,
    required this.getLowStockItemsUseCase,
    required this.getAllCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(InventoryInitial()) {
    on<LoadAllItems>(_onLoadAllItems);
    on<SearchItems>(_onSearchItems);
    on<CreateItem>(_onCreateItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
    on<UpdateStock>(_onUpdateStock);
    on<LoadLowStockItems>(_onLoadLowStockItems);
    on<LoadAllCategories>(_onLoadAllCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadAllItems(
    LoadAllItems event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await getAllItemsUseCase();
      final categories = await getAllCategoriesUseCase();
      emit(ItemsLoaded(items: items, categories: categories));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await searchItemsUseCase(event.query);
      final categories = await getAllCategoriesUseCase();
      emit(ItemsLoaded(items: items, categories: categories));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onCreateItem(
    CreateItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await createItemUseCase(event.item);
      emit(const InventorySuccess('Item created successfully'));

      // Emit inventory event
      if (event.item.id != null) {
        events.InventoryEventBus().emitItemCreated(event.item.id!);
      }

      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await updateItemUseCase(event.item);
      emit(const InventorySuccess('Item updated successfully'));

      // Emit inventory event
      if (event.item.id != null) {
        events.InventoryEventBus().emitItemUpdated(event.item.id!);
      }

      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await deleteItemUseCase(event.itemId);
      emit(const InventorySuccess('Item deleted successfully'));

      // Emit inventory event
      events.InventoryEventBus().emitItemDeleted(event.itemId);

      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateStock(
    UpdateStock event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await updateStockUseCase(event.itemId, event.quantity);
      emit(const InventorySuccess('Stock updated successfully'));
      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadLowStockItems(
    LoadLowStockItems event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final lowStockItems = await getLowStockItemsUseCase();
      emit(LowStockItemsLoaded(lowStockItems));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onLoadAllCategories(
    LoadAllCategories event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final categories = await getAllCategoriesUseCase();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await createCategoryUseCase(event.category);
      emit(const InventorySuccess('Category created successfully'));
      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await updateCategoryUseCase(event.category);
      emit(const InventorySuccess('Category updated successfully'));
      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await deleteCategoryUseCase(event.categoryId);
      emit(const InventorySuccess('Category deleted successfully'));
      add(LoadAllItems());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
