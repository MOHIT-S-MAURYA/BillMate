import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/features/billing/domain/entities/invoice.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:billmate/features/billing/services/pdf_service.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/core/navigation/modern_navigation_widgets.dart';
import 'package:billmate/core/navigation/navigation_service.dart';
import 'package:billmate/core/localization/country_service.dart';
import 'package:billmate/features/billing/presentation/widgets/smart_customer_search_field.dart';

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

  // Customer related fields
  Customer? _selectedCustomer;
  String _customerName = '';
  String _customerEmail = '';

  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _paymentStatus = 'pending';
  String _paymentMethod = 'cash';
  DateTime? _paymentDate;
  Decimal? _paidAmount;
  String? _placeOfSupply;
  bool _isGstInvoice = true;
  bool _showTaxOnBill = true; // New option to show/hide tax on bill

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
    final billingBloc = context.read<BillingBloc>();

    context.showModernDialog(
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: inventoryBloc),
          BlocProvider.value(value: billingBloc),
        ],
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
                      '${item.itemName} quantity updated ($newQuantity)',
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

    return context.showModernDialog<void>(
      child: AlertDialog(
        title: const Text('Partial Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ${getIt<CountryService>().formatCurrency(_totalAmount.toDouble())}',
            ),
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
              context.goBack();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final paidAmount = Decimal.tryParse(paidAmountController.text);
              if (paidAmount == null || paidAmount < Decimal.zero) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
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

              context.goBack();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _saveInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_customerName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter customer name')),
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
        customerId:
            _selectedCustomer?.id, // Use existing customer ID if selected
        customerName:
            _customerName.trim().isEmpty ? null : _customerName.trim(),
        customerEmail:
            _customerEmail.trim().isEmpty ? null : _customerEmail.trim(),
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
        showTaxOnBill: _showTaxOnBill,
        placeOfSupply: _placeOfSupply,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _items,
      );

      context.read<BillingBloc>().add(CreateInvoice(invoice));
    }
  }

  void _previewAndPrint() async {
    if (_formKey.currentState!.validate()) {
      if (_customerName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter customer name')),
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
        customerName:
            _customerName.trim().isEmpty ? null : _customerName.trim(),
        customerEmail:
            _customerEmail.trim().isEmpty ? null : _customerEmail.trim(),
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
        showTaxOnBill: _showTaxOnBill,
        placeOfSupply: _placeOfSupply,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: _items,
      );

      // Show print options dialog
      final options = await showDialog<Map<String, bool>>(
        context: context,
        builder: (BuildContext context) {
          return _PrintOptionsDialog(defaultShowTax: _showTaxOnBill);
        },
      );

      // If user cancelled the dialog, don't print
      if (options == null) return;

      // Generate PDF preview with selected options
      PdfService.generateAndPrintInvoice(
        invoice,
        customerName:
            _customerName.trim().isEmpty ? null : _customerName.trim(),
        customerEmail:
            _customerEmail.trim().isEmpty ? null : _customerEmail.trim(),
        showTax: options['showTax'] ?? _showTaxOnBill,
        showAddress: options['showAddress'] ?? true,
        showPhone: options['showPhone'] ?? true,
        showEmail: options['showEmail'] ?? true,
        showGstin: options['showGstin'] ?? true,
      );
    }
  }

  // Helper method for email validation
  bool _isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ModernNavigationPage(
      enableSwipeBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ModernAppBar(
          title: 'Create Invoice',
          backgroundColor: AppColors.background,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            } else if (state is InvoiceCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice created successfully!')),
              );
              context.goBack();
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
                  const SizedBox(
                    height: 100,
                  ), // Space for floating action button
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: ModernFloatingActionButtonExtended(
          heroTag: "addItemFAB",
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: Text(_items.isEmpty ? 'Add First Item' : 'Add Another Item'),
        ),
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
            SmartCustomerSearchField(
              labelText: 'Customer Name *',
              hintText: 'Search existing customer or enter new name...',
              initialCustomer: _selectedCustomer,
              required: true,
              onCustomerSelected: (customer) {
                setState(() {
                  _selectedCustomer = customer;
                  if (customer != null) {
                    _customerName = customer.name;
                    _customerEmail = customer.email ?? '';
                  }
                });
              },
              onTextChanged: (text) {
                setState(() {
                  _customerName = text;
                  if (_selectedCustomer == null ||
                      _selectedCustomer!.name != text) {
                    _selectedCustomer = null;
                    _customerEmail = '';
                  }
                });
              },
            ),
            if (_selectedCustomer == null && _customerName.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Customer Email (Optional)',
                  border: const OutlineInputBorder(),
                  hintText: 'Enter customer email',
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon:
                      _customerEmail.isNotEmpty
                          ? Icon(
                            _isValidEmail(_customerEmail)
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                                _isValidEmail(_customerEmail)
                                    ? Colors.green
                                    : Colors.red,
                          )
                          : null,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _customerEmail = value;
                  });
                },
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!_isValidEmail(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _selectedCustomer != null
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _selectedCustomer != null
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedCustomer != null
                        ? Icons.check_circle
                        : Icons.info_outline,
                    color:
                        _selectedCustomer != null
                            ? AppColors.success
                            : AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCustomer != null
                          ? 'Using existing customer: ${_selectedCustomer!.name}${_selectedCustomer!.email != null ? ' (${_selectedCustomer!.email})' : ''}'
                          : 'New customer details for this invoice only. Create a customer profile to save permanently.',
                      style: TextStyle(
                        color:
                            _selectedCustomer != null
                                ? AppColors.success
                                : AppColors.primary,
                        fontSize: 12,
                      ),
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
            SwitchListTile(
              title: const Text('Show Tax on Bill'),
              subtitle: const Text('Display tax breakdown on invoice PDF'),
              value: _showTaxOnBill,
              onChanged: (value) {
                setState(() {
                  _showTaxOnBill = value;
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
                    color: AppColors.primary.withValues(alpha: 0.1),
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
                    color: AppColors.borderColor.withValues(alpha: 0.3),
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
                            color: AppColors.borderColor.withValues(alpha: 0.3),
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
              children: [
                const Text('Subtotal:'),
                Text(
                  getIt<CountryService>().formatCurrency(_subtotal.toDouble()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Text(
                  getIt<CountryService>().formatCurrency(_taxAmount.toDouble()),
                ),
              ],
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
                  '₹$_totalAmount',
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
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _searchController = TextEditingController();

  Item? _selectedItem;
  InvoiceItem? _existingItem;
  bool _itemAlreadyExists = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
    _discountController.addListener(_onDiscountChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
    _discountController.removeListener(_onDiscountChanged);
    _quantityController.dispose();
    _discountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    _checkItemExists();
  }

  void _onDiscountChanged() {
    setState(() {});
  }

  void _checkItemExists() {
    if (_selectedItem == null) return;

    final existingItem = widget.existingItems.firstWhere(
      (item) => item.itemId == _selectedItem!.id,
      orElse:
          () => InvoiceItem(
            id: null,
            invoiceId: 0,
            itemId: -1,
            quantity: Decimal.zero,
            unitPrice: Decimal.zero,
            taxRate: Decimal.zero,
            discountPercent: Decimal.zero,
            lineTotal: Decimal.zero,
            createdAt: DateTime.now(),
            itemName: '',
          ),
    );

    setState(() {
      _itemAlreadyExists = existingItem.itemId != -1;
      _existingItem = _itemAlreadyExists ? existingItem : null;
    });
  }

  Decimal get _quantity {
    return Decimal.tryParse(_quantityController.text) ?? Decimal.zero;
  }

  Decimal get _discount {
    return Decimal.tryParse(_discountController.text) ?? Decimal.zero;
  }

  Decimal get _unitPrice {
    return _selectedItem?.sellingPrice ?? Decimal.zero;
  }

  Decimal get _taxRate {
    return _selectedItem?.taxRate ?? Decimal.zero;
  }

  Decimal get _subtotal {
    return _unitPrice * _quantity;
  }

  Decimal get _discountAmount {
    return (_subtotal * _discount / Decimal.fromInt(100)).toDecimal();
  }

  Decimal get _taxableAmount {
    return _subtotal - _discountAmount;
  }

  Decimal get _taxAmount {
    return (_taxableAmount * _taxRate / Decimal.fromInt(100)).toDecimal();
  }

  Decimal get _lineTotal {
    return _taxableAmount + _taxAmount;
  }

  int get _totalRequestedQuantity {
    final currentQuantity = _quantity.toBigInt().toInt();
    final existingQuantity = _existingItem?.quantity.toBigInt().toInt() ?? 0;
    return currentQuantity + existingQuantity;
  }

  void _addItem() {
    if (!_formKey.currentState!.validate()) return;

    final invoiceItem = InvoiceItem(
      id: null,
      invoiceId: 0,
      itemId: _selectedItem!.id!,
      quantity: _quantity,
      unitPrice: _unitPrice,
      taxRate: _taxRate,
      discountPercent: _discount,
      lineTotal: _lineTotal,
      createdAt: DateTime.now(),
      itemName: _selectedItem!.name,
    );

    widget.onItemAdded(invoiceItem);
    context.goBack();
  }

  Future<void> _createNewItem() async {
    final inventoryBloc = context.read<InventoryBloc>();

    final result = await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: inventoryBloc,
            child: const _CreateNewItemDialog(),
          ),
    );

    if (result != null && mounted) {
      // Refresh inventory to load the newly created item
      context.read<InventoryBloc>().add(LoadAllItems());

      // Select the newly created item
      setState(() {
        _selectedItem = result;
        _checkItemExists();
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} added to inventory!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
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
                    final items = state.items;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Autocomplete<Item>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return items;
                            }
                            return items.where((Item item) {
                              final searchLower =
                                  textEditingValue.text.toLowerCase();
                              return item.name.toLowerCase().contains(
                                    searchLower,
                                  ) ||
                                  (item.hsnCode?.toLowerCase().contains(
                                        searchLower,
                                      ) ??
                                      false) ||
                                  item.sellingPrice.toString().contains(
                                    searchLower,
                                  );
                            });
                          },
                          displayStringForOption:
                              (Item item) =>
                                  '${item.name} - ₹${item.sellingPrice} (Stock: ${item.stockQuantity})',
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            _searchController.text = textEditingController.text;
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Search Item',
                                hintText: 'Search by name, HSN code, or price',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.primary,
                                ),
                                suffixIcon:
                                    textEditingController.text.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            textEditingController.clear();
                                            setState(() {
                                              _selectedItem = null;
                                            });
                                          },
                                        )
                                        : null,
                              ),
                              validator: (value) {
                                if (_selectedItem == null) {
                                  return 'Please select an item';
                                }
                                return null;
                              },
                            );
                          },
                          optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<Item> onSelected,
                            Iterable<Item> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 300,
                                    maxWidth: 450,
                                  ),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: options.length,
                                    shrinkWrap: true,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final Item item = options.elementAt(
                                        index,
                                      );
                                      return ListTile(
                                        title: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Price: ₹${item.sellingPrice} | Stock: ${item.stockQuantity}${item.hsnCode != null ? ' | HSN: ${item.hsnCode}' : ''}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        trailing:
                                            item.stockQuantity <=
                                                    item.lowStockAlert
                                                ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Low Stock',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                                : null,
                                        onTap: () {
                                          onSelected(item);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (Item item) {
                            setState(() {
                              _selectedItem = item;
                              _checkItemExists();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // Create New Item Button
                        OutlinedButton.icon(
                          onPressed: _createNewItem,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create New Item'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        if (_selectedItem != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedItem!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: ₹${_selectedItem!.sellingPrice} | Tax: ${_selectedItem!.taxRate}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Available Stock: ${_selectedItem!.stockQuantity} ${_selectedItem!.unit}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        _selectedItem!.stockQuantity <=
                                                _selectedItem!.lowStockAlert
                                            ? AppColors.error
                                            : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: const OutlineInputBorder(),
                        suffixIcon:
                            _quantityController.text.isNotEmpty &&
                                    Decimal.tryParse(
                                          _quantityController.text,
                                        ) !=
                                        null &&
                                    Decimal.parse(_quantityController.text) >
                                        Decimal.zero
                                ? _selectedItem != null &&
                                        (_totalRequestedQuantity <=
                                            _selectedItem!.stockQuantity)
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : const Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                    )
                                : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (Decimal.tryParse(value) == null ||
                            Decimal.parse(value) <= Decimal.zero) {
                          return 'Enter valid quantity';
                        }

                        // Check inventory availability
                        if (_selectedItem != null) {
                          final totalRequested = _totalRequestedQuantity;
                          final availableStock = _selectedItem!.stockQuantity;

                          if (totalRequested > availableStock) {
                            return 'Only $availableStock available in stock';
                          }
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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
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
                            Text(
                              getIt<CountryService>().formatCurrency(
                                _unitPrice.toDouble(),
                              ),
                            ),
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
                    onPressed: () => context.goBack(),
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

// Print Options Dialog Widget
class _PrintOptionsDialog extends StatefulWidget {
  final bool defaultShowTax;

  const _PrintOptionsDialog({this.defaultShowTax = true});

  @override
  State<_PrintOptionsDialog> createState() => _PrintOptionsDialogState();
}

class _PrintOptionsDialogState extends State<_PrintOptionsDialog> {
  late bool showTax;
  bool showAddress = true;
  bool showPhone = true;
  bool showEmail = true;
  bool showGstin = true;

  @override
  void initState() {
    super.initState();
    showTax = widget.defaultShowTax;
  }

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

// Create New Item Dialog Widget
class _CreateNewItemDialog extends StatefulWidget {
  const _CreateNewItemDialog();

  @override
  State<_CreateNewItemDialog> createState() => _CreateNewItemDialogState();
}

class _CreateNewItemDialogState extends State<_CreateNewItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _sellingPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _taxRateController = TextEditingController(text: '18');
  final _stockQuantityController = TextEditingController(text: '0');
  final _lowStockAlertController = TextEditingController(text: '10');

  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load categories after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    if (!mounted) return;
    final state = context.read<InventoryBloc>().state;
    if (state is ItemsLoaded) {
      setState(() {
        _categories = state.categories;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hsnCodeController.dispose();
    _unitController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _taxRateController.dispose();
    _stockQuantityController.dispose();
    _lowStockAlertController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final item = Item(
        id: null,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        hsnCode:
            _hsnCodeController.text.trim().isEmpty
                ? null
                : _hsnCodeController.text.trim(),
        unit: _unitController.text.trim(),
        sellingPrice: Decimal.parse(_sellingPriceController.text),
        purchasePrice:
            _purchasePriceController.text.trim().isEmpty
                ? null
                : Decimal.parse(_purchasePriceController.text),
        taxRate: Decimal.parse(_taxRateController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        lowStockAlert: int.parse(_lowStockAlertController.text),
        categoryId: _selectedCategoryId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add item to inventory
      if (!mounted) return;
      context.read<InventoryBloc>().add(CreateItem(item));

      // Wait for the bloc to process and get the created item with ID
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Get the newly created item from the state
      final state = context.read<InventoryBloc>().state;
      Item? createdItem = item;

      if (state is ItemsLoaded) {
        // Find the item by name (since we just created it)
        try {
          createdItem = state.items.firstWhere(
            (i) => i.name == item.name && i.sellingPrice == item.sellingPrice,
          );
        } catch (e) {
          // If not found, use the original item
          createdItem = item;
        }
      }

      if (mounted) {
        Navigator.of(context).pop(createdItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating item: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_box, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New Item',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Add product details to inventory',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name *',
                          hintText: 'Enter item name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Item name is required';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter item description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),

                      // HSN Code and Category
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _hsnCodeController,
                              decoration: const InputDecoration(
                                labelText: 'HSN Code',
                                hintText: 'Enter HSN code',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items:
                                  _categories.map((category) {
                                    return DropdownMenuItem<int>(
                                      value: category.id,
                                      child: Text(category.name),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                              hint: const Text('Select category'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Unit and Stock Quantity
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit *',
                                hintText: 'pcs, kg, ltr',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unit is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockQuantityController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Quantity *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantity is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Selling Price and Purchase Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sellingPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price *',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.currency_rupee),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Selling price is required';
                                }
                                if (Decimal.tryParse(value) == null) {
                                  return 'Enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _purchasePriceController,
                              decoration: const InputDecoration(
                                labelText: 'Purchase Price',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.shopping_cart),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (Decimal.tryParse(value) == null) {
                                    return 'Enter valid price';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tax Rate and Low Stock Alert
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _taxRateController,
                              decoration: const InputDecoration(
                                labelText: 'Tax Rate (%) *',
                                hintText: '18',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.percent),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tax rate is required';
                                }
                                final rate = Decimal.tryParse(value);
                                if (rate == null) {
                                  return 'Enter valid rate';
                                }
                                if (rate < Decimal.zero ||
                                    rate > Decimal.fromInt(100)) {
                                  return 'Rate must be 0-100';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lowStockAlertController,
                              decoration: const InputDecoration(
                                labelText: 'Low Stock Alert *',
                                hintText: '10',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.warning_amber),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Alert level is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This item will be saved to inventory and automatically selected for billing.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveItem,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save & Select'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
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
