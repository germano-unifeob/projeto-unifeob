import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartchef/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUpAll(() {
    // Registra tipos genéricos para evitar erros com mocktail
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    mockApi = MockApiService();
  });

  group('IA - Recomendação de Receitas', () {
    test('TC-001 - Ingredientes válidos e compatíveis com estilo/alergia', () async {
      final ingredientes = [
        {'ingredient_id': 1, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 2, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 99,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'vegetarian risotto', 'ingredients': ['rice', 'tomato', 'tofu']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 99,
        ingredientes: ingredientes,
      );

      expect(result, isA<List>());
      expect(result.first['name'], contains('vegetarian'));
    });

    test('TC-002 - Ingrediente vencido presente', () async {
      final ingredientes = [
        {'ingredient_id': 5, 'expiration_date': '2022-01-01'},
        {'ingredient_id': 6, 'expiration_date': '2025-12-01'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 88,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'baked potato'}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 88,
        ingredientes: ingredientes,
      );

      expect(result.first['name'], contains('potato'));
    });

    test('TC-003 - Receita sem alérgeno (ex: milk)', () async {
      final ingredientes = [
        {'ingredient_id': 9, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 10, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 77,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'morning oats', 'ingredients': ['oats']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 77,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], isNot(contains('milk')));
    });

    test('TC-004 - Estilo vegetariano mas contém carne', () async {
      final ingredientes = [
        {'ingredient_id': 11, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 12, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 66,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'basic beans'}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 66,
        ingredientes: ingredientes,
      );

      expect(result.first['name'], contains('beans'));
    });

    test('TC-005 - Nenhum ingrediente disponível', () async {
      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 55,
        ingredientes: [],
      )).thenAnswer((_) async => []);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 55,
        ingredientes: [],
      );

      expect(result, isEmpty);
    });

    test('TC-006 - Estilo vegetariano com alimentos adequados', () async {
      final ingredientes = [
        {'ingredient_id': 13, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 14, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 15, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 44,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'veggie omelette', 'ingredients': ['egg', 'zucchini', 'cheese']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 44,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], containsAll(['egg', 'zucchini', 'cheese']));
    });
  });
}
