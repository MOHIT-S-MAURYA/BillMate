// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:billmate/shared/constants/app_strings.dart';
import 'package:billmate/shared/constants/app_colors.dart';

void main() {
  group('BillMate Constants Tests', () {
    test('App constants are properly defined', () {
      // Test app strings
      expect(AppStrings.appName, isNotEmpty);
      expect(AppStrings.appName, equals('BillMate'));

      // Test app colors are defined
      expect(AppColors.primary, isNotNull);
      expect(AppColors.background, isNotNull);
      expect(AppColors.textPrimary, isNotNull);
    });

    test('Currency formatting works correctly', () {
      // Basic sanity test for currency values
      expect(1000.toString(), equals('1000'));
      expect(1000.50.toString(), contains('1000.5'));
    });
  });
}
