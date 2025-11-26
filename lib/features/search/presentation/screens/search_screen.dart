import 'package:flutter/material.dart';
import '../../../feed/domain/models.dart';
import '../../../profile/presentation/screens/other_user_profile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock suggested accounts
    final suggestions = [
      const User(id: 's1', name: 'Maximilian Werner', username: '@maximilian', avatarUrl: 'https://i.pravatar.cc/150?u=max', headline: 'Founder of INSPIRED', location: 'Switzerland', isVerified: true),
      const User(id: 's2', name: 'Franziska Heyde', username: '@franziska', avatarUrl: 'https://i.pravatar.cc/150?u=fran', headline: 'Founder of With All Your Heart', location: 'Germany', isVerified: true),
      const User(id: 's3', name: 'Impact Radar', username: '@impactradar', avatarUrl: 'https://i.pravatar.cc/150?u=impact', headline: 'Community', location: 'Germany'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Accounts, topics, keywords...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Suggested accounts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey[800]),
              itemBuilder: (context, index) {
                final user = suggestions[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OtherUserProfileScreen(user: user))
                    );
                  },
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                  title: Row(
                    children: [
                      Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      if (user.isVerified) const Icon(Icons.verified, size: 14, color: Colors.blue),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username, style: const TextStyle(color: Colors.grey)),
                      Text(user.headline, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Follow", style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}