import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({super.key, required this.avatarUrl, this.radius = 20, this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(avatarUrl),
      backgroundColor: Colors.grey[800], // Fallback color
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: avatar)
        : avatar;
  }
}