import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/payment_history.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/core/utils/currency_helper.dart';
import 'package:billmate/core/widgets/smart_deletion_widgets.dart';

class PaymentManagementPage extends StatelessWidget {
  final Invoice invoice;

  const PaymentManagementPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              getIt<BillingBloc>()
                ..add(LoadPaymentHistoryByInvoice(invoice.id!)),
      child: PaymentManagementView(invoice: invoice),
    );
  }
}

class PaymentManagementView extends StatefulWidget {
  final Invoice invoice;

  const PaymentManagementView({super.key, required this.invoice});

  @override
  State<PaymentManagementView> createState() => _PaymentManagementViewState();
}

class _PaymentManagementViewState extends State<PaymentManagementView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  bool _isProcessing = false;

  // Store payment history to calculate totals
  List<PaymentHistory> _paymentHistory = [];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.money},
    {'value': 'card', 'label': 'Card', 'icon': Icons.credit_card},
    {'value': 'upi', 'label': 'UPI', 'icon': Icons.qr_code},
    {'value': 'cheque', 'label': 'Cheque', 'icon': Icons.receipt_long},
    {'value': 'neft', 'label': 'NEFT', 'icon': Icons.account_balance},
    {'value': 'rtgs', 'label': 'RTGS', 'icon': Icons.swap_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Add listener to amount controller for real-time preview updates
    _amountController.addListener(() {
      setState(() {}); // Trigger rebuild to update preview
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: _handleBlocState,
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: const Text(
        'Payment Management',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<BillingBloc>().add(
              LoadPaymentHistoryByInvoice(widget.invoice.id!),
            );
          },
        ),
      ],
    );
  }

  void _handleBlocState(BuildContext context, BillingState state) {
    if (state is PaymentHistoryLoaded) {
      setState(() {
        _isProcessing = false;
        _paymentHistory = state.paymentHistory;
      });
    } else if (state is BillingSuccess) {
      setState(() => _isProcessing = false);
      _showSuccessMessage(context, 'Payment recorded successfully!');
      _clearForm();
      // Reload payment history to get updated totals
      context.read<BillingBloc>().add(
        LoadPaymentHistoryByInvoice(widget.invoice.id!),
      );
      // Update invoice with new payment totals
      _updateInvoicePaymentStatus();
    } else if (state is BillingError) {
      setState(() => _isProcessing = false);
      _showErrorMessage(context, state.message);
    }
  }

  Widget _buildBody(BuildContext context, BillingState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceCard(),
              const SizedBox(height: 24),
              _buildPaymentForm(),
              const SizedBox(height: 24),
              _buildPaymentHistory(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard() {
    final totalPaid = _calculateTotalPaid();
    final remainingAmount = widget.invoice.totalAmount - totalPaid;
    final paymentStatus = _getPaymentStatus(totalPaid);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice #${widget.invoice.invoiceNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(paymentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAmountRow(
              'Total Amount:',
              widget.invoice.totalAmount,
              Colors.white70,
            ),
            const SizedBox(height: 8),
            _buildAmountRow('Paid Amount:', totalPaid, Colors.green[200]!),
            const SizedBox(height: 8),
            _buildAmountRow(
              'Remaining:',
              remainingAmount,
              remainingAmount > Decimal.zero
                  ? Colors.orange[200]!
                  : Colors.green[200]!,
            ),
            const SizedBox(height: 16),
            _buildProgressBar(totalPaid, widget.invoice.totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, Decimal amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        Text(
          CurrencyHelper.formatCurrency(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Decimal paid, Decimal total) {
    final progress = total > Decimal.zero ? (paid / total).toDouble() : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Progress',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.orange,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% Complete',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Add New Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 16),
              _buildDateSelector(),
              const SizedBox(height: 16),
              if (_needsReference()) ...[
                _buildReferenceField(),
                const SizedBox(height: 16),
              ],
              _buildNotesField(),
              const SizedBox(height: 20),
              _buildPaymentPreview(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    final remainingAmount = widget.invoice.totalAmount - _calculateTotalPaid();

    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Payment Amount',
        hintText: 'Enter amount to pay',
        prefixIcon: const Icon(Icons.currency_rupee),
        suffixText: 'Max: ${CurrencyHelper.formatCurrency(remainingAmount)}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        helperText:
            remainingAmount <= Decimal.zero
                ? 'This invoice is fully paid'
                : 'Remaining balance: ${CurrencyHelper.formatCurrency(remainingAmount)}',
        helperStyle: TextStyle(
          color:
              remainingAmount <= Decimal.zero ? Colors.green : Colors.grey[600],
        ),
      ),
      enabled: remainingAmount > Decimal.zero, // Disable if fully paid
      validator: (value) {
        if (remainingAmount <= Decimal.zero) {
          return 'This invoice is already fully paid';
        }
        if (value == null || value.isEmpty) {
          return 'Please enter payment amount';
        }
        final amount = Decimal.tryParse(value);
        if (amount == null || amount <= Decimal.zero) {
          return 'Please enter a valid amount';
        }
        if (amount > remainingAmount) {
          return 'Amount (${CurrencyHelper.formatCurrency(amount)}) cannot exceed remaining balance (${CurrencyHelper.formatCurrency(remainingAmount)})';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method['value'];
                return GestureDetector(
                  onTap:
                      () => setState(
                        () => _selectedPaymentMethod = method['value'],
                      ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          method['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          method['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Date',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _referenceController,
      decoration: InputDecoration(
        labelText: _getReferenceLabel(),
        hintText: _getReferencePlaceholder(),
        prefixIcon: const Icon(Icons.receipt),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator:
          _needsReference()
              ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${_getReferenceLabel().toLowerCase()}';
                }
                return null;
              }
              : null,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes about this payment...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildPaymentPreview() {
    final currentAmount =
        _amountController.text.isEmpty
            ? Decimal.zero
            : Decimal.tryParse(_amountController.text) ?? Decimal.zero;

    if (currentAmount <= Decimal.zero) {
      return const SizedBox.shrink();
    }

    final currentPaid = _calculateTotalPaid();
    final newPaidAmount = currentPaid + currentAmount;
    final remainingAfterPayment = widget.invoice.totalAmount - newPaidAmount;
    final willBeFullyPaid = remainingAfterPayment <= Decimal.zero;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewRow('Current Paid:', currentPaid),
          _buildPreviewRow(
            'Payment Amount:',
            currentAmount,
            isHighlighted: true,
          ),
          const Divider(height: 16),
          _buildPreviewRow('New Total Paid:', newPaidAmount, isTotal: true),
          _buildPreviewRow(
            'Remaining Balance:',
            remainingAfterPayment < Decimal.zero
                ? Decimal.zero
                : remainingAfterPayment,
            isRemaining: true,
          ),
          if (willBeFullyPaid) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '✓ Invoice will be marked as PAID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    String label,
    Decimal amount, {
    bool isHighlighted = false,
    bool isTotal = false,
    bool isRemaining = false,
  }) {
    final color =
        isHighlighted
            ? Colors.blue[700]
            : isTotal
            ? Colors.green[700]
            : isRemaining
            ? (amount > Decimal.zero ? Colors.orange[700] : Colors.green[700])
            : Colors.grey[700];

    final fontWeight =
        isTotal || isHighlighted ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
          Text(
            CurrencyHelper.formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final remainingAmount = widget.invoice.totalAmount - _calculateTotalPaid();
    final isFullyPaid = remainingAmount <= Decimal.zero;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isProcessing || isFullyPaid) ? null : _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFullyPaid ? Colors.grey : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child:
            _isProcessing
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  isFullyPaid ? 'Invoice Fully Paid' : 'Record Payment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildPaymentHistory(BillingState state) {
    if (state is PaymentHistoryLoaded) {
      final payments = state.paymentHistory;

      if (payments.isEmpty) {
        return _buildEmptyPaymentHistory();
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${payments.length} payments',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...payments.map((payment) => _buildPaymentHistoryItem(payment)),
            ],
          ),
        ),
      );
    }

    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEmptyPaymentHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Payments Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first payment to get started',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryItem(PaymentHistory payment) {
    return SmartDeletableItem(
      canDelete: true,
      canEdit: false,
      deleteConfirmationTitle: 'Delete Payment',
      deleteConfirmationMessage:
          'Are you sure you want to delete this payment record of ${CurrencyHelper.formatCurrency(payment.paymentAmount)}? This action cannot be undone and will affect the invoice balance.',
      onDelete: () => _deletePayment(payment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPaymentMethodIcon(payment.paymentMethod),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyHelper.formatCurrency(payment.paymentAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        payment.paymentMethod.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (payment.paymentReference?.isNotEmpty == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            payment.paymentReference!,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (payment.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      payment.notes!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
    );
  }

  // Smart deletion method for payment history
  void _deletePayment(PaymentHistory payment) {
    context.read<BillingBloc>().add(DeletePaymentHistory(payment.id!));

    // Reload payment history after deletion
    context.read<BillingBloc>().add(
      LoadPaymentHistoryByInvoice(widget.invoice.id!),
    );

    _showSuccessMessage(context, 'Payment deleted successfully!');
  }

  // Helper methods
  Decimal _calculateTotalPaid() {
    // Calculate total from actual payment history
    return _paymentHistory.fold(
      Decimal.zero,
      (total, payment) => total + payment.paymentAmount,
    );
  }

  String _getPaymentStatus(Decimal totalPaid) {
    if (totalPaid >= widget.invoice.totalAmount) {
      return 'PAID';
    } else if (totalPaid > Decimal.zero) {
      return 'PARTIAL';
    } else {
      return 'UNPAID';
    }
  }

  void _updateInvoicePaymentStatus() {
    final totalPaid = _calculateTotalPaid();
    final paymentStatus = _getPaymentStatus(totalPaid);

    // Update the invoice with new payment information
    final updatedInvoice = widget.invoice.copyWith(
      paidAmount: totalPaid,
      paymentStatus: paymentStatus.toLowerCase(),
      paymentDate: paymentStatus == 'PAID' ? DateTime.now() : null,
    );

    // Update the invoice in the database
    context.read<BillingBloc>().add(UpdateInvoice(updatedInvoice));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'PARTIAL':
        return Colors.orange;
      case 'UNPAID':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _needsReference() {
    return ['cheque', 'upi', 'neft', 'rtgs'].contains(_selectedPaymentMethod);
  }

  String _getReferenceLabel() {
    switch (_selectedPaymentMethod) {
      case 'cheque':
        return 'Cheque Number';
      case 'upi':
        return 'UPI Transaction ID';
      case 'neft':
        return 'NEFT Reference';
      case 'rtgs':
        return 'RTGS Reference';
      default:
        return 'Reference';
    }
  }

  String _getReferencePlaceholder() {
    switch (_selectedPaymentMethod) {
      case 'cheque':
        return 'Enter cheque number';
      case 'upi':
        return 'Enter UPI transaction ID';
      case 'neft':
        return 'Enter NEFT reference number';
      case 'rtgs':
        return 'Enter RTGS reference number';
      default:
        return 'Enter reference';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.qr_code;
      case 'cheque':
        return Icons.receipt_long;
      case 'neft':
        return Icons.account_balance;
      case 'rtgs':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitPayment() {
    if (!_formKey.currentState!.validate()) return;

    // Double-check remaining amount validation
    final remainingAmount = widget.invoice.totalAmount - _calculateTotalPaid();
    final amount = Decimal.parse(_amountController.text);

    if (amount > remainingAmount) {
      _showErrorMessage(
        context,
        'Payment amount (${CurrencyHelper.formatCurrency(amount)}) cannot exceed remaining balance (${CurrencyHelper.formatCurrency(remainingAmount)})',
      );
      return;
    }

    if (remainingAmount <= Decimal.zero) {
      _showErrorMessage(context, 'This invoice is already fully paid');
      return;
    }

    setState(() => _isProcessing = true);

    final paymentHistory = PaymentHistory(
      invoiceId: widget.invoice.id!,
      paymentAmount: amount,
      paymentMethod: _selectedPaymentMethod,
      paymentDate: _selectedDate,
      paymentReference:
          _referenceController.text.isEmpty ? null : _referenceController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<BillingBloc>().add(CreatePaymentHistory(paymentHistory));
  }

  void _clearForm() {
    _amountController.clear();
    _referenceController.clear();
    _notesController.clear();
    setState(() {
      _selectedPaymentMethod = 'cash';
      _selectedDate = DateTime.now();
    });
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
