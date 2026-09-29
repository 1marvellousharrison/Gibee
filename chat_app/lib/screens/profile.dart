import 'package:flutter/material.dart';

import '../session.dart';
import '../state.dart';
import '../theme/app_theme.dart';
import '../widgets/neu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.session,
    this.store,
    this.openConversation,
  });

  final Session session;
  final ChatStore? store;
  final ValueChanged<String>? openConversation;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;

  static const _tabs = ['Media', 'Docs', 'Links'];

  @override
  Widget build(BuildContext context) {
    final user = widget.session.current.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;

    Widget header;
    if (widget.openConversation != null) {
      header = Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const NeuBox(
              radius: 20,
              blur: 10,
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Profile', style: AppText.title1),
        ],
      );
    } else {
      header = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Avatar(
              letters: user?.initials ?? '?',
              color: AppColors.primary.toARGB32(),
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Guest', style: AppText.nameBar),
                  Text('Signed in', style: AppText.caption.copyWith(color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgBlack : AppColors.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            header,
            const SizedBox(height: 18),
            // Profile card
            NeuBox(
              radius: 24,
              blur: 14,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  NeuBox(
                    radius: 26,
                    inset: true,
                    blur: 10,
                    padding: const EdgeInsets.all(6),
                    child: Avatar(
                      letters: user?.initials ?? '?',
                      color: AppColors.primary.toARGB32(),
                      size: 64,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Guest user', style: AppText.title1.copyWith(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'guest@example.com',
                          style: AppText.body.copyWith(
                            color: fg.withValues(alpha: .6),
                            fontSize: 13,
                          ),
                        ),
                        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.phone!,
                            style: AppText.body.copyWith(color: fg.withValues(alpha: .6), fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Media tabs
            NeuBox(
              radius: 20,
              blur: 12,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _tab == i ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _tabs[i],
                                style: AppText.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _tab == i ? AppColors.softLight : fg.withValues(alpha: .65),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < _tabs.length - 1) const SizedBox(width: 4),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      for (var i = 0; i < 9; i++)
                        NeuBox(
                          inset: true,
                          radius: 14,
                          blur: 8,
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.primary.withValues(alpha: .5 + (i % 3) * .15),
                              size: 26,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Settings panel
            NeuBox(
              radius: 22,
              blur: 14,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _item(
                    Icons.person_outline,
                    'Profile',
                    'Edit your details',
                    divider: true,
                    onTap: () => _toast('Edit profile (demo).'),
                  ),
                  _item(
                    Icons.archive_outlined,
                    'Archived chats',
                    'View hidden conversations',
                    divider: true,
                    onTap: () {
                      final store = widget.store;
                      if (store != null && widget.openConversation != null) {
                        final archived = store.conversations.where((c) => c.archived).toList();
                        if (archived.isEmpty) {
                          _toast('No archived chats.');
                        } else {
                          Navigator.of(context).maybePop();
                          widget.openConversation!(archived.first.id);
                        }
                      }
                    },
                  ),
                  _item(
                    Icons.star_outline,
                    'Starred messages',
                    'Saved for later',
                    divider: true,
                    onTap: () => _toast('Starred messages (demo).'),
                  ),
                  _item(
                    Icons.notifications_none,
                    'Notifications',
                    'Mute and alerts',
                    divider: true,
                    trailing: NeuBox(
                      radius: 16,
                      inset: true,
                      blur: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text('On', style: AppText.caption),
                    ),
                    onTap: () => _toast('Notification settings (demo).'),
                  ),
                  _item(
                    Icons.dark_mode_outlined,
                    'Dark mode',
                    null,
                    color: AppColors.amber,
                    trailing: NeuBox(
                      radius: 8,
                      inset: true,
                      blur: 6,
                      padding: const EdgeInsets.all(4),
                      child: _ThemeSwitch(session: widget.session),
                    ),
                  ),
                  _item(
                    Icons.logout,
                    'Sign out',
                    null,
                    color: AppColors.error,
                    onTap: () => _confirmSignOut(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String? subtitle, {
    Color color = AppColors.primary,
    bool divider = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        ListTile(
          leading: NeuBox(
            radius: 12,
            inset: true,
            blur: 8,
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: color),
          ),
          title: Text(title, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: AppText.caption.copyWith(color: fg.withValues(alpha: .55))),
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: fg.withValues(alpha: .4), size: 26),
          onTap: onTap,
        ),
        if (divider) Divider(height: 1, indent: 66, endIndent: 16),
      ],
    );
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _confirmSignOut() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark ? AppColors.bgSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign out?', style: AppText.title1),
        content: const Text('You’ll need to sign in again to use the chat.', style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Stay', style: const TextStyle(color: AppColors.primary)),
          ),
          NeuBox(
            radius: 12,
            inset: true,
            blur: 6,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.session.signOut();
              },
              child: const Text('Sign out', style: TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: session.theme,
      builder: (context, mode, _) {
        return Switch(
          value: mode == ThemeMode.dark,
          onChanged: (_) => session.toggleTheme(),
        );
      },
    );
  }
}