import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/theme_controller.dart';
import 'package:flutter_firebase_auth/app/ui/routes/app_routes.dart';
import 'package:flutter_firebase_auth/app/ui/routes/routes.dart';
import 'package:flutter_meedu/router.dart' as router;
import 'package:flutter_meedu/state.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, watch, __) {
      final theme = watch(themeProvider);
      return MaterialApp(
        title: 'Flutter FA',
        navigatorKey: router.navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.SPLASH,
        darkTheme: theme.darkTheme,
        theme: ThemeData.light(),
        themeMode: theme.mode,
        
        navigatorObservers: [
          router.observer,
        ],
        routes: appRoutes,
      );
    });
  }
}
