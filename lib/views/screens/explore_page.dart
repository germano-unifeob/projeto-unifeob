import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/search_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/category_card.dart';
import 'package:hungry/views/widgets/popular_recipe_card.dart';
import 'package:hungry/views/widgets/recommendation_recipe_card.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Recipe? popularRecipe;
  List<Recipe> sweetFoodRecommendationRecipe = [];

  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }

  void carregarReceitas() async {
    // TODO: Substituir com chamada à IA ou API
    setState(() {
      popularRecipe = Recipe(
        title: 'Torta de Morango',
        photo: '',
        calories: '380',
        time: '35',
        description: 'Uma torta doce com cobertura de morango fresco.',
        ingredients: [],
        ingredientsString: 'morango; leite condensado; manteiga; bolacha',
        steps: 'Triture as bolachas e misture com manteiga; Forre a forma e adicione o creme; Decore com morangos',
        tutorial: [],
        reviews: [],
      );

      sweetFoodRecommendationRecipe = [
        Recipe(
          title: 'Bolo de Chocolate',
          photo: '',
          calories: '450',
          time: '45',
          description: 'Bolo fofo com cobertura cremosa de chocolate.',
          ingredients: [],
          ingredientsString: 'farinha; chocolate; açúcar; ovo; leite',
          steps: 'Misture os ingredientes; Asse por 40 minutos; Cubra com chocolate derretido',
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
        centerTitle: false,
        title: Text('Explore Recipe', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
            },
            icon: SvgPicture.asset('assets/icons/search.svg', color: Colors.white),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Categorias
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width,
            height: 245,
            color: AppColor.primary,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                CategoryCard(title: 'Healthy', image: AssetImage('assets/images/healthy.jpg')),
                CategoryCard(title: 'Drink', image: AssetImage('assets/images/drink.jpg')),
                CategoryCard(title: 'Seafood', image: AssetImage('assets/images/seafood.jpg')),
                CategoryCard(title: 'Desert', image: AssetImage('assets/images/desert.jpg')),
                CategoryCard(title: 'Spicy', image: AssetImage('assets/images/spicy.jpg')),
                CategoryCard(title: 'Meat', image: AssetImage('assets/images/meat.jpg')),
              ],
            ),
          ),

          // Section 2 - Receita Popular
          if (popularRecipe != null)
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: PopularRecipeCard(data: popularRecipe!),
            ),

          // Section 3 - Recomendações doces
          if (sweetFoodRecommendationRecipe.isNotEmpty)
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Todays sweet food to make your day happy ......',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // Lista horizontal
                  Container(
                    height: 174,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: sweetFoodRecommendationRecipe.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (context, index) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return RecommendationRecipeCard(data: sweetFoodRecommendationRecipe[index]);
                      },
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
