import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/cart.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/helpers.dart';

/// السلة: كل عملية ترجع الملخص الكامل من الخادم (المجموع، الخصم، التوصيل، الإجمالي).
class CartGetxController extends GetxController {
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var summary = CartSummary().obs;
  var busyItemId = 0.obs;
  final RxString errorMessage = ''.obs;

  int get count => summary.value.itemsCount;

  @override
  void onInit() {
    fetchCart();
    super.onInit();
  }

  Future<void>fetchCart() async {
    String token = UserGetStorage().getToken();
    if (token.isEmpty) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http
          .get(
            Uri.parse(ApiSettings.cart),
            headers: {
              'Accept': 'application/json', 
              'Accept-Language': 'ar',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
      } else {
        errorMessage.value = body['message'] ?? "فشل في جلب السلة.";
      }
    } catch (e) {
      errorMessage.value = "تعذر الاتصال بالخادم، تحقق من الإنترنت";
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart({
    required int productId,
    int quantity = 1,
    Map<String, dynamic>? options,
  }) async {
    isSubmitting.value = true;

    try {
      final response = await http
          .post(
            Uri.parse(ApiSettings.cartItems),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({
              'product_id': productId,
              'quantity': quantity,
              if (options != null && options.isNotEmpty) 'options': options,
            }),
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
        Helpers.showSnackBar(message: body['message'] ?? 'تمت الإضافة للسلة');
        return true;
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشلت الإضافة للسلة',
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
      isSubmitting.value = false;
    }
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    if (quantity < 1) return removeItem(item);
    busyItemId.value = item.id;

    try {
      final response = await http
          .patch(
            Uri.parse('${ApiSettings.cartItems}/${item.id}'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({'quantity': quantity}),
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشل تعديل الكمية',
          error: true,
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
    } finally {
      busyItemId.value = 0;
    }
  }

  Future<void> removeItem(CartItem item) async {
    busyItemId.value = item.id;

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiSettings.cartItems}/${item.id}'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشل حذف المنتج',
          error: true,
        );
        fetchCart();
      }
    } catch (e) {
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
      fetchCart();
    } finally {
      busyItemId.value = 0;
    }
  }

  Future<bool> applyCoupon(String code) async {
    if (code.trim().isEmpty) return false;
    isSubmitting.value = true;

    try {
      final response = await http
          .post(
            Uri.parse(ApiSettings.cartCoupon),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({'code': code.trim()}),
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
        Helpers.showSnackBar(message: body['message'] ?? 'تم تطبيق الكوبون');
        return true;
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'الكوبون غير صالح',
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
      isSubmitting.value = false;
    }
  }

  Future<void> removeCoupon() async {
    try {
      final response = await http
          .delete(
            Uri.parse(ApiSettings.cartCoupon),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        summary.value = CartResponse.fromJson(body).data ?? CartSummary();
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشل إزالة الكوبون',
          error: true,
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
    }
  }

  void reset() => summary.value = CartSummary();
}
