import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:smartchef/views/screens/page_switcher.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/custom_text_field.dart';
import 'package:smartchef/views/widgets/modals/login_modal.dart';
import '/services/api_service.dart';
import 'dart:convert';

class RegisterModal extends StatefulWidget {
  @override
  _RegisterModalState createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final alergiaController = TextEditingController();

  int? estiloVidaId;
  int? nivelExperienciaId;
  List<Map<String, dynamic>> selectedAlergias = [];
  bool isLoading = false;

  List<Map<String, dynamic>> estilosVida = [];
  List<Map<String, dynamic>> niveisExperiencia = [];

  String? erroSenha;
  String? erroTelefone;
  String? erroEmail;
  String? erroConfirmacao;
  String? erroNome;
  String? erroEstiloVida;
  String? erroExperiencia;

  final senhaForteRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\\$&*~])(?=.*[0-9]).{6,}$');
  final telefoneRegex = RegExp(r'^(\+55)?[\s-]?(\d{2})[\s-]?[\s-9]?(\d{4})[\s-]?(\d{4})$');
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    alergiaController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final estilos = await ApiService.getEstilosVida();
      final niveis = await ApiService.getNiveisExperiencia();
      setState(() {
        estilosVida = estilos;
        niveisExperiencia = niveis;
      });
    } catch (e) {
      mostrarErro('Erro ao carregar opções: $e');
    }
  }

  void _limparErros() {
    setState(() {
      erroEmail = null;
      erroTelefone = null;
      erroSenha = null;
      erroConfirmacao = null;
      erroNome = null;
      erroEstiloVida = null;
      erroExperiencia = null;
    });
  }

  bool validarCampos() {
    _limparErros();

    final email = emailController.text.trim();
    final telefone = phoneController.text.trim();
    final senha = passwordController.text;
    final confirmacao = confirmPasswordController.text;
    final nome = nameController.text.trim();

    bool isValid = true;

    if (nome.isEmpty) {
      setState(() => erroNome = 'Nome completo é obrigatório');
      isValid = false;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() => erroEmail = 'Email inválido. Exemplo: usuario@dominio.com');
      isValid = false;
    }

    if (!telefoneRegex.hasMatch(telefone)) {
      setState(() => erroTelefone = 'Use o formato +55 (DD) 9XXXX-XXXX');
      isValid = false;
    }

    if (!senhaForteRegex.hasMatch(senha)) {
      setState(() => erroSenha = 'Mín. 6 caracteres, 1 maiúscula, 1 número e 1 caractere especial');
      isValid = false;
    }

    if (confirmacao != senha) {
      setState(() => erroConfirmacao = 'As senhas não coincidem');
      isValid = false;
    }

    if (estiloVidaId == null) {
      setState(() => erroEstiloVida = 'Selecione um estilo de vida');
      isValid = false;
    }

    if (nivelExperienciaId == null) {
      setState(() => erroExperiencia = 'Selecione um nível de experiência');
      isValid = false;
    }

    return isValid;
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            physics: BouncingScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Text(
                'Cadastrar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'inter',
                ),
              ),
              SizedBox(height: 24),
              CustomTextField(
                title: 'Email',
                hint: 'seuemail@exemplo.com',
                controller: emailController,
                errorText: erroEmail,
                onChanged: (value) {
                  if (erroEmail != null && emailRegex.hasMatch(value.trim())) {
                    setState(() => erroEmail = null);
                  }
                },
              ),
              CustomTextField(
                title: 'Nome completo',
                hint: 'Seu nome',
                controller: nameController,
                errorText: erroNome,
                margin: EdgeInsets.only(top: 16),
                onChanged: (value) {
                  if (erroNome != null && value.trim().isNotEmpty) {
                    setState(() => erroNome = null);
                  }
                },
              ),
              CustomTextField(
                title: 'Telefone',
                hint: '+55 (DD) 9XXXX-XXXX',
                controller: phoneController,
                errorText: erroTelefone,
                margin: EdgeInsets.only(top: 16),
                onChanged: (value) {
                  if (erroTelefone != null && telefoneRegex.hasMatch(value.trim())) {
                    setState(() => erroTelefone = null);
                  }
                },
              ),
              CustomTextField(
                title: 'Senha',
                hint: '**********',
                controller: passwordController,
                obscureText: true,
                errorText: erroSenha,
                margin: EdgeInsets.only(top: 16),
                onChanged: (value) {
                  if (erroSenha != null && senhaForteRegex.hasMatch(value)) {
                    setState(() => erroSenha = null);
                  }
                },
              ),
              CustomTextField(
                title: 'Repita a senha',
                hint: '**********',
                controller: confirmPasswordController,
                obscureText: true,
                errorText: erroConfirmacao,
                margin: EdgeInsets.only(top: 16),
                onChanged: (value) {
                  if (erroConfirmacao != null && value == passwordController.text) {
                    setState(() => erroConfirmacao = null);
                  }
                },
              ),
              SizedBox(height: 16),
              _buildDropdown(
                "Estilo de vida",
                estilosVida,
                estiloVidaId,
                (val) {
                  setState(() {
                    estiloVidaId = val;
                    if (erroEstiloVida != null) erroEstiloVida = null;
                  });
                },
                errorText: erroEstiloVida,
              ),
              SizedBox(height: 16),
              _buildDropdown(
                "Nível de experiência",
                niveisExperiencia,
                nivelExperienciaId,
                (val) {
                  setState(() {
                    nivelExperienciaId = val;
                    if (erroExperiencia != null) erroExperiencia = null;
                  });
                },
                errorText: erroExperiencia,
              ),
              SizedBox(height: 16),
              _buildAlergiasField(),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();
                        
                        setState(() => isLoading = true);
                        
                        if (!validarCampos()) {
                          setState(() => isLoading = false);
                          return;
                        }

                        final userData = {
                          'email': emailController.text.trim(),
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'password': passwordController.text,
                          'lifestyle_id': estiloVidaId,
                          'experience_level_id': nivelExperienciaId,
                          'allergy_ids': selectedAlergias.map((a) => a['id']).toList(),
                        };

                        try {
                          final response = await ApiService.registerUser(userData);
                          final responseData = json.decode(response.body);
                          
                          if (response.statusCode == 201) {
                            mostrarSucesso('Cadastro realizado com sucesso!');
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => PageSwitcher()),
                            );
                          } else {
                            mostrarErro(responseData['message'] ?? 'Erro ao realizar cadastro');
                          }
                        } catch (e) {
                          mostrarErro('Erro de conexão: ${e.toString()}');
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primarySoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 60),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColor.secondary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Registrar',
                        style: TextStyle(
                          color: AppColor.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => LoginModal(),
                        );
                      },
                child: RichText(
                  text: TextSpan(
                    text: 'Já tem uma conta? ',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Entrar',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<Map<String, dynamic>> items,
    int? value,
    ValueChanged<int?> onChanged, {
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(label, style: TextStyle(color: Colors.grey)),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.primaryExtraSoft,
            borderRadius: BorderRadius.circular(10),
            border: errorText != null
                ? Border.all(color: Colors.redAccent, width: 1)
                : null,
          ),
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: InputBorder.none,
              errorText: errorText,
              errorStyle: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
            value: value,
            items: items
                .map((item) => DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(item['name']),
                    ))
                .toList(),
            onChanged: onChanged,
            hint: Text('Selecione'),
          ),
        ),
      ],
    );
  }

  Widget _buildAlergiasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('Alergias', style: TextStyle(color: Colors.grey)),
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
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion['name']),
                ),
                onSuggestionSelected: (suggestion) {
                  if (!selectedAlergias.any((a) => a['id'] == suggestion['id'])) {
                    setState(() {
                      selectedAlergias.add(suggestion);
                      alergiaController.clear();
                    });
                  }
                },
              ),
              if (selectedAlergias.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 6,
                    children: selectedAlergias.map((alergia) {
                      return Chip(
                        label: Text(alergia['name']),
                        backgroundColor: Colors.orange.shade100,
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () => setState(
                            () => selectedAlergias.remove(alergia)),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}