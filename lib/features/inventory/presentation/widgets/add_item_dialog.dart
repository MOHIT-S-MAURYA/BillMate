import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:billmate/shared/constants/app_colors.dart';

class AddItemDialog extends StatefulWidget {
  final Item? item;

  const AddItemDialog({super.key, this.item});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _unitController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _lowStockAlertController = TextEditingController();

  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeFields();
  }

  void _loadCategories() {
    context.read<InventoryBloc>().add(LoadAllItems());
  }

  void _initializeFields() {
    if (widget.item != null) {
      final item = widget.item!;
      _nameController.text = item.name;
      _descriptionController.text = item.description ?? '';
      _hsnCodeController.text = item.hsnCode ?? '';
      _unitController.text = item.unit;
      _sellingPriceController.text = item.sellingPrice.toString();
      _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
      _taxRateController.text = item.taxRate.toString();
      _stockQuantityController.text = item.stockQuantity.toString();
      _lowStockAlertController.text = item.lowStockAlert.toString();
      _selectedCategoryId = item.categoryId;
    } else {
      // Set default values for new item
      _unitController.text = 'pcs';
      _taxRateController.text = '18';
      _stockQuantityController.text = '0';
      _lowStockAlertController.text = '10';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is ItemsLoaded) {
          setState(() {
            _categories = state.categories;
          });
        } else if (state is InventorySuccess) {
          Navigator.of(context).pop();
        } else if (state is InventoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoSection(),
                        const SizedBox(height: 24),
                        _buildPricingSection(),
                        const SizedBox(height: 24),
                        _buildInventorySection(),
                        const SizedBox(height: 24),
                        _buildCategorySection(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.item != null ? Icons.edit : Icons.add,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item != null ? 'Edit Item' : 'Add New Item',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.item != null
                    ? 'Update item details'
                    : 'Enter item information',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Item Name',
          hint: 'Enter item name',
          required: true,
          icon: Icons.inventory_2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter item description (optional)',
          icon: Icons.description,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _hsnCodeController,
                label: 'HSN Code',
                hint: 'Enter HSN code',
                icon: Icons.qr_code,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _unitController,
                label: 'Unit',
                hint: 'pcs, kg, ltr',
                required: true,
                icon: Icons.straighten,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pricing'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _sellingPriceController,
                label: 'Selling Price',
                hint: '0.00',
                required: true,
                icon: Icons.currency_rupee,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefix: '₹',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _purchasePriceController,
                label: 'Purchase Price',
                hint: '0.00',
                icon: Icons.shopping_cart,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefix: '₹',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _taxRateController,
          label: 'Tax Rate',
          hint: '18',
          required: true,
          icon: Icons.percent,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffix: '%',
        ),
      ],
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Inventory'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _stockQuantityController,
                label: 'Stock Quantity',
                hint: '0',
                required: true,
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lowStockAlertController,
                label: 'Low Stock Alert',
                hint: '10',
                required: true,
                icon: Icons.warning,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Category'),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Select Category',
              prefixIcon: const Icon(Icons.category, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('No Category'),
              ),
              ..._categories.map(
                (category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator:
          required
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
              : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.borderColor),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      widget.item != null ? 'Update Item' : 'Add Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final sellingPrice = Decimal.parse(_sellingPriceController.text);
      final purchasePrice =
          _purchasePriceController.text.isNotEmpty
              ? Decimal.parse(_purchasePriceController.text)
              : null;
      final taxRate = Decimal.parse(_taxRateController.text);
      final stockQuantity = int.parse(_stockQuantityController.text);
      final lowStockAlert = int.parse(_lowStockAlertController.text);

      final now = DateTime.now();

      final item = Item(
        id: widget.item?.id,
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
        hsnCode:
            _hsnCodeController.text.trim().isNotEmpty
                ? _hsnCodeController.text.trim()
                : null,
        unit: _unitController.text.trim(),
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        taxRate: taxRate,
        stockQuantity: stockQuantity,
        lowStockAlert: lowStockAlert,
        categoryId: _selectedCategoryId,
        isActive: true,
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.item != null) {
        context.read<InventoryBloc>().add(UpdateItem(item));
      } else {
        context.read<InventoryBloc>().add(CreateItem(item));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid input: Please check your entries'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
