import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billmate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:billmate/shared/constants/app_colors.dart';

class EditBusinessDialog extends StatefulWidget {
  final Map<String, String?> currentConfig;

  const EditBusinessDialog({super.key, required this.currentConfig});

  @override
  State<EditBusinessDialog> createState() => _EditBusinessDialogState();
}

class _EditBusinessDialogState extends State<EditBusinessDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _gstinController;
  late final TextEditingController _stateCodeController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _businessNameController = TextEditingController(
      text: widget.currentConfig['business_name'] ?? '',
    );
    _gstinController = TextEditingController(
      text: widget.currentConfig['business_gstin'] ?? '',
    );
    _stateCodeController = TextEditingController(
      text: widget.currentConfig['business_state_code'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.currentConfig['business_address'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.currentConfig['business_phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.currentConfig['business_email'] ?? '',
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _businessNameController.dispose();
    _gstinController.dispose();
    _stateCodeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildForm()),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Update your business details',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(
              title: 'Basic Information',
              icon: Icons.info_outline,
              children: [
                _buildTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  hint: 'e.g., Rajesh Electronics Store',
                  helperText: 'Enter your complete business or shop name',
                  icon: Icons.store,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Business name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _gstinController,
                  label: 'GSTIN',
                  hint: 'e.g., 27AABCU9603R1ZX',
                  helperText:
                      'Format: 2-digit state code + 10-digit PAN + 1-digit entity + 1-digit checksum + Z + 1-digit checksum',
                  icon: Icons.receipt_long,
                  textInputAction: TextInputAction.next,
                  showFormatIndicator: true,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(15),
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]')),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 15) {
                        return 'GSTIN must be exactly 15 characters';
                      }
                      if (!RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                      ).hasMatch(value)) {
                        return 'Invalid GSTIN format. Example: 27AABCU9603R1ZX';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _stateCodeController,
                  label: 'State Code',
                  hint: 'e.g., 27',
                  helperText:
                      'GST state code (01-37). Maharashtra: 27, Delhi: 07, Karnataka: 29',
                  icon: Icons.location_on,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final code = int.tryParse(value);
                      if (code == null || code < 1 || code > 37) {
                        return 'Enter valid state code (01-37)';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildFormSection(
              title: 'Contact Details',
              icon: Icons.contact_phone,
              children: [
                _buildTextField(
                  controller: _addressController,
                  label: 'Business Address',
                  hint: 'e.g., Shop No. 12, MG Road, Pune, Maharashtra',
                  helperText:
                      'Complete address with shop/building number, street, area, city, and state',
                  icon: Icons.home,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.trim().length < 10) {
                      return 'Please enter a complete address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'e.g., +91 98765 43210',
                  helperText:
                      'Mobile or landline number with country code. Formats: +91 98765 43210, 020-12345678',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  showFormatIndicator: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                    LengthLimitingTextInputFormatter(18),
                    PhoneNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final cleanNumber = value.replaceAll(
                        RegExp(r'[\s\-\(\)]'),
                        '',
                      );
                      if (cleanNumber.startsWith('+91')) {
                        if (cleanNumber.length != 13) {
                          return 'Indian mobile number should be 10 digits after +91';
                        }
                      } else if (cleanNumber.length < 10 ||
                          cleanNumber.length > 15) {
                        return 'Phone number should be 10-15 digits';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g., rajesh.electronics@gmail.com',
                  helperText:
                      'Business email for invoices and communication. Must contain @ and valid domain',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  showFormatIndicator: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'\s'),
                    ), // No spaces
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value)) {
                        return 'Enter valid email: name@domain.com';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
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
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool isRequired = false,
    bool showFormatIndicator = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                ],
              ),
            ),
            if (showFormatIndicator) ...[
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  final isValid =
                      validator?.call(value.text) == null &&
                      value.text.isNotEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          value.text.isEmpty
                              ? AppColors.textHint.withValues(alpha: 0.1)
                              : isValid
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          value.text.isEmpty
                              ? Icons.info_outline
                              : isValid
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          size: 12,
                          color:
                              value.text.isEmpty
                                  ? AppColors.textHint
                                  : isValid
                                  ? AppColors.success
                                  : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          value.text.isEmpty
                              ? 'Format'
                              : isValid
                              ? 'Valid'
                              : 'Invalid',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                value.text.isEmpty
                                    ? AppColors.textHint
                                    : isValid
                                    ? AppColors.success
                                    : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 3,
            helperStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16),
            ),
            suffixIcon:
                showFormatIndicator
                    ? ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        final isValid = validator?.call(value.text) == null;
                        return Icon(
                          isValid ? Icons.check_circle : Icons.error,
                          color: isValid ? AppColors.success : AppColors.error,
                          size: 20,
                        );
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.borderColor),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocConsumer<SettingsBloc, SettingsState>(
              listener: (context, state) {
                if (state is SettingsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Error: ${state.message}')),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else if (state is BusinessConfigLoaded) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Business information updated successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is SettingsLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      final settings = <String, String>{
        'business_name': _businessNameController.text.trim(),
        'business_gstin': _gstinController.text.trim(),
        'business_state_code': _stateCodeController.text.trim(),
        'business_address': _addressController.text.trim(),
        'business_phone': _phoneController.text.trim(),
        'business_email': _emailController.text.trim(),
      };

      context.read<SettingsBloc>().add(UpdateBusinessConfig(settings));
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove all non-digit characters except +
    String digitsOnly = text.replaceAll(RegExp(r'[^\d+]'), '');

    // Handle Indian numbers starting with +91
    if (digitsOnly.startsWith('+91') && digitsOnly.length > 3) {
      final countryCode = '+91';
      final number = digitsOnly.substring(3);

      if (number.length <= 5) {
        digitsOnly = '$countryCode $number';
      } else {
        digitsOnly =
            '$countryCode ${number.substring(0, 5)} ${number.substring(5)}';
      }
    }
    // Handle other numbers with country codes
    else if (digitsOnly.startsWith('+') && digitsOnly.length > 1) {
      // Keep as is for other country codes
    }
    // Handle domestic numbers (10 digits)
    else if (!digitsOnly.startsWith('+') && digitsOnly.length > 5) {
      if (digitsOnly.length <= 10) {
        digitsOnly = '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5)}';
      } else {
        digitsOnly =
            '${digitsOnly.substring(0, 5)} ${digitsOnly.substring(5, 10)} ${digitsOnly.substring(10)}';
      }
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
