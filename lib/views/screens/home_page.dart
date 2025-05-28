import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/screens/suas_receitas_page.dart';
import 'package:smartchef/views/screens/new_recipe_page.dart';
import 'package:smartchef/views/screens/profile_page.dart';
import 'package:smartchef/views/screens/search_page.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/custom_app_bar.dart';
import 'package:smartchef/views/widgets/dummy_search_bar.dart';
import 'package:smartchef/views/widgets/featured_recipe_card.dart';
import 'package:smartchef/views/widgets/new_recipe_card.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';
import 'package:smartchef/views/widgets/recommendation_recipe_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartchef/services/api_service.dart';
import 'package:smartchef/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  List<Recipe> iaRecipes = [];
  List<Recipe> viewedRecipes = [];
  int? userId;

  final Recipe recomendacaoDoDia = Recipe(
    title: 'Frango com Curry',
    photo: 'assets/images/frango.jpg',
    calories: '420',
    time: '30',
    description: 'Frango cremoso ao molho de curry, servido com arroz.',
    ingredients: [],
    ingredientsString: 'Frango, Curry, Creme de leite, Arroz',
    steps: 'Refogue, adicione curry e creme de leite, sirva com arroz.',
    tutorial: [],
    reviews: [],
  );

  final List<Recipe> receitasMocadas = [
    Recipe(
      title: 'Torrada com Abacate e Ovo Pochê',
      photo: 'assets/images/list1.jpg',
      calories: '280',
      time: '15',
      description: 'Torrada com abacate, vegetais verdes e ovo pochê.',
      ingredients: [],
      ingredientsString: 'Pão, Abacate, Ovo, Espinafre, Pimenta calabresa',
      steps: 'Amasse o abacate, refogue os verdes, cozinhe o ovo e monte tudo na torrada.',
      tutorial: [],
      reviews: [],
    ),
    Recipe(
      title: 'Cordeiro ao Molho de Vinho',
      photo: 'assets/images/list5.jpg',
      calories: '610',
      time: '50',
      description: 'Cordeiro suculento com batata gratinada, couve e linguiça ao molho demi-glace.',
      ingredients: [],
      ingredientsString: 'Cordeiro, Batata, Couve, Linguiça, Vinho tinto, Manteiga, Alho',
      steps: 'Asse o cordeiro ao ponto, grelhe a linguiça e monte com batata e couve. Regue com molho de vinho.',
      tutorial: [],
      reviews: [],
    ),
  ];

  final Recipe receitaCarrosselMocada = Recipe(
    title: 'Hambúrguer Artesanal',
    photo: 'assets/images/hamburguer.jpg', // substitua pela nova imagem
    calories: '750',
    time: '25',
    description: 'Pão brioche, carne suculenta, queijo, alface e tomate.',
    ingredients: [],
    steps: 'Grelhe a carne, monte o lanche e sirva quente.',
    ingredientsString: 'Pão, Carne moída, Queijo, Tomate, Alface',
    tutorial: [],
    reviews: [],
  );

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
    _loadViewedRecipes();
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
      FeaturedRecipeCard(data: receitaCarrosselMocada),
      ...iaRecipes.map((recipe) => FeaturedRecipeCard(data: recipe)),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('SmartChef', style: TextStyle(color: Colors.white,fontFamily: 'inter', fontWeight: FontWeight.w700)),
        showProfilePhoto: true,
        profilePhoto: AssetImage('assets/images/profile.jpg'),
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
                              if (userId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SuasReceitasPage(userId: userId!),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro: Usuário não identificado. Faça login novamente.')),
                                );
                              }
                            },
                            child: Text('ver tudo'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                            ),
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

          // Bloco mocado de recomendação
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recomendação de hoje baseada no seu estilo...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(
                  height: 174,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 1,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return RecommendationRecipeCard(data: recomendacaoDoDia);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Visualizadas recentemente (mocado se vazio)
          Container(
            margin: EdgeInsets.only(top: 14),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visualizadas Recentemente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: viewedRecipes.isNotEmpty ? viewedRecipes.length : receitasMocadas.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final recipe = viewedRecipes.isNotEmpty ? viewedRecipes[index] : receitasMocadas[index];
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