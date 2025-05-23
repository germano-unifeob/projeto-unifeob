import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/services/api_service.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/modals/search_filter_modal.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchInputController = TextEditingController();
  List<Recipe> searchResult = [];

  @override
  void initState() {
    super.initState();
    carregarReceitasAleatorias();
  }

  Future<void> carregarReceitasAleatorias() async {
    try {
      final resultados = await ApiService.getReceitasAleatorias();
      setState(() {
        searchResult = resultados.map((e) => Recipe.fromJson(e)).toList();
      });
    } catch (e) {
      print('Erro ao carregar receitas aleatórias: $e');
    }
  }

  Future<void> buscarReceitas() async {
    final termo = searchInputController.text.trim();
    if (termo.isEmpty) return;

    try {
      final resultados = await ApiService.searchReceitas(termo);
      setState(() {
        searchResult = resultados.map((e) => Recipe.fromJson(e)).toList();
      });
    } catch (e) {
      print('Erro ao buscar receitas: $e');
      setState(() {
        searchResult = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Recipe',
          style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Search
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
                              return await ApiService.autocompleteReceitas(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              final item = suggestion as Map<String, dynamic>;
                              return ListTile(
                                title: Text(item['name']),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              final item = suggestion as Map<String, dynamic>;
                              setState(() {
                                searchResult = [Recipe.fromJson(item)];
                              });
                              searchInputController.text = item['title'] ?? '';
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: searchInputController,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => buscarReceitas(),
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
                            builder: (_) => SearchFilterModal(),
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

          // Section 2 - Resultados
          Container(
            padding: EdgeInsets.all(16),
            child: searchResult.isEmpty
                ? Center(child: Text('Nenhuma receita encontrada'))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: searchResult.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16),
                    itemBuilder: (_, index) => RecipeTile(data: searchResult[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
