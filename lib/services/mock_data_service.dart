import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataService {
  MockDataService._internal();
  static final MockDataService instance = MockDataService._internal();

  Map<String, dynamic>? _cachedData;

  Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) return _cachedData!;
    final jsonString = await rootBundle.loadString('assets/data/mock_data.json');
    _cachedData = jsonDecode(jsonString) as Map<String, dynamic>;
    return _cachedData!;
  }

  Future<Map<String, dynamic>> getUser() async {
    final data = await _loadData();
    return (data['user'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> updateUser(String name, String email) async {
    final data = await _loadData();
    final user = Map<String, dynamic>.from(data['user'] as Map? ?? {});
    final cleanName = name.trim();
    user['nome'] = cleanName;
    user['email'] = email.trim();
    final initials = cleanName.isNotEmpty
        ? cleanName.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase()
        : 'PD';
    user['avatar'] = initials;
    _cachedData!['user'] = user;
    return user;
  }

  Future<Map<String, dynamic>> getResumoPerfil() async {
    final turmas = await getTurmas();
    final alunos = await getAlunos();
    final ativs = await getAtividades();
    return {
      'turmas_count': turmas.length,
      'estudantes_count': alunos.length,
      'atividades_count': ativs.length,
    };
  }

  Future<List<Map<String, dynamic>>> getAtividadesRecentes() async {
    final ativs = await getAtividades();
    if (ativs.isNotEmpty) {
      return ativs.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return {
          'id': a['id'] ?? (i + 1),
          'titulo': a['nome'] ?? a['titulo'] ?? 'Atividade',
          'data': a['data'] ?? '23/10/2026',
          'status': i % 2 == 0 ? 'Concluída' : 'Em andamento',
        };
      }).toList();
    }
    return [
      {
        'id': 1,
        'titulo': 'Missão Espacial: Caligrafia nas Estrelas',
        'data': '23/10/2026',
        'status': 'Concluída',
      },
      {
        'id': 2,
        'titulo': 'Camarada da Turma: Desafio Relâmpago',
        'data': '22/10/2026',
        'status': 'Concluída',
      },
      {
        'id': 3,
        'titulo': 'Coordenação Motora e Traçados',
        'data': '20/10/2026',
        'status': 'Em andamento',
      },
    ];
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

  /// Retorna a lista de arquivos de exemplo para upload a partir do JSON
  Future<List<Map<String, String>>> getArquivosExemplo() async {
    final data = await _loadData();
    final list = data['arquivos_exemplo'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  /// Validação de login: valida senha correta ('user123')
  Future<bool> authenticate(String matricula, String senha) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final cleanMatricula = matricula.trim();
    if (cleanMatricula.isEmpty) return false;
    // Aceita user123 como padrão para qualquer usuário
    return senha == 'user123';
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 350));
    // Em mock/offline aceita 1234 ou 2026 como código válido de teste
    final c = code.trim();
    return c == '1234' || c == '2026';
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
    _cachedData!['turmas'] = turmas;

    if (nomesAlunos.isNotEmpty) {
      await addAlunosNaTurma(turmaId: newTurmaId, nomesAlunos: nomesAlunos);
    }

    return novaTurma;
  }

  /// Adiciona uma lista de alunos (reconhecidos via foto da chamada) a uma turma existente
  Future<void> addAlunosNaTurma({
    required int turmaId,
    required List<String> nomesAlunos,
  }) async {
    final data = await _loadData();
    final turmas = (data['turmas'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final alunos = (data['alunos'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final padrao = (data['aluno_padrao_template'] as Map<String, dynamic>?) ?? {};

    int nextAlunoId = alunos.isEmpty
        ? 100
        : (alunos.map((a) => (a['id'] as num).toInt()).reduce((a, b) => a > b ? a : b) + 1);

    for (final nomeAluno in nomesAlunos) {
      final cleanName = nomeAluno.trim();
      final initial = cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'A';
      final templateMatch = alunos.cast<Map<String, dynamic>?>().firstWhere(
            (a) => (a?['nome'] as String?)?.toLowerCase() == cleanName.toLowerCase(),
            orElse: () => null,
          );

      alunos.add({
        'id': nextAlunoId,
        'turma_id': turmaId,
        'nome': cleanName,
        'avatar': initial,
        'matricula': 'AL-2026-0$nextAlunoId',
        'nascimento': templateMatch?['nascimento'] ?? padrao['nascimento'] ?? '',
        'status': templateMatch?['status'] ?? padrao['status'] ?? '',
        'precisa_conferencia': false,
        'acompanhamento': templateMatch?['acompanhamento'] ?? padrao['acompanhamento'] ?? '',
        'atividades': templateMatch?['atividades'] != null
            ? List<Map<String, dynamic>>.from(
                (templateMatch!['atividades'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
              )
            : <Map<String, dynamic>>[],
      });
      nextAlunoId++;
    }

    final totalDaTurma = alunos.where((a) => a['turma_id'] == turmaId).length;
    for (final t in turmas) {
      if (t['id'] == turmaId) {
        t['estudantes_count'] = totalDaTurma;
        break;
      }
    }

    _cachedData!['alunos'] = alunos;
    _cachedData!['turmas'] = turmas;
  }

  /// Adiciona uma atividade enviada na turma
  Future<Map<String, dynamic>> addAtividade({
    required int turmaId,
    required String nome,
    String? dataAtividade,
    String? observacoes,
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
      'data': dataAtividade ?? '',
      'descricao': observacoes ?? '',
      'relatorios_count': 0,
    };
    atividades.insert(0, novaAtividade);
    _cachedData!['atividades'] = atividades;
    return novaAtividade;
  }
}
