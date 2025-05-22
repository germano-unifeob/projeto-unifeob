import 'package:flutter/material.dart';
import 'package:hungry/views/utils/AppColor.dart';

class NewRecipeCard extends StatelessWidget {
  final VoidCallback onTap;

  const NewRecipeCard({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 170,
        height: 220,
        decoration: BoxDecoration(
          color: AppColor.primarySoft, // cor semelhante aos outros cards
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.13),
              blurRadius: 25,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.add,
                color: AppColor.primary,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nova Receita',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'inter',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
