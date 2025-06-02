import 'dart:convert';
import 'package:http/http.dart' as http;

const String pixabayApiKey = '50580943-84f5161cd569cf01c4fe1596a'; // 👈 substitua pela sua chave

Future<String?> buscarImagemPixabay(String termo) async {
  final url = Uri.parse(
    'https://pixabay.com/api/?key=$pixabayApiKey&q=${Uri.encodeComponent(termo)}&image_type=photo&per_page=3',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['hits'] != null && data['hits'].isNotEmpty) {
      return data['hits'][0]['webformatURL'];
    }
  }

  return null;
}
