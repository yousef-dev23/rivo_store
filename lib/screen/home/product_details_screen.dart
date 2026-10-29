import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/getx_controller/product_details_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/models/review.dart';
import 'package:rivo_store/widget/favorite_icon.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/price.dart';
import 'package:rivo_store/widget/product_card.dart';
import 'package:rivo_store/widget/product_grid.dart';
import 'package:rivo_store/widget/quantity_stepper.dart';
import 'package:rivo_store/widget/review_card.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/home/reviews_screen.dart';

/// تفاصيل المنتج: معرض صور، السعر، المقاس واللون، الوصف، التقييمات، ومنتجات مشابهة.
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.id,
    this.product,
    this.hero,
  });

  final int id;
  final Product? product;
  final String? hero;

  @override
  State<ProductDetailsScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductDetailsScreen> {
  late final int _id = widget.id;
  late final String _hero = widget.hero ?? 'p-$_id';
  late final String _tag =
      'product-$_id-${DateTime.now().microsecondsSinceEpoch}';
  late final ProductDetailsGetxController _detailsController = Get.put(
    ProductDetailsGetxController(),
    tag: _tag,
  );
  final CartGetxController _cartController = Get.find();

  int _imageIndex = 0;
  int _quantity = 1;
  String? _size;
  String? _color;

  @override
  void initState() {
    super.initState();
    _detailsController.product.value = widget.product;
    _loadDetails();
  }

  @override
  void dispose() {
    Get.delete<ProductDetailsGetxController>(tag: _tag);
    super.dispose();
  }

  Future<void> _loadDetails() async {
    await _detailsController.fetchProductDetails(id: _id);
    final product = _detailsController.product.value;
    if (product == null || !mounted) return;
    setState(() {
      _size ??= product.sizes.length == 1 ? product.sizes.first : null;
      _color ??= product.colors.isNotEmpty ? product.colors.first : null;
    });
  }

  Future<void> _addToCart({bool buyNow = false}) async {
    final p = _detailsController.product.value;
    if (p!.sizes.isNotEmpty && _size == null) {
      Helpers.showSnackBar(message: 'اختاري المقاس أولًا', error: true);
      return;
    }
    final UserProfileGetxController profile = Get.find();
    if (!await profile.ensureLoggedIn()) return;
    final ok = await _cartController.addToCart(
      productId: p.id,
      quantity: _quantity,
      options: {'size': _size ?? 'M', 'color': _color},
    );
    if (ok && buyNow) {
      Get.until((route) => route.isFirst);
      MainScreenController.to.go(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = _detailsController.product.value;
      if (p == null) {
        return Scaffold(
          appBar: AppBar(),
          body: _detailsController.errorMessage.value.isNotEmpty
              ? ErrorView(
                  message: _detailsController.errorMessage.value,
                  onRetry: _loadDetails,
                )
              : const Center(child: CircularProgressIndicator()),
        );
      }
      return _buildDetails(context, p);
    });
  }

  Widget _buildDetails(BuildContext context, Product p) {
    final images = p.images.isNotEmpty
        ? p.images
        : [if (p.image != null) p.image!];
    final size = MediaQuery.sizeOf(context);

    // على الشاشات الواسعة: الصور والتفاصيل جنبًا إلى جنب بدل صورة بطول الشاشة.
    if (size.width >= _twoPaneWidth) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: FavoriteIcon(p, size: 40),
            ),
          ],
        ),
        body: MaxWidthBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: AspectRatio(
                    aspectRatio: 1 / 1.1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: _gallery(images),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  // 120: مساحة لشريط «أضيفي للسلة» السفلي فوق آخر المحتوى.
                  padding: EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    120 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: _info(context, p),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: _bottomBar(context, p),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // نسبة التصميم 1:1.1، بحد أقصى حتى يبقى جزء من التفاصيل ظاهرًا في الوضع الأفقي.
            expandedHeight: (size.width * 1.1).clamp(0, size.height * 0.6),
            pinned: true,
            backgroundColor: AppColors.paper,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: BackButton(color: AppColors.ink),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: FavoriteIcon(p, size: 40),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _gallery(images)),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: EdgeInsets.fromLTRB(20.w, 24, 20.w, 140),
              child: _info(context, p),
            ),
          ),
        ],
      ),
      bottomSheet: _bottomBar(context, p),
    );
  }

  static const _twoPaneWidth = 840.0;

  Widget _gallery(List<String> images) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _imageIndex = i),
          itemBuilder: (_, i) => i == 0
              ? Hero(tag: _hero, child: NetImage(images[i]))
              : NetImage(images[i]),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _imageIndex ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _imageIndex ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _info(BuildContext context, Product p) {
    final reviews = _detailsController.reviewsSummary.value;
    final related = _detailsController.relatedList;
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.categoryName != null)
          Text(
            p.categoryName!,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          p.name,
          style: TextStyle(
            fontSize: 23.sp,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: PriceView(p, size: 22)),
            if (p.discountPercent != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'خصم ${p.discountPercent}%',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (reviews != null && reviews.count > 0) ...[
              Stars(reviews.average),
              const SizedBox(width: 6),
              Text(
                '${reviews.average.toStringAsFixed(1)} (${reviews.count} تقييم)',
                style: TextStyle(color: AppColors.muted, fontSize: 13.sp),
              ),
              const SizedBox(width: 14),
            ],
            Icon(
              p.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16,
              color: p.inStock ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(width: 4),
            Text(
              !p.inStock
                  ? 'نفدت الكمية'
                  : (p.stock <= 5 ? 'باقي ${p.stock} فقط!' : 'متوفر'),
              style: TextStyle(
                color: p.inStock
                    ? (p.stock <= 5 ? AppColors.warning : AppColors.success)
                    : AppColors.danger,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (p.sizes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'المقاس',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: p.sizes.map((s) {
              final active = _size == s;
              return GestureDetector(
                onTap: () => setState(() => _size = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  constraints: const BoxConstraints(minWidth: 52),
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? AppColors.ink : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active ? AppColors.ink : AppColors.line,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (p.colors.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'اللون',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            children: p.colors.map((c) {
              final active = _color == c;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Fmt.hex(c),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: active
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Fmt.hex(c).computeLuminance() > 0.5
                                ? AppColors.ink
                                : Colors.white,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (p.description != null) ...[
          const SizedBox(height: 24),
          Text(
            'الوصف',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
          const SizedBox(height: 8),
          Text(
            p.description!,
            style: TextStyle(
              color: AppColors.muted,
              height: 1.8,
              fontSize: 14.5.sp,
            ),
          ),
        ],
        if (p.attributesDisplay
            .where((a) => a.type != 'color' && a.key != 'sizes')
            .isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'تفاصيل المنتج',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: p.attributesDisplay
                  .where((a) => a.type != 'color' && a.key != 'sizes')
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.label,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                          Text(
                            a.display,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _ReviewsSection(
          productId: p.id,
          summary: reviews,
          loading: _detailsController.isLoading.value,
          controller: _detailsController,
        ),
        if (related.isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(
            'قد يعجبك أيضًا',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          const SizedBox(height: 14),
          HorizontalProducts(
            padding: EdgeInsets.zero,
            itemWidth: 160.w,
            itemCount: related.length,
            itemBuilder: (_, i) =>
                ProductCard(related[i], heroPrefix: 'rel$_id'),
          ),
        ],
      ],
    );
  }

  Widget _bottomBar(BuildContext context, Product p) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: MaxWidthBox(
        maxWidth: Responsive.readingMaxWidth,
        child: p.inStock
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final label =
                      'أضيفي للسلة · ${Fmt.money(p.finalPrice * _quantity)}';
                  final stepper = QuantityStepper(
                    value: _quantity,
                    max: p.stock,
                    onChanged: (q) => setState(() => _quantity = q),
                  );
                  final button = _addButton(label);
                  // إن لم يتسع النص بجانب العداد (شاشة ضيقة أو خط كبير)
                  // نضع العداد فوق زر بعرض كامل بدل تصغير النص أو تكسيره.
                  if (!_labelFits(context, label, constraints.maxWidth)) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [stepper, const SizedBox(height: 10), button],
                    );
                  }
                  return Row(
                    children: [
                      stepper,
                      const SizedBox(width: 12),
                      Expanded(child: button),
                    ],
                  );
                },
              )
            : const FilledButton(onPressed: null, child: Text('نفدت الكمية')),
      ),
    );
  }

  /// العداد (40+34+40) + الفاصل 12 + حشوة FilledButton.icon في M3 (16+24)
  /// + الأيقونة 18 والمسافة بعدها 8.
  static const _besideLabel = 114 + 12 + 16 + 24 + 18 + 8;

  bool _labelFits(BuildContext context, String label, double maxWidth) {
    final style = Theme.of(
      context,
    ).filledButtonTheme.style?.textStyle?.resolve({});
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.rtl,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final fits = painter.width <= maxWidth - _besideLabel;
    painter.dispose();
    return fits;
  }

  Widget _addButton(String label) {
    return FilledButton.icon(
      onPressed: _cartController.isSubmitting.value ? null : () => _addToCart(),
      icon: _cartController.isSubmitting.value
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.shopping_bag_outlined),
      // بدون FittedBox: لا نصغّر النص؛ وإن ضاق يلتف (FilledButton.icon يضعه في Flexible).
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.productId,
    required this.summary,
    required this.loading,
    required this.controller,
  });

  final int productId;
  final ReviewsSummary? summary;
  final bool loading;
  final ProductDetailsGetxController controller;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'آراء العميلات',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
              ),
            ),
            TextButton.icon(
              onPressed: () => _openAddReview(context),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('أضيفي تقييمك'),
            ),
          ],
        ),
        if (s == null || s.count == 0)
          Text(
            loading
                ? '…'
                : 'لا توجد تقييمات بعد — كوني أول من يقيّم هذا المنتج.',
            style: const TextStyle(color: AppColors.muted),
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      s.average.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Stars(s.average),
                    const SizedBox(height: 4),
                    Text(
                      '${s.count} تقييم',
                      style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((r) {
                      final n = s.distribution[r] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$r', style: TextStyle(fontSize: 12.sp)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: s.count == 0 ? 0 : n / s.count,
                                  minHeight: 6,
                                  backgroundColor: AppColors.sand,
                                  color: const Color(0xFFF5A623),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...s.latest.map(ReviewCard.new),
          if (s.count > s.latest.length)
            Center(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.to(() => ReviewsScreen(productId: productId)),
                icon: const Icon(Icons.reviews_outlined, size: 18),
                label: Text('عرض كل التقييمات (${s.count})'),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _openAddReview(BuildContext context) async {
    final UserProfileGetxController profile = Get.find();
    if (!await profile.ensureLoggedIn()) return;
    int rating = 5;
    final comment = TextEditingController();
    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          // قابلة للتمرير: مع لوحة المفاتيح في الوضع الأفقي لا يتسع المحتوى.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قيّمي المنتج',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => setState(() => rating = i + 1),
                      icon: Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 38,
                        color: const Color(0xFFF5A623),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: comment,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'شاركينا رأيك (اختياري)',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    Get.back();
                    await controller.addReview(
                      productId: productId,
                      rating: rating,
                      comment: comment.text,
                    );
                  },
                  child: const Text('إرسال التقييم'),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
    comment.dispose();
  }
}
