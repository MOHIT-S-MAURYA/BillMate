import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    int? id,
    required String name,
    String? description,
    String? hsnCode,
    required String unit,
    required Decimal sellingPrice,
    Decimal? purchasePrice,
    required Decimal taxRate,
    @Default(0) int stockQuantity,
    @Default(10) int lowStockAlert,
    int? categoryId,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@freezed
class Category with _$Category {
  const factory Category({
    int? id,
    required String name,
    String? description,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
