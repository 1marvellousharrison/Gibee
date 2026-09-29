import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_theme.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: .55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          label.toUpperCase(),
          style: AppText.stamp.copyWith(color: secondary, fontSize: 10, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

/// Incoming (surface) or outgoing (purple gradient) bubble with inline time.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showStatus = false,
  });

  final Message message;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final incoming = message.incoming;
    final bubble = incoming
        ? BoxDecoration(
            color: isDark ? AppColors.bgSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomRight: const Radius.circular(18),
              bottomLeft: const Radius.circular(6),
            ),
            boxShadow: isDark
                ? const [
                    BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(3, 4)),
                  ]
                : const [
                    BoxShadow(color: Color(0x0F31145B), blurRadius: 10, offset: Offset(3, 4)),
                  ],
          )
        : BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, AppColors.midPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: .3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          );

    final fg = incoming ? scheme.onSurface : Colors.white;
    final stamp = incoming
        ? scheme.onSurface.withValues(alpha: .5)
        : Colors.white.withValues(alpha: .8);
    final statusIcon = switch (message.status) {
      MessageStatus.sending => Icon(Icons.schedule, size: 11, color: stamp),
      MessageStatus.sent => Icon(Icons.check, size: 11, color: stamp),
      MessageStatus.failed => Icon(Icons.error_outline, size: 11, color: AppColors.error),
      MessageStatus.recv => Icon(Icons.done_all, size: 11, color: stamp),
    };

    return Align(
      alignment: incoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: bubble,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                message.text,
                style: AppText.body.copyWith(color: fg, fontSize: 18, height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.time, style: AppText.stamp.copyWith(color: stamp, fontSize: 10)),
                if (!incoming && showStatus) ...[
                  const SizedBox(width: 2),
                  statusIcon,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark
                ? const [BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(3, 4))]
                : const [BoxShadow(color: Color(0x0F31145B), blurRadius: 10, offset: Offset(3, 4))],
          ),
          child: _Dots(color: isDark ? AppColors.softLight : AppColors.lightSoft),
        ),
      ),
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots({required this.color});

  final Color color;

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_c.value * 3 + i) % 3;
            final scale = phase < 1 ? 0.5 + phase * 0.5 : 1.0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}