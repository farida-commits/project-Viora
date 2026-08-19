import 'package:flutter/material.dart';

Route<T> slideRoute<T>(Widget page, {bool fromRight = true}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final beginOffset = Offset(fromRight ? 1.0 : -1.0, 0.0);
      final tween = Tween(begin: beginOffset, end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}