import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/turma_cadastro_flow.dart';
import 'package:mobile_template/screens/turma_detail_screen.dart';
import 'package:mobile_template/services/mock_data_service.dart';

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

  testWidgets('ConfirmarNomesScreen renderiza etapa 2 de 2 com dados do JSON', (WidgetTester tester) async {
    final nomes = await MockDataService.instance.getChamadaOcrNomes();
    await tester.pumpWidget(
      MaterialApp(
        home: ConfirmarNomesScreen(
          nomeTurma: '1º ano A',
          turno: 'Manhã',
          anoLetivo: 2026,
          nomesIniciais: nomes,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Confira os nomes'), findsOneWidget);
    expect(find.text('ETAPA 2 DE 2 · CONFERIR E CRIAR'), findsOneWidget);
    expect(find.text('8 nomes encontrados'), findsOneWidget);
    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('Davi Pereira'), findsOneWidget);
    expect(find.text('Confirmar 8 alunos'), findsOneWidget);
  });

  testWidgets('TurmaDetailScreen renderiza Alunos cadastrados e Sem alunos conforme Figma', (WidgetTester tester) async {
    // Turma 1 tem 8 estudantes no JSON
    await tester.pumpWidget(
      const MaterialApp(
        home: TurmaDetailScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
          turno: 'Manhã',
          totalAlunos: 8,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estudantes da turma'), findsOneWidget);
    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('8 estudantes cadastrados'), findsOneWidget);
    expect(find.text('Atividades da turma'), findsOneWidget);

    // Turma 2 não possui estudantes cadastrados -> exibe Sem alunos (326:78)
    await tester.pumpWidget(
      const MaterialApp(
        home: TurmaDetailScreen(
          turmaId: 2,
          turmaNome: '2º ano B',
          turno: 'Tarde',
          totalAlunos: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum aluno cadastrado'), findsOneWidget);
    expect(find.text('Os estudantes aparecerão aqui.'), findsOneWidget);
  });
}
