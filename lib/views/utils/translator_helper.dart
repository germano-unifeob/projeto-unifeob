import 'package:translator/translator.dart';

final translator = GoogleTranslator();

Future<String> traduzirTexto(String texto) async {
  final traducao = await translator.translate(texto, from: 'en', to: 'pt');
  return traducao.text;
}