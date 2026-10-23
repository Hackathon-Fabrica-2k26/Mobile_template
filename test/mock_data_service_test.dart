import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/services/mock_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockDataService', () {
    test('carrega usuário padrão com dados válidos', () async {
      final user = await MockDataService.instance.getUser();
      expect(user, isNotEmpty);
      expect(user['nome'], isNotNull);
      expect(user['email'], contains('@'));
    });

    test('carrega turmas e alunos', () async {
      final turmas = await MockDataService.instance.getTurmas();
      expect(turmas, isNotEmpty);

      final alunos = await MockDataService.instance.getAlunos();
      expect(alunos, isNotEmpty);

      final alunosTurma1 = await MockDataService.instance.getAlunos(turmaId: 1);
      expect(alunosTurma1, isNotEmpty);
      expect(alunosTurma1.every((a) => a['turma_id'] == 1), isTrue);
    });

    test('validação de autenticação e OTP', () async {
      expect(await MockDataService.instance.authenticate('PROF2026', '123456'), isTrue);
      expect(await MockDataService.instance.authenticate('', ''), isFalse);

      expect(await MockDataService.instance.verifyOtp('1234'), isTrue);
      expect(await MockDataService.instance.verifyOtp('12'), isFalse);
    });
  });
}
