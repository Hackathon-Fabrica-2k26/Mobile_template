import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/main.dart';

void main() {
  testWidgets('MarsupiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MarsupiApp());
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
