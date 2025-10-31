import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/repositories/billing_repository.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/presentation/pages/payment_management_page.dart';
import 'package:billmate/features/billing/services/pdf_service.dart';
import 'package:billmate/core/di/injection_container.dart';

class InvoiceDetailPage extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BillingBloc>(),
      child: InvoiceDetailView(invoice: invoice),
    );
  }
}

class InvoiceDetailView extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailView({super.key, required this.invoice});

  @override
  State<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends State<InvoiceDetailView> {
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController =
      TextEditingController();
  late Invoice _currentInvoice;
  bool _isEditingCustomer = false;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    _paidAmountController.text =
        (_currentInvoice.paidAmount ?? Decimal.zero).toString();

    // Initialize customer fields
    _loadCustomerData();

    // Load payment history for this invoice
    if (_currentInvoice.id != null) {
      context.read<BillingBloc>().add(
        LoadPaymentHistoryByInvoice(_currentInvoice.id!),
      );
    }
  }

  Future<void> _loadCustomerData() async {
    String? customerName = _currentInvoice.customerName;
    String? customerEmail = _currentInvoice.customerEmail;

    // If invoice has a customer ID and no stored name, fetch the customer details
    if (_currentInvoice.customerId != null && customerName == null) {
      try {
        final billingRepo = getIt<BillingRepository>();
        final customer = await billingRepo.getCustomerById(
          _currentInvoice.customerId!,
        );
        customerName = customer?.name;
        customerEmail = customer?.email;
      } catch (e) {
        // If customer not found, continue without customer details
      }
    }

    setState(() {
      _customerNameController.text = customerName ?? 'Walk-in Customer';
      _customerEmailController.text = customerEmail ?? '';
    });
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'pending':
      default:
        return AppColors.error;
    }
  }

  void _openPaymentManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentManagementPage(invoice: _currentInvoice),
      ),
    ).then((result) {
      // Refresh the invoice data when returning from payment management
      if (mounted && _currentInvoice.id != null) {
        context.read<BillingBloc>().add(
          LoadPaymentHistoryByInvoice(_currentInvoice.id!),
        );
      }
    });
  }

  Future<void> _updateCustomerInfo() async {
    if (_currentInvoice.id == null) return;

    try {
      final billingRepo = getIt<BillingRepository>();

      // Update the invoice with new customer name and email
      final updatedInvoice = _currentInvoice.copyWith(
        customerName:
            _customerNameController.text.trim().isEmpty
                ? null
                : _customerNameController.text.trim(),
        customerEmail:
            _customerEmailController.text.trim().isEmpty
                ? null
                : _customerEmailController.text.trim(),
      );

      await billingRepo.updateInvoice(updatedInvoice);

      setState(() {
        _currentInvoice = updatedInvoice;
        _isEditingCustomer = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer information updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update customer: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _printInvoice() async {
    // Show dialog to let user choose what to include in the invoice
    final options = await showDialog<Map<String, bool>>(
      context: context,
      builder: (BuildContext context) {
        return _PrintOptionsDialog();
      },
    );

    // If user cancelled the dialog, don't print
    if (options == null) return;

    // Use the customer name and email from the text controllers
    // This ensures we print the latest values (even if not yet saved)
    String? customerName =
        _customerNameController.text.trim().isEmpty
            ? null
            : _customerNameController.text.trim();
    String? customerEmail =
        _customerEmailController.text.trim().isEmpty
            ? null
            : _customerEmailController.text.trim();

    PdfService.generateAndPrintInvoice(
      _currentInvoice,
      customerName: customerName,
      customerEmail: customerEmail,
      showTax: options['showTax'] ?? true,
      showAddress: options['showAddress'] ?? true,
      showPhone: options['showPhone'] ?? true,
      showEmail: options['showEmail'] ?? true,
      showGstin: options['showGstin'] ?? true,
    );
  }

  Future<void> _editInvoiceItem(int index, InvoiceItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditItemDialog(item: item),
    );

    if (result != null && mounted) {
      try {
        final updatedItems = List<InvoiceItem>.from(_currentInvoice.items);

        // Calculate new line total
        final quantity = Decimal.parse(result['quantity'].toString());
        final unitPrice = Decimal.parse(result['unitPrice'].toString());
        final discountPercent = Decimal.parse(
          result['discountPercent']?.toString() ?? '0',
        );
        final taxRate = Decimal.parse(result['taxRate'].toString());

        final subtotal = unitPrice * quantity;
        final discountAmount =
            subtotal * (discountPercent / Decimal.fromInt(100)).toDecimal();
        final lineTotal = subtotal - discountAmount;

        updatedItems[index] = item.copyWith(
          quantity: quantity,
          unitPrice: unitPrice,
          discountPercent: discountPercent,
          taxRate: taxRate,
          lineTotal: lineTotal,
        );

        // Recalculate totals
        final subtotalAmount = updatedItems.fold<Decimal>(
          Decimal.zero,
          (sum, item) => sum + item.lineTotal,
        );

        final taxAmount = updatedItems.fold<Decimal>(Decimal.zero, (sum, item) {
          final itemTotal = item.lineTotal;
          final itemTax =
              itemTotal * (item.taxRate / Decimal.fromInt(100)).toDecimal();
          return sum + itemTax;
        });

        final totalAmount = subtotalAmount + taxAmount;

        final updatedInvoice = _currentInvoice.copyWith(
          items: updatedItems,
          subtotal: subtotalAmount,
          taxAmount: taxAmount,
          totalAmount: totalAmount,
        );

        final billingRepo = getIt<BillingRepository>();
        await billingRepo.updateInvoice(updatedInvoice);

        setState(() {
          _currentInvoice = updatedInvoice;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update item: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteInvoiceItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: const Text(
              'Are you sure you want to delete this item from the invoice?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        if (_currentInvoice.items.length <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot delete the last item from the invoice'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final updatedItems = List<InvoiceItem>.from(_currentInvoice.items);
        updatedItems.removeAt(index);

        // Recalculate totals
        final subtotalAmount = updatedItems.fold<Decimal>(
          Decimal.zero,
          (sum, item) => sum + item.lineTotal,
        );

        final taxAmount = updatedItems.fold<Decimal>(Decimal.zero, (sum, item) {
          final itemTotal = item.lineTotal;
          final itemTax =
              itemTotal * (item.taxRate / Decimal.fromInt(100)).toDecimal();
          return sum + itemTax;
        });

        final totalAmount = subtotalAmount + taxAmount;

        final updatedInvoice = _currentInvoice.copyWith(
          items: updatedItems,
          subtotal: subtotalAmount,
          taxAmount: taxAmount,
          totalAmount: totalAmount,
        );

        final billingRepo = getIt<BillingRepository>();
        await billingRepo.updateInvoice(updatedInvoice);

        setState(() {
          _currentInvoice = updatedInvoice;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete item: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final remainingAmount =
        _currentInvoice.totalAmount -
        (_currentInvoice.paidAmount ?? Decimal.zero);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Invoice ${_currentInvoice.invoiceNumber}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _printInvoice,
            icon: const Icon(Icons.print, color: AppColors.primary),
            tooltip: 'Print Invoice',
          ),
          IconButton(
            onPressed: _openPaymentManagement,
            icon: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.success,
            ),
            tooltip: 'Manage Payments',
          ),
        ],
      ),
      body: BlocListener<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BillingSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Payment Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payment Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _currentInvoice.paymentStatus,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentInvoice.paymentStatus.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Payment Method',
                      _currentInvoice.paymentMethod,
                    ),
                    if (_currentInvoice.paymentDate != null)
                      _buildInfoRow(
                        'Payment Date',
                        dateFormatter.format(_currentInvoice.paymentDate!),
                      ),
                    _buildInfoRow(
                      'Total Amount',
                      '₹${_currentInvoice.totalAmount.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Paid Amount',
                      '₹${(_currentInvoice.paidAmount ?? Decimal.zero).toStringAsFixed(2)}',
                    ),
                    if (remainingAmount > Decimal.zero)
                      _buildInfoRow(
                        'Remaining Amount',
                        '₹${remainingAmount.toStringAsFixed(2)}',
                        valueColor: AppColors.error,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Customer Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Customer Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingCustomer = !_isEditingCustomer;
                              if (!_isEditingCustomer) {
                                // Cancel editing - reload original data
                                _loadCustomerData();
                              }
                            });
                          },
                          icon: Icon(
                            _isEditingCustomer ? Icons.close : Icons.edit,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          tooltip: _isEditingCustomer ? 'Cancel' : 'Edit',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isEditingCustomer) ...[
                      TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customerEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Email (Optional)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateCustomerInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ] else ...[
                      _buildInfoRow(
                        'Customer Name',
                        _customerNameController.text.isEmpty
                            ? 'Walk-in Customer'
                            : _customerNameController.text,
                      ),
                      if (_customerEmailController.text.isNotEmpty)
                        _buildInfoRow(
                          'Customer Email',
                          _customerEmailController.text,
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Invoice Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Invoice Number',
                      _currentInvoice.invoiceNumber,
                    ),
                    _buildInfoRow(
                      'Invoice Date',
                      dateFormatter.format(_currentInvoice.invoiceDate),
                    ),
                    if (_currentInvoice.dueDate != null)
                      _buildInfoRow(
                        'Due Date',
                        dateFormatter.format(_currentInvoice.dueDate!),
                      ),
                    if (_currentInvoice.placeOfSupply != null)
                      _buildInfoRow(
                        'Place of Supply',
                        _currentInvoice.placeOfSupply!,
                      ),
                    if (_currentInvoice.notes != null)
                      _buildInfoRow('Notes', _currentInvoice.notes!),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Items List - Professional Table Format
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Price',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Tax %',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'Total',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Rows
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.borderColor.withValues(alpha: 0.5),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        children:
                            _currentInvoice.items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isLast =
                                  index == _currentInvoice.items.length - 1;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      index.isEven
                                          ? Colors.white
                                          : AppColors.background,
                                  border:
                                      !isLast
                                          ? const Border(
                                            bottom: BorderSide(
                                              color: AppColors.borderColor,
                                              width: 0.5,
                                            ),
                                          )
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Item #${item.itemId}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₹${item.unitPrice.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${item.taxRate}%',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₹${item.lineTotal.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    // Edit and Delete buttons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_rounded,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed:
                                              () =>
                                                  _editInvoiceItem(index, item),
                                          tooltip: 'Edit item',
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_rounded,
                                            size: 18,
                                            color: AppColors.error,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed:
                                              () => _deleteInvoiceItem(index),
                                          tooltip: 'Delete item',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Amount Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Subtotal',
                      '₹${_currentInvoice.subtotal.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Tax Amount',
                      '₹${_currentInvoice.taxAmount.toStringAsFixed(2)}',
                    ),
                    if (_currentInvoice.discountAmount > Decimal.zero)
                      _buildInfoRow(
                        'Discount',
                        '₹${_currentInvoice.discountAmount.toStringAsFixed(2)}',
                      ),
                    const Divider(),
                    _buildInfoRow(
                      'Total Amount',
                      '₹${_currentInvoice.totalAmount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              // Payment History Section
              if (_currentInvoice.paymentStatus != 'pending') ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Payment History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentHistorySection(),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        if (state is PaymentHistoryLoaded) {
          if (state.paymentHistory.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Center(
                child: Text(
                  'No payment records found',
                  style: TextStyle(color: AppColors.textHint),
                ),
              ),
            );
          }

          return Column(
            children:
                state.paymentHistory.asMap().entries.map((entry) {
                  final payment = entry.value;
                  final isLast = entry.key == state.paymentHistory.length - 1;

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            _getPaymentMethodIcon(payment.paymentMethod),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₹${payment.paymentAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(payment.paymentDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        payment.paymentMethod.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (payment.paymentReference != null)
                                        Text(
                                          'Ref: ${payment.paymentReference}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (payment.notes != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      payment.notes!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
          );
        } else if (state is BillingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _getPaymentMethodIcon(String method) {
    IconData iconData;
    Color color;

    switch (method.toLowerCase()) {
      case 'cash':
        iconData = Icons.money;
        color = AppColors.success;
        break;
      case 'card':
        iconData = Icons.credit_card;
        color = AppColors.primary;
        break;
      case 'upi':
        iconData = Icons.qr_code;
        color = AppColors.warning;
        break;
      case 'cheque':
        iconData = Icons.receipt_long;
        color = AppColors.textSecondary;
        break;
      case 'bank_transfer':
        iconData = Icons.account_balance;
        color = AppColors.primary;
        break;
      case 'digital_wallet':
        iconData = Icons.wallet;
        color = AppColors.success;
        break;
      default:
        iconData = Icons.payment;
        color = AppColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}

// Print Options Dialog Widget
class _PrintOptionsDialog extends StatefulWidget {
  const _PrintOptionsDialog();

  @override
  State<_PrintOptionsDialog> createState() => _PrintOptionsDialogState();
}

class _PrintOptionsDialogState extends State<_PrintOptionsDialog> {
  bool showTax = true;
  bool showAddress = true;
  bool showPhone = true;
  bool showEmail = true;
  bool showGstin = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Print Options',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Display Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCheckboxOption(
              'Show Tax Columns',
              'Display tax rate and amount columns',
              showTax,
              (value) => setState(() => showTax = value ?? true),
            ),
            const Divider(height: 24),
            const Text(
              'Issuer Details to Show',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCheckboxOption(
              'Business Address',
              'Show business address in header',
              showAddress,
              (value) => setState(() => showAddress = value ?? true),
            ),
            _buildCheckboxOption(
              'Phone Number',
              'Show phone number in header',
              showPhone,
              (value) => setState(() => showPhone = value ?? true),
            ),
            _buildCheckboxOption(
              'Email Address',
              'Show email address in header',
              showEmail,
              (value) => setState(() => showEmail = value ?? true),
            ),
            _buildCheckboxOption(
              'GSTIN',
              'Show GST identification number',
              showGstin,
              (value) => setState(() => showGstin = value ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop({
              'showTax': showTax,
              'showAddress': showAddress,
              'showPhone': showPhone,
              'showEmail': showEmail,
              'showGstin': showGstin,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.print, size: 20),
          label: const Text('Print Invoice'),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
    String title,
    String subtitle,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

// Edit Item Dialog
class _EditItemDialog extends StatefulWidget {
  final InvoiceItem item;

  const _EditItemDialog({required this.item});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxRateController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice.toString(),
    );
    _discountController = TextEditingController(
      text: widget.item.discountPercent.toString(),
    );
    _taxRateController = TextEditingController(
      text: widget.item.taxRate.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (Decimal.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (Decimal.parse(value) <= Decimal.zero) {
                    return 'Quantity must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Unit Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit price';
                  }
                  if (Decimal.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (Decimal.parse(value) < Decimal.zero) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Discount %',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.discount),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter discount percentage';
                  }
                  if (Decimal.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  final discount = Decimal.parse(value);
                  if (discount < Decimal.zero ||
                      discount > Decimal.fromInt(100)) {
                    return 'Discount must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxRateController,
                decoration: const InputDecoration(
                  labelText: 'Tax Rate %',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tax rate';
                  }
                  if (Decimal.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (Decimal.parse(value) < Decimal.zero) {
                    return 'Tax rate cannot be negative';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'quantity': _quantityController.text,
                'unitPrice': _priceController.text,
                'discountPercent': _discountController.text,
                'taxRate': _taxRateController.text,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
