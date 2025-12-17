class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String headline;
  final String location;
  final bool isVerified;
  // NEW FIELDS
  final String bio;
  final String websiteUrl;
  final int totalConnections;
  final int totalPosts;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.headline,
    required this.location,
    this.isVerified = false,
    this.bio = '',
    this.websiteUrl = '',
    this.totalConnections = 0,
    this.totalPosts = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final String first = json['firstName'] ?? '';
    final String last = json['lastName'] ?? '';
    final String fullName = '$first $last'.trim();

    return User(
      id: json['id']?.toString() ?? '',
      name: fullName.isNotEmpty ? fullName : 'User',
      username: json['emailAddress'] != null ? "@${json['emailAddress'].split('@')[0]}" : '',
      avatarUrl: json['avatarURL'] ?? '',
      headline: json['headline'] ?? '',
      location: json['location'] ?? '',
      isVerified: json['isVerified'] ?? false,
      // MAPPING NEW FIELDS
      bio: json['bio'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      totalConnections: json['totalConnections'] ?? 0,
      totalPosts: json['totalPosts'] ?? 0,
    );
  }
}