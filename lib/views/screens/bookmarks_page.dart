import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/modals/search_filter_modal.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';
import 'package:smartchef/views/widgets/custom_app_bar.dart';
import 'package:smartchef/views/screens/page_switcher.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  TextEditingController searchInputController = TextEditingController();
  List<Recipe> bookmarkedRecipes = [];
  String _currentFilter = '';

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('receitas_favoritas') ?? [];

    setState(() {
      bookmarkedRecipes = listaJson.map((jsonStr) {
        final map = jsonDecode(jsonStr);
        return Recipe(
          title: map['title'] ?? '',
          photo: map['photo'] ?? '',
          calories: map['calories'] ?? '',
          time: map['minutes'] ?? '',
          description: map['description'] ?? '',
          ingredients: [],
          ingredientsString: map['ingredients'] ?? '',
          steps: map['steps'] ?? '',
          tutorial: [],
          reviews: [],
          difficulty_id: map['difficulty_id'] as int?,
          food_type_id: map['food_type_id'] as int?,
        );
      }).toList();
    });
  }

  List<Recipe> aplicarFiltro(List<Recipe> receitas) {
    if (_currentFilter == 'Iniciante') {
      return receitas.where((r) => r.difficultyId == 1).toList();
    } else if (_currentFilter == 'Intermediário') {
      return receitas.where((r) => r.difficultyId == 2).toList();
    } else if (_currentFilter == 'Avançado') {
      return receitas.where((r) => r.difficultyId == 3).toList();
    } else if (_currentFilter == 'Normal') {
      return receitas.where((r) => r.foodTypeId == 1).toList();
    } else if (_currentFilter == 'Vegetariano') {
      return receitas.where((r) => r.foodTypeId == 2).toList();
    } else if (_currentFilter == 'Fit') {
      return receitas.where((r) => r.foodTypeId == 3).toList();
    } else if (_currentFilter == 'Até 30 minutos') {
      return receitas.where((r) => r.preparationMinutes <= 30).toList();
    } else if (_currentFilter == '30 a 60 minutos') {
      return receitas.where((r) => r.preparationMinutes > 30 && r.preparationMinutes <= 60).toList();
    } else if (_currentFilter == 'Mais de 1 hora') {
      return receitas.where((r) => r.preparationMinutes > 60).toList();
    }
    return receitas;
  }

  @override
  Widget build(BuildContext context) {
    final query = searchInputController.text.toLowerCase();

    final filtered = aplicarFiltro(bookmarkedRecipes).where((r) => r.title.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            fontFamily: 'inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
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
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Search bar
          Container(
            width: MediaQuery.of(context).size.width,
            height: 95,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColor.primary,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.primarySoft),
                    child: TextField(
                      controller: searchInputController,
                      onChanged: (value) => setState(() {}),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Digite o nome da receita salva',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 17),
                        border: InputBorder.none,
                        prefixIcon: Visibility(
                          visible: searchInputController.text.isEmpty,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SvgPicture.asset('assets/icons/search.svg', color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (context) => SearchFilterModal(
                        selectedFilter: _currentFilter,
                        onFilterSelected: (String filtro) {
                          setState(() {
                            _currentFilter = filtro;
                          });
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.secondary,
                    ),
                    child: SvgPicture.asset('assets/icons/filter.svg'),
                  ),
                ),
              ],
            ),
          ),

          // Lista de favoritos
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: filtered.isEmpty
                ? Center(child: Text('Você ainda não tem receitas favoritas.', style: TextStyle(fontFamily: 'inter')))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return RecipeTile(data: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
