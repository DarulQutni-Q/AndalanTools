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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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

/// Minimalist Swiss-style vector emblem: Two Layered Document Sheets with Optical Notch
class AndalanLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AndalanLogo({
    super.key,
    this.size = 28,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final strokeColor = color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AndalanLogoPainter(strokeColor),
      ),
    );
  }
}

class _AndalanLogoPainter extends CustomPainter {
  final Color color;
  _AndalanLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = (w * 0.085).clamp(1.5, 3.5);
    final r = w * 0.10;

    // 1. Back Sheet (Offset to top-left)
    final backPaint = Paint()
      ..color = color.withOpacity(0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final backPath = Path();
    // Top-left to bottom-left corner of back sheet
    backPath.moveTo(w * 0.06 + r, h * 0.06);
    backPath.lineTo(w * 0.72 - r, h * 0.06);
    backPath.quadraticBezierTo(w * 0.72, h * 0.06, w * 0.72, h * 0.06 + r);
    backPath.lineTo(w * 0.72, h * 0.22); // hides behind front sheet

    // Left and bottom edges of back sheet
    backPath.moveTo(w * 0.06, h * 0.06 + r);
    backPath.lineTo(w * 0.06, h * 0.72 - r);
    backPath.quadraticBezierTo(w * 0.06, h * 0.72, w * 0.06 + r, h * 0.72);
    backPath.lineTo(w * 0.24, h * 0.72); // stops where front sheet starts

    canvas.drawPath(backPath, backPaint);

    // 2. Front Sheet (In foreground, offset to bottom-right)
    final frontPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final x0 = w * 0.24;
    final y0 = w * 0.24;
    final x1 = w * 0.94;
    final y1 = h * 0.94;
    final notch = w * 0.24;

    final frontPath = Path();
    frontPath.moveTo(x0 + r, y0);
    frontPath.lineTo(x1 - notch, y0);
    // Optical diagonal cut for the notch
    frontPath.lineTo(x1, y0 + notch);
    frontPath.lineTo(x1, y1 - r);
    frontPath.quadraticBezierTo(x1, y1, x1 - r, y1);
    frontPath.lineTo(x0 + r, y1);
    frontPath.quadraticBezierTo(x0, y1, x0, y1 - r);
    frontPath.lineTo(x0, y0 + r);
    frontPath.quadraticBezierTo(x0, y0, x0 + r, y0);
    frontPath.close();

    canvas.drawPath(frontPath, frontPaint);

    // Optical Notch Flap fold line
    final flapPath = Path();
    flapPath.moveTo(x1 - notch, y0);
    flapPath.lineTo(x1 - notch, y0 + notch);
    flapPath.lineTo(x1, y0 + notch);
    canvas.drawPath(flapPath, frontPaint);

    // Minimal horizontal content lines inside front sheet
    final linePaint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(x0 + w * 0.16, y0 + h * 0.38),
      Offset(x1 - w * 0.16, y0 + h * 0.38),
      linePaint,
    );

    canvas.drawLine(
      Offset(x0 + w * 0.16, y0 + h * 0.52),
      Offset(x1 - w * 0.28, y0 + h * 0.52),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AndalanLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Interactive Apple-style capsule pill for Header Vault access
class IosHeaderVaultPill extends StatelessWidget {
  final VoidCallback onTap;

  const IosHeaderVaultPill({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IosBouncyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      borderRadius: BorderRadius.circular(20),
      backgroundColor: AppTheme.subtleFill,
      border: Border.all(color: AppTheme.dividerColor, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x04000000),
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ],
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14.5, color: AppTheme.primaryText),
          SizedBox(width: 5),
          Text(
            'Brankas',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}


