import 'package:domify/providers/appointments_provider.dart';
import 'package:domify/screens/appointments_screen.dart';
import 'package:domify/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildBookingsScreen({VoidCallback? onBack}) {
    return ChangeNotifierProvider<AppointmentsProvider>(
      create: (_) => AppointmentsProvider(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: AppointmentsScreen(onBack: onBack),
      ),
    );
  }

  testWidgets('renders bookings language and empty states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildBookingsScreen());
    await tester.pumpAndSettle();

    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('0 upcoming · 0 past'), findsOneWidget);
    expect(find.text('No upcoming bookings'), findsOneWidget);
    expect(find.text('Appointments'), findsNothing);
  });

  testWidgets('header back button uses provided callback', (
    WidgetTester tester,
  ) async {
    bool didGoBack = false;

    await tester.pumpWidget(
      buildBookingsScreen(onBack: () => didGoBack = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();

    expect(didGoBack, isTrue);
  });
}
