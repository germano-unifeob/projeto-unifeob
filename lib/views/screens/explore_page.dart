import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/screens/search_by_estilo_page.dart';
import 'package:smartchef/views/screens/search_page.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/popular_recipe_card.dart';
import 'package:smartchef/views/widgets/recommendation_recipe_card.dart';
import 'package:smartchef/views/widgets/custom_app_bar.dart';
import 'package:smartchef/views/screens/page_switcher.dart';

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

  void carregarReceitas() {
    setState(() {
      popularRecipe = Recipe(
        title: 'Macarrão à Bolonhesa', // ✅ novo título
        photo: 'assets/images/macarrao-bolonhesa.jpg', // ✅ imagem nova, se tiver
        calories: '530',
        time: '40',
        description: 'Macarrão com molho bolonhesa tradicional e parmesão.',
        ingredients: [],
        ingredientsString: 'macarrão; carne moída; molho de tomate; alho; cebola; parmesão',
        steps: 'Cozinhe o macarrão; Prepare o molho com carne; Misture tudo e sirva com queijo.',
        tutorial: [],
        reviews: [],
      );

      sweetFoodRecommendationRecipe = [
        Recipe(
          title: 'Bolo de Chocolate',
          photo: 'assets/images/bolo-chocolate.jpg',
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

  void _abrirBuscaPorEstilo(int estiloVidaId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchByEstiloPage(estiloVidaId: estiloVidaId),
      ),
    );
  }

  Widget _estiloCard(String title, String imagePath, int estiloVidaId) {
    return GestureDetector(
      onTap: () => _abrirBuscaPorEstilo(estiloVidaId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          height: 110,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 6,
                  offset: Offset(1, 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  appBar: CustomAppBar(
    title: Text(
      'Explorar Receitas',
      style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700, color: Colors.white),
    ),
    showProfilePhoto: false,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: () {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PageSwitcher()),
    );
  }
},
    ),
    actions: [
      IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchPage()));
        },
        icon: SvgPicture.asset('assets/icons/search.svg', color: Colors.white),
      ),
    ],
  ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Categorias
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: MediaQuery.of(context).size.width,
            color: AppColor.primary,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _estiloCard('Fit', 'assets/images/healthy.jpg', 2),
                _estiloCard('Vegetariano', 'assets/images/vegetarian.png', 1),
                _estiloCard('Sobremesas', 'assets/images/desert.jpg', 3),
                _estiloCard('Carnes', 'assets/images/carnes.jpg', 4),
              ],
            ),
          ),

          // Receita Popular
          if (popularRecipe != null)
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: PopularRecipeCard(data: popularRecipe!),
            ),

          // Recomendações
          if (sweetFoodRecommendationRecipe.isNotEmpty)
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Hoje é dia de adoçar o dia com essas delícias...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
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
