

class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String headline;
  final String location;
  final bool isVerified;
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.headline,
    required this.location,
    this.isVerified = false,
  });

  // --- ADD THIS ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] ?? '', // Handle nulls safely
      headline: json['headline'] ?? '',
      location: json['location'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar_url': avatarUrl,
      'headline': headline,
      'location': location,
      'is_verified': isVerified,
    };
  }

}