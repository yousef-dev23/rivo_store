import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/home_getx_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/models/banner_item.dart';
import 'package:rivo_store/models/category.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/product_card.dart';
import 'package:rivo_store/widget/product_grid.dart';
import 'package:rivo_store/widget/section_header.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/home/product_details_screen.dart';
import 'package:rivo_store/screen/home/product_screen.dart';
import 'package:rivo_store/screen/home/store_details_screen.dart';

/// الرئيسية: تحية، بحث، سلايدر، أقسام، مميز، وصل حديثًا، الأكثر مبيعًا.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeGetxController home = Get.find();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (home.isLoading.value) return const _HomeSkeleton();
          if (home.errorMessage.value.isNotEmpty &&
              home.featured.isEmpty &&
              home.newest.isEmpty) {
            return ErrorView(
              message: home.errorMessage.value,
              onRetry: home.fetchHome,
            );
          }
          return RefreshIndicator(
            onRefresh: home.fetchHome,
            child: CustomScrollView(
              slivers: [
                const _Box(_Header()),
                const _Box(_SearchBar()),
                if (home.banners.isNotEmpty)
                  _Box(_BannerCarousel(home.banners)),
                if (home.categories.isNotEmpty) ...[
                  _Box(
                    SectionHeader(
                      'تسوّقي حسب القسم',
                      onMore: () => MainScreenController.to.go(1),
                    ),
                  ),
                  _Box(_CategoriesRow(home.categories)),
                ],
                if (home.featured.isNotEmpty) ...[
                  _Box(
                    SectionHeader(
                      'مختارات مميزة',
                      subtitle: 'قطع اخترناها لكِ بعناية',
                      onMore: () => Get.to(
                        () => const ProductScreen(
                          title: 'مختارات مميزة',
                          featured: true,
                        ),
                      ),
                    ),
                  ),
                  _Box(_HorizontalProducts(home.featured, hero: 'featured')),
                ],
                if (home.newest.isNotEmpty) ...[
                  _Box(
                    SectionHeader(
                      'وصل حديثًا',
                      onMore: () => Get.to(
                        () => const ProductScreen(title: 'وصل حديثًا'),
                      ),
                    ),
                  ),
                  SliverProductGrid(
                    itemCount: home.newest.length,
                    maxRows: 3,
                    itemBuilder: (_, i) =>
                        ProductCard(home.newest[i], heroPrefix: 'new'),
                  ),
                ],
                if (home.bestSellers.isNotEmpty) ...[
                  _Box(
                    SectionHeader(
                      'الأكثر مبيعًا',
                      subtitle: 'اختيارات عميلاتنا',
                      onMore: () => Get.to(
                        () => const ProductScreen(
                          title: 'الأكثر مبيعًا',
                          sort: 'best_selling',
                        ),
                      ),
                    ),
                  ),
                  _Box(_HorizontalProducts(home.bestSellers, hero: 'best')),
                ],
                // مسافة تكفي لظهور آخر المحتوى فوق الشريط السفلي العائم.
                SliverToBoxAdapter(
                  child: SizedBox(height: Responsive.bottomClearance(context)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// عنصر في الرئيسية محصور بعرض المحتوى الأقصى على الشاشات الواسعة.
class _Box extends StatelessWidget {
  const _Box(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SliverToBoxAdapter(child: MaxWidthBox(child: child));
}

class _Header extends StatelessWidget {
  const _Header();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 18) return 'نهارك سعيد';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14, 20.w, 6),
      child: Row(
        children: [
          Obx(() {
            final store = Get.find<AppGetxController>().store.value;
            return Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: ClipOval(child: NetImage(store?.logo)),
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final name = Get.find<UserProfileGetxController>()
                  .userProfile
                  .value
                  ?.name
                  .split(' ')
                  .first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name != null ? '$_greeting، $name 👋' : '$_greeting 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.muted),
                  ),
                  // اسم المتجر قد يكون طويلًا: نسمح بسطرين بدل قصّه.
                  Text(
                    Get.find<AppGetxController>().store.value?.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'عن المتجر',
            onPressed: () => Get.to(() => const StoreDetailsScreen()),
            icon: const Icon(Icons.storefront_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.sand,
              foregroundColor: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12, 20.w, 4),
      child: GestureDetector(
        onTap: () =>
            Get.to(() => const ProductScreen(title: 'البحث', search: true)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.subtle),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ابحثي عن فستان، عباية، حقيبة…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.subtle, fontSize: 14.sp),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel(this.banners);

  final List<BannerItem> banners;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  /// صور البانر من لوحة التحكم 1600×700، والنص والزر مرسومان داخل الصورة
  /// قرب الأطراف؛ لذلك يجب أن يطابق الإطار هذه النسبة وإلا قصّ BoxFit.cover الكتابة.
  static const _bannerAspect = 16 / 7;

  PageController _controller = PageController(viewportFraction: 0.9);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients || widget.banners.length < 2) return;
      _controller.animateToPage(
        (_page + 1) % widget.banners.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _open(BannerItem b) {
    if (b.linkType == 'product' && b.linkId != null) {
      Get.to(() => ProductDetailsScreen(id: b.linkId!));
    } else if (b.linkType == 'category' && b.linkId != null) {
      Get.to(
        () => ProductScreen(title: b.title ?? 'المنتجات', categoryId: b.linkId),
      );
    }
  }

  /// على الموبايل بانر واحد مع ظهور طرف المجاور، وعلى الشاشات الأعرض أكثر من بانر.
  double _fractionFor(double width) {
    if (width < Responsive.tablet) return 0.9;
    if (width < Responsive.desktop) return 0.62;
    return 0.46;
  }

  void _syncController(double fraction) {
    if (_controller.viewportFraction == fraction) return;
    final old = _controller;
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: _page,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        // في الوضع الأفقي نحدّ ارتفاع البانر (42% من الشاشة) ونضيّق عرضه
        // بنفس النسبة حتى لا يملأ الشاشة ولا تُقص الكتابة.
        final maxHeight = MediaQuery.sizeOf(context).height * 0.42;
        // 5 هامش داخلي من كل جانب حول كل بانر.
        final pageWidth = math.min(
          constraints.maxWidth * _fractionFor(constraints.maxWidth) - 10,
          maxHeight * _bannerAspect,
        );
        _syncController((pageWidth + 10) / constraints.maxWidth);
        return _carousel(primary, pageWidth / _bannerAspect);
      },
    );
  }

  Widget _carousel(Color primary, double height) {
    return Column(
      children: [
        const SizedBox(height: 14),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                double scale = 1;
                if (_controller.position.haveDimensions) {
                  scale = (1 - ((_controller.page ?? 0) - i).abs() * 0.06)
                      .clamp(0.92, 1.0);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: GestureDetector(
                onTap: () => _open(widget.banners[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: NetImage(widget.banners[i].image, radius: 22.r),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? primary : AppColors.line,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow(this.categories);

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    // ارتفاع طبيعي بدل SizedBox ثابت: أسماء الأقسام قد تأخذ سطرين أو تكبر مع الخط.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            _CategoryItem(categories[i]),
          ],
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem(this.c);

  final Category c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductScreen(title: c.name, categoryId: c.id)),
      child: SizedBox(
        width: 80.r,
        child: Column(
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ClipOval(child: NetImage(c.image)),
            ),
            const SizedBox(height: 8),
            Text(
              c.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts(this.products, {required this.hero});

  final List<Product> products;
  final String hero;

  @override
  Widget build(BuildContext context) {
    return HorizontalProducts(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemWidth: 168.w,
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(
        products[i],
        heroPrefix: hero,
        imageAspect: ProductCard.railImageAspect,
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: centeredPadding(
        MediaQuery.sizeOf(context).width,
        top: 20,
        bottom: 20,
      ),
      children: [
        const Row(
          children: [
            Skeleton(width: 46, height: 46, radius: 23),
            SizedBox(width: 12),
            Skeleton(width: 140, height: 18),
          ],
        ),
        const SizedBox(height: 20),
        const Skeleton(height: 54, radius: 18),
        const SizedBox(height: 18),
        const Skeleton(height: 160, radius: 22),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          children: List.generate(
            4,
            (_) => const Skeleton(width: 64, height: 64, radius: 32),
          ),
        ),
        const SizedBox(height: 24),
        const ProductGridSkeleton(count: 4),
      ],
    );
  }
}
