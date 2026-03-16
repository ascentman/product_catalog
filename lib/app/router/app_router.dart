import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/product_detail/screens/product_detail_screen.dart';
import '../../features/product_list/screens/product_list_screen.dart';
import '../../features/showcase/screens/showcase_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        GoRoute(
          path: 'products/:id',
          // Custom slide-up + fade transition for the detail screen.
          // Pairs with the Hero image transition for a layered feel.
          pageBuilder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: ProductDetailScreen(productId: id),
              transitionDuration: const Duration(milliseconds: 380),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Outgoing list fades out slightly.
                final fadeOut = Tween<double>(begin: 1.0, end: 0.85).animate(
                  CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
                );
                // Incoming detail slides up from 6% below and fades in.
                final slideIn = Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOut);

                return FadeTransition(
                  opacity: fadeOut,
                  child: SlideTransition(
                    position: slideIn,
                    child: FadeTransition(opacity: fadeIn, child: child),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/showcase',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const ShowcaseScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    ),
  ],
);
