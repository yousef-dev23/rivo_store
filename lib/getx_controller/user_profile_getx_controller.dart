import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/getx_controller/favorites_getx_controller.dart';
import 'package:rivo_store/models/customer.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/screen/auth/login_screen.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/widget/loading.dart';

class UserProfileGetxController extends GetxController {
  var isLoading = false.obs;
  var userProfile = Rxn<Customer>();

  /// نقرأ userProfile أولًا دائمًا حتى تتابعه Obx حتى عندما لا يوجد توكن.
  bool get isLoggedIn =>
      userProfile.value != null && UserGetStorage().isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    if (UserGetStorage().isLoggedIn) {
      userProfile.value = UserGetStorage().getUser();
    }
  }

  Future<void> fetchUserProfile() async {
    if (!UserGetStorage().isLoggedIn) return;
    isLoading.value = true;

    try {
      final response = await http
          .get(
            Uri.parse(ApiSettings.profile),
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final customerResponse = CustomerResponse.fromJson(body);
        if (customerResponse.data != null) {
          userProfile.value = customerResponse.data;
          await UserGetStorage().save(customerResponse.data!);
        }
      } else if (response.statusCode == 401 ||
          body['error']?['code'] == 'NOT_STORE_CUSTOMER') {
        // التوكن انتهى أو يخص متجرًا آخر → نخرج بهدوء.
        await clearSession();
      }
    } catch (e) {
      // بدون إنترنت نبقى على البيانات المحفوظة.
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    var url = Uri.parse(ApiSettings.updateProfile);
    LoadingOverlay.showCustomLoading();

    try {
      var response = await http
          .put(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
            body: jsonEncode({'name': name.trim(), 'phone': phone.trim()}),
          )
          .timeout(ApiSettings.timeout);

      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decodedJson['success'] == true) {
        final customerResponse = CustomerResponse.fromJson(decodedJson);
        userProfile.value = customerResponse.data;
        await UserGetStorage().save(customerResponse.data!);
        Helpers.showSnackBar(
          message: decodedJson['message'] ?? 'تم تحديث الملف الشخصي',
        );
        return true;
      } else {
        final details = decodedJson['error']?['details'];
        if (details is Map && details.isNotEmpty) {
          details.forEach((key, value) {
            Helpers.showSnackBar(
              message: value[0] ?? 'حدث خطأ في الحقل ($key)',
              error: true,
            );
          });
        } else {
          Helpers.showSnackBar(
            message: decodedJson['message'] ?? 'فشل التحديث',
            error: true,
          );
        }
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

  Future<void> clearSession() async {
    await UserGetStorage().logout();
    userProfile.value = null;
    Get.find<CartGetxController>().reset();
    Get.find<FavoritesGetxController>().reset();
  }

  /// للأفعال التي تحتاج حسابًا (السلة، المفضلة، الطلب): يفتح الدخول ويرجع النتيجة.
  Future<bool> ensureLoggedIn() async {
    if (isLoggedIn) return true;
    final result = await Get.to(
      () => const LoginScreen(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    );
    return result == true || isLoggedIn;
  }
}
