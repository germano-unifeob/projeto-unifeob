// Tela de login com tratamento direto de código 404 para usuário não encontrado
import 'package:flutter/material.dart';
import 'package:smartchef/views/screens/page_switcher.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/services/api_service.dart';
import 'forgot_password_modal.dart';

class LoginModal extends StatefulWidget {
  @override
  _LoginModalState createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;
  String? erroMensagem;

  void _login() async {
    setState(() {
      erroMensagem = null;
    });

    if (_emailController.text.trim().isEmpty || _senhaController.text.isEmpty) {
      setState(() {
        erroMensagem = 'Preencha todos os campos';
      });
      return;
    }

    setState(() => _loading = true);

    final response = await ApiService.login({
      'email': _emailController.text,
      'senha': _senhaController.text,
    });

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final responseData = jsonDecode(response.body);

      final token = responseData['token'];
      final userId = responseData['user_id'];

      await prefs.setString('auth_token', token);
      await prefs.setInt('user_id', userId);

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PageSwitcher()),
      );
    } else {
      try {
        final body = jsonDecode(response.body);
        final msg = body['message']?.toString().toLowerCase();

        if (response.statusCode == 404) {
          setState(() => erroMensagem = 'Usuário não encontrado. Você já tem uma conta?');
        } else if (msg != null && msg.contains('senha')) {
          setState(() => erroMensagem = 'Senha inválida');
        } else {
          setState(() => erroMensagem = null);
        }
      } catch (_) {
        setState(() => erroMensagem = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'inter',
                    ),
                  ),
                ),
                if (erroMensagem != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, left: 8),
                    child: Text(
                      erroMensagem!,
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                CustomTextField(
                  title: 'Email',
                  hint: 'youremail@email.com',
                  controller: _emailController,
                ),
                CustomTextField(
                  title: 'Senha',
                  hint: '**********',
                  controller: _senhaController,
                  obscureText: true,
                  margin: EdgeInsets.only(top: 16),
                ),
                Container(
                  margin: EdgeInsets.only(top: 32, bottom: 6),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: _loading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: AppColor.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppColor.primarySoft,
                          ),
                        ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ForgotPasswordModal(),
                      );
                    },
                    child: Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}