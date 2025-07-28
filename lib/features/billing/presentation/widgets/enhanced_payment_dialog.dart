import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';

class EnhancedPaymentDialog extends StatefulWidget {
  final Invoice invoice;

  const EnhancedPaymentDialog({super.key, required this.invoice});

  @override
  State<EnhancedPaymentDialog> createState() => _EnhancedPaymentDialogState();
}

class _EnhancedPaymentDialogState extends State<EnhancedPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load payment history for this invoice
    context.read<BillingBloc>().add(
      LoadPaymentHistoryByInvoice(widget.invoice.id!),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Decimal get _remainingAmount {
    return widget.invoice.totalAmount -
        (widget.invoice.paidAmount ?? Decimal.zero);
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) return;

    final paymentAmount = Decimal.parse(_amountController.text);

    // Create payment history record
    final paymentHistory = PaymentHistory(
      invoiceId: widget.invoice.id!,
      paymentAmount: paymentAmount,
      paymentMethod: _selectedPaymentMethod,
      paymentDate: _paymentDate,
      paymentReference:
          _referenceController.text.isEmpty ? null : _referenceController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save payment history - the BillingBloc will automatically update invoice status
    context.read<BillingBloc>().add(CreatePaymentHistory(paymentHistory));

    Navigator.of(context).pop(true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.payment, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Record Payment',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Invoice Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice: ${widget.invoice.invoiceNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total Amount:',
                    '₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow(
                    'Paid Amount:',
                    '₹${(widget.invoice.paidAmount ?? Decimal.zero).toStringAsFixed(2)}',
                  ),
                  _buildSummaryRow(
                    'Remaining Amount:',
                    '₹${_remainingAmount.toStringAsFixed(2)}',
                    valueColor: AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Amount',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter payment amount';
                          }
                          final amount = Decimal.tryParse(value);
                          if (amount == null || amount <= Decimal.zero) {
                            return 'Please enter a valid amount';
                          }
                          if (amount > _remainingAmount) {
                            return 'Amount cannot exceed remaining balance';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Method
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(value: 'upi', child: Text('UPI')),
                          DropdownMenuItem(
                            value: 'cheque',
                            child: Text('Cheque'),
                          ),
                          DropdownMenuItem(
                            value: 'bank_transfer',
                            child: Text('Bank Transfer'),
                          ),
                          DropdownMenuItem(
                            value: 'digital_wallet',
                            child: Text('Digital Wallet'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Payment Date'),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy').format(_paymentDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _paymentDate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Reference (for cheque, UPI, etc.)
                      if (_selectedPaymentMethod != 'cash') ...[
                        TextFormField(
                          controller: _referenceController,
                          decoration: InputDecoration(
                            labelText:
                                _selectedPaymentMethod == 'cheque'
                                    ? 'Cheque Number'
                                    : _selectedPaymentMethod == 'upi'
                                    ? 'UPI Transaction ID'
                                    : 'Reference Number',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Payment History Section
                      const Text(
                        'Payment History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentHistorySection(),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Record Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Center(
                child: Text(
                  'No payments recorded yet',
                  style: TextStyle(color: AppColors.textHint),
                ),
              ),
            );
          }

          return Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.paymentHistory.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: AppColors.borderColor),
              itemBuilder: (context, index) {
                final payment = state.paymentHistory[index];
                return ListTile(
                  leading: _getPaymentMethodIcon(payment.paymentMethod),
                  title: Text(
                    '₹${payment.paymentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${payment.paymentMethod.toUpperCase()} • ${DateFormat('dd/MM/yyyy').format(payment.paymentDate)}',
                  ),
                  trailing:
                      payment.paymentReference != null
                          ? Text(
                            payment.paymentReference!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          )
                          : null,
                );
              },
            ),
          );
        } else if (state is BillingLoading) {
          return const Center(child: CircularProgressIndicator());
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

    return Icon(iconData, color: color, size: 24);
  }
}
