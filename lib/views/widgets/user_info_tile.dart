import 'package:flutter/material.dart';
import 'package:hungry/views/utils/AppColor.dart';

class UserInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? valueBackground;

  const UserInfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.margin,
    this.padding,
    this.valueBackground,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('$label', style: TextStyle(color: AppColor.primary, fontSize: 12)),
          ),
          Container(
            margin: EdgeInsets.only(top: 6),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            color: valueBackground ?? AppColor.primaryExtraSoft,
            child: Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'inter')),
          )
        ],
      ),
    );
  }
}
