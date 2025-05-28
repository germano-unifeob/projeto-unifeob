import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/widgets/user_info_tile.dart';
import 'package:smartchef/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool carregando = true;
  bool isEditing = false;

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  int? estiloIdSelecionado;
  int? nivelIdSelecionado;

  List<Map<String, dynamic>> estilos = [];
  List<Map<String, dynamic>> niveis = [];

  File? _imagemSelecionada;

  @override
  void initState() {
    super.initState();
    carregarCamposFixos();
    carregarPerfil();
  }

  Future<void> carregarCamposFixos() async {
    estilos = await ApiService.getEstilosVida();
    niveis = await ApiService.getNiveisExperiencia();
    setState(() {});
  }

  Future<void> carregarPerfil() async {
    final perfil = await ApiService.getUserProfile();
    if (perfil != null) {
      setState(() {
        user = perfil;
        nomeController.text = perfil['nome'] ?? '';
        telefoneController.text = perfil['telefone'] ?? '';
        estiloIdSelecionado = perfil['estilo_vida_id'];
        nivelIdSelecionado = perfil['nivel_experiencia_id'];
        carregando = false;
      });
    } else {
      setState(() => carregando = false);
    }
  }

  Future<void> salvarPerfil() async {
    final success = await ApiService.updateUserProfile({
      'nome': nomeController.text,
      'telefone': telefoneController.text,
      'estilo_vida_id': estiloIdSelecionado,
      'nivel_experiencia_id': nivelIdSelecionado,
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      await carregarPerfil();
      setState(() => isEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil')),
      );
    }
  }

  Future<void> selecionarImagem() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
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
        title: Text('My Profile',
            style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? 'Cancelar' : 'Editar',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : user == null
              ? Center(child: Text('Erro ao carregar perfil.'))
              : ListView(
                  children: [
                    Container(
                      color: AppColor.primary,
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: GestureDetector(
                        onTap: selecionarImagem,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              margin: EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  image: _imagemSelecionada != null
                                      ? FileImage(_imagemSelecionada!)
                                      : AssetImage('assets/images/profile.jpg') as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Change Profile Picture',
                                    style: TextStyle(
                                        fontFamily: 'inter',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                SizedBox(width: 8),
                                SvgPicture.asset('assets/icons/camera.svg', color: Colors.white),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        children: [
                          isEditing
                              ? TextField(
                                  controller: nomeController,
                                  decoration: InputDecoration(labelText: 'Nome'),
                                )
                              : UserInfoTile(label: 'Nome', value: user!['nome'] ?? ''),
                          SizedBox(height: 16),
                          isEditing
                              ? TextField(
                                  controller: telefoneController,
                                  decoration: InputDecoration(labelText: 'Telefone'),
                                )
                              : UserInfoTile(label: 'Telefone', value: user!['telefone'] ?? ''),
                          SizedBox(height: 16),
                          isEditing
                              ? DropdownButtonFormField<int>(
                                  value: estiloIdSelecionado,
                                  items: estilos
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e['id'] as int,
                                            child: Text(e['name'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (value) => setState(() => estiloIdSelecionado = value),
                                  decoration: InputDecoration(labelText: 'Estilo de Vida'),
                                )
                              : UserInfoTile(label: 'Estilo de Vida', value: user!['estilo_vida'] ?? ''),
                          SizedBox(height: 16),
                          isEditing
                              ? DropdownButtonFormField<int>(
                                  value: nivelIdSelecionado,
                                  items: niveis
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e['id'] as int,
                                            child: Text(e['name'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (value) => setState(() => nivelIdSelecionado = value),
                                  decoration: InputDecoration(labelText: 'Nível de Experiência'),
                                )
                              : UserInfoTile(
                                  label: 'Nível de Experiência',
                                  value: user!['nivel_experiencia'] ?? ''),
                          SizedBox(height: 32),
                          if (isEditing)
                            ElevatedButton(
                              onPressed: salvarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Salvar Alterações'),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
  