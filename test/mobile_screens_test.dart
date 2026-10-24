import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/aluno_detalhes_screen.dart';
import 'package:mobile_template/screens/enviar_atividades_screen.dart';
import 'package:mobile_template/screens/enviar_trabalhos_screen.dart';
import 'package:mobile_template/screens/erro_404_screen.dart';
import 'package:mobile_template/screens/home_screen.dart';

void main() {
  testWidgets('AlunoDetalhesScreen renderiza detalhes, abas e atividades do aluno', (WidgetTester tester) async {
    final alunoMock = {
      'id': 101,
      'nome': 'Alice Santos',
      'matricula': 'AL-2026-014',
      'nascimento': '14/03/2019 · 7 anos',
      'status': 'Aluno ativo',
      'acompanhamento': 'Participa das propostas em sala e demonstra interesse.',
      'atividades': [
        {
          'titulo': 'Explorando as vogais',
          'data_envio': 'Enviada em 23/10/2026',
          'observacao': 'Reconhece as vogais nas palavras trabalhadas.',
        }
      ],
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

  testWidgets('Erro404Screen renderiza página de erro conforme Figma', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Erro404Screen(),
      ),
    );

    expect(find.text('Parece que saímos do caminho.'), findsOneWidget);
    expect(find.text('← Voltar ao login'), findsOneWidget);
  });

  testWidgets('EnviarAtividadesScreen renderiza dropzone, campos vazios e nenhum arquivo simulado', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EnviarAtividadesScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enviar atividades'), findsOneWidget);
    expect(find.textContaining('Arraste e solte os arquivos'), findsOneWidget);
    expect(find.text('Título da atividade'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Arquivos (0)'), findsOneWidget);
  });

  testWidgets('HomeScreen possui bottom navigation bar com 3 abas e barra de busca', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Marsupi'), findsOneWidget);
    expect(find.text('Buscar turma'), findsOneWidget);
    expect(find.text('Minhas turmas'), findsOneWidget);
    expect(find.text('+ Nova turma'), findsOneWidget);

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Turmas'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('EnviarTrabalhosScreen exibe trabalhos pendentes e pede para escolher aluno da turma', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EnviarTrabalhosScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
          atividadeId: 10,
          atividadeTitulo: 'Explorando as vogais',
          estudantesIniciais: [
            {'id': 101, 'nome': 'Alice Santos'},
            {'id': 102, 'nome': 'Bruno Lima'},
          ],
          trabalhosIniciais: [
            {
              'id': 501,
              'aluno': null,
              'nome_lido': 'Alice S.',
              'confianca_nome': 0.72,
              'identificacao': 'pendente',
            },
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enviar trabalhos'), findsOneWidget);
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Galeria'), findsOneWidget);
    expect(find.text('Nome lido: Alice S.'), findsOneWidget);
    expect(find.text('Escolha o aluno da turma para confirmar:'), findsOneWidget);
    expect(find.text('Confirmar aluno'), findsOneWidget);
  });
}
