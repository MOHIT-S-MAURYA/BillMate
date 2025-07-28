import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:billmate/features/billing/domain/entities/customer.dart';
import 'package:billmate/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/billing/presentation/widgets/add_customer_dialog.dart';

class SmartCustomerSearchField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final Function(Customer?)? onCustomerSelected;
  final Function(String)? onTextChanged;
  final String? initialValue;
  final Customer? initialCustomer;
  final bool required;

  const SmartCustomerSearchField({
    super.key,
    this.labelText = 'Customer',
    this.hintText = 'Search or enter customer name...',
    this.onCustomerSelected,
    this.onTextChanged,
    this.initialValue,
    this.initialCustomer,
    this.required = false,
  });

  @override
  State<SmartCustomerSearchField> createState() =>
      _SmartCustomerSearchFieldState();
}

class _SmartCustomerSearchFieldState extends State<SmartCustomerSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  Timer? _debounceTimer;
  OverlayEntry? _overlayEntry;
  List<Customer> _searchResults = [];
  Customer? _selectedCustomer;
  bool _isSearching = false;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();

    // Initialize with provided values
    if (widget.initialCustomer != null) {
      _selectedCustomer = widget.initialCustomer;
      _controller.text = widget.initialCustomer!.name;
    } else if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // When field gains focus, show dropdown if there's text
      if (_controller.text.trim().isNotEmpty) {
        setState(() {
          _showDropdown = true;
        });
        _showOverlay();
      }
    } else {
      // Small delay to allow for selection
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideDropdown();
        }
      });
    }
  }

  void _onTextChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear selected customer if text changed
    if (_selectedCustomer != null && _selectedCustomer!.name != value) {
      _selectedCustomer = null;
      widget.onCustomerSelected?.call(null);
    }

    // Notify parent of text change
    widget.onTextChanged?.call(value);

    // If empty, hide dropdown
    if (value.trim().isEmpty) {
      _hideDropdown();
      return;
    }

    // Show dropdown immediately if we have text and focus
    if (_focusNode.hasFocus && value.trim().isNotEmpty) {
      setState(() {
        _showDropdown = true;
      });
      // Show overlay even with current results (might be empty initially)
      _showOverlay();
    }

    // Debounce search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && value.trim().isNotEmpty) {
        _searchCustomers(value.trim());
      }
    });
  }

  void _searchCustomers(String query) {
    setState(() {
      _isSearching = true;
    });
    context.read<BillingBloc>().add(SearchCustomers(query));
  }

  void _onCustomerSelected(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _controller.text = customer.name;
      _showDropdown = false;
    });

    _hideDropdown();
    _focusNode.unfocus();
    widget.onCustomerSelected?.call(customer);
  }

  void _showAddCustomerDialog() {
    _hideDropdown();
    _focusNode.unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<BillingBloc>(),
            child: AddCustomerDialog(
              onCustomerAdded: (customer) {
                // Auto-select the newly created customer
                _onCustomerSelected(customer);
              },
            ),
          ),
    );
  }

  void _hideDropdown() {
    setState(() {
      _showDropdown = false;
    });
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: _getTextFieldWidth(),
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 55), // Position below the text field
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: _buildDropdownContent(),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  Widget _buildDropdownContent() {
    if (_isSearching) {
      return Container(
        height: 60,
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Searching customers...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _controller.text.trim().isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.search_off, color: AppColors.textHint, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No customers found for "${_controller.text.trim()}"',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddCustomerDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: Text('Add "${_controller.text.trim()}" as new customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _searchResults.length + 1, // +1 for "Add new customer" option
      separatorBuilder:
          (context, index) => Divider(height: 1, color: AppColors.borderColor),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          // "Add new customer" option at the bottom
          return ListTile(
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.person_add, color: AppColors.primary, size: 16),
            ),
            title: const Text(
              'Add new customer',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Create new customer profile',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            onTap: _showAddCustomerDialog,
          );
        }

        final customer = _searchResults[index];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            customer.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customer.email != null)
                Text(
                  customer.email!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              if (customer.phone != null)
                Text(
                  customer.phone!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          onTap: () => _onCustomerSelected(customer),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state is CustomersLoaded) {
          setState(() {
            _searchResults = state.customers;
            _isSearching = false;
          });

          // Show overlay if field is focused and has text
          if (_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
            setState(() {
              _showDropdown = true;
            });
            _showOverlay();
          }
        } else if (state is BillingError) {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: Icon(
              _selectedCustomer != null ? Icons.person : Icons.search,
              color:
                  _selectedCustomer != null
                      ? AppColors.success
                      : AppColors.textHint,
            ),
            suffixIcon:
                _selectedCustomer != null
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Selected',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : _controller.text.trim().isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _selectedCustomer = null;
                        widget.onCustomerSelected?.call(null);
                        widget.onTextChanged?.call('');
                        _hideDropdown();
                      },
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: _onTextChanged,
          validator:
              widget.required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Customer name is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ),
    );
  }
}
