import 'package:flutter/material.dart';
import 'package:smartchef/models/core/recipe.dart';

class ingredientTile extends StatelessWidget {
  final ingredient data;
  ingredientTile({required this.data});

  @override
Widget build(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey[350]!, width: 1)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 9,
          child: Text(
            data.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Text(
            data.size,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'inter',
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    ),
  );
}
}
