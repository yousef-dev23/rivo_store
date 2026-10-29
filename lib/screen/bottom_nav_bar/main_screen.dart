import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/screen/bottom_nav_bar/shopping_screen.dart';
import 'package:rivo_store/screen/bottom_nav_bar/categories_screen.dart';
import 'package:rivo_store/screen/bottom_nav_bar/favorites_screen.dart';
import 'package:rivo_store/screen/bottom_nav_bar/home_screen.dart';
import 'package:rivo_store/screen/bottom_nav_bar/more_screen.dart';

class MainScreenController extends GetxController {
  static MainScreenController get to => Get.find();
  final index = 0.obs;
  void go(int i) => index.value = i;
}

/// الهيكل الرئيسي: خمس تبويبات مع شريط سفلي عائم،
/// ويصبح شريطًا جانبيًا على الشاشات الواسعة (سطح المكتب).
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _tabs = [
    HomeScreen(),
    CategoriesScreen(),
    ShoppingScreen(),
    FavoritesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(MainScreenController());
    final sideNav = Responsive.useSideNav(context);
    return Obx(
      () => PopScope(
        canPop: shell.index.value == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) shell.go(0);
        },
        child: Scaffold(
          extendBody: !sideNav,
          body: sideNav
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SideBar(),
                    Expanded(
                      child: IndexedStack(
                        index: shell.index.value,
                        children: _tabs,
                      ),
                    ),
                  ],
                )
              : IndexedStack(index: shell.index.value, children: _tabs),
          bottomNavigationBar: sideNav ? null : const _BottomBar(),
        ),
      ),
    );
  }
}

const _navItems = [
  (Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
  (Icons.grid_view_outlined, Icons.grid_view_rounded, 'الأقسام'),
  (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'السلة'),
  (Icons.favorite_border_rounded, Icons.favorite_rounded, 'المفضلة'),
  (Icons.person_outline_rounded, Icons.person_rounded, 'حسابي'),
];

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      // heightFactor: 1 حتى لا يتمدد Align لكامل ارتفاع الشاشة.
      child: Align(
        heightFactor: 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68, maxWidth: 560),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(
              _navItems.length,
              (i) => Expanded(child: _NavItem(i)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      color: AppColors.ink,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: List.generate(
              _navItems.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _NavItem(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final shell = MainScreenController.to;
    final (icon, activeIcon, label) = _navItems[index];
    return Obx(() {
      final active = shell.index.value == index;
      final count = Get.find<CartGetxController>().count;
      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => shell.go(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: index == 2 && count > 0,
                label: Text('$count'),
                backgroundColor: primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? primary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    active ? activeIcon : icon,
                    color: active ? primary : Colors.white60,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
