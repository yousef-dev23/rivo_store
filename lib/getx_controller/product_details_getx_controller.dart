import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/models/product_details.dart';
import 'package:rivo_store/models/review.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/widget/loading.dart';

/// تفاصيل المنتج + منتجات مشابهة + التقييمات.
class ProductDetailsGetxController extends GetxController {
  var isLoading = false.obs;
  var product = Rxn<Product>();
  var relatedList = <Product>[].obs;
  var reviewsSummary = Rxn<ReviewsSummary>();
  final RxString errorMessage = ''.obs;

  Future<void> fetchProductDetails({required int id}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final token = UserGetStorage().getToken();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiSettings.products}/$id'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final model = ProductDetailsResponse.fromJson(body);
        product.value = model.product;
        relatedList.value = model.related ?? [];
        reviewsSummary.value = model.reviewsSummary;
      } else {
        errorMessage.value = body['message'] ?? 'فشل في جلب المنتج';
      }
    } catch (e) {
      errorMessage.value = 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    LoadingOverlay.showCustomLoading();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiSettings.products}/$productId/reviews'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({
              'rating': rating,
              'comment': comment?.trim() ?? '',
            }),
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        Helpers.showSnackBar(message: body['message'] ?? 'شكرًا على تقييمك');
        return true;
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشل إرسال التقييم',
          error: true,
        );
        return false;
      }
    } catch (e) {
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
      return false;
    } finally {
      LoadingOverlay.hideCustomLoading();
    }
  }
}
