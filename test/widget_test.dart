import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  testWidgets('expense tracker app loads with default expenses',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Flutter Course'), findsOneWidget);
    expect(find.text('Cinema'), findsOneWidget);
  });

  testWidgets('dashboard fits phone and wide layouts',
      (WidgetTester tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final size in [const Size(390, 844), const Size(1024, 768)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Recent expenses'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('spending overview keeps all categories when list is filtered',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final foodFilter = find.widgetWithText(ChoiceChip, 'Food');
    await tester.ensureVisible(foodFilter);
    await tester.tap(foodFilter);
    await tester.pumpAndSettle();

    expect(find.text('Leisure'), findsOneWidget);
    expect(find.text(currencyFormatter.format(15.69)), findsOneWidget);
    expect(find.text('Cinema'), findsNothing);
  });
}
