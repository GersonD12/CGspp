// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calet/app/view/app.dart';
import 'test_utils.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(createTestApp(const App()));

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have debug banner disabled', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(createTestApp(const App()));

    // Verify debug banner is disabled
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
