import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:billmate/features/billing/services/pdf_service.dart';
import 'package:billmate/core/di/injection_container.dart';

class CreateInvoicePage extends StatelessWidget {
  const CreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<BillingBloc>()),
        BlocProvider(
          create: (context) => getIt<InventoryBloc>()..add(LoadAllItems()),
        ),
      ],
      child: const CreateInvoiceView(),
    );
  }
}

class CreateInvoiceView extends StatefulWidget {
  const CreateInvoiceView({super.key});

  @override
  State<CreateInvoiceView> createState() => _CreateInvoiceViewState();
}

class _CreateInvoiceViewState extends State<CreateInvoiceView> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();

  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _paymentStatus = 'pending';
  String _paymentMethod = 'cash';
  DateTime? _paymentDate;
  Decimal? _paidAmount;
  String? _placeOfSupply;
  bool _isGstInvoice = true;

  final List<InvoiceItem> _items = [];

  Decimal get _subtotal =>
      _items.fold(Decimal.zero, (sum, item) => sum + item.lineTotal);

  Decimal get _taxAmount => _items.fold(Decimal.zero, (sum, item) {
    try {
      // Convert to double for calculation to avoid Rational issues
      final lineTotal = double.parse(item.lineTotal.toString());
      final taxRate = double.parse(item.taxRate.toString());

      // Calculate tax using doubles
      final taxAmount = lineTotal * (taxRate / 100);

      // Convert back to Decimal and add to sum
      final taxDecimal = Decimal.parse(taxAmount.toStringAsFixed(2));
      final sumDouble = double.parse(sum.toString());
      final newSum = sumDouble + double.parse(taxDecimal.toString());

      return Decimal.parse(newSum.toStringAsFixed(2));
    } catch (e) {
      return sum;
    }
  });

  Decimal get _totalAmount {
    try {
      final subtotal = double.parse(_subtotal.toString());
      final taxAmount = double.parse(_taxAmount.toString());
      final total = subtotal + taxAmount;
      return Decimal.parse(total.toStringAsFixed(2));
    } catch (e) {
      return Decimal.zero;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  Decimal _calculateLineTotal(
    Decimal unitPrice,
    Decimal quantity,
    Decimal discountPercent,
  ) {
    try {
      // Convert to double for calculation to avoid Rational issues
      final unitPriceDouble = double.parse(unitPrice.toString());
      final quantityDouble = double.parse(quantity.toString());
      final discountDouble = double.parse(discountPercent.toString());

      // Calculate using doubles
      final subtotal = unitPriceDouble * quantityDouble;
      final discountAmount = subtotal * (discountDouble / 100);
      final finalAmount = subtotal - discountAmount;

      // Convert back to Decimal with proper precision
      return Decimal.parse(finalAmount.toStringAsFixed(2));
    } catch (e) {
      return Decimal.zero;
    }
  }

  void _addItem() {
    final inventoryBloc = context.read<InventoryBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: _AddItemDialog(
              onItemAdded: (item) {
                setState(() {
                  // Check if item with same itemId and discount already exists
                  final existingIndex = _items.indexWhere((existingItem) {
                    final sameItemId = existingItem.itemId == item.itemId;
                    final sameDiscount =
                        (existingItem.discountPercent.toDouble() -
                                item.discountPercent.toDouble())
                            .abs() <
                        0.01;
                    return sameItemId && sameDiscount;
                  });

                  if (existingIndex != -1) {
                    // Update existing item's quantity and recalculate line total
                    final existingItem = _items[existingIndex];
                    final newQuantity = existingItem.quantity + item.quantity;

                    // Recalculate line total with new quantity
                    final updatedItem = InvoiceItem(
                      invoiceId: existingItem.invoiceId,
                      itemId: existingItem.itemId,
                      quantity: newQuantity,
                      unitPrice: existingItem.unitPrice,
                      discountPercent: existingItem.discountPercent,
                      taxRate: existingItem.taxRate,
                      lineTotal: _calculateLineTotal(
                        existingItem.unitPrice,
                        newQuantity,
                        existingItem.discountPercent,
                      ),
                      createdAt: existingItem.createdAt,
                      itemName: existingItem.itemName,
                      itemDescription: existingItem.itemDescription,
                      unit: existingItem.unit,
                    );

                    _items[existingIndex] = updatedItem;

                    // Show update message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.itemName} quantity updated (${newQuantity})',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // Add new item
                    _items.add(item);

                    // Show add message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.itemName} added to invoice'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                });
              },
              existingItems: _items,
            ),
          ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _showPartialPaymentDialog() async {
    final TextEditingController paidAmountController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Partial Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: ₹${_totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: paidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Paid Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _paymentStatus = 'pending';
                  });
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final paidAmount = Decimal.tryParse(
                    paidAmountController.text,
                  );
                  if (paidAmount == null || paidAmount < Decimal.zero) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                      ),
                    );
                    return;
                  }

                  if (paidAmount > _totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paid amount cannot exceed total amount'),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _paidAmount = paidAmount;
                    _paymentDate = DateTime.now();
                  });

                  Navigator.pop(context);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_customerNameController.text.trim().isEmpty &&
          _customerEmailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter customer name or email')),
        );
        return;
      }

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final invoice = Invoice(
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        customerId: null, // No customer ID for temporary customers
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: Decimal.zero,
        totalAmount: _totalAmount,
        paymentStatus: _paymentStatus,
        paymentMethod: _paymentMethod,
        paymentDate: _paymentDate,
        paidAmount: _paymentStatus == 'paid' ? _totalAmount : _paidAmount,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        isGstInvoice: _isGstInvoice,
        placeOfSupply: _placeOfSupply,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _items,
      );

      context.read<BillingBloc>().add(CreateInvoice(invoice));
    }
  }

  void _previewAndPrint() {
    if (_formKey.currentState!.validate()) {
      if (_customerNameController.text.trim().isEmpty &&
          _customerEmailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter customer name or email')),
        );
        return;
      }

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final invoice = Invoice(
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        customerId: null,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: Decimal.zero,
        totalAmount: _totalAmount,
        paymentStatus: _paymentStatus,
        paymentMethod: _paymentMethod,
        paymentDate: _paymentDate,
        paidAmount: _paymentStatus == 'paid' ? _totalAmount : _paidAmount,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        isGstInvoice: _isGstInvoice,
        placeOfSupply: _placeOfSupply,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _items,
      );

      // Generate PDF preview
      PdfService.generateAndPrintInvoice(
        invoice,
        customerName:
            _customerNameController.text.trim().isEmpty
                ? null
                : _customerNameController.text.trim(),
        customerEmail:
            _customerEmailController.text.trim().isEmpty
                ? null
                : _customerEmailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Create Invoice',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton.icon(
            onPressed: _previewAndPrint,
            icon: const Icon(Icons.print, color: AppColors.secondary),
            label: const Text(
              'Print',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _saveInvoice,
            icon: const Icon(Icons.save, color: AppColors.primary),
            label: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          } else if (state is InvoiceCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invoice created successfully!')),
            );
            Navigator.of(context).pop();
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerSection(),
                const SizedBox(height: 24),
                _buildInvoiceDetailsSection(),
                const SizedBox(height: 24),
                _buildItemsSection(),
                const SizedBox(height: 24),
                _buildSummarySection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 100), // Space for floating action button
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          _items.isEmpty
              ? FloatingActionButton.extended(
                heroTag: "addFirstItemFAB",
                onPressed: _addItem,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Add First Item'),
              )
              : FloatingActionButton(
                heroTag: "addItemFAB",
                onPressed: _addItem,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
                tooltip: 'Add Another Item',
              ),
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
                hintText: 'Enter customer name',
              ),
              validator: (value) {
                // At least one of name or email must be provided
                if ((value == null || value.trim().isEmpty) &&
                    _customerEmailController.text.trim().isEmpty) {
                  return 'Please enter customer name or email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerEmailController,
              decoration: const InputDecoration(
                labelText: 'Customer Email',
                border: OutlineInputBorder(),
                hintText: 'Enter customer email',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                // If email is provided, validate its format
                if (value != null && value.trim().isNotEmpty) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer details are only for this invoice and will not be saved permanently.',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
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

  Widget _buildInvoiceDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Invoice Date'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_invoiceDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _invoiceDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _invoiceDate = date;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      _dueDate != null
                          ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _dueDate ??
                            _invoiceDate.add(const Duration(days: 30)),
                        firstDate: _invoiceDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _dueDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('GST Invoice'),
              value: _isGstInvoice,
              onChanged: (value) {
                setState(() {
                  _isGstInvoice = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank Transfer'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(
                        value: 'partial',
                        child: Text('Partial'),
                      ),
                      DropdownMenuItem(
                        value: 'overdue',
                        child: Text('Overdue'),
                      ),
                    ],
                    onChanged: (value) async {
                      setState(() {
                        _paymentStatus = value!;
                        // If payment is marked as paid, set payment date to now
                        if (value == 'paid' && _paymentDate == null) {
                          _paymentDate = DateTime.now();
                        }
                      });

                      // Show partial payment dialog when partial is selected
                      if (value == 'partial') {
                        await _showPartialPaymentDialog();
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_paymentStatus == 'paid' || _paymentStatus == 'partial') ...[
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Payment Date'),
                subtitle: Text(
                  _paymentDate != null
                      ? DateFormat('dd/MM/yyyy').format(_paymentDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate ?? DateTime.now(),
                    firstDate: _invoiceDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _paymentDate = date;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_items.length} item${_items.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No items added yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the "Add Item" button to get started',
                      style: TextStyle(color: AppColors.textHint, fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Qty × Rate',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Tax',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color: AppColors.borderColor.withOpacity(0.3),
                          ),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName ?? 'Item ${item.itemId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (item.itemDescription != null)
                                      Text(
                                        item.itemDescription!,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.quantity} × ₹${item.unitPrice}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    if (item.discountPercent > Decimal.zero)
                                      Text(
                                        '${item.discountPercent}% off',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${item.taxRate}%',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₹${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 48,
                                child: IconButton(
                                  onPressed: () => _removeItem(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  tooltip: 'Remove item',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add more items to this invoice',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Subtotal:'), Text('₹${_subtotal}')],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Tax:'), Text('₹${_taxAmount}')],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₹${_totalAmount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(InvoiceItem) onItemAdded;
  final List<InvoiceItem> existingItems;

  const _AddItemDialog({
    required this.onItemAdded,
    this.existingItems = const [],
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');

  Item? _selectedItem;

  Decimal get _quantity =>
      Decimal.tryParse(_quantityController.text) ?? Decimal.one;
  Decimal get _discount =>
      Decimal.tryParse(_discountController.text) ?? Decimal.zero;
  Decimal get _unitPrice => _selectedItem?.sellingPrice ?? Decimal.zero;
  Decimal get _taxRate => _selectedItem?.taxRate ?? Decimal.zero;
  Decimal get _lineTotal {
    if (_selectedItem == null) return Decimal.zero;

    try {
      // Convert to double for calculation to avoid Rational issues
      final unitPrice = double.parse(_unitPrice.toString());
      final quantity = double.parse(_quantity.toString());
      final discount = double.parse(_discount.toString());

      // Calculate using doubles
      final subtotal = unitPrice * quantity;
      final discountAmount = subtotal * (discount / 100);
      final finalAmount = subtotal - discountAmount;

      // Convert back to Decimal with proper precision
      return Decimal.parse(finalAmount.toStringAsFixed(2));
    } catch (e) {
      return Decimal.zero;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  bool get _itemAlreadyExists {
    if (_selectedItem == null) return false;
    return widget.existingItems.any(
      (existingItem) =>
          existingItem.itemId == _selectedItem!.id! &&
          existingItem.discountPercent == _discount,
    );
  }

  InvoiceItem? get _existingItem {
    if (_selectedItem == null) return null;
    try {
      return widget.existingItems.firstWhere(
        (existingItem) =>
            existingItem.itemId == _selectedItem!.id! &&
            existingItem.discountPercent == _discount,
      );
    } catch (e) {
      return null;
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate() && _selectedItem != null) {
      final item = InvoiceItem(
        invoiceId: 0, // Will be set when invoice is created
        itemId: _selectedItem!.id!,
        quantity: _quantity,
        unitPrice: _unitPrice,
        discountPercent: _discount,
        taxRate: _taxRate,
        lineTotal: _lineTotal,
        createdAt: DateTime.now(),
        itemName: _selectedItem!.name,
        itemDescription: _selectedItem!.description,
        unit: _selectedItem!.unit,
      );

      // Add the item
      widget.onItemAdded(item);

      // Close the dialog immediately to prevent duplicate additions
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state is ItemsLoaded) {
                    return DropdownButtonFormField<Item>(
                      value: _selectedItem,
                      decoration: const InputDecoration(
                        labelText: 'Select Item',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          state.items.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                '${item.name} - ₹${item.sellingPrice}',
                              ),
                            );
                          }).toList(),
                      onChanged: (item) {
                        setState(() {
                          _selectedItem = item;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Please select an item';
                        return null;
                      },
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (Decimal.tryParse(value) == null ||
                            Decimal.parse(value) <= Decimal.zero) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final discount = Decimal.tryParse(value);
                        if (discount == null ||
                            discount < Decimal.zero ||
                            discount > Decimal.fromInt(100)) {
                          return 'Enter valid discount (0-100)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedItem != null) ...[
                const SizedBox(height: 16),
                // Show warning if item already exists
                if (_itemAlreadyExists) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This item is already in the invoice. Quantity will be added to existing entry (Current: ${_existingItem?.quantity}).',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Unit Price:'),
                            Text('₹$_unitPrice'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax Rate:'),
                            Text('$_taxRate%'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Line Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹$_lineTotal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
