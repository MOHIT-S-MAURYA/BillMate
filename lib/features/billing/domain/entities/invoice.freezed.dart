// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Invoice _$InvoiceFromJson(Map<String, dynamic> json) {
  return _Invoice.fromJson(json);
}

/// @nodoc
mixin _$Invoice {
  int? get id => throw _privateConstructorUsedError;
  String get invoiceNumber => throw _privateConstructorUsedError;
  int? get customerId => throw _privateConstructorUsedError;
  String? get customerName =>
      throw _privateConstructorUsedError; // Store customer name directly in invoice
  String? get customerEmail =>
      throw _privateConstructorUsedError; // Store customer email directly in invoice
  DateTime get invoiceDate => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  Decimal get subtotal => throw _privateConstructorUsedError;
  Decimal get taxAmount => throw _privateConstructorUsedError;
  Decimal get discountAmount => throw _privateConstructorUsedError;
  Decimal get totalAmount => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get paymentMethod => throw _privateConstructorUsedError;
  DateTime? get paymentDate => throw _privateConstructorUsedError;
  Decimal? get paidAmount =>
      throw _privateConstructorUsedError; // New field for partial payments
  String? get notes => throw _privateConstructorUsedError;
  bool get isGstInvoice => throw _privateConstructorUsedError;
  bool get showTaxOnBill =>
      throw _privateConstructorUsedError; // New field to control tax display on PDF
  String? get placeOfSupply => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<InvoiceItem> get items => throw _privateConstructorUsedError;

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceCopyWith<Invoice> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceCopyWith<$Res> {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) then) =
      _$InvoiceCopyWithImpl<$Res, Invoice>;
  @useResult
  $Res call({
    int? id,
    String invoiceNumber,
    int? customerId,
    String? customerName,
    String? customerEmail,
    DateTime invoiceDate,
    DateTime? dueDate,
    Decimal subtotal,
    Decimal taxAmount,
    Decimal discountAmount,
    Decimal totalAmount,
    String paymentStatus,
    String paymentMethod,
    DateTime? paymentDate,
    Decimal? paidAmount,
    String? notes,
    bool isGstInvoice,
    bool showTaxOnBill,
    String? placeOfSupply,
    DateTime createdAt,
    DateTime updatedAt,
    List<InvoiceItem> items,
  });
}

