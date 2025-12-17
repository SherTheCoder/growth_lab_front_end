import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../feed/domain/models.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'dart:io';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  bool _isPosting = false; // Local state to track loading
  final ImagePicker _picker = ImagePicker(); // Image Picker instance
  File? _selectedImage; // State to hold the selected file

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      List<String> uploadedUrls = [];
      PostContentType contentType = PostContentType.text;

      // 1. Upload Image if exists
      if (_selectedImage != null) {
        // Call the upload method we just created in the repo
        // We access the repo via the provider's valid ref
        final repo = ref.read(feedRepositoryProvider);
        final url = await repo.uploadMedia(_selectedImage!);
        uploadedUrls.add(url);
        contentType = PostContentType.image;
      }
      // Create a temporary Post object to carry the data.
      // The Backend will ignore the ID, Timestamp, and Author fields and generate real ones.

      final draftPost = Post(
        id: '',
        author: user,
        content: text,
        type: contentType, // Set type based on content
        mediaUrls: uploadedUrls, // Pass the backend URL here
        timestamp: DateTime.now(),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18), // Use theme text color,
              decoration: const InputDecoration(
                hintText: "What do you want to talk about?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              enabled: !_isPosting, // Disable input while posting
            ),
            // NEW: Image Preview Area
            if (_selectedImage != null)
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: double.infinity,
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              const Spacer(),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage, // Hooked up the picker
                  icon: const Icon(Icons.image, color: Colors.blue),
                ),
                IconButton(
                    onPressed: () {
                      // Logic for video can be added similarly later
                    },
                    icon: const Icon(Icons.videocam, color: Colors.blue)
                ),
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