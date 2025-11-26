import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../feed/domain/models.dart';
import '../../domain/chat_models.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final User otherUser;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.otherUser,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;

    // 1. Send Message via Provider
    ref.read(chatThreadProvider(widget.conversationId).notifier).sendMessage(
      currentUser.id,
      content,
    );

    _textController.clear();

    // 2. Scroll to bottom (optional, as the list is reversed)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authProvider).value;
    final messagesState = ref.watch(chatThreadProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.otherUser.avatarUrl),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "@${widget.otherUser.username.replaceAll('@', '')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "Start a conversation with ${widget.otherUser.name}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  );
                }

                // Reverse List View so latest messages are at the bottom
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Key for chat apps
                  padding: const EdgeInsets.all(16),
                  // We reverse the list rendering because the ListView is reversed
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Riverpod returns latest last, but ListView.reverse expects latest first (at index 0)
                    // So we must access the list from end to start
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == currentUser?.id;

                    return _MessageBubble(message: message, isMe: isMe, theme: theme);
                  },
                );
              },
              error: (e, _) => Center(child: Text("Error: $e")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[900]!, width: 0.5)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Message...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final ThemeData theme;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}