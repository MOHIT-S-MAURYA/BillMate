import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/features/billing/presentation/pages/create_invoice_page.dart';
import 'package:billmate/features/billing/presentation/pages/invoice_detail_page.dart';

class InvoiceListPage extends StatelessWidget {
  final String? initialFilter;

  const InvoiceListPage({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BillingBloc>()..add(LoadAllInvoices()),
      child: InvoiceListView(initialFilter: initialFilter),
    );
  }
}

class InvoiceListView extends StatefulWidget {
  final String? initialFilter;

  const InvoiceListView({super.key, this.initialFilter});

  @override
  State<InvoiceListView> createState() => _InvoiceListViewState();
}

class _InvoiceListViewState extends State<InvoiceListView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Set initial filter if provided
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Invoice> _getFilteredInvoices(List<Invoice> invoices) {
    List<Invoice> filtered = invoices;

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((invoice) {
            return invoice.invoiceNumber.toLowerCase().contains(searchQuery) ||
                (invoice.notes?.toLowerCase().contains(searchQuery) ?? false);
          }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((invoice) {
            switch (_selectedFilter) {
              case 'Paid':
                return invoice.paymentStatus == 'paid';
              case 'Pending':
                return invoice.paymentStatus == 'pending';
              case 'Partial':
                return invoice.paymentStatus == 'partial';
              case 'Overdue':
                return invoice.paymentStatus == 'overdue';
              default:
                return true;
            }
          }).toList();
    }

    return filtered;
  }

  void _onSearch(String query) {
    setState(() {
      // The filtering will be applied automatically in _getFilteredInvoices
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Invoices',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BillingBloc>().add(LoadAllInvoices());
            },
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by invoice number, customer...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textHint,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    const Text(
                      'Filter:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              ['All', 'Paid', 'Pending', 'Partial', 'Overdue']
                                  .map(
                                    (filter) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(filter),
                                        selected: _selectedFilter == filter,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedFilter = filter;
                                          });
                                          // Apply filter logic here
                                          context.read<BillingBloc>().add(
                                            LoadAllInvoices(),
                                          );
                                        },
                                        selectedColor: AppColors.primary
                                            .withOpacity(0.2),
                                        checkmarkColor: AppColors.primary,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Invoice List
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state is BillingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is BillingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading invoices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(color: AppColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BillingBloc>().add(LoadAllInvoices());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is InvoicesLoaded) {
                  final allInvoices = state.invoices;

                  // Apply search and filter
                  final filteredInvoices = _getFilteredInvoices(allInvoices);

                  if (filteredInvoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'All'
                                ? 'No invoices found'
                                : 'No $_selectedFilter invoices found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilter == 'All'
                                ? 'Create your first invoice to get started'
                                : 'Try changing the filter or create a new invoice',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = filteredInvoices[index];
                      return _buildInvoiceCard(context, invoice);
                    },
                  );
                }

                return const Center(child: Text('Loading invoices...'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "createInvoiceFAB",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoicePage()),
          ).then((_) {
            // Refresh the list when returning from create page
            context.read<BillingBloc>().add(LoadAllInvoices());
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final formatter = NumberFormat.currency(symbol: '₹');
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailPage(invoice: invoice),
            ),
          ).then((_) {
            // Refresh the list when returning from detail page
            context.read<BillingBloc>().add(LoadAllInvoices());
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        invoice.paymentStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.paymentStatus.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(invoice.paymentStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Customer name (if available)
              if (invoice.customerId != null) ...[
                Text(
                  'Customer ID: ${invoice.customerId}',
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Date and amount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormatter.format(invoice.invoiceDate),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    formatter.format(invoice.totalAmount.toDouble()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Notes (if available)
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  invoice.notes!,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
