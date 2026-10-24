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
}
