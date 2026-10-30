import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sem backend acessível o login falha e as listagens lançam ApiException (sem dados simulados)', () async {
    final api = ApiService.instance;
    final original = api.baseUrl;
    api.setBaseUrl('http://127.0.0.1:9');

    final res = await api.login('PROF2026', 'user123');
    expect(res['success'], isFalse);
    expect(res['error'], isNotNull);

    expect(() => api.getTurmas(), throwsA(isA<ApiException>()));

    api.setBaseUrl(original);
  });

  test('formatarData converte ISO do backend para DD/MM/AAAA', () {
    expect(ApiService.formatarData('2026-10-23T12:00:00Z'), isNotEmpty);
    expect(ApiService.formatarData(null), '');
    expect(ApiService.formatarData('inválido'), '');
  });

  test('setTokens e logout gerenciam a sessao e limpam tokens', () async {
    final api = ApiService.instance;
    final original = api.baseUrl;
    api.setBaseUrl('http://127.0.0.1:9');

    api.setTokens(access: 'token-access-teste', refresh: 'token-refresh-teste');
    expect(api.isAuthenticated, isTrue);
    expect(api.accessToken, 'token-access-teste');
    expect(api.refreshToken, 'token-refresh-teste');

    // logout tenta chamar POST /api/auth/logout/ no servidor; se falhar (offline), limpa mesmo assim
    await api.logout();
    expect(api.isAuthenticated, isFalse);
    expect(api.accessToken, isNull);
    expect(api.refreshToken, isNull);

    api.setBaseUrl(original);
  });

  test('refreshToken sem token de refresh chama onSessionExpired e devolve false', () async {
    final api = ApiService.instance;
    api.setTokens(access: null, refresh: null);

    var expirou = false;
    api.onSessionExpired = () {
      expirou = true;
    };

    final sucesso = await api.refreshToken();
    expect(sucesso, isFalse);
    expect(expirou, isTrue);

    api.onSessionExpired = null;
  });
}
