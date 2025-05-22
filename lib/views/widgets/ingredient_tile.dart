import 'package:flutter/material.dart';
import 'package:hungry/models/core/recipe.dart';

class ingredientTile extends StatelessWidget {
  final ingredient data;
  ingredientTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[350]!, width: 1)),
      ),
      // O child deve vir AQUI, e não dentro de decoration
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              data.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (data.size.isNotEmpty) ...[
            SizedBox(width: 8),
            Text(
              data.size,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
