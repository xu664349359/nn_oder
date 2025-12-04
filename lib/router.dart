import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/chef/chef_screens.dart';
import 'screens/foodie/foodie_screens.dart';
import 'screens/unbound/unbound_profile_screen.dart';
import 'screens/unbound/invitation_screen.dart';
import 'screens/moments/moments_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/binding_success/binding_success_screen.dart';
import 'screens/foodie/shopping_cart_screen.dart';
import 'screens/foodie/checkout_screen.dart';
import 'models/menu_model.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';
    final isSplash = state.uri.toString() == '/';

    // Allow Splash Screen to handle initial navigation
    if (isSplash) return null;

    if (!isLoggedIn && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    if (isLoggedIn) {
      final user = authProvider.currentUser;
      final isBound = user?.partnerId != null;
      final isUnboundRoute = state.uri.toString().startsWith('/unbound');
      final isSettingsRoute = state.uri.toString() == '/settings';
      final isBindingSuccessRoute = state.uri.toString() == '/binding-success';

      // If not bound, force to unbound profile (unless already there, inviting, settings, or binding success)
      if (!isBound) {
        if (!isUnboundRoute && !isSettingsRoute && !isBindingSuccessRoute) return '/unbound/profile';
        return null;
      }

      // If bound, prevent access to auth/unbound pages (but allow binding-success animation)
      if (isLoggingIn || isRegistering || isUnboundRoute) {
        if (user?.role == UserRole.chef) return '/chef/home';
        return '/foodie/home';
      }

      // Allow binding success animation even for bound users
      if (isBindingSuccessRoute) return null;

      // Normal role based redirection for bound users
      if (user?.role == UserRole.chef) {
        if (state.uri.toString().startsWith('/chef') || 
            state.uri.toString() == '/settings' || 
            state.uri.toString() == '/moments') return null;
        return '/chef/home';
      } else if (user?.role == UserRole.foodie) {
        if (state.uri.toString().startsWith('/foodie') || 
            state.uri.toString() == '/settings' || 
            state.uri.toString() == '/moments') return null;
        return '/foodie/home';
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
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/unbound/profile',
      builder: (context, state) => const UnboundProfileScreen(),
    ),
    GoRoute(
      path: '/unbound/invite',
      builder: (context, state) => const InvitationScreen(),
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
        Object? extra = state.extra;
        MenuItem menuItem;
        if (extra is MenuItem) {
          menuItem = extra;
        } else if (extra is Map<String, dynamic>) {
          menuItem = MenuItem.fromJson(extra);
        } else {
          // Fallback or error handling
          return const Scaffold(body: Center(child: Text('Error: Invalid menu item data')));
        }
        return MenuDetailScreen(menuItem: menuItem);
      },
    ),
    GoRoute(
      path: '/foodie/orders',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: '/moments',
      builder: (context, state) => const MomentsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/binding-success',
      builder: (context, state) => const BindingSuccessScreen(),
    ),
    GoRoute(
      path: '/foodie/cart',
      builder: (context, state) => const ShoppingCartScreen(),
    ),
    GoRoute(
      path: '/foodie/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
  ],
  );
}
