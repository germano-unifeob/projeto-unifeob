import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/ingredient.dart';
import '/models/core/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "https://apiprojetosmartchef-production.up.railway.app/";

  static Future<http.Response> registerUser(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> login(Map<String, dynamic> data) async {
  final url = Uri.parse('$baseUrl/login');
  print('🔍 Tentando login em: $url');
  print('📦 Dados enviados: $data');

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    print('✅ Resposta status: ${response.statusCode}');
    print('📨 Corpo da resposta: ${response.body}');
    return response;
  } catch (e) {
    print('❌ Erro ao tentar login: $e');
    rethrow;
  }
}

  static Future<http.Response> sendRecoveryToken(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/password/send-token'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> resetPassword(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$baseUrl/password/reset'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<List<Ingredient>> fetchUserIngredients(int userId) async {
    final url = Uri.parse('$baseUrl/ingredientes/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        return data.map((e) => Ingredient.fromJson(e)).toList();
      } catch (e) {
        print('Erro ao parse JSON em fetchUserIngredients: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em fetchUserIngredients');
      return [];
    }
  }

  Future<void> cadastrarIngrediente({
  required int userId,
  required String nomeIngrediente,
  required String validade,
}) async {
  final url = Uri.parse('$baseUrl/ingredientes');
  final body = jsonEncode({
    'user_id': userId,
    'ingredient_name': nomeIngrediente,
    'expiration_date': validade,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode != 201) {
    print('Erro ao cadastrar ingrediente: ${response.statusCode} ${response.body}');
    throw Exception('Erro ao cadastrar ingrediente');
  }
}

  static Future<List<Map<String, dynamic>>> buscarIngredientesPorPrefixo(String prefixo) async {
    final url = Uri.parse('$baseUrl/ingredientes?q=$prefixo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty && data.first is String) {
          return data.asMap().entries.map<Map<String, dynamic>>((entry) => {
            'id': entry.key,
            'name': entry.value,
          }).toList();
        }
        return data.map<Map<String, dynamic>>((e) => {
          'id': e['ingredient_id'] is String
              ? int.parse(e['ingredient_id'])
              : e['ingredient_id'],
          'name': e['ingredient'] ?? e['name'] ?? '',
        }).toList();
      } catch (e) {
        print('Erro ao parse JSON em buscarIngredientesPorPrefixo: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em buscarIngredientesPorPrefixo');
      return [];
    }
  }

  static Future<http.Response> salvarAlergias(int userId, List<int> allergyIds) {
    final url = Uri.parse('$baseUrl/usuarios/alergias');
    final body = jsonEncode({
      'user_id': userId,
      'allergy_ids': allergyIds,
    });
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

 Future<List<Map<String, dynamic>>> recomendarReceitasComIngredientes({
  required int userId,
  required List<Map<String, dynamic>> ingredientes,
}) async {
  final url = Uri.parse('$baseUrl/ia/recomendar-receitas');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'ingredients': ingredientes,
    }),
  );
  if (response.statusCode == 200) {
    try {
      final jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['receitas']);
    } catch (e) {
      print('Erro ao parse JSON em recomendarReceitas: $e');
      return [];
    }
  } else {
    print('Status ${response.statusCode} em recomendarReceitas');
    return [];
  }
}

  static Future<List<Map<String, dynamic>>> getEstilosVida() async {
    final url = Uri.parse('$baseUrl/estilos-vida');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((e) => {
          'id': e['estilo_vida_id'],
          'name': e['nome'] ?? '',
        }).toList();
      } catch (e) {
        print('Erro ao parse JSON em getEstilosVida: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em getEstilosVida');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getNiveisExperiencia() async {
    final url = Uri.parse('$baseUrl/niveis-experiencia');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((e) => {
          'id': e['nivel_experiencia_id'],
          'name': e['nome'] ?? '',
        }).toList();
      } catch (e) {
        print('Erro ao parse JSON em getNiveisExperiencia: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em getNiveisExperiencia');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getListaAlergias() async {
    final url = Uri.parse('$baseUrl/alergias');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final List data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((e) => {
          'id': e['ingredient_id'] is String
              ? int.parse(e['ingredient_id'])
              : e['ingredient_id'],
          'name': e['ingredient'] ?? e['name'] ?? '',
        }).toList();
      } catch (e) {
        print('Erro ao parse JSON em getListaAlergias: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em getListaAlergias');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getRecomendacoes(int userId) async {
    final url = Uri.parse('$baseUrl/receitas/recomendar/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final result = jsonDecode(response.body);
        return result;
      } catch (e) {
        print('Erro ao parse JSON em getRecomendacoes: $e');
        return {};
      }
    } else {
      print('Status ${response.statusCode} em getRecomendacoes');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> searchReceitas(String query) async {
    final url = Uri.parse('$baseUrl/receitas/search?q=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final result = jsonDecode(response.body);
        if (result is List) {
          return List<Map<String, dynamic>>.from(result);
        } else {
          return [];
        }
      } catch (e) {
        print('Erro ao parse JSON em searchReceitas: $e');
        return [];
      }
    } else {
      print('Status ${response.statusCode} em searchReceitas');
      return [];
    }
  }

  static Future<List<dynamic>> autocompleteReceitas(String termo) async {
    final response = await http.get(Uri.parse('$baseUrl/receitas/autocomplete?q=$termo'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar sugestões');
    }
  }

  static Future<List<dynamic>> getReceitasAleatorias() async {
    final response = await http.get(Uri.parse('$baseUrl/receitas/random'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar receitas aleatórias');
    }
  }

  Future<List<Recipe>> getReceitasDoUsuario(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user_recipes/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar receitas do usuário');
    }
  }

  static Future<List<dynamic>> getReceitasByEstiloPaginado({
    required int estiloVidaId,
    required int page,
    required int pageSize,
    int? difficultyId,
    int? foodTypeId,
    int? minMinutes,
    int? maxMinutes,
  }) async {
    final queryParams = {
      'estiloVidaId': estiloVidaId.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (difficultyId != null) queryParams['difficultyId'] = difficultyId.toString();
    if (foodTypeId != null) queryParams['foodTypeId'] = foodTypeId.toString();
    if (minMinutes != null) queryParams['minMinutes'] = minMinutes.toString();
    if (maxMinutes != null) queryParams['maxMinutes'] = maxMinutes.toString();

    final uri = Uri.parse('$baseUrl/receitas/por-estilo').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar receitas paginadas com filtros');
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return null;

    final url = Uri.parse('$baseUrl/usuarios/perfil/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erro na API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar com a API: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return false;

    final url = Uri.parse('$baseUrl/usuarios/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro ao atualizar perfil: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return false;
    }
  }

static Future<List<Map<String, dynamic>>> getReceitasComFiltros({
  int? difficultyId,
  int? foodTypeId,
  int? minMinutes,
  int? maxMinutes,
  int page = 1,
  int pageSize = 10,
}) async {
  final queryParams = {
    'page': page.toString(),
    'pageSize': pageSize.toString(),
  };

  if (difficultyId != null) queryParams['nivel_experiencia_id'] = difficultyId.toString();

  if (foodTypeId != null) {
    queryParams['estilo_vida_id'] = foodTypeId.toString();

    // 🥗 Adiciona o filtro de calorias se for o estilo "Fit"
    if (foodTypeId == 0) {
      queryParams['maxCalories'] = '300';
    }
  }

  if (minMinutes != null) queryParams['minMinutes'] = minMinutes.toString();
  if (maxMinutes != null) queryParams['maxMinutes'] = maxMinutes.toString();

  final uri = Uri.parse('$baseUrl/receitas/com-filtros').replace(queryParameters: queryParams);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    throw Exception('Erro ao buscar receitas com filtros');
  }
}


static Future<List<dynamic>> getReceitasCarnes({
  required int page,
  int pageSize = 10,
}) async {
  final response = await http.get(Uri.parse('$baseUrl/receitas/carnes?page=$page&pageSize=$pageSize'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Erro ao carregar receitas com carnes');
  }
}


}
