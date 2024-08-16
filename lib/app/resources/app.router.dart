import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telehealth_app/app/helpers/sharedprefs.dart';
import 'package:telehealth_app/app/services/navigation_service.dart';
import 'package:telehealth_app/ui/features/app_nav_bar/app_nav_bar.dart';
import 'package:telehealth_app/ui/features/create_account/login_views/signin_user_view.dart';
import 'package:telehealth_app/ui/features/emergency/emergency_view/emergency_screen.dart';
import 'package:telehealth_app/ui/features/homepage/homepage_views/homepage.dart';
import 'package:telehealth_app/ui/features/profile_view/profile_view.dart';
import 'package:telehealth_app/ui/features/splash_screen/splash_screen.dart';
import 'package:telehealth_app/ui/shared/global_variables.dart';

class AppRouter {
  static Future<String> determineInitialRoute() async {
    final savedUsername = await getSharedPrefsSavedString("myUsername");
    final savedPassword = await getSharedPrefsSavedString("myPassword");
    final savedRole = await getSharedPrefsSavedString("myRole");
    if (savedUsername.isNotEmpty) {
      GlobalVariables.myUsername = savedUsername;
      GlobalVariables.myPassword = savedPassword;
      GlobalVariables.myRole = savedRole;
      return '/homeScreen'; // Navigate to home screen if user is logged in
    } else {
      return '/signInView'; // Navigate to sign-in screen if user is not logged in
    }
  }

  static Future<GoRouter> createRouter() async {
    final initialRoute = await determineInitialRoute();
    return GoRouter(
      navigatorKey: NavigationService.navigatorKey,
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),

        /// App Pages
        GoRoute(
          path: '/homepageView',
          pageBuilder: (context, state) =>
              CustomNormalTransition(
                  child: HomepageView(), key: state.pageKey),
        ),
        GoRoute(
          path: '/homeScreen',
          pageBuilder: (context, state) =>
              CustomNormalTransition(
                  child: const AppNavBar(), key: state.pageKey),
        ),
        GoRoute(
          path: '/scheduleView',
          pageBuilder: (context, state) =>
              CustomSlideTransition(
                  child: const Scaffold(), key: state.pageKey),
        ),
        GoRoute(
          path: '/profilePageView',
          pageBuilder: (context, state) =>
              CustomNormalTransition(
                  child: const ProfilePageView(), key: state.pageKey),
        ),
        GoRoute(
          path: '/signInView',
          builder: (context, state) => SignInView(),
        ),
        GoRoute(
          path: '/emergencyScreen',
          builder: (context, state) => EmergencyScreen(),
        ),
      ],
    );
  }
}

class CustomNormalTransition extends CustomTransitionPage {
  CustomNormalTransition({required LocalKey key, required Widget child})
      : super(
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 0),
          child: child,
        );
}

class CustomSlideTransition extends CustomTransitionPage {
  CustomSlideTransition({required LocalKey key, required Widget child})
      : super(
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
          child: child,
        );
}
