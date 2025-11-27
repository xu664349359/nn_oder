import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/chef/chef_screens.dart';
import 'screens/foodie/foodie_screens.dart';
import 'models/menu_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';
    final isSplash = state.uri.toString() == '/';

    if (isSplash && authProvider.isLoading) {
      return null; // Stay on splash
    }

    if (!isLoggedIn && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    if (isLoggedIn) {
      final user = authProvider.currentUser!;
      
      // Check for binding
      if (user.partnerId == null && !state.uri.toString().startsWith('/binding')) {
        return '/binding';
      }
      
      // If bound (or skipping binding logic if we want), go to home
      if (user.partnerId != null || state.uri.toString().startsWith('/binding')) {
         if (state.uri.toString() == '/binding' && user.partnerId != null) {
            // If already bound and trying to go to binding, redirect to home
            return user.role == UserRole.chef ? '/chef/home' : '/foodie/home';
         }
         
         // If just bound, or navigating normally
         if (state.uri.toString() == '/binding') return null; // Stay on binding if partnerId is null
         
         // Normal role based redirection
         if (user.role == UserRole.chef) {
          if (state.uri.toString().startsWith('/chef')) return null;
          return '/chef/home';
        } else {
          if (state.uri.toString().startsWith('/foodie')) return null;
          return '/foodie/home';
        }
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RoleSelectionScreen(), // Using RoleSelection as register start
    ),
    GoRoute(
      path: '/binding',
      builder: (context, state) => const BindingScreen(),
    ),
    // Chef Routes
    GoRoute(
      path: '/chef/home',
      builder: (context, state) => const ChefHomeScreen(),
    ),
    GoRoute(
      path: '/chef/menu',
      builder: (context, state) => const MenuManagementScreen(),
    ),
    GoRoute(
      path: '/chef/intimacy',
      builder: (context, state) => const IntimacyManagementScreen(),
    ),
    // Foodie Routes
    GoRoute(
      path: '/foodie/home',
      builder: (context, state) => const FoodieHomeScreen(),
    ),
    GoRoute(
      path: '/foodie/menu',
      builder: (context, state) => const MenuBrowserScreen(),
    ),
    GoRoute(
      path: '/foodie/menu/detail',
      builder: (context, state) {
        final menuItem = state.extra as MenuItem;
        return MenuDetailScreen(menuItem: menuItem);
      },
    ),
    GoRoute(
      path: '/foodie/orders',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
  ],
);
