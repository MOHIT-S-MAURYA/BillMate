import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/features/billing/presentation/widgets/add_customer_dialog.dart';
import 'package:billmate/core/navigation/modern_navigation_widgets.dart';
import 'package:billmate/core/widgets/smart_deletion_widgets.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BillingBloc>()..add(LoadAllCustomers()),
      child: const CustomerListView(),
    );
  }
}

class CustomerListView extends StatefulWidget {
  const CustomerListView({super.key});

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<BillingBloc>().add(LoadAllCustomers());
    } else {
      context.read<BillingBloc>().add(SearchCustomers(query));
    }
  }

  void _showCustomerDetailDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => _CustomerDetailDialog(customer: customer),
    );
  }

  void _editCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<BillingBloc>(),
            child: AddCustomerDialog(
              existingCustomer: customer,
              onCustomerAdded: (updatedCustomer) {
                // Refresh the customer list
                context.read<BillingBloc>().add(LoadAllCustomers());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer updated successfully!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
    );
  }

  void _deleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text(
              'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<BillingBloc>().add(DeleteCustomer(customer.id!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer "${customer.name}" deleted'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Customers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<BillingBloc>().add(LoadAllCustomers());
            },
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search customers by name, email, phone...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
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
          ),

          // Customer List
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
                          'Error loading customers',
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
                            context.read<BillingBloc>().add(LoadAllCustomers());
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

                if (state is CustomersLoaded) {
                  final customers = state.customers;

                  if (customers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first customer to get started',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _buildCustomerCard(context, customer);
                    },
                  );
                }

                return const Center(child: Text('Loading customers...'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ModernFloatingActionButtonExtended(
        heroTag: "addCustomerFAB",
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (dialogContext) => BlocProvider.value(
                  value: context.read<BillingBloc>(),
                  child: AddCustomerDialog(
                    onCustomerAdded: (customer) {
                      // Refresh the customer list
                      context.read<BillingBloc>().add(LoadAllCustomers());
                    },
                  ),
                ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return SmartDeletableItem(
      canDelete: true,
      canEdit: true,
      deleteConfirmationTitle: 'Delete Customer',
      deleteConfirmationMessage:
          'Are you sure you want to delete customer "${customer.name}"? This action cannot be undone.',
      onDelete: () => _deleteCustomer(context, customer),
      onEdit: () => _editCustomer(context, customer),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            _showCustomerDetailDialog(context, customer);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (customer.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              customer.email!,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Contact details
                if (customer.phone != null || customer.gstin != null) ...[
                  const SizedBox(height: 12),
                  if (customer.phone != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          customer.phone!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (customer.gstin != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GSTIN: ${customer.gstin}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],

                // Address
                if (customer.address != null &&
                    customer.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.address!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerDetailDialog extends StatelessWidget {
  final Customer customer;

  const _CustomerDetailDialog({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (customer.email != null)
                        Text(
                          customer.email!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildDetailSection('Contact Information', Icons.contact_phone, [
              if (customer.phone != null)
                _buildDetailRow('Phone', customer.phone!, Icons.phone),
              if (customer.email != null)
                _buildDetailRow('Email', customer.email!, Icons.email),
            ]),

            // Business Information
            if (customer.gstin != null || customer.stateCode != null) ...[
              const SizedBox(height: 16),
              _buildDetailSection('Business Information', Icons.business, [
                if (customer.gstin != null)
                  _buildDetailRow('GSTIN', customer.gstin!, Icons.receipt_long),
                if (customer.stateCode != null)
                  _buildDetailRow(
                    'State Code',
                    customer.stateCode!,
                    Icons.location_city,
                  ),
              ]),
            ],

            // Address
            if (customer.address != null) ...[
              const SizedBox(height: 16),
              _buildDetailSection('Address', Icons.location_on, [
                _buildDetailRow('Address', customer.address!, Icons.home),
              ]),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // You could trigger edit from here
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textHint, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
