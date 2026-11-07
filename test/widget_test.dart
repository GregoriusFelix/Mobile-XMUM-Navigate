import 'package:flutter_test/flutter_test.dart';
import 'package:xmum_navigate/main.dart';

void main() {
  testWidgets('Welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const XMUMNavigateApp(
      firebaseReady: false,
      firebaseError: 'Firebase not configured',
    ));

    expect(find.text('XMUM Navigate'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
