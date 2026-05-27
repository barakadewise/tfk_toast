import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfk_toast/enum.dart';
import 'package:tfk_toast/tfk_toast.dart';

//initilization using material app
// ======================================================
// 1. SETUP WITH MATERIAL APP
// ======================================================

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // Attach navigator key for global toast support
//       navigatorKey: TfkToast.navigatorKey,
//       home: const GlobalToastPage(),
//     );
//   }
// }

///initilization with go route
// ======================================================
// 2. SETUP WITH GO ROUTER
// ======================================================

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Attach GoRouter navigator key to toast system
  TfkToast.appNavigatorKey = rootNavigatorKey;

  runApp(const GoApp());
}

class GoApp extends StatelessWidget {
  const GoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const GlobalToastPage(),
    ),
  ],
);

/// ======================================================
/// PAGE 1
/// GLOBAL CONTEXT TOAST (NO BuildContext USED)
/// ======================================================
class GlobalToastPage extends StatelessWidget {
  const GlobalToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Toast Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GLOBAL CONTEXT TOASTS"),
            ElevatedButton(
              onPressed: () {
                TfkToast.showToast(
                  "This toast uses global",
                  title: "Global Toast",
                  position: ToastPosition.top,
                  type: ToastType.error,
                );
              },
              child: const Text("Top Toast (Global)"),
            ),
            ElevatedButton(
              onPressed: () {
                TfkToast.showToast(
                  "Bottom global toast",
                  title: "Global",
                  position: ToastPosition.bottom,
                  type: ToastType.success,
                );
              },
              child: const Text("Bottom Toast (Global)"),
            ),
            ElevatedButton(
              onPressed: () {
                TfkToast.showToast(
                  "Center global toast",
                  title: "Global",
                  position: ToastPosition.center,
                  type: ToastType.warning,
                );
              },
              child: const Text("Center Toast (Global)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TfkToast.showToast(
                //   "Globall Navigating to other page",
                //   title: "Global",
                //   position: ToastPosition.top,
                //   type: ToastType.success,
                // );
                TfkToast.showToast(
                  "Navigate after toast",
                  type: ToastType.success,
                );

                // context.go('/success');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SuccessToastPage()));
              },
              child: const Text("Navigate to othe rpage with toast"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocalToastPage(),
                  ),
                );
              },
              child: const Text("Go to Local Context Page"),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================================================
/// PAGE 2
/// LOCAL CONTEXT TOAST (USES BuildContext)
/// THE TOATS WILL ONLY APPER ON THE BULD SCREEN TREE BEFORE MOUNTED
/// ======================================================
class LocalToastPage extends StatelessWidget {
  const LocalToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Toast Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("LOCAL CONTEXT TOASTS"),
            Builder(
              builder: (ctx) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        TfkToast.showToast(
                          "Toast using BuildContext",
                          context: ctx,
                          title: "Local Toast",
                          type: ToastType.info,
                          position: ToastPosition.top,
                        );
                      },
                      child: const Text("Top Toast (Context)"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        TfkToast.showToast(
                          "Bottom context toast",
                          context: ctx,
                          title: "Local",
                          type: ToastType.success,
                          position: ToastPosition.bottom,
                        );
                      },
                      child: const Text("Bottom Toast (Context)"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        TfkToast.showToast(
                          "Center context toast",
                          context: ctx,
                          title: "Local",
                          type: ToastType.warning,
                          position: ToastPosition.center,
                        );
                      },
                      child: const Text("Center Toast (Context)"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessToastPage extends StatelessWidget {
  const SuccessToastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Navigated to success page"),
      ),
    );
  }
}
