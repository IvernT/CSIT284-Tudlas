import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('expense tracker app loads with default expenses',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Flutter Course'), findsOneWidget);
    expect(find.text('Cinema'), findsOneWidget);
  });
}
