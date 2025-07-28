import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/shared/constants/app_colors.dart';

class AddCustomerDialog extends StatefulWidget {
  final Customer? existingCustomer; // For edit mode
  final Function(Customer)? onCustomerAdded;

  const AddCustomerDialog({
    super.key,
    this.existingCustomer,
    this.onCustomerAdded,
  });

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _stateCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFields();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeFields() {
    if (widget.existingCustomer != null) {
      final customer = widget.existingCustomer!;
      _nameController.text = customer.name;
      _emailController.text = customer.email ?? '';
      _phoneController.text = customer.phone ?? '';
      _addressController.text = customer.address ?? '';
      _gstinController.text = customer.gstin ?? '';
      _stateCodeController.text = customer.stateCode ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _stateCodeController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final customer = Customer(
        id: widget.existingCustomer?.id,
        name: _nameController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        gstin:
            _gstinController.text.trim().isEmpty
                ? null
                : _gstinController.text.trim(),
        stateCode:
            _stateCodeController.text.trim().isEmpty
                ? null
                : _stateCodeController.text.trim(),
        isActive: true,
        createdAt: widget.existingCustomer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.existingCustomer == null) {
        // Create new customer
        context.read<BillingBloc>().add(CreateCustomer(customer));
      } else {
        // Update existing customer
        context.read<BillingBloc>().add(UpdateCustomer(customer));
      }
    }
  }

  String? _validateGSTIN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // GSTIN is optional
    }

    final gstin = value.trim().toUpperCase();

    // Basic GSTIN validation - 15 characters, specific pattern
    final gstinRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$',
    );

    if (!gstinRegex.hasMatch(gstin)) {
      return 'Please enter a valid GSTIN (15 characters)';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state is CustomerCreated || state is CustomerUpdated) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingCustomer == null
                    ? 'Customer added successfully!'
                    : 'Customer updated successfully!',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Call the callback if provided
          if (widget.onCustomerAdded != null) {
            final customer = Customer(
              name: _nameController.text.trim(),
              email:
                  _emailController.text.trim().isEmpty
                      ? null
                      : _emailController.text.trim(),
              phone:
                  _phoneController.text.trim().isEmpty
                      ? null
                      : _phoneController.text.trim(),
              address:
                  _addressController.text.trim().isEmpty
                      ? null
                      : _addressController.text.trim(),
              gstin:
                  _gstinController.text.trim().isEmpty
                      ? null
                      : _gstinController.text.trim(),
              stateCode:
                  _stateCodeController.text.trim().isEmpty
                      ? null
                      : _stateCodeController.text.trim(),
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            widget.onCustomerAdded!(customer);
          }

          Navigator.of(context).pop();
        } else if (state is BillingError) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 700,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildForm(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.existingCustomer == null ? Icons.person_add : Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingCustomer == null
                      ? 'Add Customer'
                      : 'Edit Customer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.existingCustomer == null
                      ? 'Create a new customer profile'
                      : 'Update customer information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildFormField(
          controller: _nameController,
          labelText: 'Customer Name *',
          hintText: 'Enter customer name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Customer name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Enter email address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _phoneController,
          labelText: 'Phone Number',
          hintText: 'Enter 10-digit mobile number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _addressController,
          labelText: 'Address',
          hintText: 'Enter customer address',
          icon: Icons.location_on,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _gstinController,
          labelText: 'GSTIN',
          hintText: 'Enter 15-digit GSTIN',
          icon: Icons.business,
          validator: _validateGSTIN,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          controller: _stateCodeController,
          labelText: 'State Code',
          hintText: 'Enter state code (e.g., 07 for Delhi)',
          icon: Icons.map,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final stateCode = value.trim();
              if (stateCode.length != 2 || int.tryParse(stateCode) == null) {
                return 'State code must be 2 digits (01-37)';
              }
              final code = int.parse(stateCode);
              if (code < 1 || code > 37) {
                return 'State code must be between 01-37';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCustomer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    widget.existingCustomer == null
                        ? 'Add Customer'
                        : 'Update Customer',
                  ),
        ),
      ],
    );
  }
}