/// @nodoc
class _$InvoiceCopyWithImpl<$Res, $Val extends Invoice>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceNumber = null,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? customerEmail = freezed,
    Object? invoiceDate = null,
    Object? dueDate = freezed,
    Object? subtotal = null,
    Object? taxAmount = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? paymentStatus = null,
    Object? paymentMethod = null,
    Object? paymentDate = freezed,
    Object? paidAmount = freezed,
    Object? notes = freezed,
    Object? isGstInvoice = null,
    Object? showTaxOnBill = null,
    Object? placeOfSupply = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            invoiceNumber:
                null == invoiceNumber
                    ? _value.invoiceNumber
                    : invoiceNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            customerId:
                freezed == customerId
                    ? _value.customerId
                    : customerId // ignore: cast_nullable_to_non_nullable
                        as int?,
            customerName:
                freezed == customerName
                    ? _value.customerName
                    : customerName // ignore: cast_nullable_to_non_nullable
                        as String?,
            customerEmail:
                freezed == customerEmail
                    ? _value.customerEmail
                    : customerEmail // ignore: cast_nullable_to_non_nullable
                        as String?,
            invoiceDate:
                null == invoiceDate
                    ? _value.invoiceDate
                    : invoiceDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            dueDate:
                freezed == dueDate
                    ? _value.dueDate
                    : dueDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            subtotal:
                null == subtotal
                    ? _value.subtotal
                    : subtotal // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            taxAmount:
                null == taxAmount
                    ? _value.taxAmount
                    : taxAmount // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            discountAmount:
                null == discountAmount
                    ? _value.discountAmount
                    : discountAmount // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            totalAmount:
                null == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            paymentStatus:
                null == paymentStatus
                    ? _value.paymentStatus
                    : paymentStatus // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentMethod:
                null == paymentMethod
                    ? _value.paymentMethod
                    : paymentMethod // ignore: cast_nullable_to_non_nullable
                        as String,
            paymentDate:
                freezed == paymentDate
                    ? _value.paymentDate
                    : paymentDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            paidAmount:
                freezed == paidAmount
                    ? _value.paidAmount
                    : paidAmount // ignore: cast_nullable_to_non_nullable
                        as Decimal?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            isGstInvoice:
                null == isGstInvoice
                    ? _value.isGstInvoice
                    : isGstInvoice // ignore: cast_nullable_to_non_nullable
                        as bool,
            showTaxOnBill:
                null == showTaxOnBill
                    ? _value.showTaxOnBill
                    : showTaxOnBill // ignore: cast_nullable_to_non_nullable
                        as bool,
            placeOfSupply:
                freezed == placeOfSupply
                    ? _value.placeOfSupply
                    : placeOfSupply // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            items:
                null == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<InvoiceItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvoiceImplCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$$InvoiceImplCopyWith(
    _$InvoiceImpl value,
    $Res Function(_$InvoiceImpl) then,
  ) = __$$InvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String invoiceNumber,
    int? customerId,
    String? customerName,
    String? customerEmail,
    DateTime invoiceDate,
    DateTime? dueDate,
    Decimal subtotal,
    Decimal taxAmount,
    Decimal discountAmount,
    Decimal totalAmount,
    String paymentStatus,
    String paymentMethod,
    DateTime? paymentDate,
    Decimal? paidAmount,
    String? notes,
    bool isGstInvoice,
    bool showTaxOnBill,
    String? placeOfSupply,
    DateTime createdAt,
    DateTime updatedAt,
    List<InvoiceItem> items,
  });
}

