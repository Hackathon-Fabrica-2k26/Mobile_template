import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/turma_cadastro_flow.dart';
import 'package:mobile_template/screens/turma_detail_screen.dart';

void main() {
  testWidgets('NovaTurmaFotoScreen renderiza etapa 1 de 2 com campos vazios', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NovaTurmaFotoScreen()));

    expect(find.text('Nova turma'), findsOneWidget);
    expect(find.text('ETAPA 1 DE 2 · DADOS E FOTO'), findsOneWidget);
    expect(find.text('Nome da turma *'), findsOneWidget);
    expect(find.text('Enviar foto'), findsOneWidget);
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Reconhecer nomes'), findsOneWidget);
  });

  testWidgets('ConfirmarNomesScreen renderiza etapa 2 de 2 com os nomes reconhecidos', (WidgetTester tester) async {
    final nomes = <Map<String, dynamic>>[
      {'nome': 'Aluno Alfa', 'precisaConferencia': false},
      {'nome': 'Aluno Beta', 'precisaConferencia': false},
      {'nome': 'Aluno Gama', 'precisaConferencia': true},
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: ConfirmarNomesScreen(
          nomeTurma: 'Turma A',
          turno: 'Manhã',
          anoLetivo: 2026,
          nomesIniciais: nomes,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confira os nomes'), findsOneWidget);
    expect(find.text('ETAPA 2 DE 2 · CONFERIR E CRIAR'), findsOneWidget);
    expect(find.text('${nomes.length} nomes encontrados'), findsOneWidget);
    expect(find.text('Aluno Alfa'), findsOneWidget);
    expect(find.text('Aluno Gama'), findsOneWidget);
    expect(find.text('Confirmar ${nomes.length} alunos'), findsOneWidget);
  });

  testWidgets('TurmaDetailScreen exibe erro e Tentar novamente quando o backend não responde', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TurmaDetailScreen(
          turmaId: 1,
          turmaNome: 'Turma A',
          turno: 'Manhã',
          totalAlunos: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Aluno Alfa'), findsNothing);
  });
}
