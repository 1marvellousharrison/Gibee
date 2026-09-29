import 'package:flutter/material.dart';

import 'models.dart';

/// In-memory session store. Mirrors the web `Session`/`Theme` logic;
/// Sign out lives only in Settings.
class Session {
  Session()
      : current = ValueNotifier<AppUser?>(null),
        theme = ValueNotifier<ThemeMode>(ThemeMode.dark);

  final ValueNotifier<AppUser?> current;
  final ValueNotifier<ThemeMode> theme;

  bool get isSignedIn => current.value != null;

  void signIn(AppUser user) => current.value = user;

  void signOut() => current.value = null;

  /// Guest/demo auto sign-in used by the auth screens.
  void signInDemo() =>
      signIn(const AppUser(name: 'David Lee', email: 'david@example.com', phone: '+1 555 0123'));

  void toggleTheme() => theme.value =
      theme.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}