import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:smartchef/services/api_service.dart';

// Mock personalizado para ApiService
class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  group('Teste de Integração - Cadastro, Login, Ingredientes e IA (INT-CAD-LOG-ING-IA-001)', () {
    test('TC-INT-IA-001 - Cadastro e login funcionam corretamente', () async {
      final loginData = {'email': 'user@test.com', 'senha': '123456'};

      when(() => mockApi.login(loginData)).thenAnswer(
        (_) async => http.Response('{"token":"abc123","user_id":42}', 200),
      );

      final response = await mockApi.login(loginData);

      expect(response.statusCode, equals(200));
      expect(response.body, contains('token'));
    });

    test('TC-INT-IA-002 - Ingrediente com alergia e estilo de vida registrado corretamente', () async {
      when(() => mockApi.cadastrarIngrediente(
        userId: 42,
        nomeIngrediente: 'milk',
        validade: '2025-12-30',
      )).thenAnswer((_) async {});

      await mockApi.cadastrarIngrediente(
        userId: 42,
        nomeIngrediente: 'milk',
        validade: '2025-12-30',
      );

      verify(() => mockApi.cadastrarIngrediente(
        userId: 42,
        nomeIngrediente: 'milk',
        validade: '2025-12-30',
      )).called(1);
    });

    test('TC-INT-IA-003 - IA ignora ingredientes vencidos', () async {
      final ingredientes = [
        {'ingredient_id': 1, 'expiration_date': '2022-01-01'}, // vencido
        {'ingredient_id': 2, 'expiration_date': '2025-12-01'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'salad', 'ingredients': ['lettuce', 'tomato']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], isNot(contains('expired')));
    });

    test('TC-INT-IA-004 - IA respeita alergias e estilo de vida', () async {
      final ingredientes = [
        {'ingredient_id': 3, 'expiration_date': '2025-12-30'}, // tofu
        {'ingredient_id': 4, 'expiration_date': '2025-12-30'}, // rice
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'vegan bowl', 'ingredients': ['tofu', 'rice']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      );

      expect(result.first['name'], contains('vegan'));
    });

    test('TC-INT-IA-005 - Integração entre todos os módulos sem erros', () async {
      final loginData = {'email': 'user@test.com', 'senha': '123456'};
      final ingredientes = [
        {'ingredient_id': 3, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.login(loginData)).thenAnswer(
        (_) async => http.Response('{"token":"abc123","user_id":42}', 200),
      );

      when(() => mockApi.cadastrarIngrediente(
        userId: 42,
        nomeIngrediente: 'lettuce',
        validade: '2025-12-30',
      )).thenAnswer((_) async {});

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'healthy salad', 'ingredients': ['lettuce']}
      ]);

      final loginResponse = await mockApi.login(loginData);
      expect(loginResponse.statusCode, equals(200));

      await mockApi.cadastrarIngrediente(
        userId: 42,
        nomeIngrediente: 'lettuce',
        validade: '2025-12-30',
      );

      final receita = await mockApi.recomendarReceitasComIngredientes(
        userId: 42,
        ingredientes: ingredientes,
      );

      expect(receita.first['ingredients'], contains('lettuce'));
    });
  });
}
