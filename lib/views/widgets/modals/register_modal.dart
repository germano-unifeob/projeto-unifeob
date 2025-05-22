import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hungry/views/screens/page_switcher.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_text_field.dart';
import 'package:hungry/views/widgets/modals/login_modal.dart';
import '/services/api_service.dart';

class RegisterModal extends StatefulWidget {
  @override
  _RegisterModalState createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController alergiaController = TextEditingController();

  int? estiloVidaId;
  int? nivelExperienciaId;
  List<Map<String, dynamic>> selectedAlergias = [];

  List<Map<String, dynamic>> estilosVida = [];
  List<Map<String, dynamic>> niveisExperiencia = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final estilos = await ApiService.getEstilosVida();
    final niveis = await ApiService.getNiveisExperiencia();
    setState(() {
      estilosVida = estilos;
      niveisExperiencia = niveis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 85 / 100,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            physics: BouncingScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 35 / 100,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 6,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Cadastrar',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'inter'),
                ),
              ),
              CustomTextField(title: 'Email', hint: 'youremail@email.com', controller: emailController),
              CustomTextField(title: 'Nome completo', hint: 'Seu nome', controller: nameController, margin: EdgeInsets.only(top: 16)),
              CustomTextField(title: 'Senha', hint: '**********', controller: passwordController, obscureText: true, margin: EdgeInsets.only(top: 16)),
              CustomTextField(title: 'Repita a senha', hint: '**********', controller: confirmPasswordController, obscureText: true, margin: EdgeInsets.only(top: 16)),

              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('Estilo de vida', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColor.primaryExtraSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(border: InputBorder.none),
                        value: estiloVidaId,
                        items: estilosVida.map((estilo) => DropdownMenuItem<int>(
                          value: estilo['id'],
                          child: Text(estilo['name']),
                        )).toList(),
                        onChanged: (value) => setState(() => estiloVidaId = value),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('Nível de experiência', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColor.primaryExtraSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(border: InputBorder.none),
                        value: nivelExperienciaId,
                        items: niveisExperiencia.map((nivel) => DropdownMenuItem<int>(
                          value: nivel['id'],
                          child: Text(nivel['name']),
                        )).toList(),
                        onChanged: (value) => setState(() => nivelExperienciaId = value),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Alergias',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.primaryExtraSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          TypeAheadField<Map<String, dynamic>>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: alergiaController,
                              decoration: InputDecoration(
                                hintText: 'Digite para buscar alergias',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                                border: InputBorder.none,
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return await ApiService.buscarIngredientesPorPrefixo(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(title: Text(suggestion['name']));
                            },
                            onSuggestionSelected: (suggestion) {
                              if (!selectedAlergias.any((a) => a['id'] == suggestion['id'])) {
                                setState(() {
                                  selectedAlergias.add(suggestion);
                                  alergiaController.clear();
                                });
                              }
                            },
                          ),
                          Wrap(
                            spacing: 6,
                            children: selectedAlergias.map((alergia) {
                              return Chip(
                                label: Text(alergia['name']),
                                backgroundColor: Colors.orange.shade100,
                                deleteIcon: Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() => selectedAlergias.remove(alergia));
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: 32, bottom: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    final userData = {
                      'email': emailController.text,
                      'nome': nameController.text,
                      'senha': passwordController.text,
                      'estilo_vida_id': estiloVidaId,
                      'nivel_experiencia_id': nivelExperienciaId,
                      'alergia_id': selectedAlergias.map((a) => a['id']).toList(),
                    };
                    await ApiService.registerUser(userData);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PageSwitcher()));
                  },
                  child: Text('Registrar', style: TextStyle(color: AppColor.secondary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter')),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: AppColor.primarySoft,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                    isScrollControlled: true,
                    builder: (context) {
                      return LoginModal();
                    },
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Já tem uma conta? ',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Entrar',
                        style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
