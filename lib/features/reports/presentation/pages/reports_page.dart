import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:billmate/features/reports/presentation/pages/sales_report_page.dart';
import 'package:billmate/features/reports/presentation/pages/inventory_report_page.dart';
import 'package:billmate/features/reports/presentation/pages/payment_report_page.dart';
import 'package:billmate/features/reports/presentation/pages/business_report_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const ReportsView(),
      ),
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Report Type',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _ReportCard(
                  title: 'Sales Report',
                  description: 'View sales performance and trends',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BlocProvider.value(
                                value: context.read<ReportsBloc>(),
                                child: const SalesReportPage(),
                              ),
                        ),
                      ),
                ),
                _ReportCard(
                  title: 'Inventory Report',
                  description: 'Check stock levels and movements',
                  icon: Icons.inventory,
                  color: Colors.blue,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BlocProvider.value(
                                value: context.read<ReportsBloc>(),
                                child: const InventoryReportPage(),
                              ),
                        ),
                      ),
                ),
                _ReportCard(
                  title: 'Payment Report',
                  description: 'Track payments and outstanding amounts',
                  icon: Icons.payment,
                  color: Colors.orange,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BlocProvider.value(
                                value: context.read<ReportsBloc>(),
                                child: const PaymentReportPage(),
                              ),
                        ),
                      ),
                ),
                _ReportCard(
                  title: 'Business Report',
                  description: 'Overall business performance metrics',
                  icon: Icons.business,
                  color: Colors.purple,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BlocProvider.value(
                                value: context.read<ReportsBloc>(),
                                child: const BusinessReportPage(),
                              ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
