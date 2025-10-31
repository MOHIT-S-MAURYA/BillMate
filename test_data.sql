-- Sample data for testing BillMate app

-- Insert sample categories
INSERT OR IGNORE INTO categories (name, description) VALUES
('Electronics', 'Electronic items and accessories'),
('Appliances', 'Home and kitchen appliances'),
('Hardware', 'Tools and hardware items'),
('Stationery', 'Office and school supplies');

-- Insert sample customers
INSERT OR IGNORE INTO customers (name, email, phone, address, gstin) VALUES
('ABC Electronics Store', 'abc@electronics.com', '9876543210', '123 Electronics Market, Delhi', '07AABCA1234A1Z5'),
('XYZ Hardware Shop', 'xyz@hardware.com', '9876543211', '456 Hardware Street, Mumbai', '27BBBCB5678B2Z6'),
('Modern Tech Solutions', 'info@moderntech.com', '9876543212', '789 Tech Park, Bangalore', '29CCCDC9012C3Z7'),
('Global Supplies Co.', 'global@supplies.com', '9876543213', '321 Supply Chain Road, Chennai', '33DDDDD3456D4Z8'),
('Quick Mart', 'quick@mart.com', '9876543214', '654 Quick Avenue, Pune', '27EEEEE6789E5Z9');

-- Insert sample items
INSERT OR IGNORE INTO items (name, description, stock_quantity, purchase_price, selling_price, low_stock_alert, category_id) VALUES
('LED Bulb 9W', 'Energy efficient LED bulb 9 watts', 45, 180.00, 250.00, 10, 1),
('Ceiling Fan 48"', '48 inch ceiling fan with remote control', 8, 1800.00, 2500.00, 5, 2),
('Switch Board 2-way', '2-way electrical switch board', 2, 100.00, 150.00, 10, 1),
('Extension Cord 5m', '5 meter heavy duty extension cord', 0, 250.00, 350.00, 5, 1),
('Table Fan', 'Portable table fan 16 inch', 12, 800.00, 1200.00, 3, 2),
('Screwdriver Set', 'Complete screwdriver set with case', 15, 150.00, 220.00, 5, 3),
('Notebook A4', 'A4 size 200 pages notebook', 25, 45.00, 65.00, 10, 4),
('Pen Set', 'Set of 10 blue ballpoint pens', 30, 35.00, 50.00, 15, 4);

-- Insert sample invoices
INSERT OR IGNORE INTO invoices (
    invoice_number, customer_id, invoice_date, due_date, 
    subtotal, tax_rate, tax_amount, total_amount, 
    payment_status, payment_method, notes
) VALUES
('INV-001', 1, '2024-01-15 10:30:00', '2024-02-15', 4200.00, 18.0, 756.00, 4956.00, 'paid', 'upi', 'Bulk order for electronics'),
('INV-002', 2, '2024-01-16 14:20:00', '2024-02-16', 2100.00, 18.0, 378.00, 2478.00, 'paid', 'cash', 'Hardware supplies'),
('INV-003', 3, '2024-01-17 09:15:00', '2024-02-17', 2500.00, 18.0, 450.00, 2950.00, 'paid', 'upi', 'Tech equipment'),
('INV-004', 4, '2024-01-18 16:45:00', '2024-02-18', 1800.00, 18.0, 324.00, 2124.00, 'pending', 'credit', 'Office supplies'),
('INV-005', 5, '2024-01-19 11:30:00', '2024-02-19', 1200.00, 18.0, 216.00, 1416.00, 'pending', 'cash', 'Quick purchase'),
('INV-006', 1, '2024-01-20 13:00:00', '2024-01-05', 3600.00, 18.0, 648.00, 4248.00, 'overdue', 'credit', 'Overdue payment');

-- Insert sample invoice items
INSERT OR IGNORE INTO invoice_items (invoice_id, item_id, quantity, unit_price, total_price) VALUES
-- INV-001 items
(1, 1, 10, 250.00, 2500.00),
(1, 5, 1, 1200.00, 1200.00),
(1, 7, 8, 65.00, 520.00),

-- INV-002 items  
(2, 6, 5, 220.00, 1100.00),
(2, 3, 6, 150.00, 900.00),
(2, 8, 2, 50.00, 100.00),

-- INV-003 items
(3, 2, 1, 2500.00, 2500.00),

-- INV-004 items
(4, 7, 20, 65.00, 1300.00),
(5, 8, 10, 50.00, 500.00),

-- INV-005 items
(5, 5, 1, 1200.00, 1200.00),

-- INV-006 items
(6, 1, 8, 250.00, 2000.00),
(6, 6, 8, 220.00, 1600.00);

-- Insert sample payments
INSERT OR IGNORE INTO payments (
    payment_number, invoice_id, payment_date, amount, 
    payment_method, reference_number, notes
) VALUES
('PAY-001', 1, '2024-01-16 15:30:00', 4956.00, 'upi', 'UPI123456789', 'Full payment via UPI'),
('PAY-002', 2, '2024-01-16 14:30:00', 2478.00, 'cash', 'CASH001', 'Cash payment in full'),
('PAY-003', 3, '2024-01-18 10:00:00', 2950.00, 'upi', 'UPI987654321', 'UPI payment received'),
('PAY-004', 6, '2024-01-25 16:00:00', 2000.00, 'cash', 'CASH002', 'Partial payment received');
