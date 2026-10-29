import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/widget/favorite_icon.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/price.dart';
import 'package:rivo_store/screen/home/product_details_screen.dart';

/// بطاقة المنتج في القوائم: صورة كبيرة، خصم، مفضلة، اسم، سعر، تقييم.
class ProductCard extends StatelessWidget {
  const ProductCard(
    this.product, {
    super.key,
    this.heroPrefix = 'p',
    this.imageAspect = gridImageAspect,
  });

  /// نسب الصور من فيجما: الشبكة 164×195، والقوائم الأفقية 168×220.
  static const gridImageAspect = 164 / 195;
  static const railImageAspect = 168 / 220;

  final Product product;
  final String heroPrefix;
  final double imageAspect;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => Get.to(
        () => ProductDetailsScreen(
          id: product.id,
          product: product,
          hero: '$heroPrefix-${product.id}',
        ),
        preventDuplicates: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: imageAspect,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: '$heroPrefix-${product.id}',
                    child: NetImage(
                      product.thumb ?? product.image,
                      radius: 20.r,
                    ),
                  ),
                ),
                if (product.discountPercent != null)
                  PositionedDirectional(
                    top: 10,
                    start: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: FavoriteIcon(product, size: 36),
                ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'نفدت الكمية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (product.categoryName != null)
            Text(
              product.categoryName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, color: AppColors.subtle),
            ),
          // سطران للاسم: الأسماء العربية الطويلة شائعة، وارتفاع الصف يتبع المحتوى.
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: PriceView(product, size: 14)),
              if (product.ratingCount > 0) ...[
                Icon(
                  Icons.star_rounded,
                  size: 14.sp,
                  color: const Color(0xFFF5A623),
                ),
                const SizedBox(width: 2),
                Text(
                  product.ratingAverage.toStringAsFixed(1),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.muted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
