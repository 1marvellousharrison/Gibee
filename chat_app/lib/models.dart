// Core domain models (mirrors the mock data used by the web build).

class AppUser {
  const AppUser({required this.name, required this.email, this.phone});

  final String name;
  final String email;
  final String? phone;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}

class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.color,
    required this.online,
    required this.unread,
    required this.last,
    required this.time,
    this.members = const [],
    this.isGroup = false,
    this.archived = false,
    required this.messages,
    this.status = MessageStatus.recv,
  });

  final String id;
  final String name;
  final int color; // ARGB as int
  final bool online;
  final int unread;
  final String last;
  final String time;
  final List<String> members;
  final bool isGroup;
  final bool archived;
  final List<Message> messages;
  final MessageStatus status;

  String get initials {
    if (isGroup) {
      final words = name.replaceAll('@', '').split(RegExp(r'\s+'));
      return words.length > 1 ? '${words.first[0]}${words[1][0]}' : name[0];
    }
    final parts = name.split(RegExp(r'\s+'));
    return parts.length > 1 ? '${parts.first[0]}${parts.last[0]}'.toUpperCase() : name[0].toUpperCase();
  }

  Conversation copyWith({
    List<Message>? messages,
    int? unread,
    String? last,
    String? time,
    MessageStatus? status,
    bool? archived,
  }) {
    return Conversation(
      id: id,
      name: name,
      color: color,
      online: online,
      unread: unread ?? this.unread,
      last: last ?? this.last,
      time: time ?? this.time,
      members: members,
      isGroup: isGroup,
      archived: archived ?? this.archived,
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus { sending, sent, failed, recv }

class Message {
  const Message({
    required this.id,
    required this.text,
    required this.time,
    required this.incoming,
    this.status = MessageStatus.recv,
  });

  final String id;
  final String text;
  final String time;
  final bool incoming;
  final MessageStatus status;

  Message copyWith({MessageStatus? status}) => Message(
        id: id,
        text: text,
        time: time,
        incoming: incoming,
        status: status ?? this.status,
      );
}