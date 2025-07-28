import 'package:flutter/material.dart';
import 'package:billmate/shared/constants/app_colors.dart';

/// Smart deletion widget that provides multiple ways to delete records
/// without cluttering the UI with visible delete buttons everywhere
class SmartDeletableItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final String? deleteConfirmationTitle;
  final String? deleteConfirmationMessage;
  final bool canDelete;
  final bool canEdit;
  final bool enableSwipeToDelete;
  final bool enableLongPressMenu;
  final IconData? deleteIcon;
  final Color? deleteColor;

  const SmartDeletableItem({
    super.key,
    required this.child,
    this.onDelete,
    this.onEdit,
    this.deleteConfirmationTitle,
    this.deleteConfirmationMessage,
    this.canDelete = true,
    this.canEdit = false,
    this.enableSwipeToDelete = true,
    this.enableLongPressMenu = true,
    this.deleteIcon = Icons.delete,
    this.deleteColor = Colors.red,
  });

  @override
  State<SmartDeletableItem> createState() => _SmartDeletableItemState();
}

class _SmartDeletableItemState extends State<SmartDeletableItem> {
  @override
  Widget build(BuildContext context) {
    if (!widget.canDelete && !widget.canEdit) {
      return widget.child;
    }

    Widget childWidget = widget.child;

    // Add swipe to delete functionality
    if (widget.enableSwipeToDelete && widget.canDelete) {
      childWidget = Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        background: _buildSwipeBackground(),
        confirmDismiss: (direction) => _showDeleteConfirmation(context),
        onDismissed: (direction) {
          if (widget.onDelete != null) {
            widget.onDelete!();
          }
        },
        child: childWidget,
      );
    }

    // Add long press menu functionality - simplified
    if (widget.enableLongPressMenu && (widget.canDelete || widget.canEdit)) {
      childWidget = InkWell(
        onLongPress: () => _showContextMenu(context),
        child: childWidget,
      );
    }

    return childWidget;
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            widget.deleteColor?.withOpacity(0.8) ?? Colors.red.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.deleteIcon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          const Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 100,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        if (widget.canEdit && widget.onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Text('Edit'),
              ],
            ),
          ),
        if (widget.canDelete && widget.onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(widget.deleteIcon, color: widget.deleteColor, size: 20),
                const SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: widget.deleteColor)),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value == 'edit' && widget.onEdit != null) {
        widget.onEdit!();
      } else if (value == 'delete' && widget.onDelete != null) {
        _showDeleteConfirmation(context).then((confirmed) {
          if (confirmed == true) {
            widget.onDelete!();
          }
        });
      }
    });
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: widget.deleteColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.deleteConfirmationTitle ?? 'Delete Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              widget.deleteConfirmationMessage ??
                  'Are you sure you want to delete this item? This action cannot be undone.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.deleteColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

/// Smart selection mode widget for batch operations
class SmartSelectionMode extends StatefulWidget {
  final List<Widget> children;
  final Function(List<int> selectedIndices)? onDelete;
  final Function(List<int> selectedIndices)? onBulkAction;
  final String? bulkActionLabel;
  final IconData? bulkActionIcon;
  final bool showSelectAll;

  const SmartSelectionMode({
    super.key,
    required this.children,
    this.onDelete,
    this.onBulkAction,
    this.bulkActionLabel,
    this.bulkActionIcon,
    this.showSelectAll = true,
  });

  @override
  State<SmartSelectionMode> createState() => _SmartSelectionModeState();
}

class _SmartSelectionModeState extends State<SmartSelectionMode> {
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selection mode header
        if (_isSelectionMode) _buildSelectionHeader(),

        // Items with selection capability
        ...widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;

          if (_isSelectionMode) {
            return _buildSelectableItem(index, child);
          }

          return GestureDetector(
            onLongPress: () {
              setState(() {
                _isSelectionMode = true;
                _selectedIndices.add(index);
              });
            },
            child: child,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (widget.showSelectAll)
            Checkbox(
              value: _selectedIndices.length == widget.children.length,
              tristate: true,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIndices = Set.from(
                      List.generate(widget.children.length, (index) => index),
                    );
                  } else {
                    _selectedIndices.clear();
                  }
                });
              },
            ),

          Expanded(
            child: Text(
              '${_selectedIndices.length} selected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          if (widget.onBulkAction != null && _selectedIndices.isNotEmpty)
            IconButton(
              onPressed: () {
                widget.onBulkAction!(_selectedIndices.toList());
              },
              icon: Icon(widget.bulkActionIcon ?? Icons.more_vert),
              tooltip: widget.bulkActionLabel ?? 'Bulk Action',
            ),

          if (widget.onDelete != null && _selectedIndices.isNotEmpty)
            IconButton(
              onPressed: () => _showBulkDeleteConfirmation(),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Selected',
            ),

          IconButton(
            onPressed: () {
              setState(() {
                _isSelectionMode = false;
                _selectedIndices.clear();
              });
            },
            icon: const Icon(Icons.close),
            tooltip: 'Exit Selection Mode',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableItem(int index, Widget child) {
    final isSelected = _selectedIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIndices.remove(index);
          } else {
            _selectedIndices.add(index);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          border:
              isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            child,
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Delete Selected Items'),
              ],
            ),
            content: Text(
              'Are you sure you want to delete ${_selectedIndices.length} selected items? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete!(_selectedIndices.toList());
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIndices.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

/// Smart floating action button that shows contextual actions
class SmartActionButton extends StatefulWidget {
  final List<SmartAction> actions;
  final Widget? child;
  final Color? backgroundColor;
  final bool mini;

  const SmartActionButton({
    super.key,
    required this.actions,
    this.child,
    this.backgroundColor,
    this.mini = false,
  });

  @override
  State<SmartActionButton> createState() => _SmartActionButtonState();
}

class _SmartActionButtonState extends State<SmartActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action buttons
        ...widget.actions.reversed.map((action) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * 60),
                  child: Opacity(
                    opacity: _animation.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FloatingActionButton(
                        mini: true,
                        heroTag:
                            "smart_action_${widget.actions.indexOf(action)}_${hashCode}",
                        backgroundColor: action.backgroundColor,
                        onPressed: () {
                          _toggleExpanded();
                          action.onTap();
                        },
                        child: Icon(action.icon, color: action.iconColor),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),

        // Main FAB
        FloatingActionButton(
          mini: widget.mini,
          heroTag: "smart_main_fab_${hashCode}",
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          onPressed: _toggleExpanded,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: widget.child ?? const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class SmartAction {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;

  const SmartAction({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.tooltip,
  });
}
