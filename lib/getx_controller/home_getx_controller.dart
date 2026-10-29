import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/banner_item.dart';
import 'package:rivo_store/models/category.dart';
import 'package:rivo_store/models/home.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';

/// الشاشة الرئيسية تأتي في طلب واحد: /home
class HomeGetxController extends GetxController {
  var isLoading = true.obs;
  var banners = <BannerItem>[].obs;
  var categories = <Category>[].obs;
  var featured = <Product>[].obs;
  var newest = <Product>[].obs;
  var bestSellers = <Product>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchHome();
    super.onInit();
  }

  Future<void> fetchHome() async {
    if (featured.isEmpty) isLoading.value = true;
    errorMessage.value = '';

    final token = UserGetStorage().getToken();

    try {
      final response = await http
          .get(
            Uri.parse(ApiSettings.home),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final homeData = HomeResponse.fromJson(body);
        banners.value = homeData.banners!;
        categories.value = homeData.categories ?? [];
        featured.value = homeData.featured ?? [];
        newest.value = homeData.newest ?? [];
        bestSellers.value = homeData.bestSellers ?? [];
      } else {
        errorMessage.value = body['message'] ?? 'فشل في جلب الصفحة الرئيسية';
      }
    } catch (e) {
      errorMessage.value = 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
    } finally {
      isLoading.value = false;
    }
  }
}
