import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/screens/full_screen_image.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/ingredient_tile.dart';
import 'package:smartchef/views/widgets/step_tile.dart';
import 'package:smartchef/views/utils/pixabay_helper.dart';
import 'package:translator/translator.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe data;
  RecipeDetailPage({required this.data});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool isFavorited = false;
  String? pixabayImageUrl;

  String? tituloTraduzido;
  String? descricaoTraduzida;
  List<String>? ingredientesTraduzidos;
  List<String>? passosTraduzidos;

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });
    _verificarFavorito();
    _salvarReceitaVisualizada(widget.data);
    _carregarImagemEPossiveisTraducoes();
  }

  Future<void> _carregarImagemEPossiveisTraducoes() async {
    if (!widget.data.photo.startsWith('http')) {
      final url = await buscarImagemPixabay(widget.data.title);
      setState(() {
        pixabayImageUrl = url;
      });
    }

    final tituloT = await translator.translate(widget.data.title, from: 'en', to: 'pt');
    final descricaoT = await translator.translate(widget.data.description, from: 'en', to: 'pt');

    List<String> ingredientes = widget.data.ingredients.isNotEmpty
        ? widget.data.ingredients.map((e) => e.name).toList()
        : widget.data.ingredientsString?.split(RegExp(r';|,')) ?? [];
    List<String> passos = widget.data.tutorial.isNotEmpty
        ? widget.data.tutorial.map((e) => e.description).toList()
        : widget.data.steps?.split(RegExp(r';|\n|\. ')).where((s) => s.trim().isNotEmpty).toList() ?? [];

    final ingredientesT = await Future.wait(
        ingredientes.map((i) async => (await translator.translate(i, from: 'en', to: 'pt')).text));
    final passosT = await Future.wait(
        passos.map((p) async => (await translator.translate(p, from: 'en', to: 'pt')).text));

    setState(() {
      tituloTraduzido = tituloT.text;
      descricaoTraduzida = descricaoT.text;
      ingredientesTraduzidos = ingredientesT;
      passosTraduzidos = passosT;
    });
  }

  Future<void> _verificarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = prefs.getStringList('receitas_favoritas') ?? [];
    setState(() {
      isFavorited = favoritos.any((jsonStr) {
        final map = jsonDecode(jsonStr);
        return map['title'] == widget.data.title;
      });
    });
  }

  Future<void> _alternarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = prefs.getStringList('receitas_favoritas') ?? [];

    favoritos.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['title'] == widget.data.title;
    });

    String mensagem;

    if (!isFavorited) {
      favoritos.insert(0, jsonEncode({
        'title': widget.data.title,
        'photo': widget.data.photo,
        'calories': widget.data.calories,
        'minutes': widget.data.time,
        'description': widget.data.description,
        'ingredients': widget.data.ingredientsString ?? widget.data.ingredients.map((e) => e.name).join('; '),
        'steps': widget.data.steps ?? widget.data.tutorial.map((e) => e.description).join('; '),
      }));
      mensagem = 'Item salvo nos seus favoritos!';
    } else {
      mensagem = 'Item removido dos seus favoritos.';
    }

    await prefs.setStringList('receitas_favoritas', favoritos);

    setState(() {
      isFavorited = !isFavorited;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: Duration(seconds: 2),
        backgroundColor: AppColor.primary,
      ),
    );
  }

  Future<void> _salvarReceitaVisualizada(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('receitas_vistas') ?? [];

    listaJson.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['title'] == recipe.title;
    });

    listaJson.insert(0, jsonEncode({
      'title': recipe.title,
      'photo': recipe.photo,
      'calories': recipe.calories,
      'minutes': recipe.time,
      'description': recipe.description,
      'ingredients': recipe.ingredientsString ?? recipe.ingredients.map((e) => e.name).join('; '),
      'steps': recipe.steps ?? recipe.tutorial.map((e) => e.description).join('; '),
    }));

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
    final String photoUrl = widget.data.photo.startsWith('http')
        ? widget.data.photo
        : pixabayImageUrl ?? 'assets/images/placeholder_recipe.png';

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
            title: Text('Detalhe da Receita', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                onPressed: _alternarFavorito,
                icon: SvgPicture.asset(
                  isFavorited ? 'assets/icons/bookmark-filled.svg' : 'assets/icons/bookmark.svg',
                  color: Colors.white,
                ),
              ),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FullScreenImage(
                  image: Image.network(photoUrl, fit: BoxFit.cover),
                ),
              ));
            },
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: photoUrl.startsWith('http')
                      ? NetworkImage(photoUrl)
                      : AssetImage(photoUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                Text(tituloTraduzido ?? widget.data.title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                Text(descricaoTraduzida ?? widget.data.description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          Container(
            height: 60,
            color: AppColor.secondary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) => setState(() => _tabController.index = index),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.6),
              labelStyle: TextStyle(fontWeight: FontWeight.w500),
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
                    children: ingredientesTraduzidos != null
                        ? ingredientesTraduzidos!.map((e) => ingredientTile(data: ingredient(name: e.trim(), size: ''))).toList()
                        : widget.data.ingredients.isNotEmpty
                            ? widget.data.ingredients.map((e) => ingredientTile(data: e)).toList()
                            : (widget.data.ingredientsString?.split(RegExp(r';|,')) ?? []).map((e) => ingredientTile(data: ingredient(name: e.trim(), size: ''))).toList(),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: passosTraduzidos != null
                        ? passosTraduzidos!
                            .asMap()
                            .entries
                            .map((entry) => StepTile(data: TutorialStep(step: 'Passo ${entry.key + 1}', description: entry.value)))
                            .toList()
                        : widget.data.tutorial.isNotEmpty
                            ? widget.data.tutorial.map((e) => StepTile(data: e)).toList()
                            : (widget.data.steps?.split(RegExp(r';|\n|\. ')).where((s) => s.trim().isNotEmpty).toList() ?? [])
                                .asMap()
                                .entries
                                .map((entry) => StepTile(data: TutorialStep(step: 'Passo ${entry.key + 1}', description: entry.value.trim())))
                                .toList(),
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
