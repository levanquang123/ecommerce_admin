import 'package:flutter/material.dart';
import '../main.dart';

class SnackBarHelper {
  static OverlayEntry? _overlay;

  static void _show(String message, Color color, IconData icon, {bool autoDismiss = true}) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlay?.remove();
    _overlay = null;

    _overlay = OverlayEntry(
      builder: (context) {
        final width = MediaQuery.of(context).size.width;

        return TweenAnimationBuilder(
          tween: Tween(begin: -100.0, end: 20.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, double top, child) {
            return Positioned(
              top: top,
              left: width > 600 ? width * 0.35 : 20,
              right: width > 600 ? width * 0.35 : 20,
              child: child!,
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black26,
                  )
                ],
              ),
              child: Row(
                children: [
                  icon == Icons.sync 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlay!);

    if (autoDismiss) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _overlay?.remove();
        _overlay = null;
      });
    }
  }

  static void showSuccessSnackBar(String message) {
    _show(message, Colors.green, Icons.check_circle);
  }

  static void showErrorSnackBar(String message) {
    _show(message, Colors.red, Icons.error);
  }

  static void showLoadingSnackBar(String message) {
    _show(message, Colors.blueGrey, Icons.sync, autoDismiss: false);
  }

  static void hideSnackBar() {
    _overlay?.remove();
    _overlay = null;
  }
}
