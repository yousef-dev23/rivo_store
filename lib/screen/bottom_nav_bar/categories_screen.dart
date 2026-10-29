import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/home_getx_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/home/product_screen.dart';

/// كل الأقسام كبطاقات صور كبيرة.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  /// عرض البطاقة بين ~160 و 240: عمودان على الموبايل وأكثر كلما اتسعت الشاشة.
  static const _delegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.9,
  );

  @override
  Widget build(BuildContext context) {
    final HomeGetxController home = Get.find();
    return Scaffold(
      appBar: AppBar(title: const Text('الأقسام')),
      body: Obx(() {
        if (home.isLoading.value) {
          return GridView.builder(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              top: 20,
              bottom: 20,
            ),
            gridDelegate: _delegate,
            itemCount: 6,
            itemBuilder: (_, _) => const Skeleton(radius: 22),
          );
        }
        if (home.categories.isEmpty) {
          return const EmptyView(
            icon: Icons.grid_view_rounded,
            title: 'لا توجد أقسام بعد',
          );
        }
        return RefreshIndicator(
          onRefresh: home.fetchHome,
          child: GridView.builder(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              top: 8,
              bottom: Responsive.bottomClearance(context),
            ),
            gridDelegate: _delegate,
            itemCount: home.categories.length,
            itemBuilder: (_, i) {
              final c = home.categories[i];
              return GestureDetector(
                onTap: () => Get.to(
                  () => ProductScreen(title: c.name, categoryId: c.id),
                  preventDuplicates: false,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(c.image),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC0F1222)],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 14,
                        end: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              '${c.productsCount} منتج',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        top: 12,
                        end: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 16.r,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
