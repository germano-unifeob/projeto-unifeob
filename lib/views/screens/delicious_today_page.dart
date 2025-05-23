import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/popular_recipe_card.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';

class DeliciousTodayPage extends StatefulWidget {
  @override
  _DeliciousTodayPageState createState() => _DeliciousTodayPageState();
}

class _DeliciousTodayPageState extends State<DeliciousTodayPage> {
  // Simulação: Substitua por dados reais da IA, API ou banco de dados
  Recipe? popularRecipe;
  List<Recipe> featuredRecipe = [];

  @override
  void initState() {
    super.initState();
    carregarReceitasDoDia();
  }

  void carregarReceitasDoDia() async {
    // TODO: Substitua com chamada real à API/banco
    // Exemplo de preenchimento temporário:
    setState(() {
      popularRecipe = Recipe(
        title: 'Panqueca de Banana',
        photo: '',
        calories: '300',
        time: '20',
        description: 'Panqueca saudável feita com banana, ovos e aveia.',
        ingredients: [],
        ingredientsString: 'banana; ovo; aveia',
        steps: 'Amasse a banana; Misture com os ovos e aveia; Cozinhe em frigideira antiaderente',
        tutorial: [],
        reviews: [],
      );

      featuredRecipe = [
        Recipe(
          title: 'Omelete de Legumes',
          photo: '',
          calories: '250',
          time: '10',
          description: 'Uma omelete rápida e saudável com legumes frescos.',
          ingredients: [],
          ingredientsString: 'ovo; tomate; cebola; espinafre',
          steps: 'Bata os ovos; Adicione os legumes picados; Frite até dourar',
          tutorial: [],
          reviews: [],
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Delicious Today', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Popular Recipe
          Container(
            color: AppColor.primary,
            alignment: Alignment.topCenter,
            height: 210,
            padding: EdgeInsets.all(16),
            child: popularRecipe != null
                ? PopularRecipeCard(data: popularRecipe!)
                : Center(child: Text('Nenhuma receita popular encontrada', style: TextStyle(color: Colors.white))),
          ),
          // Section 2 - Featured Recipes
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: featuredRecipe.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    itemCount: featuredRecipe.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return RecipeTile(data: featuredRecipe[index]);
                    },
                  )
                : Center(child: Text('Nenhuma receita recomendada no momento')),
          ),
        ],
      ),
    );
  }
}
