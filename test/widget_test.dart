import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/main.dart';

void main() {
  testWidgets('MobileTemplateApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileTemplateApp());
    expect(find.text('Itens'), findsOneWidget);
  });
}
