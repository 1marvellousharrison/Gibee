import 'models.dart';

/// In-memory demo store mirroring the web mock data.
abstract final class MockData {
  static const List<Message> _rick = [
    Message(id: 'r1', text: 'Hey Dave! How have you been?', time: '10:24', incoming: true),
    Message(id: 'r2', text: 'I’m good Rick, just busy with this chat app.', time: '10:26', incoming: false),
    Message(id: 'r3', text: 'Looks amazing so far! Loving the dark neumorphic vibe.', time: '10:27', incoming: true),
    Message(id: 'r4', text: 'Appreciate it! Pushing the Flutter build right now.', time: '10:29', incoming: false),
  ];

  static const List<Message> _design = [
    Message(id: 'd1', text: 'We merged the purple theme yesterday 🎨', time: '09:02', incoming: true),
    Message(id: 'd2', text: 'Send over the new screenshots when ready.', time: '09:12', incoming: false),
  ];

  static const List<Message> _mil = [
    Message(id: 'm1', text: 'Coffee?', time: '08:41', incoming: false),
    Message(id: 'm2', text: 'Always ☕', time: '08:42', incoming: true),
  ];

  static List<Conversation> conversations() => [
        const Conversation(
          id: 'rick',
          name: 'Rick Harrison',
          color: 0xFF7C3AED,
          online: true,
          unread: 2,
          last: 'Appreciate it! Pushing the Flutter build right now.',
          time: '10:29',
          messages: _rick,
          status: MessageStatus.recv,
        ),
        const Conversation(
          id: 'design',
          name: 'Design Team',
          color: 0xFF5B21B6,
          online: true,
          unread: 0,
          last: 'We merged the purple theme yesterday 🎨',
          time: '09:12',
          members: ['Rick', 'Milan', 'Shreya'],
          isGroup: true,
          archived: true,
          messages: _design,
        ),
        const Conversation(
          id: 'milan',
          name: 'Milan Coleman',
          color: 0xFFC4B5FD,
          online: false,
          unread: 0,
          last: 'Always ☕',
          time: '08:42',
          messages: _mil,
        ),
        const Conversation(
          id: 'shreya',
          name: 'Shreya Patel',
          color: 0xFF1E1B4B,
          online: true,
          unread: 0,
          last: 'See you at the standup 👋',
          time: 'YESTERDAY',
          messages: [
            Message(id: 's1', text: 'See you at the standup 👋', time: '19:04', incoming: true),
            Message(id: 's2', text: 'Standup? Sure.', time: '19:06', incoming: false),
          ],
        ),
        const Conversation(
          id: 'city',
          name: 'City Electrics ⚡',
          color: 0xFF5B21B6,
          online: false,
          unread: 3,
          last: 'Your bill of ₹2,34,12,898 is due.',
          time: 'YESTERDAY',
          messages: [
            Message(id: 'c1', text: 'Your bill of ₹2,34,12,898 is due.', time: '18:00', incoming: true),
            Message(id: 'c2', text: 'Remind me to pay it 😅', time: '18:02', incoming: false),
          ],
        ),
        const Conversation(
          id: 'electric',
          name: 'Electric Co.',
          color: 0xFF7C3AED,
          online: false,
          unread: 0,
          last: 'Your bill is ready 💡',
          time: 'MONDAY',
          messages: [
            Message(id: 'e1', text: 'Your bill is ready 💡', time: '09:15', incoming: true),
            Message(id: 'e2', text: 'Thanks, paying now.', time: '09:30', incoming: false),
          ],
        ),
      ];
}