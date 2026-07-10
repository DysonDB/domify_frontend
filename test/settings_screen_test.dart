import 'package:domify/providers/settings_provider.dart';
import 'package:domify/providers/theme_provider.dart';
import 'package:domify/screens/settings_screen.dart';
import 'package:domify/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget buildSettingsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (
          BuildContext context,
          ThemeProvider themeProvider,
          Widget? child,
        ) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SettingsScreen(),
          );
        },
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders all settings groups and retained actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSettingsScreen());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('App Settings'), 300);
    expect(find.text('App Settings'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('About'), 300);
    expect(find.text('About'), findsOneWidget);

    expect(find.text('Admin panel'), findsNothing);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('theme selector updates the active app theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSettingsScreen());
    await tester.pumpAndSettle();

    Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFF6F8F7));

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF0B111E));
  });

  testWidgets('language picker persists selected value on the page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSettingsScreen());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Language'), 300);
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Swahili'));
    await tester.pumpAndSettle();

    expect(find.text('Swahili'), findsWidgets);
  });
}
