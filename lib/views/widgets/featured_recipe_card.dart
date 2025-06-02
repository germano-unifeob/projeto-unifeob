import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartchef/models/core/recipe.dart';
import 'package:smartchef/views/screens/recipe_detail_page.dart';
import 'package:translator/translator.dart';

class FeaturedRecipeCard extends StatefulWidget {
  final Recipe data;
  FeaturedRecipeCard({required this.data});

  @override
  State<FeaturedRecipeCard> createState() => _FeaturedRecipeCardState();
}

class _FeaturedRecipeCardState extends State<FeaturedRecipeCard> {
  String translatedTitle = '';
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _translateTitle();
  }

  Future<void> _translateTitle() async {
    try {
      final translation = await translator.translate(widget.data.title, from: 'en', to: 'pt');
      setState(() {
        translatedTitle = translation.text;
      });
    } catch (_) {
      setState(() {
        translatedTitle = widget.data.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RecipeDetailPage(data: widget.data)),
        );
      },
      child: Container(
        width: 190,
        height: 220,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: (widget.data.photo.isNotEmpty)
                ? (widget.data.photo.startsWith('http')
                    ? NetworkImage(widget.data.photo)
                    : AssetImage(widget.data.photo) as ImageProvider)
                : AssetImage('assets/images/placeholder_recipe.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              height: 80,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withOpacity(0.26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      translatedTitle.isNotEmpty ? translatedTitle : widget.data.title,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/fire-filled.svg',
                          color: Colors.white,
                          width: 12,
                          height: 12,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.data.calories.isNotEmpty ? '${widget.data.calories} cal' : '',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.alarm, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.data.time.isNotEmpty ? '${widget.data.time} min' : '',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
