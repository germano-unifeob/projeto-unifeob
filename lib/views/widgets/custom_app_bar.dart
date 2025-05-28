import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartchef/views/utils/AppColor.dart';
import 'package:smartchef/views/screens/auth/welcome_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final bool showProfilePhoto;
  final ImageProvider? profilePhoto;
  final VoidCallback? profilePhotoOnPressed;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    required this.title,
    required this.showProfilePhoto,
    this.profilePhoto,
    this.profilePhotoOnPressed,
    this.actions,
    this.leading,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: leading ??
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
      title: title,
      actions: [
        if (actions != null) ...actions!,
        if (showProfilePhoto)
          Container(
            margin: const EdgeInsets.only(right: 16),
            alignment: Alignment.center,
            child: IconButton(
              onPressed: profilePhotoOnPressed,
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                  image: profilePhoto != null
                      ? DecorationImage(image: profilePhoto!, fit: BoxFit.cover)
                      : null,
                ),
                child: profilePhoto == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
