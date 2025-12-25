import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  /// Optional: Pass a specific icon relevant to the missing feature
  final IconData icon;
  /// Optional: Pass a specific title
  final String title;
  /// Optional: Pass a specific subtitle description
  final String description;
  // Enabling this shows the go back button which pops the context
  final bool showGoBack;

  const ComingSoonScreen({
    Key? key,
    this.icon = Icons.rocket_launch_rounded, // Default cool icon
    this.title = "Coming Soon",
    this.description = "We are working hard to build something amazing for you. Stay tuned!",
    this.showGoBack = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Transparent AppBar just for the back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.iconTheme.color),
      ),
      // Extend body behind app bar so the background design fills the screen
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Visual Element (Subtle layered icon)
          Positioned(
            right: -100,
            bottom: -100,
            child: Icon(
              icon,
              size: 400,
              // Very faint color matching the background/theme
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
          ),

          // 2. Main Content Centered
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The "Glowing" Icon Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.1), // Subtle background tint
                      boxShadow: [
                        // The "Cool Glow" effect using theme primary color
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 60,
                          spreadRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 80,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Simple "Go Back" Button flowing with theme
                  if(showGoBack)
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                            "Go Back",
                            style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}