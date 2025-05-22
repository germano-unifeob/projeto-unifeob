import 'package:flutter/material.dart';
import 'package:hungry/views/screens/page_switcher.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/services/api_service.dart'; // ajuste o import conforme sua estrutura

class LoginModal extends StatefulWidget {
  @override
  _LoginModalState createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;

  void _login() async {
  if (!_formKey.currentState!.validate()) return;

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
    await prefs.setInt('user_id', userId); // <-- Adicione esta linha

    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => PageSwitcher()));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login inválido!')),
    );
  }
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              physics: BouncingScrollPhysics(),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 35 / 100,
                    margin: EdgeInsets.only(bottom: 20),
                    height: 6,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                // header
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                  ),
                ),
                // Form
                CustomTextField(
                  title: 'Email', 
                  hint: 'youremail@email.com',
                  controller: _emailController,
                  // adicionar validador se quiser
                ),
                CustomTextField(
                  title: 'Senha',
                  hint: '**********',
                  controller: _senhaController,
                  obscureText: true,
                  margin: EdgeInsets.only(top: 16),
                  // adicionar validador se quiser
                ),
                // Log in Button
                Container(
                  margin: EdgeInsets.only(top: 32, bottom: 6),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text('Login', style: TextStyle(color: AppColor.secondary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter')),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: AppColor.primarySoft,
                        ),
                      ),
                ),
                // ... esqueci senha, etc.
              ],
            ),
          ),
        )
      ],
    );
  }
}
