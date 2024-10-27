import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/screens/home_screen.dart';
import 'package:frontend_flutter/services/interest_calculator.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the BarChart widget

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('Displays loan type radio buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<InterestCalculator>(
            create: (_) => InterestCalculator(),
            child: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Loan Type:'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Mortgage'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
    });

    testWidgets('Displays principal input field with instructions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<InterestCalculator>(
            create: (_) => InterestCalculator(),
            child: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('Please enter the principal amount'), findsOneWidget);
      expect(find.text('Enter a value between 1 and 10000'), findsOneWidget);
    });

    testWidgets('Displays duration input field with instructions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<InterestCalculator>(
            create: (_) => InterestCalculator(),
            child: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Duration (years)'), findsOneWidget);
      expect(find.text('Please enter the duration in years'), findsOneWidget);
      expect(find.text('Enter a value between 1 and 10'), findsOneWidget);
    });

    testWidgets('Displays result text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<InterestCalculator>(
            create: (_) => InterestCalculator(),
            child: HomeScreen(),
          ),
        ),
      );

      expect(find.textContaining('Simple Interest:'), findsOneWidget);
      expect(find.textContaining('Compound Interest:'), findsOneWidget);
    });

    testWidgets('Displays bar chart', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<InterestCalculator>(
            create: (_) => InterestCalculator(),
            child: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}
