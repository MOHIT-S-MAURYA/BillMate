import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            child: DateRangePicker(
              selectedRange: _selectedRange,
              onRangeChanged: (range) {
                setState(() {
                  _selectedRange = range;
                });
                _generateReport();
              },
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
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _generateReport,
                          child: const Text('Retry'),
                        ),
                      ],
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
          _LowStockAlert(report: report),
          const SizedBox(height: 20),
          _StockMovements(report: report),
        ],
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
