// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  hsnCode: json['hsnCode'] as String?,
  unit: json['unit'] as String,
  sellingPrice: Decimal.fromJson(json['sellingPrice'] as String),
  purchasePrice:
      json['purchasePrice'] == null
          ? null
          : Decimal.fromJson(json['purchasePrice'] as String),
  taxRate: Decimal.fromJson(json['taxRate'] as String),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  lowStockAlert: (json['lowStockAlert'] as num?)?.toInt() ?? 10,
  categoryId: (json['categoryId'] as num?)?.toInt(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hsnCode': instance.hsnCode,
      'unit': instance.unit,
      'sellingPrice': instance.sellingPrice,
      'purchasePrice': instance.purchasePrice,
      'taxRate': instance.taxRate,
      'stockQuantity': instance.stockQuantity,
      'lowStockAlert': instance.lowStockAlert,
      'categoryId': instance.categoryId,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
