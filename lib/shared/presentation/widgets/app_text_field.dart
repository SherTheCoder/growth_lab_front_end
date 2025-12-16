import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool isPassword;
  final IconData? suffixIcon;
  final String? hint;
  final int? maxLines;

  const AppTextField({super.key, required this.controller, required this.isPassword, this.suffixIcon,this.label, this.hint, this.maxLines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines ?? 1,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.hintColor),
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: theme.iconTheme.color) : null,
      ),
    );
  }
}
