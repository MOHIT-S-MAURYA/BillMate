import 'package:billmate/features/billing/domain/entities/customer.dart';

class CustomerModel {
  const CustomerModel({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.gstin,
    this.stateCode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? gstin;
  final String? stateCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gstin: json['gstin'] as String?,
      stateCode: json['state_code'] as String?,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (gstin != null) 'gstin': gstin,
      if (stateCode != null) 'state_code': stateCode,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromDomain(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
      gstin: customer.gstin,
      stateCode: customer.stateCode,
      isActive: customer.isActive,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  // Convert to domain entity
  Customer toDomain() {
    return Customer(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      gstin: gstin,
      stateCode: stateCode,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  CustomerModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gstin,
    String? stateCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      stateCode: stateCode ?? this.stateCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
