import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rivo_store/widget/product_grid.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/favorites_getx_controller.dart';
import 'package:rivo_store/widget/product_card.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/auth/login_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesGetxController favorites = Get.find();
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: Obx(() {
        if (!Get.find<UserProfileGetxController>().isLoggedIn) {
          return EmptyView(
            icon: Icons.favorite_border_rounded,
            title: 'احفظي القطع التي تحبينها',
            body: 'سجّلي الدخول لتظهر مفضلتك هنا.',
            action: 'تسجيل الدخول',
            onAction: () => Get.to(() => const LoginScreen()),
          );
        }
        if (favorites.isLoading.value && favorites.favoritesList.isEmpty) {
          return const ProductGridSkeleton();
        }
        if (favorites.favoritesList.isEmpty) {
          return EmptyView(
            icon: Icons.favorite_border_rounded,
            title: 'لا توجد منتجات في المفضلة',
            body: 'اضغطي على ♡ في أي منتج لحفظه هنا.',
            action: 'تصفحي المنتجات',
            onAction: () => MainScreenController.to.go(0),
          );
        }
        return RefreshIndicator(
          onRefresh: favorites.fetchFavorites,
          child: ProductGrid(
            bottom: Responsive.bottomClearance(context),
            itemCount: favorites.favoritesList.length,
            itemBuilder: (_, i) =>
                ProductCard(favorites.favoritesList[i], heroPrefix: 'fav'),
          ),
        );
      }),
    );
  }
}
