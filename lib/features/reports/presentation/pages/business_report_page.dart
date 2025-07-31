import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/presentation/widgets/date_range_picker.dart';
import 'package:billmate/features/reports/presentation/widgets/export_button.dart';

class BusinessReportPage extends StatefulWidget {
  const BusinessReportPage({super.key});

  @override
  State<BusinessReportPage> createState() => _BusinessReportPageState();
}

class _BusinessReportPageState extends State<BusinessReportPage> {
  DateRange _selectedRange = DateRange.thisMonth();

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    context.read<ReportsBloc>().add(
      GenerateBusinessReportEvent(dateRange: _selectedRange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoaded && state.report is BusinessReport) {
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
                    state.report is BusinessReport) {
                  return _BusinessReportView(
                    report: state.report as BusinessReport,
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

class _BusinessReportView extends StatelessWidget {
  final BusinessReport report;

  const _BusinessReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BusinessSummaryCards(report: report),
          const SizedBox(height: 20),
          _ProfitMarginCard(report: report),
          const SizedBox(height: 20),
          _MonthlyGrowthChart(report: report),
          const SizedBox(height: 20),
          _RevenueByCategory(report: report),
        ],
      ),
    );
  }
}

class _BusinessSummaryCards extends StatelessWidget {
  final BusinessReport report;

  const _BusinessSummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Revenue',
                value: '\$${report.totalRevenue.toStringAsFixed(2)}',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'Total Profit',
                value: '\$${report.totalProfit.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Customers',
                value: '${report.totalCustomers}',
                icon: Icons.people,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'New Customers',
                value: '${report.newCustomers}',
                icon: Icons.person_add,
                color: Colors.orange,
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

class _ProfitMarginCard extends StatelessWidget {
  final BusinessReport report;

  const _ProfitMarginCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final margin = report.profitMargin;
    final color =
        margin >= 20
            ? Colors.green
            : margin >= 10
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profit Margin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${margin.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getProfitMarginDescription(margin),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getProfitMarginIcon(margin), color: color, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  String _getProfitMarginDescription(double margin) {
    if (margin >= 20) return 'Excellent';
    if (margin >= 10) return 'Good';
    if (margin >= 5) return 'Fair';
    return 'Needs Improvement';
  }

  IconData _getProfitMarginIcon(double margin) {
    if (margin >= 20) return Icons.emoji_emotions;
    if (margin >= 10) return Icons.thumb_up;
    if (margin >= 5) return Icons.warning;
    return Icons.trending_down;
  }
}

class _MonthlyGrowthChart extends StatelessWidget {
  final BusinessReport report;

  const _MonthlyGrowthChart({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Growth',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Growth Chart\n(${report.monthlyGrowth.length} months)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (report.monthlyGrowth.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.monthlyGrowth.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final growth = report.monthlyGrowth[index];
                  final isPositive = growth.growthRate >= 0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPositive ? Colors.green : Colors.red,
                      child: Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(_formatMonth(growth.month)),
                    subtitle: Text('\$${growth.revenue.toStringAsFixed(2)}'),
                    trailing: Text(
                      '${growth.growthRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _RevenueByCategory extends StatelessWidget {
  final BusinessReport report;

  const _RevenueByCategory({required this.report});

  @override
  Widget build(BuildContext context) {
    final categories =
        report.revenueByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final totalRevenue = report.totalRevenue;
                final percentage =
                    totalRevenue > Decimal.zero
                        ? (category.value * Decimal.fromInt(100) / totalRevenue)
                            .toDouble()
                        : 0.0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(index),
                    child: Text(
                      category.key.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(category.key),
                  subtitle: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                      _getCategoryColor(index),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${category.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
