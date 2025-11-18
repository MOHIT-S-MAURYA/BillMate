import 'package:flutter/material.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/core/localization/country_service.dart';
import 'package:billmate/core/navigation/navigation_service.dart';
import 'package:billmate/core/navigation/app_routes.dart';
import 'package:billmate/shared/constants/app_strings.dart';
import 'package:billmate/shared/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await configureDependencies();

  // Initialize services
  await getIt<DatabaseHelper>().database;
  await getIt<CountryService>().initialize();

  // Check if onboarding has been seen
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Reset database in debug mode for easy testing
  // await DatabaseResetService(getIt<DatabaseHelper>()).resetDatabase();
  // await DemoDataService(getIt<DatabaseHelper>()).init();

  runApp(BillMateApp(hasSeenOnboarding: hasSeenOnboarding));
}

class BillMateApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const BillMateApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.instance.navigatorKey,
      onGenerateRoute: AppRouteGenerator.generateRoute,
      initialRoute: AppRoutes.main,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
