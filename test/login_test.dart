import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'mocks/api_service_mock.dart';

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  group('Validação local', () {
    test('TC-002 - E-mail inválido', () {
      final email = 'usuarioemail.com';
      final isValid = email.contains('@') && email.contains('.');
      expect(isValid, isFalse);
    });

    test('TC-003 - Senha curta', () {
      final senha = '123';
      final isValid = senha.length >= 6;
      expect(isValid, isFalse);
    });
  });

  group('Validação com API', () {
    test('TC-001 - E-mail e senha válidos', () async {
      when(() => mockApi.login({'email': 'usuario@email.com', 'senha': 'A123bc#'}))
        .thenAnswer((_) async => http.Response('{"token":"abc123","user_id":1}', 200));

      final response = await mockApi.login({
        'email': 'usuario@email.com',
        'senha': 'A123bc#',
      });

      expect(response.statusCode, 200);
    });

    test('TC-004 - Senha incorreta', () async {
      when(() => mockApi.login({'email': 'usuario@email.com', 'senha': '000000'}))
        .thenAnswer((_) async => http.Response('{"message":"Senha inválida"}', 401));

      final response = await mockApi.login({
        'email': 'usuario@email.com',
        'senha': '000000',
      });

      expect(response.statusCode, 401);
    });

    test('TC-005 - Usuário inexistente', () async {
      when(() => mockApi.login({'email': 'inexistente@email.com', 'senha': '123456'}))
        .thenAnswer((_) async => http.Response('{"message":"Usuário não encontrado"}', 404));

      final response = await mockApi.login({
        'email': 'inexistente@email.com',
        'senha': '123456',
      });

      expect(response.statusCode, 404);
    });
  });
}