/// @nodoc
class __$$InvoiceImplCopyWithImpl<$Res>
    extends _$InvoiceCopyWithImpl<$Res, _$InvoiceImpl>
    implements _$$InvoiceImplCopyWith<$Res> {
  __$$InvoiceImplCopyWithImpl(
    _$InvoiceImpl _value,
    $Res Function(_$InvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceNumber = null,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? customerEmail = freezed,
    Object? invoiceDate = null,
    Object? dueDate = freezed,
    Object? subtotal = null,
    Object? taxAmount = null,
    Object? discountAmount = null,
    Object? totalAmount = null,
    Object? paymentStatus = null,
    Object? paymentMethod = null,
    Object? paymentDate = freezed,
    Object? paidAmount = freezed,
    Object? notes = freezed,
    Object? isGstInvoice = null,
    Object? showTaxOnBill = null,
    Object? placeOfSupply = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? items = null,
  }) {
    return _then(
      _$InvoiceImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        invoiceNumber:
            null == invoiceNumber
                ? _value.invoiceNumber
                : invoiceNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        customerId:
            freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                    as int?,
        customerName:
            freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                    as String?,
        customerEmail:
            freezed == customerEmail
                ? _value.customerEmail
                : customerEmail // ignore: cast_nullable_to_non_nullable
                    as String?,
        invoiceDate:
            null == invoiceDate
                ? _value.invoiceDate
                : invoiceDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        dueDate:
            freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        subtotal:
            null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        taxAmount:
            null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        discountAmount:
            null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        totalAmount:
            null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        paymentStatus:
            null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentMethod:
            null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                    as String,
        paymentDate:
            freezed == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        paidAmount:
            freezed == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                    as Decimal?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        isGstInvoice:
            null == isGstInvoice
                ? _value.isGstInvoice
                : isGstInvoice // ignore: cast_nullable_to_non_nullable
                    as bool,
        showTaxOnBill:
            null == showTaxOnBill
                ? _value.showTaxOnBill
                : showTaxOnBill // ignore: cast_nullable_to_non_nullable
                    as bool,
        placeOfSupply:
            freezed == placeOfSupply
                ? _value.placeOfSupply
                : placeOfSupply // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        items:
            null == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<InvoiceItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceImpl implements _Invoice {
  const _$InvoiceImpl({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    this.customerName,
    this.customerEmail,
    required this.invoiceDate,
    this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.paymentStatus = 'pending',
    this.paymentMethod = 'cash',
    this.paymentDate,
    this.paidAmount,
    this.notes,
    this.isGstInvoice = true,
    this.showTaxOnBill = true,
    this.placeOfSupply,
    required this.createdAt,
    required this.updatedAt,
    final List<InvoiceItem> items = const [],
  }) : _items = items;

  factory _$InvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceImplFromJson(json);

  @override
  final int? id;
  @override
  final String invoiceNumber;
  @override
  final int? customerId;
  @override
  final String? customerName;
  // Store customer name directly in invoice
  @override
  final String? customerEmail;
  // Store customer email directly in invoice
  @override
  final DateTime invoiceDate;
  @override
  final DateTime? dueDate;
  @override
  final Decimal subtotal;
  @override
  final Decimal taxAmount;
  @override
  final Decimal discountAmount;
  @override
  final Decimal totalAmount;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  final DateTime? paymentDate;
  @override
  final Decimal? paidAmount;
  // New field for partial payments
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isGstInvoice;
  @override
  @JsonKey()
  final bool showTaxOnBill;
  // New field to control tax display on PDF
  @override
  final String? placeOfSupply;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<InvoiceItem> _items;
  @override
  @JsonKey()
  List<InvoiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'Invoice(id: $id, invoiceNumber: $invoiceNumber, customerId: $customerId, customerName: $customerName, customerEmail: $customerEmail, invoiceDate: $invoiceDate, dueDate: $dueDate, subtotal: $subtotal, taxAmount: $taxAmount, discountAmount: $discountAmount, totalAmount: $totalAmount, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, paymentDate: $paymentDate, paidAmount: $paidAmount, notes: $notes, isGstInvoice: $isGstInvoice, showTaxOnBill: $showTaxOnBill, placeOfSupply: $placeOfSupply, createdAt: $createdAt, updatedAt: $updatedAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.invoiceDate, invoiceDate) ||
                other.invoiceDate == invoiceDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isGstInvoice, isGstInvoice) ||
                other.isGstInvoice == isGstInvoice) &&
            (identical(other.showTaxOnBill, showTaxOnBill) ||
                other.showTaxOnBill == showTaxOnBill) &&
            (identical(other.placeOfSupply, placeOfSupply) ||
                other.placeOfSupply == placeOfSupply) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    invoiceNumber,
    customerId,
    customerName,
    customerEmail,
    invoiceDate,
    dueDate,
    subtotal,
    taxAmount,
    discountAmount,
    totalAmount,
    paymentStatus,
    paymentMethod,
    paymentDate,
    paidAmount,
    notes,
    isGstInvoice,
    showTaxOnBill,
    placeOfSupply,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_items),
  ]);

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      __$$InvoiceImplCopyWithImpl<_$InvoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceImplToJson(this);
  }
}

abstract class _Invoice implements Invoice {
  const factory _Invoice({
    final int? id,
    required final String invoiceNumber,
    final int? customerId,
    final String? customerName,
    final String? customerEmail,
    required final DateTime invoiceDate,
    final DateTime? dueDate,
    required final Decimal subtotal,
    required final Decimal taxAmount,
    required final Decimal discountAmount,
    required final Decimal totalAmount,
    final String paymentStatus,
    final String paymentMethod,
    final DateTime? paymentDate,
    final Decimal? paidAmount,
    final String? notes,
    final bool isGstInvoice,
    final bool showTaxOnBill,
    final String? placeOfSupply,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final List<InvoiceItem> items,
  }) = _$InvoiceImpl;

  factory _Invoice.fromJson(Map<String, dynamic> json) = _$InvoiceImpl.fromJson;

