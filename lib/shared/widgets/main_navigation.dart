import 'package:flutter/material.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/inventory/presentation/pages/inventory_page.dart';
import 'package:billmate/features/settings/presentation/pages/settings_page.dart';
import 'package:billmate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billmate/features/billing/presentation/pages/customer_list_page.dart';
import 'package:billmate/features/billing/presentation/pages/invoice_list_page.dart';
import 'package:billmate/core/navigation/modern_navigation_widgets.dart';
import 'package:billmate/core/navigation/gesture_navigation.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  String? _invoiceFilter;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _updatePages();
  }

  void _updatePages() {
    _pages.clear();
    _pages.addAll([
      DashboardPage(
        onNavigate: _navigateToTab,
        onNavigateWithFilter: _navigateToTabWithFilter,
      ),
      const InventoryPage(),
      const CustomerListPage(),
      InvoiceListPage(initialFilter: _invoiceFilter),
      const SettingsPage(),
    ]);
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
      _invoiceFilter = null; // Clear filter when navigating normally
      _updatePages();
    });
  }

  void _navigateToTabWithFilter(int index, String? filter) {
    setState(() {
      _currentIndex = index;
      if (index == 3) {
        // Invoices tab
        _invoiceFilter = filter;
      }
      _updatePages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernNavigationPage(
      enableSwipeBack: false, // Disable on main navigation to prevent conflicts
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: ModernNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            ModernNavigationBarItem(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: 'Dashboard',
            ),
            ModernNavigationBarItem(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              label: 'Inventory',
            ),
            ModernNavigationBarItem(
              icon: Icons.people_outline,
              selectedIcon: Icons.people,
              label: 'Customers',
            ),
            ModernNavigationBarItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long,
              label: 'Invoices',
            ),
            ModernNavigationBarItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'Settings',
            ),
          ],
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: Colors.white,
          elevation: 10,
        ),
        floatingActionButton: _buildContextualFAB(),
      ),
    );
  }

  Widget? _buildContextualFAB() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return ModernFloatingActionButtonExtended(
          heroTag: "dashboardFAB",
          onPressed: () {
            // Navigate to new invoice
            setState(() {
              _currentIndex = 3; // Switch to invoices tab
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('New Invoice'),
        );
      case 1: // Inventory - Let inventory page handle its own FAB
        return null;
      case 3: // Invoices - Let invoices page handle its own FAB
        return null;
      default:
        return null;
    }
  }
}
