import 'package:flutter/material.dart';

class SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final Color? color;

  const SmallAction({required this.icon, required this.label, required this.theme, this.color});

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? Colors.grey;
    return Row(
      children: [
        Icon(icon, size: 18, color: finalColor),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: finalColor, fontSize: 12)),
        ]
      ],
    );
  }
}