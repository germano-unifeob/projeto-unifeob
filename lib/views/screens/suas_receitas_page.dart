import 'package:flutter/material.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/widgets/recipe_tile.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import '/services/api_service.dart'; 

class SuasReceitasPage extends StatefulWidget {
  final int userId;

  const SuasReceitasPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SuasReceitasPage> createState() => _SuasReceitasPageState();
}

class _SuasReceitasPageState extends State<SuasReceitasPage> {
  List<Recipe> receitas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }

  Future<void> carregarReceitas() async {
    setState(() => carregando = true);
    try {
      final response = await ApiService().getReceitasDoUsuario(widget.userId);
      setState(() {
        receitas = response;
        carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar receitas: $e");
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suas Receitas"),
        backgroundColor: AppColor.primary,
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : receitas.isEmpty
              ? Center(child: Text("Você ainda não tem nenhuma receita."))
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: receitas.length,
                  itemBuilder: (context, index) {
                    return RecipeTile(data: receitas[index]);
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                ),
    );
  }
}
