import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/services/api_service.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewlyPostedPage extends StatefulWidget {
  @override
  _NewlyPostedPageState createState() => _NewlyPostedPageState();
}

class _NewlyPostedPageState extends State<NewlyPostedPage> {
  List<Recipe> newlyPostedRecipe = [];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRecipes();
  }

  Future<void> _loadUserIdAndRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final data = await ApiService.getRecomendacoes(userId);
      final List<dynamic> lista = data['receitas'] ?? [];
      setState(() {
        newlyPostedRecipe = lista.map((e) => Recipe.fromJson(e)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        centerTitle: true,
        elevation: 0,
        title: Text('Newly Posted', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        itemCount: newlyPostedRecipe.length,
        physics: BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          return SizedBox(height: 16);
        },
        itemBuilder: (context, index) {
          return RecipeTile(
            data: newlyPostedRecipe[index],
          );
        },
      ),
    );
  }
}
