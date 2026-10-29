import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/widget/product_grid.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/product_getx_controller.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/widget/product_card.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/states.dart';

/// قائمة المنتجات: قسم، بحث، أو مختارات — مع ترتيب وفلاتر وتحميل لا نهائي.
class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    this.title = 'المنتجات',
    this.categoryId,
    this.featured = false,
    this.sort,
    this.search = false,
  });

  final String title;
  final int? categoryId;
  final bool featured;
  final String? sort;
  final bool search;

  @override
  State<ProductScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductScreen> {
  late final bool _isSearch = widget.search;
  late final String _tag = 'products-${DateTime.now().microsecondsSinceEpoch}';
  late final ProductGetxController c = Get.put(
    ProductGetxController(
      categoryId: widget.categoryId,
      featuredOnly: widget.featured,
    ),
    tag: _tag,
  );
  final _search = TextEditingController();
  final _scroll = ScrollController();
  List<String> _recent = UserGetStorage().getRecentSearches();

  @override
  void initState() {
    super.initState();
    if (widget.sort != null) c.sort.value = widget.sort!;
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        c.fetchProducts(more: true);
      }
    });
  }

  @override
  void dispose() {
    Get.delete<ProductGetxController>(tag: _tag);
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final q = value.trim();
    c.search(q);
    if (q.isEmpty) return;
    _recent = [q, ..._recent.where((r) => r != q)].take(6).toList();
    UserGetStorage().saveRecentSearches(_recent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearch
            ? TextField(
                controller: _search,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
                onChanged: (v) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحثي عن منتج…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            _submitSearch('');
                          },
                        ),
                ),
              )
            : Text(widget.title),
      ),
      body: Column(
        children: [
          _Toolbar(c: c, onFilters: () => _openFilters(context)),
          if (_isSearch && _search.text.isEmpty && _recent.isNotEmpty)
            Padding(
              padding: centeredPadding(
                MediaQuery.sizeOf(context).width,
                top: 4,
                bottom: 8,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recent
                    .map(
                      (r) => ActionChip(
                        avatar: const Icon(Icons.history_rounded, size: 16),
                        label: Text(r),
                        onPressed: () {
                          _search.text = r;
                          _submitSearch(r);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) return const ProductGridSkeleton();
              if (c.errorMessage.value.isNotEmpty) {
                return ErrorView(
                  message: c.errorMessage.value,
                  onRetry: c.fetchProducts,
                );
              }
              if (c.productsList.isEmpty) {
                return EmptyView(
                  icon: Icons.search_off_rounded,
                  title: 'لا توجد نتائج',
                  body: c.activeFilters > 0
                      ? 'جرّبي تخفيف الفلاتر.'
                      : 'جرّبي كلمة بحث أخرى.',
                );
              }
              return RefreshIndicator(
                onRefresh: c.fetchProducts,
                child: ProductGrid(
                  controller: _scroll,
                  bottom: 40 + MediaQuery.paddingOf(context).bottom,
                  itemCount:
                      c.productsList.length + (c.isLoadingMore.value ? 2 : 0),
                  itemBuilder: (_, i) => i >= c.productsList.length
                      ? const ProductCardSkeleton()
                      : ProductCard(c.productsList[i], heroPrefix: _tag),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openFilters(BuildContext context) {
    final min = TextEditingController(
      text: c.minPrice.value?.toStringAsFixed(0) ?? '',
    );
    final max = TextEditingController(
      text: c.maxPrice.value?.toStringAsFixed(0) ?? '',
    );
    var inStock = c.inStockOnly.value;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          // قابلة للتمرير حتى تبقى الأزرار ظاهرة فوق لوحة المفاتيح على الشاشات القصيرة.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'السعر (₪)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: min,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'من'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: max,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'إلى'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: inStock,
                  onChanged: (v) => setState(() => inStock = v),
                  title: const Text(
                    'المتوفر فقط',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          c.minPrice.value = null;
                          c.maxPrice.value = null;
                          c.inStockOnly.value = false;
                          Get.back();
                          c.fetchProducts();
                        },
                        child: const Text('مسح'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          c.minPrice.value = double.tryParse(min.text);
                          c.maxPrice.value = double.tryParse(max.text);
                          c.inStockOnly.value = inStock;
                          Get.back();
                          c.fetchProducts();
                        },
                        child: const Text('عرض النتائج'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      isScrollControlled: true,
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.c, required this.onFilters});

  final ProductGetxController c;
  final VoidCallback onFilters;

  static const _sorts = [
    ('newest', 'desc', 'الأحدث'),
    ('best_selling', 'desc', 'الأكثر مبيعًا'),
    ('price', 'asc', 'السعر: الأقل'),
    ('price', 'desc', 'السعر: الأعلى'),
    ('rating', 'desc', 'الأعلى تقييمًا'),
  ];

  @override
  Widget build(BuildContext context) {
    // ارتفاع طبيعي بدل 54 ثابتة: الشرائح تكبر مع تكبير الخط.
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Badge(
              isLabelVisible: c.activeFilters > 0,
              label: Text('${c.activeFilters}'),
              child: ActionChip(
                avatar: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('فلترة'),
                onPressed: onFilters,
              ),
            ),
            const SizedBox(width: 8),
            ..._sorts.map((s) {
              final active = c.sort.value == s.$1 && c.order.value == s.$2;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(s.$3),
                  selected: active,
                  showCheckmark: false,
                  selectedColor: AppColors.ink,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => c.setSort(s.$1, s.$2),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
