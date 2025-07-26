import 'package:flutter/material.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/features/inventory/presentation/pages/inventory_page.dart';
import 'package:billmate/features/settings/presentation/pages/settings_page.dart';
import 'package:billmate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billmate/features/billing/presentation/pages/customer_list_page.dart';
import 'package:billmate/features/billing/presentation/pages/invoice_list_page.dart';

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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _currentIndex == 0
                        ? Icons.dashboard
                        : Icons.dashboard_outlined,
                    size: 24,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.inventory_2
                        : Icons.inventory_2_outlined,
                    size: 24,
                  ),
                ),
                label: 'Inventory',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _currentIndex == 2 ? Icons.people : Icons.people_outline,
                    size: 24,
                  ),
                ),
                label: 'Customers',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _currentIndex == 3
                        ? Icons.receipt_long
                        : Icons.receipt_long_outlined,
                    size: 24,
                  ),
                ),
                label: 'Invoices',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Icon(
                    _currentIndex == 4
                        ? Icons.settings
                        : Icons.settings_outlined,
                    size: 24,
                  ),
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildContextualFAB(),
    );
  }

  Widget? _buildContextualFAB() {
    switch (_currentIndex) {
      case 0: // Dashboard
        return FloatingActionButton.extended(
          heroTag: "dashboardFAB",
          onPressed: () {
            // Navigate to new invoice
            setState(() {
              _currentIndex = 3; // Switch to invoices tab
            });
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Invoice'),
        );
      case 3: // Invoices - No FAB here as InvoiceListPage has its own
        return null;
      default:
        return null; // No FAB for other tabs (Inventory has its own)
    }
  }
}
