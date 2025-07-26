import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:injectable/injectable.dart';
import 'package:decimal/decimal.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardStats extends DashboardEvent {}

class RefreshDashboardStats extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardStatsLoaded extends DashboardState {
  final int totalItems;
  final int lowStockItems;
  final int totalCategories;
  final Decimal totalInventoryValue;
  final Decimal todaysSales;
  final List<DashboardActivity> recentActivity;

  const DashboardStatsLoaded({
    required this.totalItems,
    required this.lowStockItems,
    required this.totalCategories,
    required this.totalInventoryValue,
    required this.todaysSales,
    required this.recentActivity,
  });

  @override
  List<Object> get props => [
    totalItems,
    lowStockItems,
    totalCategories,
    totalInventoryValue,
    todaysSales,
    recentActivity,
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}

// Dashboard Activity Model
class DashboardActivity {
  final String type;
  final String description;
  final DateTime timestamp;
  final String? iconName;

  const DashboardActivity({
    required this.type,
    required this.description,
    required this.timestamp,
    this.iconName,
  });
}

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAllItemsUseCase getAllItemsUseCase;
  final GetLowStockItemsUseCase getLowStockItemsUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;

  DashboardBloc({
    required this.getAllItemsUseCase,
    required this.getLowStockItemsUseCase,
    required this.getAllCategoriesUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<RefreshDashboardStats>(_onRefreshDashboardStats);
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadStats(emit);
  }

  Future<void> _onRefreshDashboardStats(
    RefreshDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't emit loading for refresh to avoid UI flicker
    await _loadStats(emit);
  }

  Future<void> _loadStats(Emitter<DashboardState> emit) async {
    try {
      // Load all required data in parallel for better performance
      final results = await Future.wait([
        getAllItemsUseCase(),
        getLowStockItemsUseCase(),
        getAllCategoriesUseCase(),
      ]);

      final allItems = results[0] as List<Item>;
      final lowStockItems = results[1] as List<Item>;
      final allCategories = results[2] as List<Category>;

      // Calculate total inventory value
      Decimal totalInventoryValue = Decimal.zero;
      for (final item in allItems) {
        final itemValue =
            item.sellingPrice * Decimal.fromInt(item.stockQuantity);
        totalInventoryValue += itemValue;
      }

      // For now, today's sales will be 0 until billing is implemented
      final todaysSales = Decimal.zero;

      // Generate recent activity (can be expanded when more features are added)
      final recentActivity = _generateRecentActivity(allItems, allCategories);

      emit(
        DashboardStatsLoaded(
          totalItems: allItems.length,
          lowStockItems: lowStockItems.length,
          totalCategories: allCategories.length,
          totalInventoryValue: totalInventoryValue,
          todaysSales: todaysSales,
          recentActivity: recentActivity,
        ),
      );
    } catch (e) {
      emit(DashboardError('Failed to load dashboard stats: ${e.toString()}'));
    }
  }

  List<DashboardActivity> _generateRecentActivity(
    List<Item> items,
    List<Category> categories,
  ) {
    final activities = <DashboardActivity>[];

    // Add recent items added (last 5 items by creation date)
    final recentItems =
        items
            .where(
              (item) => item.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final item in recentItems.take(3)) {
      activities.add(
        DashboardActivity(
          type: 'item_added',
          description: 'Added item: ${item.name}',
          timestamp: item.createdAt,
          iconName: 'add_box',
        ),
      );
    }

    // Add recent categories added (last 3 categories)
    final recentCategories =
        categories
            .where(
              (category) => category.createdAt.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final category in recentCategories.take(2)) {
      activities.add(
        DashboardActivity(
          type: 'category_added',
          description: 'Added category: ${category.name}',
          timestamp: category.createdAt,
          iconName: 'category',
        ),
      );
    }

    // Sort by timestamp descending
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(5).toList();
  }
}
