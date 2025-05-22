  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '/models/ingredient.dart';

  class ApiService {
    static const baseUrl = "http://localhost:3307";

    static Future<http.Response> registerUser(Map<String, dynamic> data) {
      return http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
    }

    static Future<http.Response> login(Map<String, dynamic> data) {
      return http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
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
        Uri.parse('$baseUrl/password/reset'), // ✅ CORRETO
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

    static Future<void> cadastrarIngrediente({
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

    static Future<List<Map<String, dynamic>>> recomendarReceitasComIngredientes({
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
          print('========= [DEBUG] Resposta recomendarReceitasComIngredientes =========');
          print(jsonEncode(jsonData));
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
          print('========= [DEBUG] RESPOSTA PURA DA API =========');
          print(response.body); // 👈 Veja aqui o JSON retornado pela API!
          final result = jsonDecode(response.body);
          print('========= [DEBUG] MAP DECODED =========');
          print(result);

          // Se for uma lista de receitas:
          if (result is Map && result['receitas'] != null) {
            for (var item in result['receitas']) {
              print('========= [DEBUG] RECEITA INDIVIDUAL =========');
              print(item);
            }
          }
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
  }
