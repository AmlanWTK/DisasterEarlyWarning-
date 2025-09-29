import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bangladesh_disaster_management/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DisasterManagementApp());

    // Verify that the app starts properly
    expect(find.text('Bangladesh'), findsOneWidget);
    expect(find.text('Disaster Management'), findsOneWidget);
  });
}
