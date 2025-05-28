import 'package:flutter/material.dart';
import 'package:smartchef/views/utils/AppColor.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? errorText;

  const CustomTextField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.padding,
    this.margin,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.zero,
      margin: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.primaryExtraSoft,
              borderRadius: BorderRadius.circular(10),
              border: errorText != null
                  ? Border.all(color: Colors.redAccent)
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              style: const TextStyle( fontSize: 14),
              cursorColor: AppColor.primary,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                contentPadding: const EdgeInsets.only(left: 16),
                border: InputBorder.none,
                errorText: errorText,
                errorStyle:TextStyle(color: Colors.redAccent, fontSize: 12)
              ),
            ),
          ),
        ],
      ),
    );
  }
}