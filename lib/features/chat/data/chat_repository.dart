import '../domain/chat_models.dart';
import 'package:growth_lab/core/models/user_model.dart';

// --- MOCK DATA ---
final List<Conversation> _globalConversations = [];
final Map<String, List<Message>> _globalMessages = {};

class ChatRepository {

  Future<List<Conversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _globalConversations.sort((a, b) {
      if (a.lastMessage == null) return 1;
      if (b.lastMessage == null) return -1;
      return b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp);
    });
    return List.from(_globalConversations);
  }

  Future<List<Message>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_globalMessages[conversationId] ?? []);
  }

  Future<Message> sendMessage(String conversationId, String senderId, String content) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // 1. Add to message history
    if (!_globalMessages.containsKey(conversationId)) {
      _globalMessages[conversationId] = [];
    }
    _globalMessages[conversationId]!.add(newMessage);

    // 2. Update the Conversation (Inbox) Snippet
    final index = _globalConversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _globalConversations[index] = _globalConversations[index].copyWith(
        lastMessage: newMessage,
        unreadCount: 0,
      );
    }

    return newMessage;
  }

  // --- UPDATED: Creates the conversation in memory so Inbox sees it ---
  Future<String> getOrCreateConversation(User currentUser, User otherUser) async {
    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Check if we already have a conversation with this participant
    try {
      final existing = _globalConversations.firstWhere((c) =>
          c.participants.any((u) => u.id == otherUser.id)
      );
      return existing.id;
    } catch (e) {
      // 2. If not, create a new Conversation object and add to global list
      final newId = "conv_${currentUser.id}_${otherUser.id}";

      final newConversation = Conversation(
        id: newId,
        participants: [currentUser, otherUser],
        unreadCount: 0,
        lastMessage: null, // No message yet
      );

      _globalConversations.add(newConversation);
      return newId;
    }
  }
}