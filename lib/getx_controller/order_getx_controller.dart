import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/widget/loading.dart';

/// طلباتي + إتمام الطلب + الإلغاء.
class OrderGetxController extends GetxController {
  var isLoading = false.obs;
  var ordersList = <Order>[].obs;
  final RxString errorMessage = ''.obs;

  var isLoadingDetails = false.obs;
  var isCancelling = false.obs;
  var orderDetails = Rxn<Order>();
  final RxString detailsErrorMessage = ''.obs;

  Future<void> fetchOrders() async {
    isLoading.value = ordersList.isEmpty;
    errorMessage.value = '';

    try {
      final response = await http
          .get(
            Uri.parse('${ApiSettings.orders}?per_page=50'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        ordersList.value = OrdersResponse.fromJson(body).data ?? [];
      } else {
        errorMessage.value = body['message'] ?? "فشل في جلب الطلبات.";
      }
    } catch (e) {
      errorMessage.value = "تعذر الاتصال بالخادم، تحقق من الإنترنت";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetails({required int id}) async {
    if (orderDetails.value?.id != id) orderDetails.value = null;
    isLoadingDetails.value = true;
    detailsErrorMessage.value = '';

    try {
      final response = await http
          .get(
            Uri.parse('${ApiSettings.orders}/$id'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        orderDetails.value = OrderResponse.fromJson(body).data;
      } else {
        detailsErrorMessage.value = body['message'] ?? "فشل في جلب الطلب.";
      }
    } catch (e) {
      detailsErrorMessage.value = "تعذر الاتصال بالخادم، تحقق من الإنترنت";
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<Order?> checkout({
    required String name,
    required String phone,
    required String address,
    String? notes,
    required String payment,
  }) async {
    LoadingOverlay.showCustomLoading();

    try {
      final response = await http
          .post(
            Uri.parse(ApiSettings.checkout),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({
              'customer_name': name.trim(),
              'phone': phone.trim(),
              'address': address.trim(),
              if (notes != null && notes.trim().isNotEmpty)
                'notes': notes.trim(),
              'payment_method': payment,
            }),
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        final order = OrderResponse.fromJson(body).data!;
        ordersList.insert(0, order);
        Get.find<CartGetxController>().reset();
        return order;
      } else {
        final details = body['error']?['details'];
        if (details is Map && details.isNotEmpty) {
          details.forEach((key, value) {
            Helpers.showSnackBar(
              message: value[0] ?? 'خطأ في حقل ($key)',
              error: true,
            );
          });
        } else {
          Helpers.showSnackBar(
            message: body['message'] ?? 'فشل إرسال الطلب',
            error: true,
          );
        }
        final String code = body['error']?['code'] ?? '';
        if (code == 'OUT_OF_STOCK' || code.startsWith('COUPON')) {
          Get.find<CartGetxController>().fetchCart();
        }
        return null;
      }
    } catch (e) {
      Helpers.showSnackBar(
        message: 'تعذر الاتصال بالخادم، تحقق من الإنترنت',
        error: true,
      );
      return null;
    } finally {
      LoadingOverlay.hideCustomLoading();
    }
  }

  Future<bool> cancelOrder({required int id}) async {
    isCancelling.value = true;

    try {
      final response = await http
          .post(
            Uri.parse('${ApiSettings.orders}/$id/cancel'),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final order = OrderResponse.fromJson(body).data!;
        orderDetails.value = order;
        final index = ordersList.indexWhere((o) => o.id == id);
        if (index >= 0) ordersList[index] = order;
        Helpers.showSnackBar(message: body['message'] ?? 'تم إلغاء الطلب');
        return true;
      } else {
        Helpers.showSnackBar(
          message: body['message'] ?? 'فشل إلغاء الطلب',
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
      isCancelling.value = false;
    }
  }
}
