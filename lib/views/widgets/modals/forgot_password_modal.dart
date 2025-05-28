import 'package:flutter/material.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/custom_text_field.dart';
import 'package:smartchef/services/api_service.dart';

class ForgotPasswordModal extends StatefulWidget {
  @override
  _ForgotPasswordModalState createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _formKey = GlobalKey<FormState>();

  int _step = 1; // 1 = email/telefone, 2 = token, 3 = nova senha
  bool _loading = false;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tokenController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();

  void _enviarToken() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final response = await ApiService.sendRecoveryToken({
      'email': _emailController.text,
      'telefone': _phoneController.text,
    });

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      setState(() => _step = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar token')),
      );
    }
  }

  void _verificarToken() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 3);
  }

  void _redefinirSenha() async {
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    setState(() => _loading = true);

    final response = await ApiService.resetPassword({
      'phone': _phoneController.text,
      'token': _tokenController.text,
      'new_password': _senhaController.text,
    });

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha alterada com sucesso!')),
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao redefinir senha')),
      );
    }
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    margin: EdgeInsets.only(bottom: 20),
                    height: 6,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                Text(
                  _step == 1
                      ? 'Recuperar Senha'
                      : _step == 2
                          ? 'Verificar Código'
                          : 'Nova Senha',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'inter'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                if (_step == 1) ...[
                  CustomTextField(
                    title: 'E-mail',
                    hint: 'youremail@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Informe o e-mail' : null,
                  ),
                  CustomTextField(
                    title: 'Telefone (+55...)',
                    hint: '+55...',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
                    margin: EdgeInsets.only(top: 16),
                  ),
                ] else if (_step == 2) ...[
                  Text(
                    'Enviamos um código para o número:\n${_phoneController.text}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  CustomTextField(
                    title: 'Código recebido',
                    hint: '6 dígitos',
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Digite o código' : null,
                    margin: EdgeInsets.only(top: 16),
                  ),
                ] else if (_step == 3) ...[
                  CustomTextField(
                    title: 'Nova Senha',
                    hint: '********',
                    controller: _senhaController,
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  CustomTextField(
                    title: 'Confirmar Senha',
                    hint: '********',
                    controller: _confirmarController,
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? 'Confirme a senha' : null,
                    margin: EdgeInsets.only(top: 16),
                  ),
                ],

                SizedBox(height: 24),
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _step == 1
                            ? _enviarToken
                            : _step == 2
                                ? _verificarToken
                                : _redefinirSenha,
                        child: Text(
                          _step == 1
                              ? 'Enviar código'
                              : _step == 2
                                  ? 'Continuar'
                                  : 'Salvar nova senha',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primarySoft,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(double.infinity, 50),
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
