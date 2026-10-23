import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/aluno_detalhes_screen.dart';
import 'package:mobile_template/screens/cadastrar_aluno_screen.dart';
import 'package:mobile_template/screens/enviar_atividades_screen.dart';
import 'package:mobile_template/screens/home_screen.dart';

void main() {
  testWidgets('AlunoDetalhesScreen renderiza detalhes, abas e atividades do aluno', (WidgetTester tester) async {
    final alunoMock = {
      'id': 101,
      'nome': 'Alice Santos',
      'matricula': 'AL-2026-014',
      'nascimento': '14/03/2019 · 7 anos',
      'radar_metrics': {
        'Foco sustentado': 45,
        'Raciocínio visual': 90,
      },
    };

    await tester.pumpWidget(
      MaterialApp(
        home: AlunoDetalhesScreen(
          aluno: alunoMock,
          turmaNome: '1º ano A',
          turno: 'Manhã',
        ),
      ),
    );

    expect(find.text('Detalhes do aluno'), findsOneWidget);
    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('AL-2026-014'), findsOneWidget);
    expect(find.text('Visão geral'), findsOneWidget);
    expect(find.text('Registros'), findsOneWidget);
    expect(find.text('Acompanhamento'), findsOneWidget);
    expect(find.text('Explorando as vogais'), findsOneWidget);
    expect(find.text('Exportar todas as atividades'), findsOneWidget);
  });

  testWidgets('CadastrarAlunoScreen renderiza campos com ícone central e botões', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CadastrarAlunoScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
          turno: 'Manhã',
        ),
      ),
    );

    expect(find.text('Cadastrar aluno'), findsNWidgets(2)); // AppBar title e botão
    expect(find.text('Adicione um aluno à sua turma.'), findsOneWidget);
    expect(find.text('Nome completo *'), findsOneWidget);
    expect(find.text('Data de nascimento (opcional)'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('EnviarAtividadesScreen renderiza dropzone e lista de arquivos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EnviarAtividadesScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
        ),
      ),
    );

    expect(find.text('Enviar atividades'), findsOneWidget);
    expect(find.textContaining('Arraste e solte os arquivos'), findsOneWidget);
    expect(find.text('Atividades-parte-01.pdf'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('HomeScreen possui bottom navigation bar com 3 abas e barra de busca', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Marsupi'), findsOneWidget);
    expect(find.text('Buscar turma'), findsOneWidget);
    expect(find.text('Minhas turmas'), findsOneWidget);
    expect(find.text('Nova turma'), findsOneWidget);

    // Navbar inferior com 3 abas
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Turmas'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
