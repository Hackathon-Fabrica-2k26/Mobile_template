import 'dart:convert';
import 'package:http/http.dart' as http;

/// Erro de comunicação com o backend, com mensagem apresentável ao usuário.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Cliente do backend Marsupi. Todos os dados vêm exclusivamente da API.
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Pode ser configurada via --dart-define=API_URL=http://...
  /// No emulador Android, 10.0.2.2 mapeia para o host localhost.
  String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration _timeout = Duration(seconds: 8);
  static const String _msgOffline =
      'Não foi possível conectar ao servidor. Verifique sua conexão e tente novamente.';

  String? _accessToken;
  String? _refreshToken;
  String? _lastOtpToken;
  Map<String, dynamic>? _currentUser;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;

  void setBaseUrl(String url) {
    baseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  Map<String, String> _headers({bool withAuth = true, bool json = true}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    if (withAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  dynamic _decode(http.Response res) {
    if (res.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  /// Extrai uma mensagem legível de um corpo de erro do DRF.
  String _errorMessage(dynamic body, String fallback) {
    if (body is Map) {
      final detail = body['detail'] ?? body['erro'];
      if (detail is String && detail.isNotEmpty) return detail;
      for (final value in body.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return value.first as String;
        }
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return fallback;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } catch (_) {
      throw const ApiException(_msgOffline);
    }
  }

  Future<dynamic> _get(String path) async {
    final res = await _send(
      () => http.get(Uri.parse('$baseUrl$path'), headers: _headers()),
    );
    final body = _decode(res);
    if (res.statusCode == 200) return body;
    throw ApiException(
      _errorMessage(body, 'Falha ao carregar dados (${res.statusCode}).'),
      statusCode: res.statusCode,
    );
  }

  /// Lista todos os itens de um endpoint paginado (segue `next`).
  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final items = <Map<String, dynamic>>[];
    String? next = '$baseUrl$path';
    var guard = 0;
    while (next != null && guard++ < 50) {
      final url = next;
      final res = await _send(
        () => http.get(Uri.parse(url), headers: _headers()),
      );
      final body = _decode(res);
      if (res.statusCode != 200) {
        throw ApiException(
          _errorMessage(body, 'Falha ao carregar dados (${res.statusCode}).'),
          statusCode: res.statusCode,
        );
      }
      if (body is List) {
        items.addAll(body.whereType<Map>().map(Map<String, dynamic>.from));
        next = null;
      } else if (body is Map) {
        final results = body['results'] as List<dynamic>? ?? [];
        items.addAll(results.whereType<Map>().map(Map<String, dynamic>.from));
        next = body['next'] as String?;
      } else {
        next = null;
      }
    }
    return items;
  }

  Future<Map<String, dynamic>> _write(
    String method,
    String path,
    Map<String, dynamic> payload, {
    required Set<int> okCodes,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _send(() {
      final body = jsonEncode(payload);
      switch (method) {
        case 'PATCH':
          return http.patch(uri, headers: _headers(), body: body);
        default:
          return http.post(uri, headers: _headers(), body: body);
      }
    });
    final body = _decode(res);
    if (okCodes.contains(res.statusCode) && body is Map) {
      return Map<String, dynamic>.from(body);
    }
    throw ApiException(
      _errorMessage(body, 'Não foi possível concluir a operação.'),
      statusCode: res.statusCode,
    );
  }

  // ---------------------------------------------------------------------------
  // Utilitários de formatação (a partir de dados vindos da API)
  // ---------------------------------------------------------------------------

  static String _iniciais(String nome, {int max = 2}) {
    final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return partes.map((p) => p[0]).take(max).join().toUpperCase();
  }

  static String formatarData(dynamic iso) {
    if (iso is! String || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  static String _rotuloStatusAtividade(String? status) {
    switch (status) {
      case 'rascunho':
        return 'Rascunho';
      case 'variacoes_geradas':
        return 'Variações geradas';
      case 'aprovada':
        return 'Aprovada';
      case 'encerrada':
        return 'Encerrada';
      default:
        return status ?? '';
    }
  }

  static String _rotuloOrigem(String? origem) {
    switch (origem) {
      case 'pdf':
        return 'PDF';
      case 'docx':
        return 'DOCX';
      case 'texto':
        return 'Texto';
      default:
        return origem ?? '';
    }
  }

  // ---------------------------------------------------------------------------
  // Autenticação
  // ---------------------------------------------------------------------------

  /// Verifica se o backend está acessível.
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

  /// Passo 1: matrícula + senha em /api/auth/login/. O backend envia o OTP ao e-mail do usuário.
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
          .timeout(_timeout);
      final body = _decode(res);

      if (res.statusCode == 200 && body is Map) {
        _lastOtpToken = body['otp_token'] as String?;
        return {
          'success': true,
          'otp_token': _lastOtpToken,
          'email': body['email'] as String?,
        };
      }
      return {
        'success': false,
        'error': _errorMessage(body, 'Matrícula ou senha incorretos.'),
      };
    } catch (_) {
      return {'success': false, 'error': _msgOffline};
    }
  }

  /// Passo 2: código OTP em /api/auth/otp/verify/.
  Future<Map<String, dynamic>> verifyOtp(String code) async {
    if (_lastOtpToken == null) {
      return {
        'success': false,
        'error': 'Sessão de verificação expirada. Faça login novamente.',
      };
    }
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
          .timeout(_timeout);
      final body = _decode(res);

      if (res.statusCode == 200 && body is Map) {
        _accessToken = body['access'] as String?;
        _refreshToken = body['refresh'] as String?;
        return {'success': true};
      }
      return {
        'success': false,
        'error': _errorMessage(
          body,
          'Código de verificação incorreto ou expirado.',
        ),
      };
    } catch (_) {
      return {'success': false, 'error': _msgOffline};
    }
  }

  /// Reenviar código OTP
  Future<bool> resendOtp() async {
    if (_lastOtpToken == null) return false;
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/auth/otp/resend/'),
            headers: _headers(withAuth: false),
            body: jsonEncode({'otp_token': _lastOtpToken}),
          )
          .timeout(_timeout);
      // O backend responde 204 (sem corpo); 200 com novo otp_token também é aceito.
      if (res.statusCode == 204) return true;
      if (res.statusCode == 200) {
        final body = _decode(res);
        if (body is Map) {
          _lastOtpToken = body['otp_token'] as String? ?? _lastOtpToken;
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _lastOtpToken = null;
    _currentUser = null;
  }

  // ---------------------------------------------------------------------------
  // Perfil do professor
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _mapUser(Map<String, dynamic> data, String escolaNome) {
    final nome = (data['name'] as String?) ?? '';
    return {
      'id': data['id'],
      'nome': nome,
      'matricula': (data['matricula'] as String?) ?? '',
      'email': (data['email'] as String?) ?? '',
      'escola': escolaNome,
      'avatar': _iniciais(nome),
    };
  }

  Future<String> _nomeEscola(dynamic escolaId) async {
    if (escolaId == null) return '';
    try {
      final body = await _get('/api/escolas/$escolaId/');
      if (body is Map) return (body['nome'] as String?) ?? '';
    } catch (_) {}
    return '';
  }

  /// Dados do usuário autenticado (GET /api/auth/me/)
  Future<Map<String, dynamic>> getUser() async {
    final body = await _get('/api/auth/me/');
    final data = Map<String, dynamic>.from(body as Map);
    final escola = _currentUser != null && _currentUser!['id'] == data['id']
        ? (_currentUser!['escola'] as String? ?? '')
        : await _nomeEscola(data['escola']);
    _currentUser = _mapUser(data, escola);
    return _currentUser!;
  }

  /// Atualiza nome e e-mail (PATCH /api/auth/me/)
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final data = await _write(
      'PATCH',
      '/api/auth/me/',
      {'name': name.trim(), 'email': email.trim()},
      okCodes: {200},
    );
    _currentUser = _mapUser(data, (_currentUser?['escola'] as String?) ?? '');
    return {'success': true, 'user': _currentUser};
  }

  // ---------------------------------------------------------------------------
  // Turmas, alunos, atividades
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getTurmas() async {
    final turmas = await _getList('/api/turmas/');
    return turmas
        .map((t) => {
              'id': t['id'],
              'nome': t['nome'] ?? '',
              'turno': t['turno_display'] ?? t['turno'] ?? '',
              'ano_letivo': t['ano_letivo'],
              'estudantes_count': t['total_estudantes'] ?? 0,
              'escola': t['escola'],
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAlunos({int? turmaId}) async {
    final query = turmaId != null ? '?turma=$turmaId' : '';
    final alunos = await _getList('/api/alunos/$query');

    // Relatórios gerados para cada aluno (perfil de apoio / atividades adaptadas)
    final relatorios = await _getList('/api/relatorios/');
    final relPorAluno = <int, List<Map<String, dynamic>>>{};
    for (final r in relatorios) {
      final aId = r['aluno'] as int?;
      if (aId != null) relPorAluno.putIfAbsent(aId, () => []).add(r);
    }

    return alunos.map((a) {
      final id = a['id'] as int;
      final nome = (a['nome'] as String?) ?? '';
      final rels = relPorAluno[id] ?? const <Map<String, dynamic>>[];

      String acompanhamento = '';
      final atividades = <Map<String, dynamic>>[];
      for (final r in rels) {
        final dados = r['dados'];
        if (dados is! Map) continue;
        final resumo = dados['profile_summary'];
        if (acompanhamento.isEmpty && resumo is String) acompanhamento = resumo;
        final adaptadas = dados['adapted_activities'];
        if (adaptadas is List) {
          for (final ativ in adaptadas.whereType<Map>()) {
            final data = formatarData(r['created_at']);
            atividades.add({
              'titulo': ativ['title'] ?? '',
              'data_envio': data.isEmpty ? '' : 'Enviada em $data',
              'observacao': ativ['objective'] ?? ativ['instructions'] ?? '',
            });
          }
        }
      }

      final nascimentoIso = a['nascimento'] as String?;
      final idade = a['idade'];
      String nascimento = '';
      if (nascimentoIso != null && nascimentoIso.isNotEmpty) {
        final dt = DateTime.tryParse(nascimentoIso);
        if (dt != null) {
          final d = dt.day.toString().padLeft(2, '0');
          final m = dt.month.toString().padLeft(2, '0');
          nascimento = '$d/$m/${dt.year}';
          if (idade != null) nascimento += ' · $idade anos';
        }
      }

      return {
        'id': id,
        'turma_id': a['turma'],
        'nome': nome,
        'avatar': _iniciais(nome, max: 1),
        'matricula': (a['matricula'] as String?) ?? '',
        'nascimento': nascimento,
        'status': a['ativo'] == false ? 'Aluno inativo' : 'Aluno ativo',
        'acompanhamento': acompanhamento,
        'atividades': atividades,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAtividades({int? turmaId}) async {
    final query = turmaId != null ? '?turma=$turmaId' : '';
    final atividades = await _getList('/api/atividades/$query');
    final relatorios = await _getList('/api/relatorios/');
    final contagem = <int, int>{};
    for (final r in relatorios) {
      final atId = r['atividade'] as int?;
      if (atId != null) contagem[atId] = (contagem[atId] ?? 0) + 1;
    }

    return atividades.map((a) {
      final status = a['status'] as String?;
      return {
        'id': a['id'],
        'turma_id': a['turma'],
        'nome': (a['titulo'] ?? a['nome'] ?? '') as String,
        'tipo': _rotuloOrigem(a['origem'] as String?),
        'status': _rotuloStatusAtividade(status),
        'concluida': status == 'aprovada' || status == 'encerrada',
        'data': formatarData(a['created_at']),
        'descricao': (a['objetivo'] as String?) ?? '',
        'relatorios_count': contagem[a['id']] ?? 0,
      };
    }).toList();
  }

  /// Indicadores do perfil, calculados a partir dos dados do banco.
  Future<Map<String, dynamic>> getResumoPerfil() async {
    final turmas = await getTurmas();
    final atividades = await _getList('/api/atividades/');
    final estudantes = turmas.fold<int>(
      0,
      (soma, t) => soma + ((t['estudantes_count'] as num?)?.toInt() ?? 0),
    );
    return {
      'turmas_count': turmas.length,
      'estudantes_count': estudantes,
      'atividades_count': atividades.length,
    };
  }

  /// Atividades mais recentes do professor (já ordenadas pelo backend).
  Future<List<Map<String, dynamic>>> getAtividadesRecentes() async {
    final atividades = await _getList('/api/atividades/');
    return atividades.map((a) {
      final status = a['status'] as String?;
      return {
        'id': a['id'],
        'titulo': (a['titulo'] ?? a['nome'] ?? '') as String,
        'data': formatarData(a['created_at']),
        'status': _rotuloStatusAtividade(status),
        'concluida': status == 'aprovada' || status == 'encerrada',
        'descricao': (a['objetivo'] as String?) ?? '',
      };
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Escritas
  // ---------------------------------------------------------------------------

  /// Reconhece nomes na foto da lista de chamada (POST /api/chamada/reconhecer/).
  Future<List<Map<String, dynamic>>> reconhecerChamada({
    required List<int> bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/chamada/reconhecer/'),
    )
      ..headers.addAll(_headers(json: false))
      ..files.add(
        http.MultipartFile.fromBytes('imagem', bytes, filename: filename),
      );

    http.Response res;
    try {
      res = await http.Response.fromStream(
        await request.send().timeout(const Duration(seconds: 60)),
      );
    } catch (_) {
      throw const ApiException(_msgOffline);
    }
    final body = _decode(res);
    if (res.statusCode == 200 && body is Map) {
      final nomes = (body['nomes'] as List<dynamic>? ?? []).cast<String>();
      return nomes.map((n) => {'nome': n}).toList();
    }
    throw ApiException(
      _errorMessage(body, 'Não foi possível reconhecer os nomes da foto.'),
      statusCode: res.statusCode,
    );
  }

  Future<Map<String, dynamic>> addTurmaComAlunos({
    required String nome,
    required String turno,
    required int anoLetivo,
    required List<String> nomesAlunos,
  }) async {
    final t = turno.toLowerCase();
    final turnoCode = t.contains('tarde')
        ? 'tarde'
        : t.contains('integral')
            ? 'integral'
            : 'manha';

    final nova = await _write(
      'POST',
      '/api/turmas/',
      {'nome': nome.trim(), 'turno': turnoCode, 'ano_letivo': anoLetivo},
      okCodes: {201},
    );
    final turmaId = nova['id'] as int;
    await addAlunosNaTurma(turmaId: turmaId, nomesAlunos: nomesAlunos);

    return {
      'id': turmaId,
      'nome': nova['nome'],
      'turno': nova['turno_display'] ?? turno,
      'ano_letivo': nova['ano_letivo'],
      'estudantes_count': nomesAlunos.length,
    };
  }

  Future<void> addAlunosNaTurma({
    required int turmaId,
    required List<String> nomesAlunos,
  }) async {
    for (final nome in nomesAlunos) {
      await _write(
        'POST',
        '/api/alunos/',
        {'nome': nome.trim(), 'turma': turmaId},
        okCodes: {201},
      );
    }
  }

  Future<Map<String, dynamic>> addAtividade({
    required int turmaId,
    required String titulo,
    required String texto,
    String? objetivo,
  }) async {
    final a = await _write(
      'POST',
      '/api/atividades/',
      {
        'turma': turmaId,
        'titulo': titulo.trim(),
        'texto_original': texto.trim(),
        'origem': 'texto',
        if (objetivo != null && objetivo.trim().isNotEmpty)
          'objetivo': objetivo.trim(),
      },
      okCodes: {201},
    );
    return {'id': a['id'], 'nome': a['titulo'] ?? titulo};
  }
}
