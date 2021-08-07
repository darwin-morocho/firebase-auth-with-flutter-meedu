import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_auth/app/inject_dependencies.dart';
import 'package:flutter_meedu/router.dart' as router;
import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await injectDependencies();
  router.setDefaultTransition(router.Transition.fadeIn); 
  runApp(
    const MyApp(),
  );
}
