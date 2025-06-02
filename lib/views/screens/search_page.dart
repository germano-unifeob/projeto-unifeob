import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/services/api_service.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/modals/search_filter_modal.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchInputController = TextEditingController();
  final PagingController<int, Recipe> _pagingController = PagingController(firstPageKey: 1);
  static const int _pageSize = 10;

  String _currentFilter = '';
  int? _difficultyId;
  int? _foodTypeId;
  int? _minMinutes;
  int? _maxMinutes;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final data = await ApiService.getReceitasComFiltros(
        page: pageKey,
        pageSize: _pageSize,
        difficultyId: _difficultyId,
        foodTypeId: _foodTypeId,
        minMinutes: _minMinutes,
        maxMinutes: _maxMinutes,
      );
      final recipes = data.map((e) => Recipe.fromJson(e)).toList();
      final isLastPage = recipes.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(recipes);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(recipes, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  void _atualizarFiltro(String filtro) {
    setState(() {
      _difficultyId = null;
      _foodTypeId = null;
      _minMinutes = null;
      _maxMinutes = null;

      if (filtro == 'Iniciante') _difficultyId = 0;
      else if (filtro == 'Intermediário') _difficultyId = 1;
      else if (filtro == 'Avançado') _difficultyId = 2;
      else if (filtro == 'Normal') _foodTypeId = 2;
      else if (filtro == 'Vegetariano') _foodTypeId = 1;
      else if (filtro == 'Fit') _foodTypeId = 0;
      else if (filtro == 'Até 30 minutos') _maxMinutes = 30;
      else if (filtro == '30 a 60 minutos') {
        _minMinutes = 31;
        _maxMinutes = 60;
      } else if (filtro == 'Mais de 1 hora') _minMinutes = 61;

      _currentFilter = filtro;
    });
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Pesquisar Receitas', style: TextStyle(color: Colors.white, fontFamily: 'inter', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 145,
            color: AppColor.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColor.primarySoft,
                          ),
                          child: TypeAheadField(
                            suggestionsCallback: (pattern) async {
                              if (pattern.trim().isEmpty) return [];
                              try {
                                return await ApiService.autocompleteReceitas(pattern);
                              } catch (e) {
                                debugPrint('Erro ao buscar sugestões: $e');
                                return [];
                              }
                            },
                            itemBuilder: (context, suggestion) {
                              final item = suggestion as Map<String, dynamic>;
                              return ListTile(
                                title: Text(item['name']),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              final item = suggestion as Map<String, dynamic>;
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(title: Text(item['name'])),
                                  body: ListView(
                                    padding: EdgeInsets.all(16),
                                    children: [RecipeTile(data: Recipe.fromJson(item))],
                                  ),
                                ),
                              ));
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: searchInputController,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'What do you want to eat?',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 17),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => SearchFilterModal(
                              selectedFilter: _currentFilter,
                              onFilterSelected: (String filtro) {
                                _atualizarFiltro(filtro);
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
              ],
            ),
          ),
          Expanded(
            child: PagedListView<int, Recipe>(
              pagingController: _pagingController,
              padding: EdgeInsets.all(16),
              builderDelegate: PagedChildBuilderDelegate<Recipe>(
                itemBuilder: (context, recipe, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecipeTile(data: recipe),
                ),
                noItemsFoundIndicatorBuilder: (_) => Center(child: Text('Nenhuma receita encontrada')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
