import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/services/api_service.dart';

class NewRecipePage extends StatefulWidget {
  final int userId;
  const NewRecipePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  final List<Map<String, dynamic>> _ingredientes = [];

  void _abrirModalAdicionarIngrediente() {
    final nomeController = TextEditingController();
    String validadeTexto = '';
    Map<String, dynamic>? ingredienteSelecionado;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Adicionar Ingrediente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                        fontFamily: 'inter',
                      ),
                    ),
                    SizedBox(height: 18),
                    TypeAheadFormField<Map<String, dynamic>>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Ingrediente',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                      suggestionsCallback: (pattern) async => await ApiService.buscarIngredientesPorPrefixo(pattern),
                      itemBuilder: (context, suggestion) =>
                          ListTile(title: Text(suggestion['name'])),
                      onSuggestionSelected: (suggestion) {
                        setModalState(() {
                          nomeController.text = suggestion['name'];
                          ingredienteSelecionado = suggestion;
                        });
                      },
                      noItemsFoundBuilder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Nenhum ingrediente encontrado.'),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Validade (AAAA-MM-DD)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      onChanged: (value) => validadeTexto = value,
                    ),
                    SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.w600),
                        minimumSize: Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      icon: Icon(Icons.check, color: Colors.white,),
                      label: Text('Salvar'),
                      onPressed: () {
                        if (nomeController.text.trim().isEmpty ||
                            validadeTexto.trim().isEmpty ||
                            ingredienteSelecionado == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selecione um ingrediente válido e informe a validade')),
                          );
                          return;
                        }
                        DateTime validade;
                        try {
                          validade = DateFormat('yyyy-MM-dd').parse(validadeTexto.trim());
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Data inválida. Use o formato AAAA-MM-DD')),
                          );
                          return;
                        }
                        setState(() {
                          _ingredientes.add({
                            'name': nomeController.text.trim(),
                            'ingredient_id': ingredienteSelecionado!['id'],
                            'expiration_date': DateFormat('yyyy-MM-dd').format(validade),
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _buscarReceitas() async {
    if (_ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicione pelo menos um ingrediente')),
      );
      return;
    }
    // Exibe o loading dialog
    showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColor.primary),
            SizedBox(height: 18),
            Text(
              'Buscando receitas...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'inter',
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  },
);
    try {
      await ApiService.recomendarReceitasComIngredientes(
        userId: widget.userId,
        ingredientes: _ingredientes
            .map((ing) => {
                  'ingredient_id': ing['ingredient_id'],
                  'expiration_date': ing['expiration_date'],
                })
            .toList(),
      );

      if (mounted) Navigator.pop(context); // Fecha o loading

      // Volta para a tela anterior (Home ou MinhasReceitas) e avisa para recarregar
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar receitas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          color: AppColor.primary,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Nova Receita', style: TextStyle(color: Colors.white, fontFamily: 'inter', fontWeight: FontWeight.w700, fontSize: 18)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: Container(
        color: AppColor.primary,
        child: ListView(
          padding: EdgeInsets.only(top: 80, left: 0, right: 0, bottom: 18),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Text(
                'Adicione os ingredientes únicos que você tem com você!',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'inter'),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _abrirModalAdicionarIngrediente,
                    icon: Icon(Icons.add, color: AppColor.primary),
                    label: Text('Adicionar Ingrediente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColor.primary,
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.fromHeight(48),
                      elevation: 1.5,
                    ),
                  ),
                  SizedBox(height: 18),
                  _ingredientes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22.0),
                            child: Text('Nenhum ingrediente adicionado.', style: TextStyle(color: Colors.white70)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _ingredientes.length,
                          separatorBuilder: (context, index) => SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final ing = _ingredientes[index];
                            return Card(
                              color: Colors.white,
                              margin: EdgeInsets.zero,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                title: Text(
                                  ing['name'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'inter'),
                                ),
                                subtitle: Text("Validade: ${ing['expiration_date']}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: AppColor.primary),
                                  onPressed: () {
                                    setState(() {
                                      _ingredientes.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(14, 24, 14, 0),
              child: ElevatedButton.icon(
                onPressed: _buscarReceitas,
                icon: Icon(Icons.search, color: AppColor.primary),
                label: Text('Buscar Receitas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColor.primary,
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size.fromHeight(54),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
