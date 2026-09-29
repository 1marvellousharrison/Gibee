import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'neu.dart';

enum DockItem { chats, camera, scan, settings }

class DockSpec {
  const DockSpec(this.item, this.icon, this.label);

  final DockItem item;
  final IconData icon;
  final String label;
}

abstract final class DockSpecs {
  static const List<DockSpec> all = [
    DockSpec(DockItem.chats, Icons.chat_bubble_outline, 'Chats'),
    DockSpec(DockItem.camera, Icons.camera_alt_outlined, 'Camera'),
    DockSpec(DockItem.scan, Icons.qr_code_scanner, 'Scan'),
    DockSpec(DockItem.settings, Icons.settings_outlined, 'Settings'),
  ];
}

/// Floating neumorphic pill dock, as specified in the UI spec.
class BottomDock extends StatelessWidget {
  const BottomDock({
    super.key,
    required this.active,
    required this.onSelect,
    this.onMorePop,
  });

  final DockItem active;
  final ValueChanged<DockItem> onSelect;
  final VoidCallback? onMorePop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: NeuBox(
        radius: 30,
        blur: 14,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final spec in DockSpecs.all) ...[
              GestureDetector(
                onTap: () => onSelect(spec.item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 58,
                  height: 52,
                  decoration: BoxDecoration(
                    color: active == spec.item
                        ? (isDark ? AppColors.overlay : AppColors.softLight)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active == spec.item
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        spec.icon,
                        size: 22,
                        color: active == spec.item
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
                      ),
                      Text(
                        spec.label,
                        style: AppText.stamp.copyWith(
                          fontSize: 9,
                          color: active == spec.item
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: .45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (spec.item != DockSpecs.all.last.item) const SizedBox(width: 2),
            ],
          ],
        ),
      ),
    );
  }
}

/// Capsule-shaped message input (emoji | text | attach, paperclip+camera, send).
class CapsuleInput extends StatefulWidget {
  const CapsuleInput({
    super.key,
    required this.onSend,
    required this.controller,
    this.onAttach,
  });

  final ValueChanged<String> onSend;
  final TextEditingController controller;
  final VoidCallback? onAttach;

  @override
  State<CapsuleInput> createState() => _CapsuleInputState();
}

class _CapsuleInputState extends State<CapsuleInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  void _sync() => setState(() => _hasText = widget.controller.text.trim().isNotEmpty);

  void _send() {
    final t = widget.controller.text.trim();
    if (t.isEmpty) return;
    widget.onSend(t);
    widget.controller.clear();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(
          child: NeuBox(
            radius: 30,
            inset: true,
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emoji picker (demo)')),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.emoji_emotions_outlined, size: 22, color: fg.withValues(alpha: .7)),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    style: AppText.body.copyWith(fontSize: 16),
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onAttach ?? () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.attach_file, size: 22, color: fg.withValues(alpha: .7)),
                  ),
                ),
                if (_hasText) ...[
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera (demo)')),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.photo_camera_outlined, size: 22, color: fg.withValues(alpha: .7)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _send,
          child: NeuBox(
            radius: 30,
            blur: 10,
            color: _hasText ? AppColors.primary : (isDark ? AppColors.bgSurface : AppColors.lightSurface),
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.send_rounded,
              size: 22,
              color: _hasText ? AppColors.softLight : fg.withValues(alpha: .6),
            ),
          ),
        ),
      ],
    );
  }
}