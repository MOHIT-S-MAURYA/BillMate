import 'dart:async';

/// Event types for inventory changes
enum InventoryEventType { stockChanged, itemCreated, itemUpdated, itemDeleted }

/// Inventory event data
class InventoryEvent {
  final InventoryEventType type;
  final int? itemId;
  final Map<String, dynamic>? data;

  const InventoryEvent({required this.type, this.itemId, this.data});
}

/// Global event bus for inventory changes
class InventoryEventBus {
  static final InventoryEventBus _instance = InventoryEventBus._internal();

  factory InventoryEventBus() => _instance;

  InventoryEventBus._internal();

  final StreamController<InventoryEvent> _controller =
      StreamController<InventoryEvent>.broadcast();

  /// Stream of inventory events
  Stream<InventoryEvent> get events => _controller.stream;

  /// Emit an inventory event
  void emit(InventoryEvent event) {
    _controller.add(event);
  }

  /// Emit stock changed event
  void emitStockChanged(int itemId, {Map<String, dynamic>? data}) {
    emit(
      InventoryEvent(
        type: InventoryEventType.stockChanged,
        itemId: itemId,
        data: data,
      ),
    );
  }

  /// Emit item created event
  void emitItemCreated(int itemId) {
    emit(InventoryEvent(type: InventoryEventType.itemCreated, itemId: itemId));
  }

  /// Emit item updated event
  void emitItemUpdated(int itemId) {
    emit(InventoryEvent(type: InventoryEventType.itemUpdated, itemId: itemId));
  }

  /// Emit item deleted event
  void emitItemDeleted(int itemId) {
    emit(InventoryEvent(type: InventoryEventType.itemDeleted, itemId: itemId));
  }

  /// Dispose the event bus
  void dispose() {
    _controller.close();
  }
}
