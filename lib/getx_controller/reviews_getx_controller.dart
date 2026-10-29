import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/review.dart';

/// كل تقييمات منتج، صفحة بعد صفحة (تحميل لا نهائي).
class ReviewsGetxController {
  ReviewsGetxController({required this.productId}){
   fetchReviews();
  }

  final int productId;

  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var reviewsList = <Review>[].obs;
  var total = 0.obs;
  final RxString errorMessage = ''.obs;

  int _page = 1;
  bool _hasMore = true;


  Future<void> fetchReviews({bool more = false}) async {
    if (more && (!_hasMore || isLoadingMore.value || isLoading.value)) return;
    if (more) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
    }

    final url = Uri.parse('${ApiSettings.products}/$productId/reviews').replace(
      queryParameters: {'page': '${more ? _page + 1 : 1}', 'per_page': '15'},
    );

    try {
      final response = await http
          .get(
            url,
            headers: {'Accept': 'application/json', 'Accept-Language': 'ar'},
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final page = ReviewsResponse.fromJson(body);
        final list = page.data ?? [];
        if (more) {
          reviewsList.addAll(list);
        } else {
          reviewsList.value = list;
        }
        _page = page.meta?.page ?? 1;
        _hasMore = page.meta?.hasMore ?? false;
        total.value = page.meta?.total ?? reviewsList.length;
      } else if (!more) {
        errorMessage.value = body['message'] ?? 'فشل في جلب التقييمات';
      }
    } catch (e) {
      if (!more) errorMessage.value = 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}
