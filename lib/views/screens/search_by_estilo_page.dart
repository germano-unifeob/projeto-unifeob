import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';
import 'package:smartchef/services/api_service.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/modals/search_filter_modal.dart';

class SearchByEstiloPage extends StatefulWidget {
  final int estiloVidaId;

  const SearchByEstiloPage({Key? key, required this.estiloVidaId}) : super(key: key);

  @override
  _SearchByEstiloPageState createState() => _SearchByEstiloPageState();
}

class _SearchByEstiloPageState extends State<SearchByEstiloPage> {
  static const _pageSize = 10;
  final PagingController<int, Recipe> _pagingController = PagingController(firstPageKey: 1);
  String _currentFilter = '';
  int? _difficultyId;
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
        foodTypeId: widget.estiloVidaId, // já fixo
        difficultyId: _difficultyId,
        minMinutes: _minMinutes,
        maxMinutes: _maxMinutes,
      );

      final receitas = data.map<Recipe>((json) => Recipe.fromJson(json)).toList();
      final isLastPage = receitas.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(receitas);
      } else {
        _pagingController.appendPage(receitas, pageKey + 1);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  void _atualizarFiltro(String filtro) {
    setState(() {
      _difficultyId = null;
      _minMinutes = null;
      _maxMinutes = null;

      if (filtro == 'Iniciante') _difficultyId = 0;
      else if (filtro == 'Intermediário') _difficultyId = 1;
      else if (filtro == 'Avançado') _difficultyId = 2;
      else if (filtro == 'Até 30 minutos') _maxMinutes = 30;
      else if (filtro == '30 a 60 minutos') {
        _minMinutes = 31;
        _maxMinutes = 60;
      } else if (filtro == 'Mais de 1 hora') _minMinutes = 61;

      _currentFilter = filtro;
      _pagingController.refresh();
    });
  }

  String getTituloEstilo() {
    switch (widget.estiloVidaId) {
      case 1:
        return 'Receitas Vegetarianas';
      case 2:
        return 'Receitas Saudáveis';
      case 3:
        return 'Sobremesas';
      case 4:
        return 'Sobremesas Veganas';
      default:
        return 'Receitas';
    }
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
        title: Text(getTituloEstilo(), style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => SearchFilterModal(
                  selectedFilter: _currentFilter,
                  onFilterSelected: (String filtro) {
                    _atualizarFiltro(filtro);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: PagedListView<int, Recipe>(
        pagingController: _pagingController,
        padding: EdgeInsets.all(16),
        builderDelegate: PagedChildBuilderDelegate<Recipe>(
          itemBuilder: (context, recipe, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RecipeTile(data: recipe),
          ),
          noItemsFoundIndicatorBuilder: (_) => Center(child: Text('Nenhuma receita encontrada')),
        ),
      ),
    );
  }
}
