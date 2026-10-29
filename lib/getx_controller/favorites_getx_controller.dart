import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/helpers.dart';

/// المفضلة: نحفظ أرقام المنتجات لتظهر القلوب ممتلئة في كل الشاشات.
class FavoritesGetxController extends GetxController {
  var isLoading = false.obs;
  var favoritesList = <Product>[].obs;
  var favoriteIds = <int>{}.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchFavorites();
    super.onInit();
  }

  bool isFavorite(int id) => favoriteIds.contains(id);

  Future<void> fetchFavorites() async {
    String token = UserGetStorage().getToken();
    if (token.isEmpty) return;

    isLoading = true.obs;
    errorMessage.value = '';

    try {
      final response = await http
          .get(
            Uri.parse(ApiSettings.favorites),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final favoritesData = ProductsResponse.fromJson(body);
        favoritesList.value = favoritesData.data ?? [];
        favoriteIds
          ..clear()
          ..addAll(favoritesList.map((p) => p.id));
      } else {
        errorMessage.value = body['message'] ?? "فشل في جلب قائمة المفضلة.";
      }
    } catch (e) {
      errorMessage.value = "تعذر الاتصال بالخادم، تحقق من الإنترنت";
    } finally {
      isLoading.value = false;
    }
  }

  /// تغيير فوري في الواجهة ثم تأكيد من الخادم (ونرجع إذا فشل).
  Future<void> toggleFavorite(Product product) async {
    final isCurrentlyFavorite = favoriteIds.contains(product.id);

    if (isCurrentlyFavorite) {
      favoriteIds.remove(product.id);
      favoritesList.removeWhere((fav) => fav.id == product.id);
    } else {
      favoriteIds.add(product.id);
      product.isFavorite = true;
      favoritesList.insert(0, product);
    }

    try {
      final response = await http
          .post(
            Uri.parse('${ApiSettings.favorites}/${product.id}'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || body['success'] != true) {
        _rollback(product.id, isCurrentlyFavorite);
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشلت عملية المفضلة.',
          error: true,
        );
      }
    } catch (e) {
      _rollback(product.id, isCurrentlyFavorite);
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
    }
  }

  void _rollback(int productId, bool wasFavorite) {
    wasFavorite ? favoriteIds.add(productId) : favoriteIds.remove(productId);
    fetchFavorites();
  }

  void reset() {
    favoriteIds.clear();
    favoritesList.clear();
  }
}