  @override
  int? get id;
  @override
  String get invoiceNumber;
  @override
  int? get customerId;
  @override
  String? get customerName; // Store customer name directly in invoice
  @override
  String? get customerEmail; // Store customer email directly in invoice
  @override
  DateTime get invoiceDate;
  @override
  DateTime? get dueDate;
  @override
  Decimal get subtotal;
  @override
  Decimal get taxAmount;
  @override
  Decimal get discountAmount;
  @override
  Decimal get totalAmount;
  @override
  String get paymentStatus;
  @override
  String get paymentMethod;
  @override
  DateTime? get paymentDate;
  @override
  Decimal? get paidAmount; // New field for partial payments
  @override
  String? get notes;
  @override
  bool get isGstInvoice;
  @override
  bool get showTaxOnBill; // New field to control tax display on PDF
  @override
  String? get placeOfSupply;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<InvoiceItem> get items;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) {
  return _InvoiceItem.fromJson(json);
}

/// @nodoc
mixin _$InvoiceItem {
  int? get id => throw _privateConstructorUsedError;
  int get invoiceId => throw _privateConstructorUsedError;
  int get itemId => throw _privateConstructorUsedError;
  Decimal get quantity => throw _privateConstructorUsedError;
  Decimal get unitPrice => throw _privateConstructorUsedError;
  Decimal get discountPercent => throw _privateConstructorUsedError;
  Decimal get taxRate => throw _privateConstructorUsedError;
  Decimal get lineTotal => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Navigation properties
  String? get itemName => throw _privateConstructorUsedError;
  String? get itemDescription => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceItemCopyWith<InvoiceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceItemCopyWith<$Res> {
  factory $InvoiceItemCopyWith(
    InvoiceItem value,
    $Res Function(InvoiceItem) then,
  ) = _$InvoiceItemCopyWithImpl<$Res, InvoiceItem>;
  @useResult
  $Res call({
    int? id,
    int invoiceId,
    int itemId,
    Decimal quantity,
    Decimal unitPrice,
    Decimal discountPercent,
    Decimal taxRate,
    Decimal lineTotal,
    DateTime createdAt,
    String? itemName,
    String? itemDescription,
    String? unit,
  });
}

/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res, $Val extends InvoiceItem>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? discountPercent = null,
    Object? taxRate = null,
    Object? lineTotal = null,
    Object? createdAt = null,
    Object? itemName = freezed,
    Object? itemDescription = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            invoiceId:
                null == invoiceId
                    ? _value.invoiceId
                    : invoiceId // ignore: cast_nullable_to_non_nullable
                        as int,
            itemId:
                null == itemId
                    ? _value.itemId
                    : itemId // ignore: cast_nullable_to_non_nullable
                        as int,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            unitPrice:
                null == unitPrice
                    ? _value.unitPrice
                    : unitPrice // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            discountPercent:
                null == discountPercent
                    ? _value.discountPercent
                    : discountPercent // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            taxRate:
                null == taxRate
                    ? _value.taxRate
                    : taxRate // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            lineTotal:
                null == lineTotal
                    ? _value.lineTotal
                    : lineTotal // ignore: cast_nullable_to_non_nullable
                        as Decimal,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            itemName:
                freezed == itemName
                    ? _value.itemName
                    : itemName // ignore: cast_nullable_to_non_nullable
                        as String?,
            itemDescription:
                freezed == itemDescription
                    ? _value.itemDescription
                    : itemDescription // ignore: cast_nullable_to_non_nullable
                        as String?,
            unit:
                freezed == unit
                    ? _value.unit
                    : unit // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvoiceItemImplCopyWith<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  factory _$$InvoiceItemImplCopyWith(
    _$InvoiceItemImpl value,
    $Res Function(_$InvoiceItemImpl) then,
  ) = __$$InvoiceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int invoiceId,
    int itemId,
    Decimal quantity,
    Decimal unitPrice,
    Decimal discountPercent,
    Decimal taxRate,
    Decimal lineTotal,
    DateTime createdAt,
    String? itemName,
    String? itemDescription,
    String? unit,
  });
}

