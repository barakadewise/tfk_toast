import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:tfk_toast/animation_widget.dart';
import 'package:tfk_toast/enum.dart';
import 'package:tfk_toast/toast_queue.dart';

/// ======================================================
/// TfkToast
///
/// A simple global toast system for Flutter.
///
/// This package shows non-intrusive toast messages
/// anywhere in your app, even during navigation.
///
/// It works with:
/// - MaterialApp
/// - GoRouter
/// - Navigator 1.0 / 2.0
///
/// ------------------------------------------------------
/// HOW IT WORKS
///
/// Priority for showing toast:
/// 1. BuildContext (best and most reliable)
/// 2. Global navigatorKey (fallback)
/// 3. Safe fail (no crash)
/// ======================================================
class TfkToast {
  /// Global navigator key fallback (optional).
  /// Used when BuildContext is not available.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Optional app-provided navigator key (GoRouter / MaterialApp)
  static GlobalKey<NavigatorState>? appNavigatorKey;

  /// Active key used internally
  static GlobalKey<NavigatorState> get _activeKey =>
      appNavigatorKey ?? navigatorKey;

  /// Internal queue to show one toast at a time
  static final Queue<ToastEntry> _toastQueue = Queue<ToastEntry>();

  static bool _isToastActive = false;

  /// ======================================================
  /// SHOW TOAST
  ///
  /// Example:
  ///
  /// ```dart
  /// TfkToast.showToast(
  ///   "Order placed successfully",
  ///   type: ToastType.success,
  /// );
  /// ```
  /// ======================================================
  static void showToast(
    String message, {
    BuildContext? context,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
    Duration duration = const Duration(seconds: 2),
    String? title,
    bool showCloseIcon = true,
    ToastAnimation animation = ToastAnimation.none,
    TextStyle? messageStyle,
    TextStyle? titleStyle,
    EdgeInsetsGeometry? padding,
    double borderRadius = 8.0,
    double elevation = 0.0,
    Widget? icon,
    Color? backgroundColor,
    VoidCallback? onTap,
    double? progress,
    bool showIndicator = false,
  }) {
    _toastQueue.add(
      ToastEntry(
        message: message,
        type: type,
        position: position,
        duration: duration,
        title: title,
        showCloseIcon: showCloseIcon,
        animation: animation,
        messageStyle: messageStyle,
        titleStyle: titleStyle,
        padding: padding,
        borderRadius: borderRadius,
        elevation: elevation,
        icon: icon,
        backgroundColor: backgroundColor,
        onTap: onTap,
        progress: progress,
        showIndicator: showIndicator,
      ),
    );

    if (!_isToastActive) {
      _showNextToast(context);
    }
  }

  /// Internal: shows next toast in queue
  static void _showNextToast(BuildContext? context) {
    if (_toastQueue.isEmpty) return;

    final toast = _toastQueue.removeFirst();
    _isToastActive = true;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: _getPosition(overlayContext, toast.position),
        left: MediaQuery.of(overlayContext).size.width * 0.1,
        right: MediaQuery.of(overlayContext).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: AnimatedToastWidget(
            message: toast.message,
            type: toast.type,
            duration: toast.duration,
            title: toast.title,
            showCloseIcon: toast.showCloseIcon,
            animation: toast.animation,
            onRemove: () {
              overlayEntry.remove();
              _isToastActive = false;
              _showNextToast(context);
            },
            messageStyle: toast.messageStyle,
            titleStyle: toast.titleStyle,
            padding: toast.padding,
            borderRadius: toast.borderRadius,
            elevation: toast.elevation,
            icon: toast.icon,
            backgroundColor: toast.backgroundColor,
            onTap: toast.onTap,
            progress: toast.progress,
            isProgress: toast.showIndicator,
          ),
        ),
      ),
    );

    OverlayState? overlay;

    /// Try BuildContext first
    if (context != null) {
      overlay = Overlay.of(context, rootOverlay: true);
    }

    /// Fallback to navigatorKey
    overlay ??= _activeKey.currentState?.overlay;

    /// Safe failure
    if (overlay == null) {
      debugPrint(
        '[TfkToast] No overlay found. '
        'Provide context or set navigatorKey in MaterialApp/GoRouter.',
      );
      _isToastActive = false;
      return;
    }

    overlay.insert(overlayEntry);

    // Capture the overlay reference now
    //to avoid use_build_context_synchronously warnings.

    Future.delayed(toast.duration, () {
      if (_isToastActive) {
        //overlayEntry is captured by closure, no BuildContext used
        // after the async gap (fixes use_build_context_synchronously).
        try {
          overlayEntry.remove();
        } catch (_) {
          // Entry may have already been removed by the close button.
        }
        _isToastActive = false;
        _showNextToast(null); // No context needed; falls back to navigatorKey.
      }
    });
  }

  /// Controls toast position
  static double _getPosition(BuildContext context, ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return 50;

      case ToastPosition.center:
        return MediaQuery.of(context).size.height / 2 - 50;

      case ToastPosition.bottom:
        return MediaQuery.of(context).size.height - 150;
    }
  }
}
