import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:telehealth_app/app/resources/app.router.dart';
import 'package:telehealth_app/app/services/navigation_service.dart';
import 'package:telehealth_app/ui/features/custom_nav_bar/page_index_class.dart';
import 'package:telehealth_app/utils/app_constants/app_theme_data.dart';

class TelehealthApp extends StatelessWidget {
  final GoRouter router;

  const TelehealthApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrentPage(),
      child: MaterialApp.router(
        /// MaterialApp params
        title: "Med Minder",
        scaffoldMessengerKey: NavigationService.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: appThemeData,

        /// GoRouter specific params
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
      ),
    );
  }
}
