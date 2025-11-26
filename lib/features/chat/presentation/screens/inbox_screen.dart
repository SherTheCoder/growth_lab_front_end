import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/chat_models.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxState = ref.watch(inboxProvider);
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Messages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: inboxState.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text("No messages yet", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () {
                        // Logic to start new chat (e.g. go to search)
                      },
                      child: const Text("Start a chat")
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => Divider(color: Colors.grey[900], height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              // Identify the "Other" user to display their name/avatar
              final otherUser = conversation.getOtherParticipant(currentUser?.id ?? "");
              final lastMsg = conversation.lastMessage;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                          conversationId: conversation.id,
                          otherUser: otherUser
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(otherUser.avatarUrl),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        otherUser.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lastMsg != null)
                      Text(
                        _formatTime(lastMsg.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
                subtitle: Text(
                  lastMsg?.content ?? "Started a conversation",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (conversation.unreadCount > 0) ? Colors.white : Colors.grey,
                    fontWeight: (conversation.unreadCount > 0) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: (conversation.unreadCount > 0)
                    ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: Text(
                      "${conversation.unreadCount}",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                )
                    : null,
              );
            },
          );
        },
        error: (e, _) => Center(child: Text("Error: $e")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return "${diff.inDays}d";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}h";
    } else {
      return "${diff.inMinutes}m";
    }
  }
}