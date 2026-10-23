import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/models/models.dart';

void main() {
  group('Models alinhados com o contrato do backend Marsupi', () {
    test('Turma desserializa corretamente', () {
      final turma = Turma.fromJson({
        'id': 1,
        'nome': '1º ano A',
        'turno': 'manha',
        'turno_display': 'Manhã',
        'total_estudantes': 25,
        'escola': 1,
        'professores': [2],
      });

      expect(turma.id, 1);
      expect(turma.nome, '1º ano A');
      expect(turma.turnoDisplay, 'Manhã');
      expect(turma.totalEstudantes, 25);
      expect(turma.professores, [2]);
    });

    test('Aluno com PerfilApoio desserializa sem campos legados (Pais/DISC)', () {
      final aluno = Aluno.fromJson({
        'id': 101,
        'nome': 'Alice Santos',
        'turma': 1,
        'matricula': 'AL-2026-001',
        'status': 'Aluno ativo',
        'precisa_conferencia': false,
        'perfil_apoio': {
          'profile_summary': 'Aluno com perfil participativo.',
          'radar_metrics': {'foco_sustentado': 70, 'raciocinio_visual': 85},
          'strengths': ['Memória visual'],
          'support_needs': ['Pausas ativas'],
          'autonomy_coaching_tip': 'Estimule apoio visual.',
        },
      });

      expect(aluno.id, 101);
      expect(aluno.nome, 'Alice Santos');
      expect(aluno.avatar, 'A');
      expect(aluno.turmaId, 1);
      expect(aluno.perfilApoio, isNotNull);
      expect(aluno.perfilApoio!.metricasRadar['raciocinio_visual'], 85);
      expect(aluno.perfilApoio!.pontosFortes, contains('Memória visual'));
    });

    test('Atividade e Trabalho desserializam corretamente', () {
      final ativ = Atividade.fromJson({
        'id': 10,
        'nome': 'Explorando as vogais',
        'tipo': 'Linguagem / Alfabetização',
        'turma_id': 1,
        'relatorios_count': 5,
      });

      expect(ativ.id, 10);
      expect(ativ.nome, 'Explorando as vogais');
      expect(ativ.relatoriosCount, 5);

      final trab = Trabalho.fromJson({
        'id': 20,
        'atividade_id': 10,
        'aluno_id': 101,
        'alunoReconhecido': 'Alice Santos',
        'arquivo': 'trabalho_01.jpg',
        'duvida': false,
      });

      expect(trab.id, 20);
      expect(trab.alunoNome, 'Alice Santos');
      expect(trab.arquivoNome, 'trabalho_01.jpg');
      expect(trab.precisaConferencia, isFalse);
    });

    test('Relatorio desserializa dados de análise pedagógica', () {
      final relatorio = Relatorio.fromJson({
        'id': 1,
        'aluno': 101,
        'dados': {
          'profile_summary': 'Resumo pedagógico gerado por IA.',
          'radar_metrics': {'foco': 80},
        },
      });

      expect(relatorio.id, 1);
      expect(relatorio.alunoId, 101);
      expect(relatorio.dados.resumo, 'Resumo pedagógico gerado por IA.');
      expect(relatorio.dados.metricasRadar['foco'], 80);
    });
  });
}
