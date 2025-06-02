import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/screens/recipe_detail_page.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/utils/pixabay_helper.dart';
import 'package:translator/translator.dart';

class RecipeTile extends StatefulWidget {
  final Recipe data;
  RecipeTile({required this.data});

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  String? imageUrl;
  String? translatedTitle;
  String? translatedIngredients;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    carregarImagemETraducao();
  }

  Future<void> carregarImagemETraducao() async {
    final tituloOriginal = widget.data.title;

    // 1. Se imagem já está definida localmente, usa direto
    if (widget.data.photo.isNotEmpty && !widget.data.photo.startsWith('http')) {
      setState(() {
        imageUrl = widget.data.photo;
      });
    } else {
      // Caso contrário, busca no Pixabay
      final url = await buscarImagemPixabay(tituloOriginal);
      setState(() {
        imageUrl = url ?? '';
      });
    }

    // 2. Traduzir título e ingredientes
    final traducaoTitulo = await translator.translate(tituloOriginal, from: 'en', to: 'pt');
    String? traducaoIngredientes;
    if (widget.data.ingredientsString != null && widget.data.ingredientsString!.isNotEmpty) {
      traducaoIngredientes = (await translator.translate(
        widget.data.ingredientsString!,
        from: 'en',
        to: 'pt',
      ))
          .text;
    }

    setState(() {
      translatedTitle = traducaoTitulo.text;
      translatedIngredients = traducaoIngredientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = translatedTitle ?? widget.data.title;
    final displayIngredients = translatedIngredients ?? widget.data.ingredientsString ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RecipeDetailPage(data: widget.data)),
        );
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.whiteSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Imagem da receita
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? (imageUrl!.startsWith('http')
                      ? Image.network(
                          imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ))
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
            ),

            // Informações
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      displayTitle,
                      style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'inter'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Ingredientes traduzidos
                    Text(
                      displayIngredients,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Calorias e tempo
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/fire-filled.svg',
                          color: Colors.black,
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 5),
                        Text('${widget.data.calories} cal', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 10),
                        Icon(Icons.alarm, size: 14, color: Colors.black),
                        SizedBox(width: 5),
                        Text('${widget.data.time} min', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
