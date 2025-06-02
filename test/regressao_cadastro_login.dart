import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartchef/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class MockResponse extends Mock implements http.Response {}


class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  group('Regressão - Login', () {
    test('TC-REG-001 - Login com dados válidos retorna token e ID', () async {
      final loginData = {
        'email': 'test@email.com',
        'senha': '123456',
      };

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn(jsonEncode({
        'token': 'abc.def.ghi',
        'user_id': 999,
      }));

      when(() => mockApi.login(loginData))
          .thenAnswer((_) async => mockResponse);

      final res = await mockApi.login(loginData);

      expect(res.statusCode, 200);
      final json = jsonDecode(res.body);
      expect(json['token'], isNotEmpty);
      expect(json['user_id'], equals(999));
    });

    test('TC-REG-002 - Login com senha inválida retorna 406', () async {
      final loginData = {
        'email': 'test@email.com',
        'senha': 'errada',
      };

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(406);
      when(() => mockResponse.body).thenReturn(jsonEncode({
        'message': 'Senha inválida',
      }));

      when(() => mockApi.login(loginData))
          .thenAnswer((_) async => mockResponse);

      final res = await mockApi.login(loginData);

      expect(res.statusCode, 406);
      expect(jsonDecode(res.body)['message'], contains('Senha'));
    });

    test('TC-REG-003 - Login com e-mail não cadastrado retorna 404', () async {
      final loginData = {
        'email': 'naoexiste@email.com',
        'senha': '123456',
      };

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(() => mockResponse.body).thenReturn(jsonEncode({
        'message': 'E-mail não encontrado',
      }));

      when(() => mockApi.login(loginData))
          .thenAnswer((_) async => mockResponse);

      final res = await mockApi.login(loginData);

      expect(res.statusCode, 404);
      expect(jsonDecode(res.body)['message'], contains('E-mail'));
    });
  });
}
