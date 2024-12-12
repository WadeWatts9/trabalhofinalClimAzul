import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climaapp/main.dart';

void main() {
  testWidgets('WeatherApp basic widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Verify that the app shows the input field for location search.
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the app shows the location icon button.
    expect(find.byIcon(Icons.location_on), findsOneWidget);

    // Verify that the initial weather text or placeholder is displayed.
    expect(find.textContaining('Clima actual'), findsWidgets);
  });
}
