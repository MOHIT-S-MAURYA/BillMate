import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billmate/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';
import 'package:billmate/features/reports/presentation/widgets/date_range_picker.dart';
import 'package:billmate/features/reports/presentation/widgets/export_button.dart';

class PaymentReportPage extends StatefulWidget {
  const PaymentReportPage({super.key});

  @override
  State<PaymentReportPage> createState() => _PaymentReportPageState();
}

class _PaymentReportPageState extends State<PaymentReportPage> {
  DateRange _selectedRange = DateRange.thisMonth();

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    context.read<ReportsBloc>().add(
      GeneratePaymentReportEvent(dateRange: _selectedRange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          BlocBuilder<ReportsBloc, ReportsState>(
            builder: (context, state) {
              if (state is ReportsLoaded && state.report is PaymentReport) {
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
                    state.report is PaymentReport) {
                  return _PaymentReportView(
                    report: state.report as PaymentReport,
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

class _PaymentReportView extends StatelessWidget {
  final PaymentReport report;

  const _PaymentReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaymentSummaryCards(report: report),
          const SizedBox(height: 20),
          _PaymentStatusChart(report: report),
          const SizedBox(height: 20),
          _OverdueInvoices(report: report),
        ],
      ),
    );
  }
}

class _PaymentSummaryCards extends StatelessWidget {
  final PaymentReport report;

  const _PaymentSummaryCards({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Collected',
                value: '\$${report.totalCollected.toStringAsFixed(2)}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'Total Pending',
                value: '\$${report.totalPending.toStringAsFixed(2)}',
                icon: Icons.pending,
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
                title: 'Overdue Amount',
                value: '\$${report.totalOverdue.toStringAsFixed(2)}',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'Collection Rate',
                value: '${report.collectionRate.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: Colors.blue,
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

class _PaymentStatusChart extends StatelessWidget {
  final PaymentReport report;

  const _PaymentStatusChart({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Status Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.statusBreakdown.length,
              itemBuilder: (context, index) {
                final status = report.statusBreakdown[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status.status),
                    child: Icon(
                      _getStatusIcon(status.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(status.status.toUpperCase()),
                  subtitle: Text('${status.count} invoices'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${status.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${status.percentage.toStringAsFixed(1)}%',
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }
}

class _OverdueInvoices extends StatelessWidget {
  final PaymentReport report;

  const _OverdueInvoices({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.overdueInvoicesList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  'No Overdue Invoices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'All invoices are up to date!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Overdue Invoices (${report.overdueInvoicesList.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.overdueInvoicesList.length,
              itemBuilder: (context, index) {
                final invoice = report.overdueInvoicesList[index];
                final daysPastDue =
                    DateTime.now().difference(invoice.dueDate).inDays;

                return Card(
                  color: Colors.red.withValues(alpha: 0.1),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text(
                        '${daysPastDue}d',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(invoice.customerName),
                    subtitle: Text('Invoice #${invoice.invoiceNumber}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${invoice.amount.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'Due: ${invoice.dueDate.day}/${invoice.dueDate.month}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
