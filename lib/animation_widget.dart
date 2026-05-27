import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tfk_toast/enum.dart';

/// A private widget class that handles the toast's animation and appearance.
///
/// This widget is responsible for building the animated toast content
/// and managing its lifecycle.
///
class AnimatedToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final String? title;
  final bool showCloseIcon;
  final ToastAnimation animation;
  final VoidCallback onRemove;
  final TextStyle? messageStyle;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final Widget? icon;
  final Color? backgroundColor;

  final VoidCallback? onTap;
  final double? progress;
  final bool isProgress;

  const AnimatedToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onRemove,
    this.title,
    this.showCloseIcon = true,
    this.animation = ToastAnimation.none,
    this.messageStyle,
    this.titleStyle,
    this.padding,
    this.borderRadius = 8.0,
    this.elevation = 0.0,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.progress,
    this.isProgress = false,
  });

  @override
  AnimatedToastWidgetState createState() => AnimatedToastWidgetState();
}

class AnimatedToastWidgetState extends State<AnimatedToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _wobbleAnimation;

  // Icon entrance animations
  late Animation<double> _iconScaleAnim;
  late Animation<double> _iconOpacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 280),
    );

    if (widget.animation == ToastAnimation.slide) {
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0.15, -0.4),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    } else if (widget.animation == ToastAnimation.fade) {
      _fadeAnimation = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      );
    } else if (widget.animation == ToastAnimation.scale) {
      _scaleAnimation = Tween<double>(
        begin: 0.72,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ));
    } else if (widget.animation == ToastAnimation.bounce) {
      _bounceAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
    } else if (widget.animation == ToastAnimation.rotate) {
      _rotateAnimation = Tween<double>(
        begin: -0.08,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
    } else if (widget.animation == ToastAnimation.zoom) {
      _zoomAnimation = Tween<double>(
        begin: 0.60,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ));
    }

    if (widget.animation == ToastAnimation.wobble) {
      _wobbleAnimation = Tween<double>(
        begin: -15.0,
        end: 15.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ));
    }

    // Icon pops in slightly after the toast body settles
    _iconScaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
      ),
    );
    _iconOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onRemove();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Surface is always the solid accent — original style fully preserved.
    // All icon/badge/text tones are derived from white-over-color so they
    // adapt automatically to any custom backgroundColor.
    final surfaceColor = widget.backgroundColor ?? _getBackgroundColor();

    Widget toastContent = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            // Soft ambient lift
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            // Coloured underglow — adapts to surfaceColor automatically
            BoxShadow(
              color: surfaceColor.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
            if (widget.elevation > 0)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(0, widget.elevation),
                blurRadius: widget.elevation,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon badge ─────────────────────────────────────────────
            // Shown when icon is provided OR always as a type-default fallback.
            // Background and icon color are white-relative so they work on
            // any surfaceColor — whether the default blues/greens or a custom hue.
            ScaleTransition(
              scale: _iconScaleAnim,
              child: FadeTransition(
                opacity: _iconOpacityAnim,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    // White overlay on the solid surface — self-adapts to any color
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: widget.icon ??
                        Icon(
                          _getDefaultIcon(),
                          // Always white — readable on any backgroundColor
                          color: Colors.white,
                          size: 19,
                        ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12.0),

            // ── Text content ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: widget.titleStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                    ),
                  Text(
                    widget.message,
                    style: widget.messageStyle ??
                        TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 14.0,
                          height: 1.4,
                        ),
                  ),
                  // ── Progress bar ──────────────────────────────────
                  if (widget.isProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Track
                                Container(
                                  height: 3.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Fill with glowing leading edge
                                FractionallySizedBox(
                                  widthFactor: _controller.value,
                                  child: Container(
                                    height: 3.0,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.90),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                          blurRadius: 5,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Close button ──────────────────────────────────────────
            if (widget.showCloseIcon)
              GestureDetector(
                onTap: () {
                  if (mounted) {
                    _controller.reverse().then((_) {
                      if (mounted) widget.onRemove();
                    });
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15.0,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    switch (widget.animation) {
      case ToastAnimation.slide:
        return SlideTransition(position: _slideAnimation, child: toastContent);
      case ToastAnimation.fade:
        return FadeTransition(opacity: _fadeAnimation, child: toastContent);
      case ToastAnimation.scale:
        return ScaleTransition(scale: _scaleAnimation, child: toastContent);
      case ToastAnimation.bounce:
        return SizeTransition(
            sizeFactor: _bounceAnimation, child: toastContent);
      case ToastAnimation.rotate:
        return RotationTransition(turns: _rotateAnimation, child: toastContent);
      case ToastAnimation.zoom:
        return ScaleTransition(scale: _zoomAnimation, child: toastContent);
      case ToastAnimation.wobble:
        return AnimatedBuilder(
          animation: _wobbleAnimation,
          builder: (context, child) {
            final raw = _wobbleAnimation.value;
            // Damped sine — physically realistic settling shake
            final damped = raw * math.sin(raw * 0.3) * 0.4;
            return Transform.translate(
              offset: Offset(damped, 0),
              child: child,
            );
          },
          child: toastContent,
        );
      // case ToastAnimation.none:
      default:
        return toastContent;
    }
  }

  // ── Default icons per toast type ─────────────────────────────────────────
  IconData _getDefaultIcon() {
    switch (widget.type) {
      case ToastType.info:
        return Icons.info_outline_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.cancel_outlined;
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  /// Returns the background color for the toast based on the [type] enum.
  ///
  /// * [type] : The type of toast, which determines its background color.
  ///
  /// Returns a `Color` that represents the background color of the toast.
  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.info:
        return Colors.blue;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.error:
        return Colors.red;
      case ToastType.success:
        return Colors.green;
    }
  }
}
