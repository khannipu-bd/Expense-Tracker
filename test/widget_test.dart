import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/app/providers.dart';

void main() {
  testWidgets('App initializes and displays bottom navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
        child: const HisablyApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify main bottom navigation items are displayed
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
