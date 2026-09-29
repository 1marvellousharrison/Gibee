import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme/app_theme.dart';
import '../widgets/dock.dart';
import '../widgets/messages.dart';
import '../widgets/neu.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.store,
    required this.conversationId,
    this.compact = false,
    this.openProfile,
  });

  final ChatStore store;
  final String conversationId;
  final bool compact;
  final VoidCallback? openProfile;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _typingVisible = false;

  Conversation get _conv => widget.store.conversationById(widget.conversationId);

  @override
  void initState() {
    super.initState();
    widget.store.clearUnread(widget.conversationId);
    widget.store.addListener(_onStore);
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _postFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSend(String text) {
    widget.store.sendMessage(widget.conversationId, text);
    _postFrame();
    // Simulate an incoming typing indicator + reply shortly after.
    Future.delayed(const Duration(milliseconds: 900), () {
      widget.store.simulateIncoming(widget.conversationId);
      setState(() => _typingVisible = true);
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _typingVisible = false);
      });
    });
  }

  void _onAttach() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attach coming soon (demo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conv = _conv;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final header = Container(
      padding: EdgeInsets.fromLTRB(6, 6, 14, 6),
      color: isDark ? AppColors.bgSurface : AppColors.lightSurface,
      child: Row(
        children: [
          if (!widget.compact)
            NeuIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 42,
              iconSize: 18,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.openProfile,
            child: Avatar(
              letters: conv.initials,
              color: conv.color,
              size: 38,
              showDot: conv.online,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: widget.openProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv.name, style: AppText.nameBar, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    conv.online ? 'Online' : (conv.isGroup ? '${conv.members.length} members' : 'Offline'),
                    style: AppText.caption.copyWith(
                      color: conv.online
                          ? AppColors.success
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice call (demo)')),
            ),
            child: NeuIconButton(
              icon: Icons.call_rounded,
              size: 44,
              iconSize: 20,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call (demo)')),
              ),
            ),
          ),
          const SizedBox(width: 10),
          NeuIconButton(
            icon: Icons.video_call_outlined,
            size: 44,
            iconSize: 20,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video call (demo)')),
            ),
          ),
        ],
      ),
    );

    final messages = ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: conv.messages.length + 2,
      itemBuilder: (context, i) {
        if (i == 0) return const DateSeparator(label: 'Today');
        if (i == 1) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _typingVisible ? const TypingBubble(active: true) : const SizedBox(height: 0),
          );
        }
        final m = conv.messages[i - 2];
        return MessageBubble(
          message: m,
          showStatus: !m.incoming,
        );
      },
    );

    final input = SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: CapsuleInput(
          controller: _input,
          onSend: _onSend,
          onAttach: _onAttach,
        ),
      ),
    );

    return Scaffold(
      appBar: widget.compact ? AppBar(automaticallyImplyLeading: false, titleSpacing: 0, title: header) : null,
      backgroundColor: isDark ? AppColors.bgBlack : AppColors.lightBg,
      body: Column(
        children: [
          if (!widget.compact) header,
          Expanded(child: messages),
        ],
      ),
      bottomNavigationBar: input,
    );
  }
}