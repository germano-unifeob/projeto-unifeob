import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/modals/search_filter_modal.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  TextEditingController searchInputController = TextEditingController();

  // 👉 Substitua por onde você realmente salva os favoritos (banco, API ou local)
  List<Recipe> bookmarkedRecipe = []; // Inicialmente vazio

  @override
  void initState() {
    super.initState();
    carregarFavoritos();
  }

  void carregarFavoritos() async {
    // TODO: aqui você coloca a lógica de onde vêm os favoritos de verdade (banco, localStorage, etc.)
    // Simulação de uma receita favorita só para teste:
    setState(() {
      bookmarkedRecipe = [
        Recipe(
          title: 'Exemplo Receita',
          photo: '', // pode colocar uma URL real
          calories: '250',
          time: '15',
          description: 'Receita salva como favorita.',
          ingredients: [],
          ingredientsString: 'ovo; leite; farinha',
          steps: 'Misture tudo; leve ao forno',
          tutorial: [],
          reviews: [],
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        centerTitle: false,
        elevation: 0,
        title: Text('Bookmarks', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Search Bar
          Container(
            width: MediaQuery.of(context).size.width,
            height: 95,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.primarySoft),
                        child: TextField(
                          controller: searchInputController,
                          onChanged: (value) {
                            setState(() {}); // Para re-renderizar se necessário
                          },
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          maxLines: 1,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'What do you want to eat?',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 17),
                            border: InputBorder.none,
                            prefixIcon: Visibility(
                              visible: searchInputController.text.isEmpty,
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 12),
                                child: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SearchFilterModal();
                          },
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
                    )
                  ],
                ),
              ],
            ),
          ),

          // Section 2 - Bookmarked Recipes
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: bookmarkedRecipe.isEmpty
                ? Center(child: Text('Você ainda não tem receitas favoritas.', style: TextStyle(fontFamily: 'inter')))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: bookmarkedRecipe.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return RecipeTile(data: bookmarkedRecipe[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
