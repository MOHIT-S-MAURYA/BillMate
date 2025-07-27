import 'package:flutter/material.dart';
import 'package:billmate/shared/widgets/main_navigation.dart';
import 'package:billmate/features/billing/presentation/pages/create_invoice_page.dart';
import 'package:billmate/features/billing/presentation/pages/invoice_list_page.dart';
import 'package:billmate/features/billing/presentation/pages/customer_list_page.dart';
import 'package:billmate/features/inventory/presentation/pages/inventory_page.dart';
import 'package:billmate/features/settings/presentation/pages/settings_page.dart';
import 'package:billmate/features/dashboard/presentation/pages/dashboard_page.dart';

/// App route names
class AppRoutes {
  static const String main = '/';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String addItem = '/inventory/add';
  static const String customers = '/customers';
  static const String invoices = '/invoices';
  static const String createInvoice = '/invoices/create';
  static const String settings = '/settings';
}

/// Route generator for named navigation
class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.main:
        return _createRoute(const MainNavigationPage());

      case AppRoutes.dashboard:
        return _createRoute(
          DashboardPage(
            onNavigate: (index) {
              // Handle navigation from dashboard
            },
            onNavigateWithFilter: (index, filter) {
              // Handle navigation with filter from dashboard
            },
          ),
        );

      case AppRoutes.inventory:
        return _createRoute(const InventoryPage());

      case AppRoutes.addItem:
        // For now, navigate to inventory page
        return _createRoute(const InventoryPage());

      case AppRoutes.customers:
        return _createRoute(const CustomerListPage());

      case AppRoutes.invoices:
        final filter = settings.arguments as String?;
        return _createRoute(InvoiceListPage(initialFilter: filter));

      case AppRoutes.createInvoice:
        return _createRoute(const CreateInvoicePage());

      case AppRoutes.settings:
        return _createRoute(const SettingsPage());

      default:
        return _createErrorRoute(settings.name);
    }
  }

  /// Create a route with custom transitions
  static PageRoute<T> _createRoute<T>(
    Widget page, {
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right (iOS style)
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Create an error route for unrecognized route names
  static Route<dynamic> _createErrorRoute(String? routeName) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route not found: ${routeName ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.main,
                          (route) => false,
                        ),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Extension to add route navigation methods to BuildContext
extension RouteNavigationExtension on BuildContext {
  /// Navigate to dashboard
  Future<T?> goToDashboard<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.dashboard);

  /// Navigate to inventory
  Future<T?> goToInventory<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.inventory);

  /// Navigate to add item page
  Future<T?> goToAddItem<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.addItem);

  /// Navigate to customers
  Future<T?> goToCustomers<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.customers);

  /// Navigate to invoices
  Future<T?> goToInvoices<T extends Object?>({String? filter}) =>
      Navigator.of(this).pushNamed(AppRoutes.invoices, arguments: filter);

  /// Navigate to create invoice
  Future<T?> goToCreateInvoice<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.createInvoice);

  /// Navigate to settings
  Future<T?> goToSettings<T extends Object?>() =>
      Navigator.of(this).pushNamed(AppRoutes.settings);

  /// Navigate to main page and clear stack
  Future<T?> goToMain<T extends Object?>() => Navigator.of(
    this,
  ).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
}
