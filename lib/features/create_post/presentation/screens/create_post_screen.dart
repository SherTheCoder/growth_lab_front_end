import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../feed/domain/models.dart';
import '../../../feed/presentation/providers/feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Alias to avoid conflict

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

  // CHANGED: List of files instead of single file
  List<File> _selectedImages = [];

  // CHANGED: Support picking multiple images
  Future<void> _pickImages() async {
    try {
      // 1. Pick multiple images
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        // 2. Compress them one by one
        List<File> compressedFiles = [];
        for (var xFile in pickedFiles) {
          File? compressed = await _compressFile(File(xFile.path));
          if (compressed != null) {
            compressedFiles.add(compressed);
          }
        }

        // 3. Update state
        if (compressedFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(compressedFiles);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  // Helper to compress images to avoid Server 413 Errors
  Future<File?> _compressFile(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final fileName =
        "upload_${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
    final targetPath = p.join(path, fileName);

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg, // Force JPEG
    );

    if (result == null) return null;
    return File(result.path);
  }

  void _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      List<String> uploadedUrls = [];
      PostContentType contentType = PostContentType.text;

      // 1. Upload Images if any
      if (_selectedImages.isNotEmpty) {
        final repo = ref.read(feedRepositoryProvider);

        // Upload all images in parallel
        uploadedUrls = await Future.wait(
            _selectedImages.map((file) => repo.uploadMedia(file)));

        // Determine content type
        contentType = uploadedUrls.length > 1
            ? PostContentType.carousel
            : PostContentType.image;
      }

      // 2. Create Post Object
      final draftPost = Post(
        id: '',
        // Backend generates ID
        author: user,
        content: text,
        type: contentType,
        mediaUrls: uploadedUrls,
        timestamp: DateTime.now(),
        isFollowing: true,
        comments: 0,
        upvotes: 0,
        reposts: 0,
        isLiked: false,
        isBookmarked: false,
      );

      // 3. Submit
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
        setState(() => _isPosting = false);
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
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blue),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _post,
              child: const Text("Post",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
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
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
              // Use theme text color,
              decoration: const InputDecoration(
                hintText: "What do you want to talk about?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              enabled: !_isPosting, // Disable input while posting
            ),
            // NEW: Image Preview Area
            // Inside build(), below the TextField:
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120, // Constrained height for preview strip
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Remove Button (X)
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const Spacer(),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImages, // Correct function call
                  icon: const Icon(Icons.image, color: Colors.blue, size: 28),
                ),
                IconButton(
                  onPressed: () {
                    // Placeholder for Video
                  },
                  icon:
                      const Icon(Icons.videocam, color: Colors.blue, size: 30),
                ),
                const Spacer(),
                const Text(
                  "Anyone",
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
