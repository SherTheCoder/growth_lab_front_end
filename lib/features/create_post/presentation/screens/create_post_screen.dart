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
  bool _isPosting = false; // Local state to track loading

  void _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      // Create a temporary Post object to carry the data.
      // The Backend will ignore the ID, Timestamp, and Author fields and generate real ones.
      final draftPost = Post(
        id: '', // Ignored by Repo
        author: user, // Ignored by Repo (Backend uses token to identify author)
        content: text,
        type: PostContentType.text,
        timestamp: DateTime.now(), // Ignored by Repo
        isFollowing: true,
      );

      // Call Provider (which calls Repository -> API)
      await ref.read(feedProvider.notifier).addPost(draftPost);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Posted successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to post: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
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
          // Show Spinner if posting, otherwise show Button
          if (_isPosting)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _post,
              child: const Text(
                  "Post",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)
              ),
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
              enabled: !_isPosting, // Disable input while posting
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