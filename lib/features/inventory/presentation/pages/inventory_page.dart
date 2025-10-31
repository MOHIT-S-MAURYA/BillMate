import 'package:billmate/shared/widgets/empty_state/empty_state_widget.dart';
import 'package:billmate/shared/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/core/localization/country_service.dart';
import 'package:billmate/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:billmate/features/inventory/presentation/widgets/add_item_dialog.dart';
import 'package:billmate/features/inventory/presentation/widgets/edit_item_dialog.dart';
import 'package:billmate/features/inventory/presentation/widgets/item_card.dart';
import 'package:billmate/features/inventory/presentation/widgets/inventory_stats_card.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/core/events/inventory_events.dart' as events;
import 'package:billmate/core/navigation/modern_navigation_widgets.dart';
import 'package:billmate/core/widgets/smart_deletion_widgets.dart';
import 'dart:async';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InventoryBloc>()..add(LoadAllItems()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StreamSubscription<events.InventoryEvent>? _inventoryEventSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      if (_searchQuery.isEmpty) {
        context.read<InventoryBloc>().add(LoadAllItems());
      } else {
        context.read<InventoryBloc>().add(SearchItems(_searchQuery));
      }
    });

    // Listen to inventory events for auto-refresh
    _inventoryEventSubscription = events.InventoryEventBus().events.listen((
      event,
    ) {
      if (event.type == events.InventoryEventType.stockChanged) {
        // Auto-refresh inventory when stock changes
        _refreshInventory();
      }
    });
  }

  void _refreshInventory() {
    if (_searchQuery.isEmpty) {
      context.read<InventoryBloc>().add(LoadAllItems());
    } else {
      context.read<InventoryBloc>().add(SearchItems(_searchQuery));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh inventory data when returning to this page
    if (_searchQuery.isEmpty) {
      context.read<InventoryBloc>().add(LoadAllItems());
    } else {
      context.read<InventoryBloc>().add(SearchItems(_searchQuery));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _inventoryEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: const Text(
        'Inventory Management',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: [
        IconButton(
          onPressed: _refreshInventory,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh inventory',
        ),
        IconButton(
          onPressed: () => _showInventoryMenu(context),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search items by name, description, or HSN code...',
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear, color: AppColors.textHint),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All Items'),
          Tab(text: 'Low Stock'),
          Tab(text: 'Categories'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoading) {
          return const LoadingGridView();
        }
        if (state is ItemsLoaded) {
          final allItems = state.items;
          final lowStockItems =
              allItems
                  .where((item) => item.stockQuantity <= item.lowStockAlert)
                  .toList();
          final categories = state.categories;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildItemsList(allItems, categories),
              _buildItemsList(lowStockItems, categories),
              _buildCategoriesList(categories),
            ],
          );
        }
        if (state is InventoryError) {
          return EmptyStateWidget(
            message: state.message,
            icon: Icons.error_outline,
            onRetry: _refreshInventory,
          );
        }
        return const EmptyStateWidget(
          message: 'No items found.',
          icon: Icons.inventory_2_outlined,
        );
      },
    );
  }

  Widget _buildItemsList(List<Item> items, List<Category> categories) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        message:
            _searchQuery.isNotEmpty
                ? 'No items match "$_searchQuery"'
                : 'No items in inventory',
        icon:
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
      );
    }

    return Column(
      children: [
        InventoryStatsCard(
          totalItems: items.length,
          lowStockCount:
              items
                  .where((item) => item.stockQuantity <= item.lowStockAlert)
                  .length,
          outOfStockCount:
              items.where((item) => item.stockQuantity <= 0).length,
          totalValue: items.fold(
            0.0,
            (sum, item) =>
                sum + (item.sellingPrice.toDouble() * item.stockQuantity),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _refreshInventory();
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final category = categories.firstWhere(
                  (cat) => cat.id == item.categoryId,
                  orElse:
                      () => Category(
                        id: 0,
                        name: 'Uncategorized',
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                );

                return SmartDeletableItem(
                  canDelete: true,
                  canEdit: true,
                  deleteConfirmationTitle: 'Delete Item',
                  deleteConfirmationMessage:
                      'Are you sure you want to delete "${item.name}"? This action cannot be undone and will permanently remove the item from your inventory.',
                  onDelete: () => _showDeleteItemDialog(item),
                  onEdit: () => _showEditItemDialog(item),
                  child: ItemCard(
                    item: item,
                    category: category,
                    onEdit: () => _showEditItemDialog(item),
                    onDelete: () => _showDeleteItemDialog(item),
                    onStockUpdate:
                        (newStock) => _updateStock(item.id!, newStock),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(List<Category> categories) {
    return Column(
      children: [
        // Header with Add Category button
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categories.length} Categories',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Categories list
        Expanded(
          child:
              categories.isEmpty
                  ? _buildEmptyCategoriesState()
                  : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.category, color: AppColors.primary, size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle:
            category.description?.isNotEmpty == true
                ? Text(
                  category.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
                : null,
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditCategoryDialog(category);
            } else if (value == 'delete') {
              _showDeleteCategoryDialog(category);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No categories created',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create categories to organize your inventory items',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        // Show different FAB based on current tab
        if (_tabController.index == 2) {
          // Categories tab - Simple FAB for categories
          return ModernFloatingActionButtonExtended(
            heroTag: "categoryFAB",
            onPressed: () => _showAddCategoryDialog(context),
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.category),
            label: const Text('Add Category'),
          );
        } else {
          // All Items or Low Stock tabs - Smart Action Button
          return SmartActionButton(
            actions: [
              SmartAction(
                icon: Icons.add_box,
                onTap: () => _showAddItemDialog(context),
                backgroundColor: AppColors.primary,
                tooltip: 'Add New Item',
              ),
              SmartAction(
                icon: Icons.refresh,
                onTap: () => _refreshInventory(),
                backgroundColor: AppColors.info,
                tooltip: 'Refresh Inventory',
              ),
              SmartAction(
                icon: Icons.download,
                onTap: () => _exportInventory(),
                backgroundColor: AppColors.secondary,
                tooltip: 'Export Inventory',
              ),
              SmartAction(
                icon: Icons.analytics,
                onTap: () => _showInventoryStats(),
                backgroundColor: Colors.purple,
                tooltip: 'Inventory Analytics',
              ),
            ],
            child: const Icon(Icons.add),
          );
        }
      },
    );
  }

  void _exportInventory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Inventory'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose export format:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('CSV Format'),
                  subtitle: const Text('Excel compatible spreadsheet'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportToCSV();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF Report'),
                  subtitle: const Text('Detailed inventory report'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportToPDF();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _exportToCSV() {
    final state = context.read<InventoryBloc>().state;
    if (state is! ItemsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items to export'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final items = state.items;
      final csvData = StringBuffer();

      // Add headers
      csvData.writeln(
        'Item Name,Description,HSN Code,Unit,Stock Quantity,Purchase Price,Selling Price,Tax Rate,Low Stock Alert,Total Value',
      );

      // Add data rows
      for (final item in items) {
        final totalValue =
            item.sellingPrice * Decimal.fromInt(item.stockQuantity);
        csvData.writeln(
          '"${item.name}","${item.description ?? ''}","${item.hsnCode ?? ''}","${item.unit}",${item.stockQuantity},${item.purchasePrice ?? 0},${item.sellingPrice},${item.taxRate},${item.lowStockAlert},$totalValue',
        );
      }

      // For web/mobile, show the CSV content or save functionality would go here
      // Since we can't directly save files in Flutter web/mobile without additional packages,
      // we'll show a dialog with the CSV content that can be copied
      _showExportResult(
        'CSV Export',
        csvData.toString(),
        'inventory_export.csv',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _exportToPDF() {
    final state = context.read<InventoryBloc>().state;
    if (state is! ItemsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items to export'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final items = state.items;
      final totalItems = items.length;
      final totalValue = items.fold<double>(
        0.0,
        (sum, item) =>
            sum + (item.sellingPrice.toDouble() * item.stockQuantity),
      );
      final lowStockItems =
          items
              .where((item) => item.stockQuantity <= item.lowStockAlert)
              .length;

      // Create a simple text-based report (in a real implementation, you'd use pdf package)
      final reportContent = StringBuffer();
      reportContent.writeln('INVENTORY REPORT');
      reportContent.writeln(
        'Generated: ${DateTime.now().toString().split('.')[0]}',
      );
      reportContent.writeln('=' * 50);
      reportContent.writeln();
      reportContent.writeln('SUMMARY:');
      reportContent.writeln('Total Items: $totalItems');
      reportContent.writeln(
        'Total Inventory Value: ₹${totalValue.toStringAsFixed(2)}',
      );
      reportContent.writeln('Low Stock Items: $lowStockItems');
      reportContent.writeln();
      reportContent.writeln('ITEM DETAILS:');
      reportContent.writeln('-' * 50);

      for (final item in items) {
        final value = item.sellingPrice.toDouble() * item.stockQuantity;
        reportContent.writeln(item.name);
        reportContent.writeln('  Stock: ${item.stockQuantity} ${item.unit}');
        reportContent.writeln('  Price: ₹${item.sellingPrice}');
        reportContent.writeln('  Value: ₹${value.toStringAsFixed(2)}');
        if (item.stockQuantity <= item.lowStockAlert) {
          reportContent.writeln('  ⚠️ LOW STOCK ALERT');
        }
        reportContent.writeln();
      }

      _showExportResult(
        'PDF Report',
        reportContent.toString(),
        'inventory_report.txt',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report generation failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showExportResult(String title, String content, String filename) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  Text('File: $filename'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Copy the content above to save as a file',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showInventoryStats() {
    final state = context.read<InventoryBloc>().state;
    if (state is! ItemsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data available for statistics'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final items = state.items;

    // Calculate statistics
    final totalItems = items.length;
    final totalValue = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.sellingPrice.toDouble() * item.stockQuantity),
    );
    final totalStock = items.fold<int>(
      0,
      (sum, item) => sum + item.stockQuantity,
    );
    final lowStockItems =
        items
            .where((item) => item.stockQuantity <= item.lowStockAlert)
            .toList();
    final outOfStockItems =
        items.where((item) => item.stockQuantity == 0).length;

    final averageValue = totalItems > 0 ? totalValue / totalItems : 0.0;
    final averageStock = totalItems > 0 ? totalStock / totalItems : 0.0;

    // Get top valuable items
    final topValueItems = [...items]..sort(
      (a, b) => (b.sellingPrice.toDouble() * b.stockQuantity).compareTo(
        a.sellingPrice.toDouble() * a.stockQuantity,
      ),
    );
    final topItems = topValueItems.take(5).toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Inventory Statistics'),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCard(
                      'Total Items',
                      totalItems.toString(),
                      Icons.inventory,
                    ),
                    _buildStatCard(
                      'Total Stock Units',
                      totalStock.toString(),
                      Icons.storage,
                    ),
                    _buildStatCard(
                      'Total Value',
                      '₹${totalValue.toStringAsFixed(2)}',
                      Icons.monetization_on,
                    ),
                    _buildStatCard(
                      'Average Value per Item',
                      '₹${averageValue.toStringAsFixed(2)}',
                      Icons.analytics,
                    ),
                    _buildStatCard(
                      'Average Stock per Item',
                      averageStock.toStringAsFixed(1),
                      Icons.trending_up,
                    ),
                    _buildStatCard(
                      'Low Stock Items',
                      lowStockItems.length.toString(),
                      Icons.warning,
                      color:
                          lowStockItems.isNotEmpty
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                    _buildStatCard(
                      'Out of Stock',
                      outOfStockItems.toString(),
                      Icons.error_outline,
                      color:
                          outOfStockItems > 0
                              ? AppColors.error
                              : AppColors.success,
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Top 5 Most Valuable Items:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...topItems.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.stockQuantity} ${item.unit}'),
                          trailing: Text(
                            '₹${(item.sellingPrice.toDouble() * item.stockQuantity).toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ),

                    if (lowStockItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Low Stock Alert:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...lowStockItems
                          .take(5)
                          .map(
                            (item) => Card(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.warning,
                                  color: AppColors.warning,
                                ),
                                title: Text(item.name),
                                subtitle: Text(
                                  'Stock: ${item.stockQuantity} (Alert: ${item.lowStockAlert})',
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInventoryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Inventory Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.info),
                  title: const Text('Refresh Inventory'),
                  subtitle: const Text('Reload all items and categories'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<InventoryBloc>().add(LoadAllItems());
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.analytics,
                    color: AppColors.warning,
                  ),
                  title: const Text('Inventory Report'),
                  subtitle: const Text('View detailed inventory analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInventoryReport();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final inventoryBloc = context.read<InventoryBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: const AddItemDialog(),
          ),
    );
  }

  void _showEditItemDialog(Item item) {
    final inventoryBloc = context.read<InventoryBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: EditItemDialog(item: item),
          ),
    );
  }

  void _showDeleteItemDialog(Item item) {
    final inventoryBloc = context.read<InventoryBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 24),
                  SizedBox(width: 12),
                  Text('Delete Item'),
                ],
              ),
              content: Text('Are you sure you want to delete "${item.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<InventoryBloc>().add(DeleteItem(item.id!));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final inventoryBloc = context.read<InventoryBloc>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                List<Category> existingCategories = [];
                if (state is ItemsLoaded) {
                  existingCategories = state.categories;
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Add New Category'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.label,
                            color: AppColors.primary,
                          ),
                        ),
                        autofocus: true,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final categoryName = nameController.text.trim();
                        if (categoryName.isNotEmpty) {
                          // Check for duplicate names (case-insensitive)
                          final isDuplicate = existingCategories.any(
                            (category) =>
                                category.name.toLowerCase() ==
                                categoryName.toLowerCase(),
                          );

                          if (isDuplicate) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Category "$categoryName" already exists!',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }

                          final newCategory = Category(
                            name: categoryName,
                            isActive: true,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          inventoryBloc.add(CreateCategory(newCategory));
                          Navigator.pop(dialogContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Category'),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final inventoryBloc = context.read<InventoryBloc>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                List<Category> existingCategories = [];
                if (state is ItemsLoaded) {
                  existingCategories = state.categories;
                }

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Edit Category'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(
                            Icons.label,
                            color: AppColors.primary,
                          ),
                        ),
                        autofocus: true,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final categoryName = nameController.text.trim();
                        if (categoryName.isNotEmpty) {
                          // Check for duplicate names (case-insensitive), but exclude current category
                          final isDuplicate = existingCategories.any(
                            (cat) =>
                                cat.id != category.id &&
                                cat.name.toLowerCase() ==
                                    categoryName.toLowerCase(),
                          );

                          if (isDuplicate) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Category "$categoryName" already exists!',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }

                          final updatedCategory = Category(
                            id: category.id,
                            name: categoryName,
                            isActive: category.isActive,
                            createdAt: category.createdAt,
                            updatedAt: DateTime.now(),
                          );
                          inventoryBloc.add(UpdateCategory(updatedCategory));
                          Navigator.pop(dialogContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Category'),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    final inventoryBloc = context.read<InventoryBloc>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete, color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Delete Category'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Are you sure you want to delete "${category.name}"?'),
                  const SizedBox(height: 8),
                  Text(
                    'This action cannot be undone. Items in this category will be moved to "Uncategorized".',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    inventoryBloc.add(DeleteCategory(category.id!));
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
    );
  }

  void _updateStock(int itemId, int newStock) {
    context.read<InventoryBloc>().add(UpdateStock(itemId, newStock));
  }

  void _showInventoryReport() {
    final state = context.read<InventoryBloc>().state;
    if (state is! ItemsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data available for report'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryReportPage(items: state.items),
      ),
    );
  }
}

class InventoryReportPage extends StatelessWidget {
  final List<Item> items;

  const InventoryReportPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Calculate comprehensive statistics
    final totalItems = items.length;
    final totalValue = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.sellingPrice.toDouble() * item.stockQuantity),
    );
    final totalStock = items.fold<int>(
      0,
      (sum, item) => sum + item.stockQuantity,
    );
    final lowStockItems =
        items
            .where((item) => item.stockQuantity <= item.lowStockAlert)
            .toList();
    final outOfStockItems =
        items.where((item) => item.stockQuantity == 0).toList();
    final highValueItems =
        items
            .where(
              (item) =>
                  item.sellingPrice.toDouble() * item.stockQuantity > 1000,
            )
            .toList();

    // Category analysis (simplified since we don't have category names)
    final categoryMap = <int?, int>{};
    for (final item in items) {
      categoryMap[item.categoryId] = (categoryMap[item.categoryId] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Report',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Generated on ${DateTime.now().toString().split(' ')[0]}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Items',
                            totalItems.toString(),
                            Icons.inventory,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Stock',
                            totalStock.toString(),
                            Icons.storage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Total Value',
                            '₹${totalValue.toStringAsFixed(2)}',
                            Icons.monetization_on,
                          ),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Avg. Value',
                            '₹${(totalValue / totalItems).toStringAsFixed(2)}',
                            Icons.analytics,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alerts Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Alerts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAlertItem(
                            'Low Stock',
                            lowStockItems.length.toString(),
                            Icons.warning,
                            AppColors.warning,
                          ),
                        ),
                        Expanded(
                          child: _buildAlertItem(
                            'Out of Stock',
                            outOfStockItems.length.toString(),
                            Icons.error_outline,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Low Stock Items
            if (lowStockItems.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Low Stock Items (${lowStockItems.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...lowStockItems
                          .take(10)
                          .map(
                            (item) => ListTile(
                              leading: const Icon(
                                Icons.warning,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                'Stock: ${item.stockQuantity} ${item.unit} (Alert: ${item.lowStockAlert})',
                              ),
                              trailing: Text(
                                getIt<CountryService>().formatCurrency(
                                  item.sellingPrice.toDouble(),
                                ),
                              ),
                              dense: true,
                            ),
                          ),
                      if (lowStockItems.length > 10)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '... and ${lowStockItems.length - 10} more items',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // High Value Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Value Items (₹1000+)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (highValueItems.isEmpty)
                      Text(
                        'No items with total value over ${getIt<CountryService>().formatCurrency(1000)}',
                      )
                    else
                      ...highValueItems.take(10).map((item) {
                        final value =
                            item.sellingPrice.toDouble() * item.stockQuantity;
                        return ListTile(
                          leading: const Icon(
                            Icons.star,
                            color: AppColors.success,
                            size: 20,
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.stockQuantity} ${item.unit} × ₹${item.sellingPrice}',
                          ),
                          trailing: Text(
                            getIt<CountryService>().formatCurrency(value),
                          ),
                          dense: true,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _shareReport(BuildContext context) {
    // In a real implementation, you would generate and share the report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report sharing functionality would be implemented here'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
