import 'package:flutter_test/flutter_test.dart';
import 'package:juwishcoin_app/main.dart';

void main() {
  testWidgets('JuwishCoin app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JuwishCoinApp());

    // Verify header title
    expect(find.text('TRADE TERMINAL'), findsOneWidget);
    expect(find.text('VIP TIER 3'), findsOneWidget);
  });
}
