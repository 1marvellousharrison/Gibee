import 'package:flutter/material.dart';

import '../models.dart';
import '../session.dart';
import '../state.dart';
import '../theme/app_theme.dart';
import '../widgets/dock.dart';
import '../widgets/neu.dart';
import 'conversation.dart';
import 'profile.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session, required this.store});

  final Session session;
  final ChatStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  DockItem _dock = DockItem.chats;
  String? _activeId;
  bool _detailsOpen = false;
  bool _showArchived = false;
  final _search = TextEditingController();

  bool get _wide => MediaQuery.of(context).size.width >= 900;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
    _search.addListener(() => setState(() {}));
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    _search.dispose();
    super.dispose();
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _onDock(DockItem item) {
    switch (item) {
      case DockItem.chats:
        setState(() => _dock = item);
        break;
      case DockItem.camera:
        _toast('Camera (demo)');
        break;
      case DockItem.scan:
        _toast('Scan QR (demo)');
        break;
      case DockItem.settings:
        setState(() {
          _detailsOpen = _wide;
          _dock = item;
        });
        break;
    }
  }

  List<Conversation> get _visible =>
      widget.store.conversations.where((c) => !c.archived).toList();

  void _openConversation(String id) {
    setState(() => _activeId = id);
    if (!_wide && _dock != DockItem.chats) setState(() => _dock = DockItem.chats);
    if (!_wide) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(
            store: widget.store,
            conversationId: id,
            openProfile: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => _profilePane())),
          ),
        ),
      );
    }
  }

  Widget _profilePane() => ProfileScreen(
        session: widget.session,
        store: widget.store,
        openConversation: _openConversation,
      );

  // ---- Top bar ----
  AppBar _topbar() {
    final user = widget.store.session.current.value;
    final goingToChat = _activeId != null;
    return AppBar(
      titleSpacing: 12,
      leadingWidth: 74,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () {
            if (_dock == DockItem.chats) {
              setState(() => _dock = DockItem.settings);
              _detailsOpen = true;
            }
          },
          child: Center(
            child: NeuBox(
              radius: 20,
              blur: 10,
              padding: const EdgeInsets.all(4),
              child: Avatar(
                letters: user?.initials ?? '?',
                color: AppColors.primary.toARGB32(),
                size: 36,
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Text(goingToChat ? (_activeConv?.name ?? 'Chats') : 'Chats', style: AppText.title1),
        ],
      ),
      actions: [
        if (!goingToChat)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeuIconButton(
              icon: Icons.add_rounded,
              size: 44,
              iconSize: 26,
              inverse: true,
              tooltip: 'New chat',
              onTap: () => _toast('New chat (demo)'),
            ),
          ),
      ],
    );
  }

  Conversation? get _activeConv {
    if (_activeId == null) return null;
    try {
      return widget.store.conversationById(_activeId!);
    } catch (_) {
      return null;
    }
  }

  // ---- Search bar ----
  Widget _searchBar() => NeuBox(
        inset: true,
        radius: 24,
        blur: 10,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: TextField(
          controller: _search,
          cursorColor: AppColors.primary,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded, size: 22, color: AppColors.primary),
            hintText: 'Search',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      );

  // ---- Conversation list (mobile body) ----
  Widget _mobileBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _searchBar(),
        ),
        Expanded(child: _list()),
      ],
    );
  }

  Widget _list() {
    final convs = _visible;
    final q = _search.text.trim().toLowerCase();
    final filtered = q.isEmpty ? convs : convs.where((c) => c.name.toLowerCase().contains(q)).toList();
    final archived = widget.store.conversations.where((c) => c.archived).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        for (final c in filtered) _tile(c),
        if (archived.isNotEmpty) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _showArchived = !_showArchived),
            child: NeuBox(
              radius: 16,
              blur: 12,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  NeuBox(
                    radius: 12,
                    inset: true,
                    blur: 8,
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.archive_outlined, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('Archived', style: AppText.name),
                  const Spacer(),
                  NeuBox(
                    radius: 14,
                    inset: true,
                    blur: 6,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      '${archived.length}',
                      style: AppText.stamp.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Icon(
                    _showArchived ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                  ),
                ],
              ),
            ),
          ),
          if (_showArchived) for (final c in archived) _tile(c),
        ],
      ],
    );
  }

  Widget _tile(Conversation c) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: () => _openConversation(c.id),
      child: NeuBox(
        radius: 16,
        blur: 12,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            Avatar(letters: c.initials, color: c.color, size: 48, showDot: c.online),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.name, style: AppText.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Text(c.time, style: AppText.stamp.copyWith(color: fg.withValues(alpha: .45), fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body.copyWith(
                            color: c.unread > 0 ? AppColors.softLight : fg.withValues(alpha: .55),
                            fontWeight: c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (c.unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            '${c.unread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Desktop pane ----
  Widget _desktopList() {
    return Container(
      width: 340,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.bgSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
            child: _searchBar(),
          ),
          Expanded(child: _list()),
        ],
      ),
    );
  }

  Widget _desktopChat() {
    if (_activeId == null) {
      final fg = Theme.of(context).colorScheme.onSurface;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuBox(
              radius: 30,
              inset: true,
              blur: 10,
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.forum_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Select a conversation', style: AppText.title1),
            const SizedBox(height: 6),
            Text(
              'Your chats will appear here.',
              style: AppText.caption.copyWith(color: fg.withValues(alpha: .55)),
            ),
          ],
        ),
      );
    }
    return ConversationScreen(
      store: widget.store,
      conversationId: _activeId!,
      compact: true,
      openProfile: () => setState(() => _detailsOpen = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_wide) {
      return Scaffold(
        appBar: _topbar(),
        body: Row(
          children: [
            _desktopList(),
            const VerticalDivider(width: 1),
            Expanded(child: _desktopChat()),
            if (_detailsOpen) ...[
              const VerticalDivider(width: 1),
              SizedBox(width: 320, child: _profilePane()),
            ],
          ],
        ),
        floatingActionButton: _detailsOpen || _activeId != null
            ? FloatingActionButton.small(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => setState(() => _detailsOpen = !_detailsOpen),
                tooltip: 'Toggle details',
                child: Icon(_detailsOpen ? Icons.close : Icons.settings_outlined),
              )
            : null,
      );
    }

    // Mobile layout
    final body = switch (_dock) {
      DockItem.chats => _mobileBody(),
      DockItem.settings => _profilePane(),
      _ => _placeholder(),
    };

    return Scaffold(
      appBar: _dock == DockItem.chats ? _topbar() : null,
      body: body,
      extendBody: true,
      floatingActionButton: _typingFloating(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SafeArea(
          top: false,
          child: BottomDock(active: _dock, onSelect: _onDock),
        ),
      ),
    );
  }

  Widget _typingFloating() {
    if (!widget.store.isTyping || _dock != DockItem.chats) return const SizedBox.shrink();
    final fg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 74),
      child: NeuBox(
        radius: 20,
        blur: 10,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text('Someone is typing…', style: AppText.caption.copyWith(color: fg)),
      ),
    );
  }

  Widget _placeholder() {
    final action = _dock == DockItem.camera ? 'Camera' : 'Scan QR';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuBox(
            radius: 30,
            inset: true,
            blur: 10,
            padding: const EdgeInsets.all(20),
            child: Icon(
              _dock == DockItem.camera ? Icons.camera_alt_outlined : Icons.qr_code_scanner,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('$action coming soon', style: AppText.title1),
          const SizedBox(height: 6),
          Text(
            'This feature is a demo placeholder.',
            style: AppText.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
            ),
          ),
        ],
      ),
    );
  }
}