import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:andalan_tools/core/theme/theme.dart';

/// Interactive iOS-style bouncy card with spring scaling and haptic feedback
class IosBouncyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const IosBouncyCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  State<IosBouncyCard> createState() => _IosBouncyCardState();
}

class _IosBouncyCardState extends State<IosBouncyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(18);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.surfaceColor,
            borderRadius: radius,
            border: widget.border ?? Border.all(color: AppTheme.dividerColor, width: 1.2),
            boxShadow: widget.boxShadow ?? const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Frosted Glass container with backdrop filter and iOS blur
class IosGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final double blur;

  const IosGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.blur = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.85),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Reusable iOS Segmented Pill Control
class IosSegmentedControl<T extends Object> extends StatelessWidget {
  final T groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T?> onValueChanged;

  const IosSegmentedControl({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: groupValue,
        children: children,
        backgroundColor: Colors.transparent,
        thumbColor: Colors.white,
        onValueChanged: (val) {
          HapticFeedback.selectionClick();
          onValueChanged(val);
        },
      ),
    );
  }
}
