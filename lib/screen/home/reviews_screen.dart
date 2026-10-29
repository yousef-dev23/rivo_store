import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/reviews_getx_controller.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/review_card.dart';
import 'package:rivo_store/widget/states.dart';

/// «كل التقييمات» لمنتج — تُحمَّل صفحة بعد صفحة مع النزول.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.productId, this.productName});

  final int productId;
  final String? productName;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final String _tag = 'reviews-${widget.productId}';
  late final ReviewsGetxController c = Get.put(
    ReviewsGetxController(productId: widget.productId),
    tag: _tag,
  );
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        c.fetchReviews(more: true);
      }
    });
  }

  @override
  void dispose() {
    Get.delete<ReviewsGetxController>(tag: _tag);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            c.total.value > 0
                ? 'كل التقييمات (${c.total.value})'
                : 'كل التقييمات',
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.reviewsList.isEmpty) {
          return ListView(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.readingMaxWidth,
              top: 20,
              bottom: 20 + MediaQuery.paddingOf(context).bottom,
            ),
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Skeleton(height: 96),
              ),
            ),
          );
        }
        if (c.errorMessage.isNotEmpty) {
          return ErrorView(
            message: c.errorMessage.value,
            onRetry: c.fetchReviews,
          );
        }
        if (c.reviewsList.isEmpty) {
          return const EmptyView(
            icon: Icons.rate_review_outlined,
            title: 'لا توجد تقييمات بعد',
            body: 'كوني أول من يقيّم هذا المنتج.',
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchReviews,
          child: ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.readingMaxWidth,
              top: 20,
              bottom: 20 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: c.reviewsList.length + (c.isLoadingMore.value ? 1 : 0),
            itemBuilder: (_, i) => i < c.reviewsList.length
                ? ReviewCard(c.reviewsList[i])
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
        );
      }),
    );
  }
}
