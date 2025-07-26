import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:decimal/decimal.dart';

class ItemModel {
  final int? id;
  final String name;
  final String? description;
  final String? hsnCode;
  final String unit;
  final Decimal sellingPrice;
  final Decimal? purchasePrice;
  final Decimal taxRate;
  final int stockQuantity;
  final int lowStockAlert;
  final int? categoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemModel({
    this.id,
    required this.name,
    this.description,
    this.hsnCode,
    required this.unit,
    required this.sellingPrice,
    this.purchasePrice,
    required this.taxRate,
    this.stockQuantity = 0,
    this.lowStockAlert = 10,
    this.categoryId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      hsnCode: json['hsn_code'] as String?,
      unit: json['unit'] as String,
      sellingPrice: Decimal.parse(json['selling_price'].toString()),
      purchasePrice:
          json['purchase_price'] != null
              ? Decimal.parse(json['purchase_price'].toString())
              : null,
      taxRate: Decimal.parse(json['tax_rate'].toString()),
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      lowStockAlert: json['low_stock_alert'] as int? ?? 10,
      categoryId: json['category_id'] as int?,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (hsnCode != null) 'hsn_code': hsnCode,
      'unit': unit,
      'selling_price': sellingPrice.toString(),
      if (purchasePrice != null) 'purchase_price': purchasePrice.toString(),
      'tax_rate': taxRate.toString(),
      'stock_quantity': stockQuantity,
      'low_stock_alert': lowStockAlert,
      if (categoryId != null) 'category_id': categoryId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Item toEntity() {
    return Item(
      id: id,
      name: name,
      description: description,
      hsnCode: hsnCode,
      unit: unit,
      sellingPrice: sellingPrice,
      purchasePrice: purchasePrice,
      taxRate: taxRate,
      stockQuantity: stockQuantity,
      lowStockAlert: lowStockAlert,
      categoryId: categoryId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static ItemModel fromEntity(Item item) {
    return ItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      hsnCode: item.hsnCode,
      unit: item.unit,
      sellingPrice: item.sellingPrice,
      purchasePrice: item.purchasePrice,
      taxRate: item.taxRate,
      stockQuantity: item.stockQuantity,
      lowStockAlert: item.lowStockAlert,
      categoryId: item.categoryId,
      isActive: item.isActive,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
}

class CategoryModel {
  final int? id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CategoryModel fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}
