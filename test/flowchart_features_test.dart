import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/aluno_pei_screen.dart';
import 'package:mobile_template/screens/criar_atividade_flow.dart';
import 'package:mobile_template/screens/enviar_trabalhos_flow.dart';
import 'package:mobile_template/screens/portal_responsavel_screen.dart';
import 'package:mobile_template/screens/turma_cadastro_flow.dart';

void main() {
  testWidgets('NovaTurmaFotoScreen renderiza campos da Etapa 1 e dicas de foto', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NovaTurmaFotoScreen()));

    expect(find.text('ETAPA 1 DE 3'), findsOneWidget);
    expect(find.text('Nome da turma *'), findsOneWidget);
    expect(find.text('Reconhecer nomes com IA'), findsOneWidget);
    expect(find.textContaining('Fotografe a lista inteira'), findsOneWidget);
  });

  testWidgets('ConfirmarNomesScreen exibe lista com alunos e botões de conferência', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConfirmarNomesScreen(
          turmaNome: '1º ano A',
          anoLetivo: 2026,
          turno: 'Manhã',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ETAPA 2 DE 3'), findsOneWidget);
    expect(find.textContaining('nomes encontrados'), findsOneWidget);
    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('Davi Pereira'), findsOneWidget);
    expect(find.text('Adicionar nome manualmente'), findsOneWidget);
  });

  testWidgets('CriarAtividadeFlowScreen renderiza formulário e botão de análise com IA', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CriarAtividadeFlowScreen(
          turmaId: 1,
          turmaNome: '1º ano A',
        ),
      ),
    );

    expect(find.text('Cadastrar atividade'), findsOneWidget);
    expect(find.text('Título da atividade *'), findsOneWidget);
    expect(find.text('Analisar quem precisa de adaptação'), findsOneWidget);
  });

  testWidgets('EnviarTrabalhosFlowScreen renderiza lista de fotos e identificação OCR', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EnviarTrabalhosFlowScreen(
          atividadeId: 1,
          atividadeNome: 'Explorando as vogais',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Revisar identificação das fotos'), findsOneWidget);
    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('Davi Pereira'), findsOneWidget);
  });

  testWidgets('AlunoPeiScreen renderiza PEI e card de código de acesso para pais', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AlunoPeiScreen(
          alunoId: 101,
          alunoNome: 'Alice Santos',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice Santos'), findsOneWidget);
    expect(find.text('Código de Acesso do Responsável'), findsOneWidget);
    expect(find.textContaining('PLANO DE ENSINO INDIVIDUALIZADO'), findsOneWidget);
  });

  testWidgets('PortalResponsavelScreen renderiza consulta por código e LGPD', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PortalResponsavelScreen(),
      ),
    );

    expect(find.text('Portal da Família'), findsOneWidget);
    expect(find.text('Código do Estudante *'), findsOneWidget);
    expect(find.text('Acessar com código'), findsOneWidget);
  });
}
