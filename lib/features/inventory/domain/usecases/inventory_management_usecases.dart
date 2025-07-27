import 'package:billmate/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for reducing stock when items are sold
@injectable
class ReduceStockUseCase {
  final InventoryRepository repository;

  ReduceStockUseCase(this.repository);

  Future<void> call(int itemId, int quantity) async {
    return repository.reduceStock(itemId, quantity);
  }
}

/// Use case for increasing stock when items are restocked or returned
@injectable
class IncreaseStockUseCase {
  final InventoryRepository repository;

  IncreaseStockUseCase(this.repository);

  Future<void> call(int itemId, int quantity) async {
    return repository.increaseStock(itemId, quantity);
  }
}

/// Use case for checking stock availability before creating invoices
@injectable
class CheckStockAvailabilityUseCase {
  final InventoryRepository repository;

  CheckStockAvailabilityUseCase(this.repository);

  Future<bool> call(int itemId, int requiredQuantity) async {
    return repository.checkStockAvailability(itemId, requiredQuantity);
  }
}

/// Use case for recording inventory transactions
@injectable
class RecordInventoryTransactionUseCase {
  final InventoryRepository repository;

  RecordInventoryTransactionUseCase(this.repository);

  Future<void> call(
    int itemId,
    String transactionType,
    int quantityChange, {
    int? invoiceId,
    String? notes,
  }) async {
    return repository.recordInventoryTransaction(
      itemId,
      transactionType,
      quantityChange,
      invoiceId: invoiceId,
      notes: notes,
    );
  }
}

/// Use case for reducing stock for multiple items (for complete invoice)
@injectable
class ReduceStockForInvoiceUseCase {
  final InventoryRepository repository;

  ReduceStockForInvoiceUseCase(this.repository);

  Future<void> call(Map<int, int> itemQuantities, int invoiceId) async {
    for (final entry in itemQuantities.entries) {
      final itemId = entry.key;
      final quantity = entry.value;

      // Check stock availability first
      final isAvailable = await repository.checkStockAvailability(
        itemId,
        quantity,
      );

      if (!isAvailable) {
        throw Exception('Insufficient stock for item ID: $itemId');
      }

      // Reduce stock (this already creates a transaction record with invoice reference)
      await repository.reduceStock(
        itemId,
        quantity,
        invoiceId: invoiceId,
        notes: 'Stock reduced for invoice #$invoiceId',
      );
    }
  }
}

/// Use case for restoring stock when invoice is cancelled
@injectable
class RestoreStockForCancelledInvoiceUseCase {
  final InventoryRepository repository;

  RestoreStockForCancelledInvoiceUseCase(this.repository);

  Future<void> call(Map<int, int> itemQuantities, int invoiceId) async {
    for (final entry in itemQuantities.entries) {
      final itemId = entry.key;
      final quantity = entry.value;

      // Increase stock back (this already creates a transaction record with invoice reference)
      await repository.increaseStock(
        itemId,
        quantity,
        invoiceId: invoiceId,
        notes: 'Stock restored due to invoice cancellation #$invoiceId',
      );
    }
  }
}
