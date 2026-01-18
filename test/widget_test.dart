import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/admin/admin_dashboard.dart';

void main() {
  testWidgets('Renders Admin Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboard()));

    await tester.pump();

    // Verify that the Admin Dashboard title is present.
    expect(find.text('Admin Dashboard'), findsOneWidget);

    // Verify that the list tiles for management are present.
    expect(find.byIcon(Icons.people_outline), findsOneWidget);
    expect(find.byIcon(Icons.book_outlined), findsOneWidget);
  });
}
