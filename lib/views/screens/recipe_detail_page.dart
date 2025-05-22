import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/full_screen_image.dart';
import 'package:hungry/views/utils/AppColor.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe data;
  RecipeDetailPage({required this.data});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });
  }

  Color appBarColor = Colors.transparent;

  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('==== [RecipeDetailPage] widget.data.ingredientsString:');
    print(widget.data.ingredientsString);
    print('==== [RecipeDetailPage] widget.data.steps:');
    print(widget.data.steps);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Detalhe da Receita', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/icons/bookmark.svg', color: Colors.white)),
            ], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          // Imagem
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                      image: (widget.data.photo.isNotEmpty)
                          ? (widget.data.photo.startsWith('http')
                              ? Image.network(widget.data.photo, fit: BoxFit.cover)
                              : Image.asset(widget.data.photo, fit: BoxFit.cover))
                          : Image.asset('assets/images/placeholder_recipe.png', fit: BoxFit.cover)) ));
            },
            child: Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: (widget.data.photo.isNotEmpty)
                    ? (widget.data.photo.startsWith('http')
                        ? NetworkImage(widget.data.photo)
                        : AssetImage(widget.data.photo) as ImageProvider)
                    : AssetImage('assets/images/placeholder_recipe.png'),
                fit: BoxFit.cover,
              )),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          // Info da Receita
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorias e tempo
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/fire-filled.svg',
                      color: Colors.white,
                      width: 16,
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.calories.isNotEmpty ? '${widget.data.calories} cal' : '',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.alarm, size: 16, color: Colors.white),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.time.isNotEmpty ? '${widget.data.time} min' : '',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Título
                Container(
                  margin: EdgeInsets.only(bottom: 12, top: 16),
                  child: Text(
                    widget.data.title,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                  ),
                ),
                // Descrição
                Text(
                  widget.data.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 150 / 100),
                ),
              ],
            ),
          ),
          // TabBar (Ingredientes, Tutorial)
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _tabController.index = index;
                });
              },
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.6),
              labelStyle: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w500),
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Ingredientes'),
                Tab(text: 'Tutorial'),
              ],
            ),
          ),
          // Conteúdo das Abas (simples, direto do banco)
          Container(
            height: 250,
            child: IndexedStack(
              index: _tabController.index,
              children: [
                // Ingredientes direto como texto
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    widget.data.ingredientsString?.trim().isNotEmpty == true
                        ? widget.data.ingredientsString!
                        : 'Ingredientes não disponíveis.',
                    style: TextStyle(fontSize: 14, fontFamily: 'inter'),
                  ),
                ),
                // Passos direto como texto
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    widget.data.steps?.trim().isNotEmpty == true
                        ? widget.data.steps!
                        : 'Modo de preparo não disponível.',
                    style: TextStyle(fontSize: 14, fontFamily: 'inter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
