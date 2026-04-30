import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:denemeee/main.dart'; // Adjust if package name is different

void main() {
  testWidgets('Pomodoro app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PomodoroApp());

    // Verify that timer text exists (e.g., 25:00)
    expect(find.text('25:00'), findsOneWidget);

    // Verify that buttons exist
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
