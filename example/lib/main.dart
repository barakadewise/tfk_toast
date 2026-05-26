import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfk_toast/enum.dart';
import 'package:tfk_toast/tfk_toast.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  TfkToast.navigatorKey = navigatorKey;
  runApp(const MyApp());
}

/// ======================================================
/// APP ROOT
/// Uses ONLY global navigatorKey (no context passed)
/// ======================================================
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       home: GlobalToastPage(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}

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
                  "This toast uses global navigatorKey only",
                  title: "Global Toast",
                  position: ToastPosition.top,
                  type: ToastType.info,
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

                context.go('/success');
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) => const SuccessToastPage()));
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


final goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const GlobalToastPage(),
    ),
    GoRoute(
      path: '/local',
      builder: (context, state) => const LocalToastPage(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessToastPage(),
    ),
  ],
);