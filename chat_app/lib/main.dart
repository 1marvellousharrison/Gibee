import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/auth.dart';
import 'screens/home.dart';
import 'session.dart';
import 'state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  late final Session _session = Session();
  late final ChatStore _store = ChatStore(session: _session);

  @override
  void dispose() {
    _session.current.dispose();
    _session.theme.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _session.theme,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Purple Chat',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: _Root(session: _session, store: _store),
        );
      },
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({required this.session, required this.store});

  final Session session;
  final ChatStore store;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: session.current,
      builder: (context, user, _) {
        return user == null
            ? SignInScreen(session: session)
            : HomeShell(session: session, store: store);
      },
    );
  }
}