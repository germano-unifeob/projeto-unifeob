import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartchef/views/utils/AppColor.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 60, right: 60, bottom: 20),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            currentIndex: widget.selectedIndex,
            onTap: widget.onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: [
              widget.selectedIndex == 0
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/home-filled.svg', color: AppColor.primary),
                      label: '',
                    )
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/home.svg', color: Colors.grey[600]),
                      label: '',
                    ),
              widget.selectedIndex == 1
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/discover-filled.svg', color: AppColor.primary, height: 28, width: 26),
                      label: '',
                    )
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/discover.svg', color: Colors.grey[600], height: 28, width: 26),
                      label: '',
                    ),
              widget.selectedIndex == 2
                  ? BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bookmark-filled.svg', color: AppColor.primary),
                      label: '',
                    )
                  : BottomNavigationBarItem(
                      icon: SvgPicture.asset('assets/icons/bookmark.svg', color: Colors.grey[600]),
                      label: '',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
