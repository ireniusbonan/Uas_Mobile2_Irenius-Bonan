import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the main.dart file where the MyApp widget is defined.
import 'package:flutter_rest_api/main.dart';

void main() {
  // Define a widget test named 'Counter increments smoke test'.
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Pump the MyApp widget into the tester.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    // Ensure that there is exactly one widget with the text '0'.
    expect(find.text('0'), findsOneWidget);
    // Ensure that there is no widget with the text '1'.
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    // Find the widget with the '+' icon and simulate a tap.
    await tester.tap(find.byIcon(Icons.add));
    // Trigger a frame to rebuild the widget tree.
    await tester.pump();

    // Verify that our counter has incremented.
    // Ensure that there is no widget with the text '0'.
    expect(find.text('0'), findsNothing);
    // Ensure that there is exactly one widget with the text '1'.
    expect(find.text('1'), findsOneWidget);
  });
}
