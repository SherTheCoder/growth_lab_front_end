import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/gradient_text.dart';

class GrowthLabTitle extends StatelessWidget {
  const GrowthLabTitle({super.key, required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Growth" - Solid Color (adapts to theme)
        Text(
          "Growth",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w800,
            // Extra Bold
            fontSize: 32,
            letterSpacing: -0.5,
            fontFamily: 'Roboto', // Or system default
          ),
        ),
        // "Lab" - Gradient (Teal to Gold)
        GradientText(
          "Lab",
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A7D79), // Teal
              Color(0xFFD4AF37), // Gold
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          style: TextStyle(
            fontWeight: FontWeight.w800, // Extra Bold
            fontSize: 32,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );

  }
}

