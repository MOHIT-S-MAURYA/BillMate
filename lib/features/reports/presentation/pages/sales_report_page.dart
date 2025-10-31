import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/core/localization/country_service.dart';
import 'package:billmate/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/presentation/widgets/date_range_picker.dart';
import 'package:billmate/features/reports/presentation/widgets/export_button.dart';
import 'package:billmate/shared/widgets/empty_state/empty_state_widget.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  DateRange _selectedRange = DateRange.thisMonth();
  String _groupBy = 'day'; // 'day', 'week', 'month'
  String? _paymentStatusFilter; // null = all, 'paid', 'pending', 'partial'
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    context.read<ReportsBloc>().add(
      GenerateSalesReportEvent(dateRange: _selectedRange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoaded && state.report is SalesReport) {
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.settings_suggest_rounded,
                                            size: 20,
                                            color:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Customize View',
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
                                    // Group By Section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .calendar_view_month_rounded,
                                                size: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Group By Period',
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
                                          SegmentedButton<String>(
                                            style: SegmentedButton.styleFrom(
                                              selectedBackgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              selectedForegroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            segments: const [
                                              ButtonSegment(
                                                value: 'day',
                                                label: Text('Day'),
                                                icon: Icon(
                                                  Icons.today,
                                                  size: 18,
                                                ),
                                              ),
                                              ButtonSegment(
                                                value: 'week',
                                                label: Text('Week'),
                                                icon: Icon(
                                                  Icons.date_range,
                                                  size: 18,
                                                ),
                                              ),
                                              ButtonSegment(
                                                value: 'month',
                                                label: Text('Month'),
                                                icon: Icon(
                                                  Icons.calendar_month,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                            selected: {_groupBy},
                                            onSelectionChanged: (
                                              Set<String> newSelection,
                                            ) {
                                              setState(() {
                                                _groupBy = newSelection.first;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Payment Status Filter Section
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.payment_rounded,
                                                size: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Payment Status',
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
                                                icon: Icons.select_all_rounded,
                                                isSelected:
                                                    _paymentStatusFilter ==
                                                    null,
                                                onSelected: (selected) {
                                                  setState(() {
                                                    _paymentStatusFilter = null;
                                                  });
                                                },
                                              ),
                                              _buildFilterChip(
                                                context,
                                                label: 'Paid',
                                                icon:
                                                    Icons.check_circle_rounded,
                                                color: Colors.green,
                                                isSelected:
                                                    _paymentStatusFilter ==
                                                    'paid',
                                                onSelected: (selected) {
                                                  setState(() {
                                                    _paymentStatusFilter =
                                                        selected
                                                            ? 'paid'
                                                            : null;
                                                  });
                                                },
                                              ),
                                              _buildFilterChip(
                                                context,
                                                label: 'Pending',
                                                icon: Icons.schedule_rounded,
                                                color: Colors.orange,
                                                isSelected:
                                                    _paymentStatusFilter ==
                                                    'pending',
                                                onSelected: (selected) {
                                                  setState(() {
                                                    _paymentStatusFilter =
                                                        selected
                                                            ? 'pending'
                                                            : null;
                                                  });
                                                },
                                              ),
                                              _buildFilterChip(
                                                context,
                                                label: 'Partial',
                                                icon:
                                                    Icons
                                                        .pie_chart_outline_rounded,
                                                color: Colors.blue,
                                                isSelected:
                                                    _paymentStatusFilter ==
                                                    'partial',
                                                onSelected: (selected) {
                                                  setState(() {
                                                    _paymentStatusFilter =
                                                        selected
                                                            ? 'partial'
                                                            : null;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                    state.report is SalesReport) {
                  return _SalesReportView(report: state.report as SalesReport);
                } else if (state is ReportsError) {
                  return EmptyStateWidget(
                    message: state.message,
                    icon: Icons.error_outline,
                    onRetry: _generateReport,
                  );
                }
                return const EmptyStateWidget(
                  message: 'No data available for the selected period',
                  icon: Icons.analytics_outlined,
                );
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

class _SalesReportView extends StatelessWidget {
  final SalesReport report;

  const _SalesReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCards(report: report),
          const SizedBox(height: 20),
          _SalesChart(report: report),
          const SizedBox(height: 20),
          _TopCustomers(report: report),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final SalesReport report;

  const _SummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Revenue',
            value: getIt<CountryService>().formatCurrency(
              report.totalSales.toDouble(),
            ),
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Total Orders',
            value: '${report.totalInvoices}',
            icon: Icons.shopping_cart,
            color: Colors.blue,
          ),
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

class _SalesChart extends StatefulWidget {
  final SalesReport report;

  const _SalesChart({required this.report});

  @override
  State<_SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<_SalesChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Sales Trend',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.report.dailySales.length} days',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.report.dailySales.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No sales data available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor:
                            (group) => colorScheme.surfaceContainerHighest,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final dailySale =
                              widget.report.dailySales[group.x.toInt()];
                          final dateStr = DateFormat(
                            'MMM dd',
                          ).format(dailySale.date);
                          return BarTooltipItem(
                            '$dateStr\n',
                            TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: getIt<CountryService>().formatCurrency(
                                  dailySale.amount.toDouble(),
                                ),
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: '\n${dailySale.invoiceCount} orders',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            touchedIndex = null;
                            return;
                          }
                          touchedIndex =
                              barTouchResponse.spot!.touchedBarGroupIndex;
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >=
                                widget.report.dailySales.length) {
                              return const SizedBox.shrink();
                            }
                            final date =
                                widget.report.dailySales[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('dd').format(date),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              _formatCompactCurrency(value),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxY() / 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                        left: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    barGroups:
                        widget.report.dailySales.asMap().entries.map((entry) {
                          final index = entry.key;
                          final dailySale = entry.value;
                          final isTouched = index == touchedIndex;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: dailySale.amount.toDouble(),
                                color:
                                    isTouched
                                        ? colorScheme.primary
                                        : colorScheme.primary.withValues(
                                          alpha: 0.7,
                                        ),
                                width: isTouched ? 20 : 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: _getMaxY(),
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (widget.report.dailySales.isEmpty) return 100;

    final maxSale = widget.report.dailySales
        .map((e) => e.amount.toDouble())
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to the max value for better visualization
    return maxSale * 1.2;
  }

  String _formatCompactCurrency(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(0)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _TopCustomers extends StatelessWidget {
  final SalesReport report;

  const _TopCustomers({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Customers',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.topCustomers.length,
              itemBuilder: (context, index) {
                final customer = report.topCustomers[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(customer.customerName),
                  subtitle: Text('${customer.invoiceCount} orders'),
                  trailing: Text(
                    getIt<CountryService>().formatCurrency(
                      customer.totalAmount.toDouble(),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
}
