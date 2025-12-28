import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Required to parse server responses

import 'package:dio/dio.dart';

String getUserFriendlyErrorMessage(Object error) {
  // 1. Handle DioException (The Server Response)
  if (error is DioException) {
    final response = error.response;

    if (response != null) {
      // HANDLE 422 (Validation Error) specifically
      if (response.statusCode == 422) {
        final data = response.data;

        // Try to find the specific field error
        if (data is Map<String, dynamic>) {
          // Common format: {"detail": [{"loc": ["body", "email"], "msg": "value is not a valid email address"}]}
          if (data['detail'] is List && (data['detail'] as List).isNotEmpty) {
            final firstError = (data['detail'] as List).first;
            if (firstError is Map && firstError.containsKey('msg')) {
              return firstError['msg']; // Returns "value is not a valid email address"
            }
          }
          // Common format: {"email": ["The email has already been taken."]}
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstKey = errors.keys.first;
              return "${errors[firstKey][0]}"; // Returns "The email has already been taken"
            }
          }
          // Fallback if we have a simple message
          if (data['message'] != null) return data['message'];
        }
        return "Please check your input details and try again.";
      }

      // Handle other specific codes...
      if (response.statusCode == 400) return "This account already exists. Please log in.";
      if (response.statusCode == 409) return "This account already exists. Please log in.";
      if (response.statusCode == 401) return "Incorrect email or password.";
      if (response.statusCode == 403) return "Access denied.";
      if (response.statusCode == 429) return "Too many requests. Please wait a bit.";
      if (response.statusCode! >= 500) return "Server error. Please try again later.";
    }
  }

  // 2. Fallback for String parsing (Only if Step 1 didn't catch it)
  // This catches the "Exception: Signup failed..." case if you CANNOT fix the repository.
  final rawError = error.toString().toLowerCase();

  if (rawError.contains("422")) return "Invalid input. Please check your details.";
  if (rawError.contains("409")) return "Account already exists.";
  if (rawError.contains("socket") || rawError.contains("connection")) return "No internet connection.";

  return "An unexpected error occurred. Please try again.";
}

void showResultDialog(
    BuildContext context, {
      required String title,
      required String message,
      required bool isError,
      VoidCallback? onPressed,
    }) {
  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;

  // Determine colors based on state
  final statusColor = isError ? Colors.redAccent : primaryColor;
  final icon = isError ? Icons.close_rounded : Icons.check_rounded;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. The "Glowing" Icon Bubble
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1), // Subtle background tint
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Centered Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Centered Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // 4. Full-Width Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Okay",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}