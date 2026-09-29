import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A raised or inset neumorphic surface.
class NeuBox extends StatelessWidget {
  const NeuBox({
    super.key,
    required this.child,
    this.radius = 16,
    this.inset = false,
    this.color,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.blur = 14,
  });

  final Widget child;
  final double radius;
  final bool inset;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = color ?? (isDark ? AppColors.bgSurface : AppColors.lightSurface);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: inset
            ? NeuShadows.inset(context, radius: blur)
            : NeuShadows.outer(context, radius: blur),
      ),
      child: child,
    );
  }
}

/// Neumorphic circular icon button (floating pill dock / header actions).
class NeuIconButton extends StatelessWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.inverse = false,
    this.iconSize = 20,
    this.tooltip,
    this.radius,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool inverse;
  final double iconSize;
  final String? tooltip;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = inverse ? scheme.primary : scheme.onSurface;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: NeuBox(
          radius: radius ?? size / 2,
          inset: inverse,
          blur: 10,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(icon, size: iconSize, color: accent),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width neumorphic pill button.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = true,
    this.inset = false,
    this.textStyle,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool inset;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = primary
        ? scheme.primary
        : (isDark ? AppColors.bgCard : AppColors.lightSurface);
    final fg = primary ? AppColors.softLight : scheme.onSurface;

    Widget child = Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        boxShadow: primary
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : NeuShadows.outer(context, radius: 12),
      ),
      child: Text(label, style: textStyle ?? AppText.name.copyWith(color: fg, fontSize: 15)),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Coloured initial avatar with online dot, matching conv tiles (48 / 38 / 36).
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.letters,
    required this.color,
    this.size = 48,
    this.showDot = false,
  });

  final String letters;
  final int color;
  final double size;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final dotSize = size * .28;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(size * .33),
              boxShadow: [
                BoxShadow(
                  color: Color(color).withValues(alpha: .35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(size * .15),
                child: Text(
                  letters,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * .36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          if (showDot)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}