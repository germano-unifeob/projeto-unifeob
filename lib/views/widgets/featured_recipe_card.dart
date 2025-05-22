import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/views/screens/recipe_detail_page.dart';

class FeaturedRecipeCard extends StatelessWidget {
  final Recipe data;
  FeaturedRecipeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RecipeDetailPage(data: data)),
        );
      },
      // Card Wrapper
      child: Container(
        width: 190, // um pouco maior pra ajudar no mobile/web
        height: 220,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: (data.photo.isNotEmpty)
                ? (data.photo.startsWith('http')
                    ? NetworkImage(data.photo)
                    : AssetImage(data.photo) as ImageProvider)
                : AssetImage('assets/images/placeholder_recipe.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Recipe Card Info
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
                  // Recipe Title
                  Flexible(
                    child: Text(
                      data.title,
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
                  // Recipe Calories and Time
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
                            data.calories.isNotEmpty ? '${data.calories} cal' : '',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.alarm, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            data.time.isNotEmpty ? '${data.time} min' : '',
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
