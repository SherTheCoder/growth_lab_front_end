import '../../feed/domain/models.dart'; // To use the User model

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class Conversation {
  final String id;
  final List<User> participants; // Usually 2 users for DM
  final Message? lastMessage;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
  });

  // Helper to get the "other" user (not me) for display purposes
  User getOtherParticipant(String myUserId) {
    return participants.firstWhere(
            (u) => u.id != myUserId,
        orElse: () => participants.first
    );
  }

  Conversation copyWith({
    String? id,
    List<User>? participants,
    Message? lastMessage,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}