import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/models/product.dart';

/// السعر النهائي، والسعر القديم مشطوبًا عند وجود خصم.
/// [size] بوحدات التصميم، ويُحوَّل إلى .sp هنا.
class PriceView extends StatelessWidget {
  const PriceView(this.product, {super.key, this.size = 15});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          Fmt.money(product.finalPrice),
          style: TextStyle(
            fontSize: size.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        if (product.hasDiscount)
          Text(
            Fmt.money(product.price),
            style: TextStyle(
              fontSize: (size - 3).sp,
              color: AppColors.subtle,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.subtle,
            ),
          ),
      ],
    );
  }
}

class Stars extends StatelessWidget {
  const Stars(this.value, {super.key, this.size = 14});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final fill = (value - i).clamp(0.0, 1.0);
        return Icon(
          fill >= 0.75
              ? Icons.star_rounded
              : (fill >= 0.25
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded),
          size: size.sp,
          color: const Color(0xFFF5A623),
        );
      }),
    );
  }
}
