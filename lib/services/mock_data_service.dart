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

  /// Validação de login com usuário padrão caso não passe nada
  Future<bool> authenticate(String matricula, String senha) async {
    // Simula pequena latência de rede/validação
    await Future.delayed(const Duration(milliseconds: 350));
    return matricula.trim().isNotEmpty && senha.isNotEmpty;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return code.trim().length == 4;
  }
}
