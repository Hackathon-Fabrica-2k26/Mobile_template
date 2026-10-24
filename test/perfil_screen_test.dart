import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/screens/perfil_screen.dart';
import 'package:mobile_template/screens/turma_detail_screen.dart';
import 'package:mobile_template/screens/turma_cadastro_flow.dart';

void main() {
  final testUser = {
    'id': 1,
    'nome': 'Professora Amanda',
    'matricula': 'PROF2026',
    'email': 'amanda@escola.com',
    'escola': 'Escola Municipal Exemplo',
    'avatar': 'PA',
  };

  final testTurmas = [
    {
      'id': 1,
      'nome': '1º Ano A',
      'turno': 'Manhã',
      'ano_letivo': 2026,
      'estudantes_count': 25,
      'icon': 'book',
    },
    {
      'id': 2,
      'nome': '2º Ano B',
      'turno': 'Tarde',
      'ano_letivo': 2026,
      'estudantes_count': 22,
      'icon': 'book',
    },
  ];

  final testResumo = {
    'turmas_count': 2,
    'estudantes_count': 47,
    'atividades_count': 3,
  };

  final testAtividades = [
    {
      'id': 1,
      'titulo': 'Explorando as vogais',
      'data': '23/10/2026',
      'status': 'Aprovada',
      'concluida': true,
      'descricao': 'Reconhecer vogais.',
    },
  ];

  Future<Map<String, dynamic>> fakeUpdate(String name, String email) async => {
        'success': true,
        'user': {...testUser, 'nome': name, 'email': email},
      };

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('PerfilScreen - 7 Estados Mobile', () {
    testWidgets('Estado 1: Normal (Aba Minhas turmas) renderiza dados, badge, cadeado e turmas',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          PerfilScreen(
            initialUser: testUser,
            initialTurmas: testTurmas,
            initialResumo: testResumo,
            initialAtividades: testAtividades,
            profileUpdater: fakeUpdate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Avatar, Nome e Badge "Professora"
      expect(find.text('PA'), findsOneWidget);
      expect(find.text('Professora Amanda'), findsNWidgets(2));
      expect(find.text('Professora'), findsOneWidget);

      // Dados do perfil com cadeado na matrícula
      expect(find.text('Dados do perfil'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Matrícula'), findsOneWidget);
      expect(find.text('PROF2026'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      // 3 cards de resumo
      expect(find.text('Turmas ativas'), findsOneWidget);
      expect(find.text('Estudantes'), findsOneWidget);
      expect(find.text('Atividades'), findsOneWidget);

      // Abas
      expect(find.text('Minhas turmas'), findsOneWidget);
      expect(find.text('Atividades recentes'), findsOneWidget);

      // Listagem de turmas
      expect(find.text('Mostrando 2 turmas'), findsOneWidget);
      expect(find.text('1º Ano A'), findsOneWidget);
      expect(find.text('2º Ano B'), findsOneWidget);

      // Tocar em uma turma navega para TurmaDetailScreen
      final turmaCard = find.text('1º Ano A');
      await tester.ensureVisible(turmaCard);
      await tester.tap(turmaCard);
      await tester.pumpAndSettle();
      expect(find.byType(TurmaDetailScreen), findsOneWidget);
    });

    testWidgets('Estado 2: Carregando (Skeleton)', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PerfilScreen(forceLoading: true),
        ),
      );
      await tester.pump();

      // Durante forceLoading, não deve exibir os dados do perfil
      expect(find.text('Professora Amanda'), findsNothing);
      expect(find.text('Dados do perfil'), findsNothing);
    });

    testWidgets('Estado 3: Sem turmas exibe botão + Nova turma e navega',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          PerfilScreen(
            initialUser: testUser,
            initialTurmas: const [],
            initialResumo: testResumo,
            initialAtividades: testAtividades,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma turma encontrada'), findsOneWidget);
      final novaTurmaBtn = find.text('+ Nova turma');
      expect(novaTurmaBtn, findsOneWidget);

      // Tocar no botão + Nova turma navega para NovaTurmaFotoScreen
      await tester.ensureVisible(novaTurmaBtn);
      await tester.tap(novaTurmaBtn);
      await tester.pumpAndSettle();
      expect(find.byType(NovaTurmaFotoScreen), findsOneWidget);
    });

    testWidgets('Estado 4: Modo edição valida nome vazio e exibe toast Perfil atualizado ao salvar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          PerfilScreen(
            initialUser: testUser,
            initialTurmas: testTurmas,
            initialResumo: testResumo,
            initialAtividades: testAtividades,
            profileUpdater: fakeUpdate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Entrar no modo edição
      await tester.tap(find.text('Editar perfil'));
      await tester.pumpAndSettle();

      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // O primeiro TextField é o do Nome
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, '');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Validação obrigatória
      expect(find.text('Informe seu nome para continuar.'), findsOneWidget);

      // Preencher nome válido e salvar
      await tester.enterText(nameField, 'Professora Amanda Silva');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // SnackBar "Perfil atualizado"
      expect(find.text('Perfil atualizado'), findsOneWidget);
      expect(find.text('Professora Amanda Silva'), findsWidgets);
    });

    testWidgets('Estado 5: Erro exibe botão Tentar novamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PerfilScreen(forceError: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar o perfil'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Sem backend acessível, tentar novamente mantém o estado de erro
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Dados do perfil'), findsNothing);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('Estado 6: Aba Atividades recentes exibe filtros, lista e modal Ver',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          PerfilScreen(
            initialUser: testUser,
            initialTurmas: testTurmas,
            initialResumo: testResumo,
            initialAtividades: testAtividades,
            profileUpdater: fakeUpdate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Alternar para aba Atividades recentes
      await tester.tap(find.text('Atividades recentes'));
      await tester.pumpAndSettle();

      // Colunas / cabeçalhos
      expect(find.text('Atividade'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);

      // Botão "Ver" e abrir detalhes
      final verButton = find.text('Ver').first;
      expect(verButton, findsOneWidget);
      await tester.ensureVisible(verButton);
      await tester.tap(verButton);
      await tester.pumpAndSettle();

      expect(find.text('Fechar'), findsOneWidget);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
    });

    testWidgets('Estado 7: Modal Sair da conta? exibe confirmação e botões',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          PerfilScreen(
            initialUser: testUser,
            initialTurmas: testTurmas,
            initialResumo: testResumo,
            initialAtividades: testAtividades,
            profileUpdater: fakeUpdate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Rolar até o botão Sair da conta e tocar nele
      final sairBtn = find.text('Sair da conta');
      await tester.ensureVisible(sairBtn);
      await tester.tap(sairBtn);
      await tester.pumpAndSettle();

      // Modal de confirmação
      expect(find.text('Sair da conta?'), findsOneWidget);
      expect(find.text('Tem certeza que deseja sair do aplicativo Marsupi?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);

      // Cancelar fecha o modal
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Sair da conta?'), findsNothing);
    });
  });
}
