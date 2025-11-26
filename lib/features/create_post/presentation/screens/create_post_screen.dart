import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../feed/domain/models.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();

  void _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    // Create the Post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: user,
      content: text,
      type: PostContentType.text,
      timestamp: DateTime.now(),
      isFollowing: true, // IMPORTANT: Set true so it appears in "Following" tab
    );

    // Call Provider
    await ref.read(feedProvider.notifier).addPost(newPost);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Posted successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _post,
            child: const Text("Post", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "What do you want to talk about?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.image, color: Colors.blue)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.videocam, color: Colors.blue)),
                const Spacer(),
                const Text("Anyone", style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}