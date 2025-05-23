import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/full_screen_image.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/ingredient_tile.dart';
import 'package:hungry/views/widgets/step_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecipeDetailPage extends StatefulWidget {
  final Recipe data;
  RecipeDetailPage({required this.data});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });
    _salvarReceitaVisualizada(widget.data);
  }

  Future<void> _salvarReceitaVisualizada(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('receitas_vistas') ?? [];

    // Remove duplicatas pelo título
    listaJson.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['title'] == recipe.title;
    });

    // Adiciona nova no início
    listaJson.insert(0, jsonEncode({
      'title': recipe.title,
      'photo': recipe.photo,
      'calories': recipe.calories,
      'minutes': recipe.time,
      'description': recipe.description,
      'ingredients': recipe.ingredientsString ?? recipe.ingredients.map((e) => e.name).join('; '),
      'steps': recipe.steps ?? recipe.tutorial.map((e) => e.description).join('; '),
    }));

    // Mantém só as 5 mais recentes
    if (listaJson.length > 5) listaJson.removeRange(5, listaJson.length);

    await prefs.setStringList('receitas_vistas', listaJson);
  }

  Color appBarColor = Colors.transparent;

  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ingredient> ingredients = widget.data.ingredients;
    final List<String> ingredientsFallback = widget.data.ingredientsString?.split(RegExp(r';|,')) ?? [];
    final List<TutorialStep> steps = widget.data.tutorial;
    final List<String> stepsFallback = widget.data.steps?.split(RegExp(r';|\n|\. ')).where((s) => s.trim().isNotEmpty).toList() ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Detalhe da Receita', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/icons/bookmark.svg', color: Colors.white)),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FullScreenImage(
                  image: (widget.data.photo.isNotEmpty)
                      ? (widget.data.photo.startsWith('http')
                          ? Image.network(widget.data.photo, fit: BoxFit.cover)
                          : Image.asset(widget.data.photo, fit: BoxFit.cover))
                      : Image.asset('assets/images/placeholder_recipe.png', fit: BoxFit.cover),
                ),
              ));
            },
            child: Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (widget.data.photo.isNotEmpty)
                      ? (widget.data.photo.startsWith('http')
                          ? NetworkImage(widget.data.photo)
                          : AssetImage(widget.data.photo) as ImageProvider)
                      : AssetImage('assets/images/placeholder_recipe.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/fire-filled.svg', color: Colors.white, width: 16, height: 16),
                    SizedBox(width: 5),
                    Text(widget.data.calories.isNotEmpty ? '${widget.data.calories} cal' : '', style: TextStyle(color: Colors.white, fontSize: 12)),
                    SizedBox(width: 10),
                    Icon(Icons.alarm, size: 16, color: Colors.white),
                    SizedBox(width: 5),
                    Text(widget.data.time.isNotEmpty ? '${widget.data.time} min' : '', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 16),
                Text(widget.data.title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'inter')),
                SizedBox(height: 12),
                Text(widget.data.description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) => setState(() => _tabController.index = index),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.6),
              labelStyle: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w500),
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Ingredientes'),
                Tab(text: 'Modo de Preparo'),
              ],
            ),
          ),
          Container(
            height: 250,
            child: IndexedStack(
              index: _tabController.index,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: (ingredients.isNotEmpty
                            ? ingredients.map((e) => ingredientTile(data: e)).toList()
                            : ingredientsFallback.map((e) => ingredientTile(data: ingredient(name: e.trim(), size: ''))).toList())
                        .cast<Widget>(),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: (steps.isNotEmpty
                            ? steps.map((e) => StepTile(data: e)).toList()
                            : stepsFallback
                                .asMap()
                                .entries
                                .map((entry) => StepTile(data: TutorialStep(step: 'Passo ${entry.key + 1}', description: entry.value.trim())))
                                .toList())
                        .cast<Widget>(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
