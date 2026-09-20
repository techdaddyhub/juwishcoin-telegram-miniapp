import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juwishcoin_app/main.dart';

void main() {
  testWidgets('JuwishCoin app smoke test and Admin PIN flow', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JuwishCoinApp());

    // Verify header title & VIP badge
    expect(find.text('TRADE TERMINAL'), findsOneWidget);
    expect(find.text('VIP TIER 3'), findsOneWidget);

    // Tap on VIP Tier 3 badge to trigger Admin PIN dialog
    await tester.tap(find.text('VIP TIER 3'));
    await tester.pumpAndSettle();

    // Verify Admin PIN dialog is shown
    expect(find.text('VIP ADMIN ACCESS'), findsOneWidget);

    // Enter PIN 7777
    await tester.enterText(find.byType(TextField), '7777');
    await tester.tap(find.text('UNLOCK TERMINAL'));
    await tester.pumpAndSettle();

    // Verify VIP Admin Command Center is rendered
    expect(find.text('VIP ADMIN COMMAND CENTER'), findsOneWidget);
    expect(find.text('DEPLOY CHANGES LIVE'), findsOneWidget);
  });
}

