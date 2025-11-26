import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_models.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

// --- 1. INBOX PROVIDER ---
class InboxNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  final ChatRepository _repository;

  InboxNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      final chats = await _repository.fetchConversations();
      state = AsyncValue.data(chats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Helper to refresh the list without full reload
  void updateLastMessage(String conversationId, Message message) {
    state.whenData((conversations) {
      // Check if conversation exists in the current list
      final index = conversations.indexWhere((c) => c.id == conversationId);

      if (index != -1) {
        // Update existing
        final updatedList = conversations.map((c) {
          if (c.id == conversationId) {
            return c.copyWith(lastMessage: message);
          }
          return c;
        }).toList();

        updatedList.sort((a, b) {
          final timeA = a.lastMessage?.timestamp ?? DateTime(2000);
          final timeB = b.lastMessage?.timestamp ?? DateTime(2000);
          return timeB.compareTo(timeA);
        });

        state = AsyncValue.data(updatedList);
      } else {
        // If not in list (newly created), reload full list from repo to get the new Conversation object
        loadConversations();
      }
    });
  }
}

final inboxProvider = StateNotifierProvider<InboxNotifier, AsyncValue<List<Conversation>>>((ref) {
  return InboxNotifier(ref.watch(chatRepositoryProvider));
});


// --- 2. CHAT THREAD PROVIDER ---
class ChatThreadNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatRepository _repository;
  final String conversationId;
  final Ref ref; // Needed to talk to other providers

  ChatThreadNotifier(this._repository, this.conversationId, this.ref) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      final messages = await _repository.fetchMessages(conversationId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String senderId, String content) async {
    try {
      final newMessage = await _repository.sendMessage(conversationId, senderId, content);

      // 1. Update this thread UI
      state.whenData((messages) {
        state = AsyncValue.data([...messages, newMessage]);
      });

      // 2. Update the Inbox UI (The Snippet)
      ref.read(inboxProvider.notifier).updateLastMessage(conversationId, newMessage);

    } catch (e) {
      // Handle error
    }
  }
}

final chatThreadProvider = StateNotifierProvider.family<ChatThreadNotifier, AsyncValue<List<Message>>, String>(
      (ref, conversationId) {
    return ChatThreadNotifier(
      ref.watch(chatRepositoryProvider),
      conversationId,
      ref,
    );
  },
);