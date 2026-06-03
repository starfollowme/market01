import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MarketApp());
    expect(find.byType(MarketApp), findsOneWidget);
  });
}
