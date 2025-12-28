import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  final String? imageUrl;

  const PostImageWidget({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Validation: If URL is missing, hide the widget completely
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        // 2. Constraints: Ensure image doesn't blow up the UI
        constraints: const BoxConstraints(
          maxHeight: 450,        // Cap the height for very tall images
          minHeight: 200,        // Ensure a minimum size
          minWidth: double.infinity,
        ),
        color: Colors.grey[200], // Subtle placeholder background

        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,

          // 3. Loading State: Shows a spinner while downloading
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },

          // 4. Error State: Shows a nice icon if 404/Offline
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    "Image unavailable",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}