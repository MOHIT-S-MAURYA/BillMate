// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:billmate/main.dart';

void main() {
  testWidgets('BillMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BillMateApp());

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to BillMate'), findsOneWidget);
    expect(find.text('Your GST-compliant billing solution'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the app is still displaying the welcome message
    expect(find.text('Welcome to BillMate'), findsOneWidget);
  });
}
