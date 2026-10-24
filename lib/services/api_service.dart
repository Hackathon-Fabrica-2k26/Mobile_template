import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_data_service.dart';

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// URL padrão para desenvolvimento local.
  /// Pode ser configurada via --dart-define=API_URL=http://...
  /// No emulador Android, 10.0.2.2 mapeia para o host localhost.
  /// No desktop linux/web, usa 127.0.0.1 por padrão.
  String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  String? _accessToken;
  String? _refreshToken;
  String? _lastOtpToken;
  String? _lastUserEmail;
  Map<String, dynamic>? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;

  void setBaseUrl(String url) {
    baseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// Verifica se o backend está acessível em até 1.5s
  Future<bool> checkBackendHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health/'))
          .timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Autenticação: tenta a API /api/auth/login/. Se falhar ou offline, fallback para MockDataService.
  Future<Map<String, dynamic>> login(String matricula, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login/'),
            headers: _headers(withAuth: false),
            body: jsonEncode({
              'matricula': matricula.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        _lastOtpToken = data['otp_token'] as String?;
        _lastUserEmail = data['email'] as String?;
        return {
          'success': true,
          'is_remote': true,
          'otp_token': _lastOtpToken,
          'email': _lastUserEmail,
        };
      }
    } catch (_) {
      // Fallback
    }

    final mockOk = await MockDataService.instance.authenticate(matricula, password);
    final user = await MockDataService.instance.getUser();
    return {
      'success': mockOk,
      'is_remote': false,
      'otp_token': null,
      'email': user['email'] ?? 'professor@demo.com',
    };
  }

  /// Verificação do OTP
  Future<bool> verifyOtp(String code) async {
    if (_lastOtpToken != null) {
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/api/auth/otp/verify/'),
              headers: _headers(withAuth: false),
              body: jsonEncode({
                'otp_token': _lastOtpToken,
                'code': code.trim(),
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          _accessToken = data['access'] as String?;
          _refreshToken = data['refresh'] as String?;
          await getUser();
          return true;
        }
      } catch (_) {
        // Fallback
      }
    }

    return await MockDataService.instance.verifyOtp(code);
  }

  /// Reenviar código OTP
  Future<bool> resendOtp() async {
    if (_lastOtpToken != null) {
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/api/auth/otp/resend/'),
              headers: _headers(withAuth: false),
              body: jsonEncode({
                'otp_token': _lastOtpToken,
              }),
            )
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          _lastOtpToken = data['otp_token'] as String? ?? _lastOtpToken;
          return true;
        }
      } catch (_) {}
    }
    return true;
  }

  /// Dados do usuário autenticado (/api/auth/me/)
  Future<Map<String, dynamic>> getUser() async {
    if (_accessToken != null) {
      try {
        final res = await http
            .get(
              Uri.parse('$baseUrl/api/auth/me/'),
              headers: _headers(),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final nome = data['name'] as String? ?? 'Professor Demo';
          final initials = nome.trim().isNotEmpty
              ? nome.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase()
              : 'PD';

          _currentUser = {
            'id': data['id'],
            'nome': nome,
            'matricula': data['matricula'] ?? 'DEMO0001',
            'email': data['email'] ?? 'professor@demo.com',
            'escola': 'Escola Marsupi Demo',
            'avatar': initials,
          };
          return _currentUser!;
        }
      } catch (_) {}
    }

    if (_currentUser != null) return _currentUser!;
    return await MockDataService.instance.getUser();
  }

  /// Listagem de turmas (/api/turmas/)
  Future<List<Map<String, dynamic>>> getTurmas() async {
    if (_accessToken != null) {
      try {
        final res = await http
            .get(
              Uri.parse('$baseUrl/api/turmas/'),
              headers: _headers(),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final results = body['results'] as List<dynamic>? ?? [];
          return results.map((t) {
            final map = Map<String, dynamic>.from(t as Map);
            return {
              'id': map['id'],
              'nome': map['nome'] ?? 'Turma',
              'turno': map['turno_display'] ?? (map['turno'] == 'manha' ? 'Manhã' : 'Tarde'),
              'ano_letivo': 2026,
              'estudantes_count': map['total_estudantes'] ?? 0,
              'icon': 'book',
              'escola': map['escola'],
            };
          }).toList();
        }
      } catch (_) {}
    }

    return await MockDataService.instance.getTurmas();
  }

  /// Listagem de alunos da turma (/api/alunos/) integrada com dados de relatórios e perfil
  Future<List<Map<String, dynamic>>> getAlunos({int? turmaId}) async {
    if (_accessToken != null) {
      try {
        final query = turmaId != null ? '?turma=$turmaId' : '';
        final res = await http
            .get(
              Uri.parse('$baseUrl/api/alunos/$query'),
              headers: _headers(),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final results = body['results'] as List<dynamic>? ?? [];

          // Carrega relatórios para associar com os dados reais
          final relatoriosRes = await http
              .get(
                Uri.parse('$baseUrl/api/relatorios/'),
                headers: _headers(),
              )
              .timeout(const Duration(seconds: 4));
          final Map<int, Map<String, dynamic>> relatoriosPorAluno = {};
          if (relatoriosRes.statusCode == 200) {
            final relBody = jsonDecode(utf8.decode(relatoriosRes.bodyBytes)) as Map<String, dynamic>;
            final relList = relBody['results'] as List<dynamic>? ?? [];
            for (final r in relList) {
              final rMap = Map<String, dynamic>.from(r as Map);
              final aId = rMap['aluno'] as int?;
              if (aId != null && rMap['dados'] is Map) {
                relatoriosPorAluno[aId] = Map<String, dynamic>.from(rMap['dados'] as Map);
              }
            }
          }

          // Busca template mock para enriquecer com campos que não existem no banco
          final mockAlunos = await MockDataService.instance.getAlunos();

          return results.map((a) {
            final map = Map<String, dynamic>.from(a as Map);
            final alunoId = map['id'] as int;
            final nome = map['nome'] as String? ?? 'Aluno';
            final initial = nome.trim().isNotEmpty ? nome.trim()[0].toUpperCase() : 'A';
            final relatorio = relatoriosPorAluno[alunoId];

            final mockMatch = mockAlunos.cast<Map<String, dynamic>?>().firstWhere(
                  (m) => m?['id'] == alunoId || m?['nome'] == nome,
                  orElse: () => null,
                );

            final acompanhamento = relatorio?['profile_summary'] as String? ??
                mockMatch?['acompanhamento'] as String? ??
                'Acompanhado pelo sistema pedagógico integrado Marsupi.';

            final atividades = <Map<String, dynamic>>[];
            if (relatorio?['adapted_activities'] is List) {
              for (final ativ in relatorio!['adapted_activities'] as List) {
                final ativMap = Map<String, dynamic>.from(ativ as Map);
                atividades.add({
                  'titulo': ativMap['title'] ?? 'Atividade Adaptada',
                  'data_envio': 'Enviada em 23/10/2026',
                  'observacao': ativMap['objective'] ?? ativMap['instructions'] ?? '',
                });
              }
            } else if (mockMatch?['atividades'] is List) {
              atividades.addAll((mockMatch!['atividades'] as List).cast<Map<String, dynamic>>());
            }

            return {
              'id': alunoId,
              'turma_id': map['turma'],
              'nome': nome,
              'avatar': initial,
              'matricula': mockMatch?['matricula'] ?? 'AL-2026-00$alunoId',
              'nascimento': mockMatch?['nascimento'] ?? '14/03/2019 · 7 anos',
              'status': mockMatch?['status'] ?? 'Aluno ativo',
              'precisa_conferencia': mockMatch?['precisa_conferencia'] ?? false,
              'acompanhamento': acompanhamento,
              'radar_metrics': relatorio?['radar_metrics'] ?? mockMatch?['radar_metrics'],
              'strengths': relatorio?['strengths'] ?? mockMatch?['strengths'],
              'support_needs': relatorio?['support_needs'] ?? mockMatch?['support_needs'],
              'dica_autonomia': relatorio?['autonomy_coaching_tip'] ?? mockMatch?['dica_autonomia'],
              'atividades': atividades,
            };
          }).toList();
        }
      } catch (_) {}
    }

    return await MockDataService.instance.getAlunos(turmaId: turmaId);
  }

  /// Listagem de atividades (/api/atividades/)
  Future<List<Map<String, dynamic>>> getAtividades({int? turmaId}) async {
    if (_accessToken != null) {
      try {
        final res = await http
            .get(
              Uri.parse('$baseUrl/api/atividades/'),
              headers: _headers(),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final results = body['results'] as List<dynamic>? ?? [];
          if (results.isNotEmpty) {
            return results.map((ativ) {
              final map = Map<String, dynamic>.from(ativ as Map);
              final relCount = (map['relatorios'] as List<dynamic>?)?.length ?? 1;
              return {
                'id': map['id'],
                'turma_id': turmaId ?? 1,
                'nome': map['nome'] ?? 'Atividade',
                'tipo': map['tipo'] ?? 'Linguagem / Alfabetização',
                'relatorios_count': relCount,
                'descricao': 'Atividade pedagógica registrada no sistema.',
              };
            }).toList();
          }
        }
      } catch (_) {}
    }

    return await MockDataService.instance.getAtividades(turmaId: turmaId);
  }

  /// Cadastro de nova turma (/api/turmas/)
  Future<Map<String, dynamic>> addTurmaComAlunos({
    required String nome,
    required String turno,
    required int anoLetivo,
    required List<String> nomesAlunos,
    String? fotoChamada,
  }) async {
    if (_accessToken != null) {
      try {
        final turnoCode = turno.toLowerCase().contains('tarde')
            ? 'tarde'
            : turno.toLowerCase().contains('integral')
                ? 'integral'
                : 'manha';

        final res = await http
            .post(
              Uri.parse('$baseUrl/api/turmas/'),
              headers: _headers(),
              body: jsonEncode({
                'nome': nome.trim(),
                'turno': turnoCode,
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 201) {
          final nova = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final turmaId = nova['id'] as int;

          for (final alunoNome in nomesAlunos) {
            try {
              await http.post(
                Uri.parse('$baseUrl/api/alunos/'),
                headers: _headers(),
                body: jsonEncode({
                  'nome': alunoNome.trim(),
                  'turma': turmaId,
                }),
              );
            } catch (_) {}
          }

          return {
            'id': turmaId,
            'nome': nova['nome'],
            'turno': nova['turno_display'] ?? turno,
            'ano_letivo': anoLetivo,
            'estudantes_count': nomesAlunos.length,
            'icon': 'book',
          };
        }
      } catch (_) {}
    }

    return await MockDataService.instance.addTurmaComAlunos(
      nome: nome,
      turno: turno,
      anoLetivo: anoLetivo,
      nomesAlunos: nomesAlunos,
      fotoChamada: fotoChamada,
    );
  }

  /// Adiciona alunos em turma existente
  Future<void> addAlunosNaTurma({
    required int turmaId,
    required List<String> nomesAlunos,
  }) async {
    if (_accessToken != null) {
      try {
        for (final alunoNome in nomesAlunos) {
          await http.post(
            Uri.parse('$baseUrl/api/alunos/'),
            headers: _headers(),
            body: jsonEncode({
              'nome': alunoNome.trim(),
              'turma': turmaId,
            }),
          );
        }
        return;
      } catch (_) {}
    }

    await MockDataService.instance.addAlunosNaTurma(
      turmaId: turmaId,
      nomesAlunos: nomesAlunos,
    );
  }

  /// Adiciona nova atividade (/api/atividades/)
  Future<Map<String, dynamic>> addAtividade({
    required int turmaId,
    required String nome,
    String? dataAtividade,
    String? observacoes,
  }) async {
    if (_accessToken != null) {
      try {
        final alunos = await getAlunos(turmaId: turmaId);
        final primeiroAlunoId = alunos.isNotEmpty ? alunos.first['id'] as int? : null;

        if (primeiroAlunoId != null) {
          final res = await http.post(
            Uri.parse('$baseUrl/api/atividades/'),
            headers: _headers(),
            body: jsonEncode({
              'nome': nome.trim(),
              'aluno': primeiroAlunoId,
              'tipo': 'Linguagem / Avaliação',
            }),
          );

          if (res.statusCode == 201) {
            final map = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
            return {
              'id': map['id'],
              'turma_id': turmaId,
              'nome': map['nome'] ?? nome,
              'data': dataAtividade ?? '',
              'descricao': observacoes ?? '',
              'relatorios_count': 0,
            };
          }
        }
      } catch (_) {}
    }

    return await MockDataService.instance.addAtividade(
      turmaId: turmaId,
      nome: nome,
      dataAtividade: dataAtividade,
      observacoes: observacoes,
    );
  }

  /// Logout
  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _lastOtpToken = null;
    _currentUser = null;
  }
}
