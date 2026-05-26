import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:tfk_toast/animation_widget.dart';
import 'package:tfk_toast/enum.dart';
import 'package:tfk_toast/toast_queue.dart';

import 'dart:collection';
import 'package:flutter/material.dart';

/// ======================================================
/// TfkToast
///
/// A global toast system for Flutter apps.
///
/// FEATURES:
/// - Works with or without BuildContext
/// - Supports GoRouter + MaterialApp navigation
/// - Overlay-based rendering (no Scaffold dependency)
/// - Queue system (prevents multiple overlapping toasts)
/// - Safe fallback using navigatorKey
///
/// PRIORITY:
/// 1. BuildContext (best option)
/// 2. navigatorKey (fallback)
/// 3. Safe fail (no crash)
/// ======================================================
class TfkToast {
  /// -----------------------------------------------------
  /// GLOBAL NAVIGATOR KEY (FALLBACK)
  ///
  /// This should be assigned from your app root:
  ///
  /// void main() {
  ///   TfkToast.navigatorKey = rootNavigatorKey;
  ///   runApp(MyApp());
  /// }
  ///
  /// OR:
  /// MaterialApp(navigatorKey: rootNavigatorKey)
  /// GoRouter(navigatorKey: rootNavigatorKey)
  /// -----------------------------------------------------
  static GlobalKey<NavigatorState>? navigatorKey;

  /// -----------------------------------------------------
  /// INTERNAL TOAST QUEUE
  ///
  /// Ensures toasts are shown one at a time in order.
  /// Prevents overlapping UI glitches.
  /// -----------------------------------------------------
  static final Queue<ToastEntry> _toastQueue = Queue<ToastEntry>();

  /// Tracks whether a toast is currently visible.
  static bool _isToastActive = false;

  /// -----------------------------------------------------
  /// PUBLIC API: SHOW TOAST
  ///
  /// Example:
  ///
  /// TfkToast.showToast(
  ///   "Order placed successfully",
  ///   type: ToastType.success,
  /// );
  ///
  /// You can optionally pass BuildContext.
  /// -----------------------------------------------------
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
    // Add toast request to queue
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

    // Start queue processing if idle
    if (!_isToastActive) {
      _showNextToast(context);
    }
  }

  /// -----------------------------------------------------
  /// INTERNAL: PROCESS TOAST QUEUE
  ///
  /// Handles:
  /// - Overlay creation
  /// - Context fallback resolution
  /// - Auto dismissal
  /// -----------------------------------------------------
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

            /// When toast finishes or is closed
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

    /// STEP 1: Try BuildContext (preferred)
    if (context != null) {
      overlay = Overlay.of(context, rootOverlay: true);
    }

    /// STEP 2: Fallback to navigatorKey
    overlay ??= navigatorKey?.currentState?.overlay;

    /// STEP 3: Safe failure (no crash)
    if (overlay == null) {
      debugPrint(
        '[TfkToast ERROR] No overlay found. '
        'Provide BuildContext or set navigatorKey in GoRouter/MaterialApp.',
      );
      _isToastActive = false;
      return;
    }

    /// Insert toast into overlay
    overlay.insert(overlayEntry);

    /// Auto remove after duration
    Future.delayed(toast.duration, () {
      if (_isToastActive) {
        overlayEntry.remove();
        _isToastActive = false;
        _showNextToast(context);
      }
    });
  }

  /// -----------------------------------------------------
  /// POSITION HELPER
  ///
  /// Controls where toast appears on screen
  /// -----------------------------------------------------
  static double _getPosition(BuildContext context, ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
        return 50.0;

      case ToastPosition.center:
        return MediaQuery.of(context).size.height / 2 - 50.0;

      case ToastPosition.bottom:
        return MediaQuery.of(context).size.height - 150.0;
    }
  }
}
