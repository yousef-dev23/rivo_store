import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/favorites_getx_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/models/product.dart';

/// قلب المفضلة مع حركة نبض.
class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon(this.product, {super.key, this.size = 36});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = Get.find<FavoritesGetxController>().isFavorite(product.id);
      return Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            final UserProfileGetxController profile = Get.find();
            if (!await profile.ensureLoggedIn()) return;
            await Get.find<FavoritesGetxController>().toggleFavorite(product);
          },
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(active),
                size: size * 0.52,
                color: active ? AppColors.danger : AppColors.ink,
              ),
            ),
          ),
        ),
      );
    });
  }
}
