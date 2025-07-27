-- SQL Script to demonstrate inventory management
-- This shows how the inventory system now works

-- Before creating an invoice, check current stock
SELECT 
    id,
    name,
    stock_quantity as current_stock,
    low_stock_alert
FROM items 
WHERE name LIKE '%light%';

-- Example: Create an invoice for 5 lights
-- The system will automatically:
-- 1. Check if 5 lights are available (stock >= 5)
-- 2. Create the invoice if stock is sufficient
-- 3. Reduce stock_quantity by 5
-- 4. Create an inventory transaction record

-- After invoice creation, check updated stock
SELECT 
    id,
    name,
    stock_quantity as remaining_stock,
    low_stock_alert
FROM items 
WHERE name LIKE '%light%';

-- View inventory transaction history
SELECT 
    it.id,
    i.name as item_name,
    it.transaction_type,
    it.quantity_change,
    it.previous_quantity,
    it.new_quantity,
    it.invoice_id,
    it.notes,
    it.created_at
FROM inventory_transactions it
JOIN items i ON it.item_id = i.id
ORDER BY it.created_at DESC;

-- Check low stock alerts
SELECT 
    name,
    stock_quantity,
    low_stock_alert,
    CASE 
        WHEN stock_quantity <= 0 THEN 'OUT OF STOCK'
        WHEN stock_quantity <= low_stock_alert THEN 'LOW STOCK'
        ELSE 'SUFFICIENT'
    END as stock_status
FROM items
WHERE stock_quantity <= low_stock_alert
ORDER BY stock_quantity ASC;
