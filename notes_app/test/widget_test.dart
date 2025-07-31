
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart'; // Make sure this path matches your project

void main() {
  testWidgets('Dream Notes app loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const DreamNotesApp());

    // Check if title is present
    expect(find.text('Dream Notes'), findsOneWidget);
  });
}
