import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/delicious_today_page.dart';
import 'package:hungry/views/screens/new_recipe_page.dart';
import 'package:hungry/views/screens/profile_page.dart';
import 'package:hungry/views/screens/search_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_app_bar.dart';
import 'package:hungry/views/widgets/dummy_search_bar.dart';
import 'package:hungry/views/widgets/featured_recipe_card.dart';
import 'package:hungry/views/widgets/new_recipe_card.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hungry/services/api_service.dart';
import 'package:hungry/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  List<Recipe> iaRecipes = [];
  List<Recipe> viewedRecipes = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRecipes();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadViewedRecipes(); // chamado ao voltar de uma receita
  }

  Future<void> _loadUserIdAndRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');
    if (userId != null) {
      await _loadIaRecipes(userId!);
      await _loadViewedRecipes();
    }
  }

  Future<void> _loadIaRecipes(int userId) async {
    try {
      // Use seus dados reais aqui se necessário
      final data = await ApiService.getRecomendacoes(userId);
      final List<dynamic> lista = data['receitas'] ?? [];
      setState(() {
        iaRecipes = lista.map((e) => _recipeFromMap(e)).toList();
      });
    } catch (e) {
      setState(() => iaRecipes = []);
    }
  }

  Future<void> _loadViewedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> salvas = prefs.getStringList('receitas_vistas') ?? [];
    setState(() {
      viewedRecipes = salvas.map((jsonString) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        return _recipeFromMap(map);
      }).toList();
    });
  }

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
      time: map['minutes']?.toString() ?? '',
      description: map['description'] ?? '',
      ingredients: ingredientes,
      ingredientsString: map['ingredients'] is String ? map['ingredients'] : null,
      steps: map['steps']?.toString() ?? '',
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
    final List<Widget> allCards = [
      NewRecipeCard(onTap: () => _goToNewRecipe(context)),
      ...iaRecipes.map((recipe) => FeaturedRecipeCard(data: recipe)),
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
                            child: Text('ver tudo'),
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
          if (viewedRecipes.isNotEmpty)
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
                        'Visualizadas Recentemente',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliciousTodayPage()));
                        },
                        child: Text('ver tudo'),
                        style: TextButton.styleFrom(foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                      ),
                    ],
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: viewedRecipes.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) => RecipeTile(data: viewedRecipes[index]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
