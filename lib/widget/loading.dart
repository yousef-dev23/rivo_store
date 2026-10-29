import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/widget/product_card.dart';
import 'package:rivo_store/widget/product_grid.dart';

/// مستطيل لامع يظهر أثناء التحميل.

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.radius = 12});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 3, 0),
              end: Alignment(_c.value * 3, 0),
              colors: const [AppColors.sand, Color(0xFFFBF8F3), AppColors.sand],
            ),
          ),
        );
      },
    );
  }
}

/// شبكة منتجات وهمية أثناء التحميل — بنفس أعمدة ونِسب الشبكة الحقيقية.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ProductGrid(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      top: 16,
      itemCount: count,
      itemBuilder: (_, _) => const ProductCardSkeleton(),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: ProductCard.gridImageAspect,
          child: Skeleton(radius: 20),
        ),
        SizedBox(height: 10),
        FractionallySizedBox(widthFactor: 0.75, child: Skeleton(height: 14)),
        SizedBox(height: 6),
        FractionallySizedBox(widthFactor: 0.4, child: Skeleton(height: 14)),
      ],
    );
  }
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void showCustomLoading() {
    // الـ Overlay الخاص بالـ Navigator الرئيسي (Get.key) مباشرة.
    final overlay = Get.key.currentState?.overlay;

    if (overlay == null || _overlayEntry != null) {
      return;
    }

    final entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          Center(
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);
    _overlayEntry = entry;
  }

  static void hideCustomLoading() {
    // نفرّغ المتغير أولًا حتى لا يبقى عالقًا لو فشل remove (مثلًا بعد hot reload).
    final entry = _overlayEntry;
    _overlayEntry = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {
      // كانت قد أُزيلت من الشاشة مسبقًا.
    }
  }
}
