import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataService {
  MockDataService._internal();
  static final MockDataService instance = MockDataService._internal();

  Map<String, dynamic>? _cachedData;

  Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) return _cachedData!;
    try {
      final jsonString = await rootBundle.loadString('assets/data/mock_data.json');
      _cachedData = jsonDecode(jsonString) as Map<String, dynamic>;
      return _cachedData!;
    } catch (_) {
      return {
        'user': {
          'nome': 'Ana Paula',
          'matricula': 'PROF2026',
          'email': 'ana.professora@escola.edu.br',
          'avatar': 'AP',
        },
        'turmas': [],
        'alunos': [],
        'atividades': [],
      };
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final data = await _loadData();
    return (data['user'] as Map<String, dynamic>?) ?? {};
  }

  Future<List<Map<String, dynamic>>> getTurmas() async {
    final data = await _loadData();
    final list = data['turmas'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> getAlunos({int? turmaId}) async {
    final data = await _loadData();
    final list = data['alunos'] as List<dynamic>? ?? [];
    final alunos = list.whereType<Map<String, dynamic>>().toList();
    if (turmaId != null) {
      return alunos.where((a) => a['turma_id'] == turmaId).toList();
    }
    return alunos;
  }

  Future<List<Map<String, dynamic>>> getAtividades({int? turmaId}) async {
    final data = await _loadData();
    final list = data['atividades'] as List<dynamic>? ?? [];
    final ativs = list.whereType<Map<String, dynamic>>().toList();
    if (turmaId != null) {
      return ativs.where((a) => a['turma_id'] == turmaId).toList();
    }
    return ativs;
  }

  /// Retorna os nomes identificados no OCR a partir do template do JSON
  Future<List<Map<String, dynamic>>> getChamadaOcrNomes() async {
    final data = await _loadData();
    final list = data['chamada_ocr_template'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Retorna os modelos de submissão de trabalhos a partir do JSON
  Future<List<Map<String, dynamic>>> getTrabalhosTemplate() async {
    final data = await _loadData();
    final list = data['trabalhos_submissao_template'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Retorna a lista de arquivos de exemplo para upload a partir do JSON
  Future<List<Map<String, String>>> getArquivosExemplo() async {
    final data = await _loadData();
    final list = data['arquivos_exemplo'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  /// Validação de login
  Future<bool> authenticate(String matricula, String senha) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return matricula.trim().isNotEmpty && senha.isNotEmpty;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return code.trim().length == 4;
  }

  /// Cria uma nova turma e adiciona seus alunos reconhecidos pelo OCR da foto da chamada
  Future<Map<String, dynamic>> addTurmaComAlunos({
    required String nome,
    required String turno,
    required int anoLetivo,
    required List<String> nomesAlunos,
    String? fotoChamada,
  }) async {
    final data = await _loadData();
    final turmas = (data['turmas'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final alunos = (data['alunos'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final newTurmaId = turmas.isEmpty
        ? 1
        : (turmas.map((t) => (t['id'] as num).toInt()).reduce((a, b) => a > b ? a : b) + 1);

    final novaTurma = {
      'id': newTurmaId,
      'nome': nome,
      'turno': turno,
      'ano_letivo': anoLetivo,
      'estudantes_count': nomesAlunos.length,
      'icon': 'book',
    };
    turmas.insert(0, novaTurma);

    int nextAlunoId = alunos.isEmpty
        ? 100
        : (alunos.map((a) => (a['id'] as num).toInt()).reduce((a, b) => a > b ? a : b) + 1);

    for (final nomeAluno in nomesAlunos) {
      final initial = nomeAluno.trim().isNotEmpty ? nomeAluno.trim()[0].toUpperCase() : 'A';
      alunos.add({
        'id': nextAlunoId,
        'turma_id': newTurmaId,
        'nome': nomeAluno.trim(),
        'avatar': initial,
        'matricula': 'AL-2026-0$nextAlunoId',
        'nascimento': '10/05/2019 · 7 anos',
        'status': 'Reconhecido via foto da chamada',
        'precisa_conferencia': false,
        'perfil_disc': 'Em mapeamento inicial',
        'radar_metrics': {
          'Foco sustentado': 60,
          'Raciocínio visual': 75,
          'Interação social': 70,
          'Regulação sensorial': 65,
          'Coordenação fina': 60,
        },
        'strengths': [
          'Excelente receptividade e engajamento em sala',
        ],
        'support_needs': [
          'Acompanhamento inicial de adaptação curricular',
        ],
        'dica_autonomia': 'Estimule a participação oral com apoio visual prévio.',
        'codigo_acesso': 'MARS-${(nextAlunoId * 37) % 9000 + 1000}',
        'atividades': <Map<String, dynamic>>[],
      });
      nextAlunoId++;
    }

    _cachedData!['turmas'] = turmas;
    _cachedData!['alunos'] = alunos;
    return novaTurma;
  }

  /// Cadastra um aluno avulso na turma indicada
  Future<Map<String, dynamic>> cadastrarAluno({
    required int turmaId,
    required String nome,
    String? nascimento,
    String? matricula,
  }) async {
    final data = await _loadData();
    final alunos = (data['alunos'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final turmas = (data['turmas'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final nextId = alunos.isEmpty
        ? 101
        : (alunos.map((a) => (a['id'] as num).toInt()).reduce((a, b) => a > b ? a : b) + 1);

    final cleanNome = nome.trim();
    final initial = cleanNome.isNotEmpty ? cleanNome[0].toUpperCase() : 'A';
    final cleanMatricula = matricula?.trim().isNotEmpty == true ? matricula!.trim() : 'AL-2026-0$nextId';
    final cleanNascimento = nascimento?.trim().isNotEmpty == true ? nascimento!.trim() : '10/05/2019 · 7 anos';

    final novoAluno = {
      'id': nextId,
      'turma_id': turmaId,
      'nome': cleanNome,
      'avatar': initial,
      'matricula': cleanMatricula,
      'nascimento': cleanNascimento,
      'status': 'Aluno ativo',
      'precisa_conferencia': false,
      'acompanhamento': 'Cadastrado recentemente. Acompanhando adaptação inicial.',
      'perfil_disc': 'Em observação',
      'radar_metrics': {
        'Foco sustentado': 60,
        'Raciocínio visual': 70,
        'Interação social': 70,
        'Regulação sensorial': 60,
        'Coordenação fina': 65,
      },
      'strengths': [
        'Boa receptividade às rotinas de sala',
      ],
      'support_needs': [
        'Avaliação diagnóstica inicial em andamento',
      ],
      'dica_autonomia': 'Acompanhe a interação inicial em pequenos grupos.',
      'codigo_acesso': 'MARS-${(nextId * 37) % 9000 + 1000}',
      'atividades': <Map<String, dynamic>>[],
    };

    alunos.add(novoAluno);

    for (var t in turmas) {
      if (t['id'] == turmaId) {
        t['estudantes_count'] = ((t['estudantes_count'] as int? ?? 0) + 1);
        break;
      }
    }

    _cachedData!['alunos'] = alunos;
    _cachedData!['turmas'] = turmas;
    return novoAluno;
  }

  /// Adiciona uma atividade com sua versão geral e versões adaptadas geradas por IA
  Future<Map<String, dynamic>> addAtividadeComAdaptacoes({
    required int turmaId,
    required String nome,
    required String tipo,
    required String descricao,
    required Map<String, String> adaptacoesPorAluno,
  }) async {
    final data = await _loadData();
    final atividades = (data['atividades'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final newId = atividades.isEmpty
        ? 1
        : (atividades.map((a) => (a['id'] as num).toInt()).reduce((a, b) => a > b ? a : b) + 1);

    final novaAtividade = {
      'id': newId,
      'turma_id': turmaId,
      'nome': nome,
      'tipo': tipo,
      'descricao': descricao,
      'relatorios_count': 0,
      'adaptacoes': adaptacoesPorAluno,
      'pontos_atencao': <String>[],
    };
    atividades.insert(0, novaAtividade);
    _cachedData!['atividades'] = atividades;
    return novaAtividade;
  }

  /// Processa o upload de fotos dos trabalhos dos alunos e atualiza relatórios/pontos de atenção
  Future<void> processarTrabalhosPorFoto({
    required int atividadeId,
    required List<Map<String, dynamic>> trabalhosConfirmados,
  }) async {
    final data = await _loadData();
    final atividades = (data['atividades'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (var ativ in atividades) {
      if (ativ['id'] == atividadeId) {
        ativ['relatorios_count'] = ((ativ['relatorios_count'] as int? ?? 0) + trabalhosConfirmados.length);
        ativ['pontos_atencao'] = [
          'Atenção à coordenação motora fina no traçado de letras cursivas.',
          'Excelente desempenho no raciocínio visual e associação de figuras.',
        ];
        break;
      }
    }
  }

  /// Consulta estudante pelo código de acesso da família
  Future<Map<String, dynamic>?> getAlunoPorCodigo(String codigo) async {
    final alunos = await getAlunos();
    final cleanCode = codigo.trim().toUpperCase();
    for (final a in alunos) {
      final alunoCod = (a['codigo_acesso'] as String?)?.toUpperCase() ?? 'MARS-${a['id']}';
      if (alunoCod == cleanCode || cleanCode == 'MARS-2026' || cleanCode == 'MARS-101') {
        return a;
      }
    }
    if (cleanCode.isNotEmpty && alunos.isNotEmpty) {
      return alunos.first;
    }
    return null;
  }

  /// Gera rascunho de PEI e Parecer Pedagógico para um estudante
  Future<Map<String, dynamic>> gerarPEI(int alunoId) async {
    final alunos = await getAlunos();
    final aluno = alunos.firstWhere((a) => a['id'] == alunoId, orElse: () => alunos.first);
    final nome = aluno['nome'] ?? 'Estudante';

    return {
      'aluno': nome,
      'ano': '1º Ano do Ensino Fundamental',
      'data_emissao': 'Outubro / 2026',
      'metas_trimestrais': [
        'Consolidar a identificação fonema-grafema com apoio de pistas multissensoriais.',
        'Desenvolver autorregulação durante transições de aula com suporte de agenda visual.',
        'Estimular a autonomia na organização de materiais e tarefas coletivas.',
      ],
      'acomodacoes_pedagogicas': [
        'Tempo adicional (25%) para realização de atividades escritas.',
        'Pausas de autorregulação sensorial a cada 20 minutos de foco intenso.',
        'Enunciados fracionados e apoio visual concreto para compreensão de comandos.',
      ],
      'parecer_conselho': 'O estudante apresenta ótimo engajamento em dinâmicas visuais e colaborativas. Observa-se evolução significativa nas competências de raciocínio. Recomenda-se a continuidade do suporte inclusivo em parceria com os responsáveis.',
    };
  }
}
