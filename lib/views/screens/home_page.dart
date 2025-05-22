import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/views/screens/delicious_today_page.dart';
import 'package:hungry/views/screens/new_recipe_page.dart';
import 'package:hungry/views/screens/newly_posted_page.dart';
import 'package:hungry/views/screens/profile_page.dart';
import 'package:hungry/views/screens/search_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_app_bar.dart';
import 'package:hungry/views/widgets/dummy_search_bar.dart';
import 'package:hungry/views/widgets/featured_recipe_card.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';
import 'package:hungry/views/widgets/recommendation_recipe_card.dart';
import 'package:hungry/views/widgets/new_recipe_card.dart';
import 'package:hungry/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> featuredRecipe = RecipeHelper.featuredRecipe;
  List<Recipe> recommendationRecipe = RecipeHelper.recommendationRecipe;
  List<Recipe> newlyPostedRecipe = RecipeHelper.newlyPostedRecipe;

  List<Recipe> iaRecipes = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRecipes();
  }

  Future<void> _loadUserIdAndRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    if (userId != null) {
      await _loadIaRecipes(userId!);
    }
  }

  Future<void> _loadIaRecipes(int userId) async {
    try {
      final data = await ApiService.getRecomendacoes(userId);
      final List<dynamic> lista = data['receitas'] ?? [];
      setState(() {
        iaRecipes = lista.map((e) => _recipeFromMap(e)).toList();
      });
    } catch (e) {
      setState(() => iaRecipes = []);
    }
  }

  // Converte o Map recebido da API para seu modelo Recipe
  Recipe _recipeFromMap(Map<String, dynamic> map) {
    final ingList = map['ingredients'];
    List<ingredient> ingredientes = [];
    if (ingList != null && ingList is List) {
      ingredientes = ingList.map<ingredient>((item) {
        if (item is Map<String, dynamic>) {
          return ingredient.fromJson(item);
        } else if (item is Map) {
          return ingredient(
            name: item['name'].toString(),
            size: item['size'].toString(),
          );
        } else if (item is String) {
          return ingredient(name: item, size: "");
        }
        return ingredient(name: "", size: "");
      }).toList();
    }

    return Recipe(
      title: map['name'] ?? map['title'] ?? '',
      photo: map['photo'] ?? '',
      calories: map['calories']?.toString() ?? map['calorias']?.toString() ?? '',
      time: map['minutes']?.toString() ?? map['minutes']?.toString() ?? '',
      description: map['description'] ?? '',
      ingredients: ingredientes,
      tutorial: [],
      reviews: [],
    );
  }

  Future<void> _goToNewRecipe(BuildContext context) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Usuário não identificado. Faça login novamente.')),
      );
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewRecipePage(userId: userId!)),
    );
    if (result == true) {
      await _loadIaRecipes(userId!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Sucesso"),
            content: Text("Suas receitas foram adicionadas com sucesso!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Junta os cards das receitas IA com as mocadas (agora IA vem primeiro!)
    final List<Widget> allCards = [
      NewRecipeCard(onTap: () => _goToNewRecipe(context)),
      ...iaRecipes.map((recipe) => FeaturedRecipeCard(data: recipe)),
      ...featuredRecipe.map((recipe) => FeaturedRecipeCard(data: recipe)),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('SmartChef', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700)),
        showProfilePhoto: true,
        profilePhoto: AssetImage('assets/images/pp.png'),
        profilePhotoOnPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
        },
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Featured Recipe - Wrapper
          Container(
            height: 350,
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  height: 245,
                  color: AppColor.primary,
                ),
                Column(
                  children: [
                    DummySearchBar(
                      routeTo: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suas Receitas',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliciousTodayPage()));
                            },
                            child: Text('see all'),
                            style: TextButton.styleFrom(foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      height: 220,
                      child: ListView.separated(
                        itemCount: allCards.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => SizedBox(width: 16),
                        itemBuilder: (context, index) => allCards[index],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Section 2 - Recommendation Recipe (só mocado, ajuste se quiser misturar com IA)
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Today recomendation based on your taste...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Container(
                  height: 174,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendationRecipe.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 16);
                    },
                    itemBuilder: (context, index) {
                      final Recipe recipe = recommendationRecipe[index];
                      return RecommendationRecipeCard(data: recipe);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Section 3 - Newly Posted
          Container(
            margin: EdgeInsets.only(top: 14),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vistas Recentemente',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewlyPostedPage()));
                      },
                      child: Text('see all'),
                      style: TextButton.styleFrom(foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                    ),
                  ],
                ),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: newlyPostedRecipe.length,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    final Recipe recipe = newlyPostedRecipe[index];
                    return RecipeTile(data: recipe);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
