import 'package:flutter/foundation.dart';

import 'data.dart';
import 'models.dart';
import 'session.dart';

/// Shared mutable app state for the chat demo.
class ChatStore extends ChangeNotifier {
  ChatStore({required this.session}) {
    _load();
  }

  final Session session;
  late List<Conversation> _conversations;
  final Map<String, bool> _typing = {};

  List<Conversation> get conversations => List.unmodifiable(_conversations);

  Conversation conversationById(String id) =>
      _conversations.firstWhere((c) => c.id == id);

  bool get isTyping => _typing.values.any((v) => v);

  void _load() {
    _conversations = MockData.conversations();
    _typing.clear();
  }

  /// Marks a message as sent after a delay; simulates the failure/queue edge
  /// case rarely, mirroring the web localQueue behaviour.
  void sendMessage(String conversationId, String text) {
    final msg = Message(
      id: 'tmp-${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      time: _nowTime(),
      incoming: false,
      status: MessageStatus.sending,
    );
    _conversations = [
      for (final x in _conversations)
        if (x.id == conversationId)
          x.copyWith(
            messages: [...x.messages, msg],
            last: text,
            time: _nowTime(),
            unread: 0,
            status: MessageStatus.sending,
          )
        else
          x,
    ];
    notifyListeners();

    // Confirmation (rare fake failure via seed).
    final fail = DateTime.now().second % 19 == 0;
    Future.delayed(const Duration(milliseconds: 800), () {
      _replaceMessage(
        conversationId,
        msg.id,
        msg.copyWith(status: fail ? MessageStatus.failed : MessageStatus.sent),
      );
      notifyListeners();
    });
  }

  /// Simulates an incoming typing indicator + reply after a delay.
  void simulateIncoming(String conversationId) {
    if (_typing.containsKey(conversationId)) return;
    _typing[conversationId] = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1600), () {
      _typing.remove(conversationId);
      const replies = [
        'Nice! 😄',
        'Sounds good 👌',
        'Let me check and get back to you.',
        'Send over the details 👍',
        'Ha, agreed.',
      ];
      final r = replies[DateTime.now().second % replies.length];
      final reply = Message(
        id: 'in-${DateTime.now().microsecondsSinceEpoch}',
        text: r,
        time: _nowTime(),
        incoming: true,
      );
      _conversations = [
        for (final x in _conversations)
          if (x.id == conversationId)
            x.copyWith(
              messages: [...x.messages, reply],
              last: r,
              time: _nowTime(),
              unread: x.unread + 1,
            )
          else
            x,
      ];
      notifyListeners();
    });
  }

  void retryMessage(String conversationId, String messageId) {
    final c = conversationById(conversationId);
    final idx = c.messages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    _replaceMessage(
      conversationId,
      messageId,
      c.messages[idx].copyWith(status: MessageStatus.sent),
    );
    notifyListeners();
  }

  void _replaceMessage(String conversationId, String messageId, Message replacement) {
    final c = conversationById(conversationId);
    final msgs = [...c.messages];
    final idx = msgs.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    msgs[idx] = replacement;
    _conversations = [
      for (final x in _conversations)
        if (x.id == conversationId)
          x.copyWith(messages: msgs, status: replacement.status)
        else
          x,
    ];
  }

  void clearUnread(String conversationId) {
    _conversations = [
      for (final x in _conversations)
        if (x.id == conversationId) x.copyWith(unread: 0) else x,
    ];
    notifyListeners();
  }

  void archive(String conversationId) {
    _conversations =
        _conversations.map((x) => x.copyWith(archived: !x.archived)).toList();
    notifyListeners();
  }

  String _nowTime() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    var h = n.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 == 0 ? 12 : h % 12;
    return '${two(h)}:${two(n.minute)} $ampm';
  }
}