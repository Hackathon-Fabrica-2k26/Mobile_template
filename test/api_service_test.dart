import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('ApiService possui suporte a fallback gracioso caso backend esteja offline', () async {
    final api = ApiService.instance;
    // Com url inexistente, fallback funciona sem quebrar a app
    api.setBaseUrl('http://127.0.0.1:9999');

    final loginRes = await api.login('PROF2026', 'qualquer_senha');
    expect(loginRes['success'], isTrue);
    expect(loginRes['is_remote'], isFalse);

    final turmas = await api.getTurmas();
    expect(turmas.isNotEmpty, isTrue);

    final alunos = await api.getAlunos(turmaId: 1);
    expect(alunos.isNotEmpty, isTrue);
    expect(alunos.first['nome'], isNotEmpty);

    // Restaura padrão
    api.setBaseUrl('http://127.0.0.1:8000');
  });

  test('ApiService conecta e autentica no backend Django local quando ativo', () async {
    final api = ApiService.instance;
    api.setBaseUrl('http://127.0.0.1:8000');

    final isAlive = await api.checkBackendHealth();
    if (isAlive) {
      final loginRes = await api.login('DEMO0001', 'demo-senha-123');
      expect(loginRes['success'], isTrue);
      expect(loginRes['is_remote'], isTrue);
      expect(loginRes['otp_token'], isNotNull);
    }
  });
}
