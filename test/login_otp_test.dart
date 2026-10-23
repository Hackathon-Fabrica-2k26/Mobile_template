import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/login_screen.dart';
import 'package:mobile_template/screens/otp_screen.dart';

void main() {
  testWidgets('LoginScreen inicia com campos de texto vazios', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verifica que não há texto pré-preenchido
    final textFormFieldFinders = find.byType(TextFormField);
    expect(textFormFieldFinders, findsNWidgets(2));

    final matriculaField = tester.widget<TextFormField>(textFormFieldFinders.first);
    expect(matriculaField.controller?.text.isEmpty, isTrue);

    final senhaField = tester.widget<TextFormField>(textFormFieldFinders.last);
    expect(senhaField.controller?.text.isEmpty, isTrue);
  });

  testWidgets('OtpScreen inicia com os 4 campos de PIN vazios', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpScreen(email: 'ana.professora@escola.edu.br'),
      ),
    );

    final pinFields = find.byType(TextFormField);
    expect(pinFields, findsNWidgets(4));

    for (int i = 0; i < 4; i++) {
      final field = tester.widget<TextFormField>(pinFields.at(i));
      expect(field.controller?.text.isEmpty, isTrue);
    }

    // Verifica que o e-mail foi ofuscado de forma amigável e segura
    expect(find.textContaining('***'), findsOneWidget);
  });
}
