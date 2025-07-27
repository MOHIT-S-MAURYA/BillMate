import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:billmate/core/di/injection_container.dart';
import 'package:billmate/core/database/database_helper.dart';
import 'package:billmate/core/navigation/navigation_service.dart';
import 'package:billmate/core/navigation/app_routes.dart';
import 'package:billmate/shared/constants/app_colors.dart';
import 'package:billmate/shared/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await configureDependencies();

  // Initialize database
  await DatabaseHelper().database;

  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.instance.navigatorKey,
      onGenerateRoute: AppRouteGenerator.generateRoute,
      initialRoute: AppRoutes.main,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        // Enable gesture navigation
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) {
        // Set system UI overlay style
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        );
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
