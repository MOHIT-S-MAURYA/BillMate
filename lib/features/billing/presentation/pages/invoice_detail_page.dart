import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
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
  late Invoice _currentInvoice;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    _paidAmountController.text =
        (_currentInvoice.paidAmount ?? Decimal.zero).toString();
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
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

  void _showPaymentDialog() {
    final remainingAmount =
        _currentInvoice.totalAmount -
        (_currentInvoice.paidAmount ?? Decimal.zero);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount: ₹${_currentInvoice.totalAmount.toStringAsFixed(2)}',
                ),
                Text(
                  'Paid Amount: ₹${(_currentInvoice.paidAmount ?? Decimal.zero).toStringAsFixed(2)}',
                ),
                Text('Remaining: ₹${remainingAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _paidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Payment Amount',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _updatePayment(),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _updatePayment() {
    final paidAmount = Decimal.tryParse(_paidAmountController.text);
    if (paidAmount == null || paidAmount < Decimal.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final totalPaid = (_currentInvoice.paidAmount ?? Decimal.zero) + paidAmount;
    String newStatus;

    if (totalPaid >= _currentInvoice.totalAmount) {
      newStatus = 'paid';
    } else if (totalPaid > Decimal.zero) {
      newStatus = 'partial';
    } else {
      newStatus = 'pending';
    }

    final updatedInvoice = _currentInvoice.copyWith(
      paidAmount: totalPaid,
      paymentStatus: newStatus,
      paymentDate: newStatus != 'pending' ? DateTime.now() : null,
    );

    context.read<BillingBloc>().add(UpdateInvoice(updatedInvoice));
    Navigator.pop(context);

    setState(() {
      _currentInvoice = updatedInvoice;
    });
  }

  void _printInvoice() {
    PdfService.generateAndPrintInvoice(_currentInvoice);
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
          if (_currentInvoice.paymentStatus != 'paid')
            IconButton(
              onPressed: _showPaymentDialog,
              icon: const Icon(Icons.payment, color: AppColors.success),
              tooltip: 'Update Payment',
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

              // Items List
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
                    const SizedBox(height: 12),
                    ...(_currentInvoice.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item ID: ${item.itemId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Qty: ${item.quantity}'),
                                Text(
                                  'Price: ₹${item.unitPrice.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax: ${item.taxRate}%'),
                                Text(
                                  'Total: ₹${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
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
}
