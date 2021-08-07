import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/app/ui/pages/home/home_page.dart';
import '../../../utils/dark_mode_extension.dart';

class HomeTabBar extends StatelessWidget {
  HomeTabBar({Key? key}) : super(key: key);
  final _homeController = homeProvider.read;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = isDark ? Colors.pinkAccent : Colors.blue;
    return SafeArea(
      top: false,
      child: TabBar(
        labelColor: color,
        indicator: _CustomIndicator(color),
        unselectedLabelColor: isDark ? Colors.white30 : Colors.black26,
        tabs: const [
          Tab(
            icon: Icon(Icons.home_rounded),
          ),
          Tab(
            icon: Icon(Icons.person_rounded),
          ),
        ],
        controller: _homeController.tabController,
      ),
    );
  }
}

class _CustomIndicator extends Decoration {
  final Color _color;
  const _CustomIndicator(this._color);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(_color);
  }
}

class _CirclePainter extends BoxPainter {
  final Color _color;

  _CirclePainter(this._color);
  @override
  void paint(
    Canvas canvas,
    Offset offset,
    ImageConfiguration configuration,
  ) {
    final size = configuration.size!;
    final paint = Paint();
    paint.color = _color;
    final center = Offset(offset.dx + size.width * 0.5, size.height * 0.8);
    canvas.drawCircle(center, 3, paint);
  }
}