/// @nodoc
class __$$InvoiceItemImplCopyWithImpl<$Res>
    extends _$InvoiceItemCopyWithImpl<$Res, _$InvoiceItemImpl>
    implements _$$InvoiceItemImplCopyWith<$Res> {
  __$$InvoiceItemImplCopyWithImpl(
    _$InvoiceItemImpl _value,
    $Res Function(_$InvoiceItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceId = null,
    Object? itemId = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? discountPercent = null,
    Object? taxRate = null,
    Object? lineTotal = null,
    Object? createdAt = null,
    Object? itemName = freezed,
    Object? itemDescription = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _$InvoiceItemImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        invoiceId:
            null == invoiceId
                ? _value.invoiceId
                : invoiceId // ignore: cast_nullable_to_non_nullable
                    as int,
        itemId:
            null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                    as int,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        unitPrice:
            null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        discountPercent:
            null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        taxRate:
            null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        lineTotal:
            null == lineTotal
                ? _value.lineTotal
                : lineTotal // ignore: cast_nullable_to_non_nullable
                    as Decimal,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        itemName:
            freezed == itemName
                ? _value.itemName
                : itemName // ignore: cast_nullable_to_non_nullable
                    as String?,
        itemDescription:
            freezed == itemDescription
                ? _value.itemDescription
                : itemDescription // ignore: cast_nullable_to_non_nullable
                    as String?,
        unit:
            freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceItemImpl implements _InvoiceItem {
  const _$InvoiceItemImpl({
    this.id,
    required this.invoiceId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.discountPercent,
    required this.taxRate,
    required this.lineTotal,
    required this.createdAt,
    this.itemName,
    this.itemDescription,
    this.unit,
  });

  factory _$InvoiceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceItemImplFromJson(json);

  @override
  final int? id;
  @override
  final int invoiceId;
  @override
  final int itemId;
  @override
  final Decimal quantity;
  @override
  final Decimal unitPrice;
  @override
  final Decimal discountPercent;
  @override
  final Decimal taxRate;
  @override
  final Decimal lineTotal;
  @override
  final DateTime createdAt;
  // Navigation properties
  @override
  final String? itemName;
  @override
  final String? itemDescription;
  @override
  final String? unit;

  @override
  String toString() {
    return 'InvoiceItem(id: $id, invoiceId: $invoiceId, itemId: $itemId, quantity: $quantity, unitPrice: $unitPrice, discountPercent: $discountPercent, taxRate: $taxRate, lineTotal: $lineTotal, createdAt: $createdAt, itemName: $itemName, itemDescription: $itemDescription, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.itemDescription, itemDescription) ||
                other.itemDescription == itemDescription) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    invoiceId,
    itemId,
    quantity,
    unitPrice,
    discountPercent,
    taxRate,
    lineTotal,
    createdAt,
    itemName,
    itemDescription,
    unit,
  );

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      __$$InvoiceItemImplCopyWithImpl<_$InvoiceItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceItemImplToJson(this);
  }
}

abstract class _InvoiceItem implements InvoiceItem {
  const factory _InvoiceItem({
    final int? id,
    required final int invoiceId,
    required final int itemId,
    required final Decimal quantity,
    required final Decimal unitPrice,
    required final Decimal discountPercent,
    required final Decimal taxRate,
    required final Decimal lineTotal,
    required final DateTime createdAt,
    final String? itemName,
    final String? itemDescription,
    final String? unit,
  }) = _$InvoiceItemImpl;

  factory _InvoiceItem.fromJson(Map<String, dynamic> json) =
      _$InvoiceItemImpl.fromJson;

  @override
  int? get id;
  @override
  int get invoiceId;
  @override
  int get itemId;
  @override
  Decimal get quantity;
  @override
  Decimal get unitPrice;
  @override
  Decimal get discountPercent;
  @override
  Decimal get taxRate;
  @override
  Decimal get lineTotal;
  @override
  DateTime get createdAt; // Navigation properties
  @override
  String? get itemName;
  @override
  String? get itemDescription;
  @override
  String? get unit;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
