import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_firebase_auth/app/ui/pages/home/home_controller.dart';
import 'package:flutter_firebase_auth/app/ui/pages/home/tabs/home/home_tab.dart';
import 'package:flutter_firebase_auth/app/ui/pages/home/tabs/profile/profile_tab.dart';
import 'package:flutter_firebase_auth/app/ui/pages/home/widgets/home_tab_bar.dart';
import 'package:flutter_firebase_auth/app/ui/routes/routes.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:flutter_meedu/router.dart' as router;
import 'package:flutter_meedu/state.dart';

final homeProvider = SimpleProvider(
  (_) => HomeController(),
);

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("🎃");
    return ProviderListener<HomeController>(
      provider: homeProvider,
      builder: (_, controller) {
        return Scaffold(
          bottomNavigationBar: HomeTabBar(),
          body: SafeArea(
            child: TabBarView(
              controller: controller.tabController,
              children: const [
                HomeTab(),
                ProfileTab(),
              ],
            ),
          ),
        );
      },
    );
  }
}
