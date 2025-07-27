import 'package:flutter/material.dart';
import 'package:billmate/features/inventory/domain/entities/item.dart';
import 'package:billmate/shared/constants/app_colors.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int) onStockUpdate;

  const ItemCard({
    super.key,
    required this.item,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onStockUpdate,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = widget.item.stockQuantity <= widget.item.lowStockAlert;
    final isOutOfStock = widget.item.stockQuantity <= 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isOutOfStock
                            ? AppColors.error.withValues(alpha: 0.3)
                            : isLowStock
                            ? Colors.orange.withValues(alpha: 0.3)
                            : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMainContent(isLowStock, isOutOfStock),
                    if (_isExpanded) _buildExpandedContent(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(bool isLowStock, bool isOutOfStock) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _buildStockBadge(isLowStock, isOutOfStock),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCategoryChip(),
                        if (widget.item.hsnCode?.isNotEmpty == true) ...[
                          const SizedBox(width: 8),
                          _buildHsnChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow(),
          const SizedBox(height: 12),
          _buildStockRow(),
        ],
      ),
    );
  }

  Widget _buildStockBadge(bool isLowStock, bool isOutOfStock) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    if (isOutOfStock) {
      bgColor = AppColors.error;
      textColor = Colors.white;
      icon = Icons.error;
      text = 'Out of Stock';
    } else if (isLowStock) {
      bgColor = Colors.orange;
      textColor = Colors.white;
      icon = Icons.warning;
      text = 'Low Stock';
    } else {
      bgColor = AppColors.success;
      textColor = Colors.white;
      icon = Icons.check_circle;
      text = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            widget.category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHsnChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            widget.item.hsnCode!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.edit,
              color: AppColors.primary,
              onTap: widget.onEdit,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.delete,
              color: AppColors.error,
              onTap: widget.onDelete,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildQuickStockButton(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildQuickStockButton() {
    return InkWell(
      onTap: () => _showStockUpdateDialog(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.1),
              AppColors.success.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory, color: AppColors.success, size: 14),
            const SizedBox(width: 4),
            Text(
              'Stock',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceInfo(
            'Selling Price',
            '₹${widget.item.sellingPrice}',
            AppColors.success,
            Icons.trending_up,
          ),
        ),
        if (widget.item.purchasePrice != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildPriceInfo(
              'Purchase Price',
              '₹${widget.item.purchasePrice}',
              AppColors.primary,
              Icons.shopping_cart,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceInfo(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow() {
    final stockPercentage =
        widget.item.lowStockAlert > 0
            ? (widget.item.stockQuantity / widget.item.lowStockAlert).clamp(
              0.0,
              1.0,
            )
            : 1.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stock: ${widget.item.stockQuantity} ${widget.item.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Alert: ${widget.item.lowStockAlert}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stockPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                stockPercentage > 0.5
                    ? AppColors.success
                    : stockPercentage > 0.2
                    ? Colors.orange
                    : AppColors.error,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 12),
          if (widget.item.description?.isNotEmpty == true) ...[
            _buildExpandedRow(
              'Description',
              widget.item.description!,
              Icons.description,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: _buildExpandedRow(
                  'Tax Rate',
                  '${widget.item.taxRate}%',
                  Icons.percent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExpandedRow(
                  'Unit',
                  widget.item.unit,
                  Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExpandedRow(
                  'Created',
                  _formatDate(widget.item.createdAt),
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExpandedRow(
                  'Updated',
                  _formatDate(widget.item.updatedAt),
                  Icons.update,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStockUpdateDialog() {
    final controller = TextEditingController(
      text: widget.item.stockQuantity.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.inventory, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Update Stock'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current stock: ${widget.item.stockQuantity} ${widget.item.unit}',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'New Stock Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.inventory_2,
                      color: AppColors.primary,
                    ),
                    suffixText: widget.item.unit,
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newStock = int.tryParse(controller.text);
                  if (newStock != null) {
                    widget.onStockUpdate(newStock);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }
}
