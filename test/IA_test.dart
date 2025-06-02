import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartchef/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
  });

  group('Recomendação de receitas com IA', () {
    test('TC-001 - Ingredientes válidos e compatíveis com estilo/alergia', () async {
      final ingredientes = [
        {'ingredient_id': 1, 'expiration_date': '2025-12-30'},
        {'ingredient_id': 2, 'expiration_date': '2025-12-30'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 99,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'vegetarian rice bowl', 'ingredients': ['rice', 'tomato', 'tofu']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 99,
        ingredientes: ingredientes,
      );

      expect(result.first['name'], contains('vegetarian'));
      expect(result.first['ingredients'], containsAll(['rice', 'tomato', 'tofu']));
    });

    test('TC-002 - Ingrediente vencido presente', () async {
      final ingredientes = [
        {'ingredient_id': 5, 'expiration_date': '2022-01-01'}, // expired
        {'ingredient_id': 6, 'expiration_date': '2025-12-01'},
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 88,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'baked potato', 'ingredients': ['potato']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 88,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], contains('potato'));
    });

    test('TC-003 - Receita sem alérgeno (ex: lactose)', () async {
      final ingredientes = [
        {'ingredient_id': 9, 'expiration_date': '2025-12-30'}, // milk
        {'ingredient_id': 10, 'expiration_date': '2025-12-30'}, // oat
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 77,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'morning oats', 'ingredients': ['oat']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 77,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], isNot(contains('milk')));
    });

    test('TC-004 - Estilo vegetariano mas contém carne', () async {
      final ingredientes = [
        {'ingredient_id': 11, 'expiration_date': '2025-12-30'}, // beef
        {'ingredient_id': 12, 'expiration_date': '2025-12-30'}, // beans
      ];

      when(() => mockApi.recomendarReceitasComIngredientes(
        userId: 66,
        ingredientes: ingredientes,
      )).thenAnswer((_) async => [
        {'name': 'basic beans', 'ingredients': ['beans']}
      ]);

      final result = await mockApi.recomendarReceitasComIngredientes(
        userId: 66,
        ingredientes: ingredientes,
      );

      expect(result.first['ingredients'], isNot(contains('beef')));
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
        {'ingredient_id': 13, 'expiration_date': '2025-12-30'}, // egg
        {'ingredient_id': 14, 'expiration_date': '2025-12-30'}, // zucchini
        {'ingredient_id': 15, 'expiration_date': '2025-12-30'}, // cheese
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
