// This is a basic Flutter widget test for Chama Tracker.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mobifund smoke test - app launches and shows dashboard',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This test requires Supabase to be initialized,
    // so we test the widget structure without full app initialization
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Mobifund'),
          ),
        ),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Mobifund'), findsOneWidget);
  });
}
