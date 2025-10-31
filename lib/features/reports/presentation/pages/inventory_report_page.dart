import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:billmate/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/presentation/widgets/date_range_picker.dart';
import 'package:billmate/features/reports/presentation/widgets/export_button.dart';

class InventoryReportPage extends StatefulWidget {
  const InventoryReportPage({super.key});

  @override
  State<InventoryReportPage> createState() => _InventoryReportPageState();
}

class _InventoryReportPageState extends State<InventoryReportPage> {
  DateRange _selectedRange = DateRange.thisMonth();
  String? _categoryFilter; // null = all categories
  String _stockFilter = 'all'; // 'all', 'low', 'out_of_stock'
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    context.read<ReportsBloc>().add(
      GenerateInventoryReportEvent(dateRange: _selectedRange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoaded && state.report is InventoryReport) {
                return ExportButton(
                  onExport: (format) {
                    context.read<ReportsBloc>().add(
                      ExportReportEvent(format: format),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DateRangePicker(
                  selectedRange: _selectedRange,
                  onRangeChanged: (range) {
                    setState(() {
                      _selectedRange = range;
                    });
                    _generateReport();
                  },
                ),
                const SizedBox(height: 12),
                // Filter Toggle Button with gradient and shadow
                Material(
                  elevation: _showFilters ? 0 : 2,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            _showFilters
                                ? null
                                : LinearGradient(
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        color:
                            _showFilters
                                ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest
                                : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showFilters
                                  ? Icons.filter_list_off_rounded
                                  : Icons.tune_rounded,
                              size: 22,
                              color:
                                  _showFilters
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _showFilters
                                  ? 'Hide Filters'
                                  : 'Show Filters & Options',
                              style: TextStyle(
                                color:
                                    _showFilters
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _showFilters
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color:
                                  _showFilters
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Filters Section with animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child:
                      _showFilters
                          ? Column(
                            children: [
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .shadow
                                          .withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: BlocBuilder<ReportsBloc, ReportsState>(
                                  builder: (context, state) {
                                    final categories =
                                        state is ReportsLoaded &&
                                                state.report is InventoryReport
                                            ? (state.report as InventoryReport)
                                                .categoryStats
                                                .keys
                                                .toList()
                                            : <String>[];

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.inventory_2_rounded,
                                                size: 20,
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Filter Inventory',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        // Stock Status Filter Section
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.inventory_rounded,
                                                    size: 18,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Stock Status',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _buildFilterChip(
                                                    context,
                                                    label: 'All',
                                                    icon:
                                                        Icons
                                                            .select_all_rounded,
                                                    isSelected:
                                                        _stockFilter == 'all',
                                                    onSelected: (selected) {
                                                      setState(() {
                                                        _stockFilter = 'all';
                                                      });
                                                    },
                                                  ),
                                                  _buildFilterChip(
                                                    context,
                                                    label: 'Low Stock',
                                                    icon: Icons.warning_rounded,
                                                    color: Colors.orange,
                                                    isSelected:
                                                        _stockFilter == 'low',
                                                    onSelected: (selected) {
                                                      setState(() {
                                                        _stockFilter = 'low';
                                                      });
                                                    },
                                                  ),
                                                  _buildFilterChip(
                                                    context,
                                                    label: 'Out of Stock',
                                                    icon: Icons.error_rounded,
                                                    color: Colors.red,
                                                    isSelected:
                                                        _stockFilter ==
                                                        'out_of_stock',
                                                    onSelected: (selected) {
                                                      setState(() {
                                                        _stockFilter =
                                                            'out_of_stock';
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (categories.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          // Category Filter Section
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.category_rounded,
                                                      size: 18,
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Category',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${categories.length} categories',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    _buildFilterChip(
                                                      context,
                                                      label: 'All',
                                                      icon: Icons.apps_rounded,
                                                      isSelected:
                                                          _categoryFilter ==
                                                          null,
                                                      onSelected: (selected) {
                                                        setState(() {
                                                          _categoryFilter =
                                                              null;
                                                        });
                                                      },
                                                    ),
                                                    ...categories.map((
                                                      category,
                                                    ) {
                                                      return _buildFilterChip(
                                                        context,
                                                        label: category,
                                                        icon:
                                                            Icons.label_rounded,
                                                        isSelected:
                                                            _categoryFilter ==
                                                            category,
                                                        onSelected: (selected) {
                                                          setState(() {
                                                            _categoryFilter =
                                                                selected
                                                                    ? category
                                                                    : null;
                                                          });
                                                        },
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportsLoaded &&
                    state.report is InventoryReport) {
                  return _InventoryReportView(
                    report: state.report as InventoryReport,
                  );
                } else if (state is ReportsError) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading report',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              state.message,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _generateReport,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: Text('No data available'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build modern filter chips
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color:
            isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color:
            isSelected
                ? chipColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: isSelected ? 2 : 0,
      shadowColor: chipColor.withValues(alpha: 0.3),
    );
  }
}

class _InventoryReportView extends StatelessWidget {
  final InventoryReport report;

  const _InventoryReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InventorySummaryCards(report: report),
          const SizedBox(height: 20),
          if (report.categoryStats.isNotEmpty) ...[
            _CategoryDistributionChart(report: report),
            const SizedBox(height: 20),
          ],
          _LowStockAlert(report: report),
          const SizedBox(height: 20),
          _StockMovements(report: report),
        ],
      ),
    );
  }
}

class _CategoryDistributionChart extends StatefulWidget {
  final InventoryReport report;

  const _CategoryDistributionChart({required this.report});

  @override
  State<_CategoryDistributionChart> createState() =>
      _CategoryDistributionChartState();
}

class _CategoryDistributionChartState
    extends State<_CategoryDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = widget.report.categoryStats.entries.toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Generate colors for each category
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections:
                            categories.asMap().entries.map((entry) {
                              final index = entry.key;
                              final categoryEntry = entry.value;
                              final stats = categoryEntry.value;
                              final isTouched = index == touchedIndex;
                              final fontSize = isTouched ? 16.0 : 12.0;
                              final radius = isTouched ? 65.0 : 55.0;
                              final color = colors[index % colors.length];

                              // Calculate percentage
                              final totalItems = widget.report.totalItems;
                              final percentage =
                                  totalItems > 0
                                      ? (stats.itemCount / totalItems * 100)
                                          .toStringAsFixed(1)
                                      : '0.0';

                              return PieChartSectionData(
                                color: color,
                                value: stats.itemCount.toDouble(),
                                title: '$percentage%',
                                radius: radius,
                                titleStyle: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children:
                        categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final categoryEntry = entry.value;
                          final stats = categoryEntry.value;
                          final color = colors[index % colors.length];
                          final isTouched = index == touchedIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  touchedIndex =
                                      index == touchedIndex ? -1 : index;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isTouched
                                          ? color.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stats.categoryName,
                                            style: TextStyle(
                                              fontWeight:
                                                  isTouched
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                              fontSize: isTouched ? 14 : 13,
                                            ),
                                          ),
                                          Text(
                                            '${stats.itemCount} items',
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (stats.lowStockCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${stats.lowStockCount} low',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummaryCards extends StatelessWidget {
  final InventoryReport report;

  const _InventorySummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Items',
                value: '${report.totalItems}',
                icon: Icons.inventory_2,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'Low Stock Items',
                value: '${report.lowStockItems}',
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Out of Stock',
                value: '${report.outOfStockItems}',
                icon: Icons.remove_shopping_cart,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'Total Value',
                value: '\$${report.totalValue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockAlert extends StatelessWidget {
  final InventoryReport report;

  const _LowStockAlert({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.lowStockItemsList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.orange.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.lowStockItemsList.length,
              itemBuilder: (context, index) {
                final item = report.lowStockItemsList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(item.itemName),
                  subtitle: Text('Current stock: ${item.currentStock}'),
                  trailing: Chip(
                    label: Text('Low Stock'),
                    backgroundColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovements extends StatelessWidget {
  final InventoryReport report;

  const _StockMovements({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Stock Movements',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.stockMovements.length,
              itemBuilder: (context, index) {
                final movement = report.stockMovements[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        movement.movementType == 'in'
                            ? Colors.green
                            : Colors.red,
                    child: Icon(
                      movement.movementType == 'in' ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(movement.itemName),
                  subtitle: Text(
                    '${movement.movementType.toUpperCase()}: ${movement.quantity} units',
                  ),
                  trailing: Text(
                    '${movement.date.day}/${movement.date.month}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
