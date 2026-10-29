import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/getx_controller/favorites_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/models/customer.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/widget/loading.dart';

class UserApiController {
  Future<bool> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      Helpers.showSnackBar(
        message: "يرجى إدخال البريد الإلكتروني وكلمة المرور",
        error: true,
      );
      return false;
    }

    var url = Uri.parse(ApiSettings.login);
    LoadingOverlay.showCustomLoading();

    try {
      var response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'device_name': 'flutter',
            }),
          )
          .timeout(ApiSettings.timeout);

      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decodedJson['success'] == true) {
        final authResponse = AuthResponse.fromJson(decodedJson);
        await _saveSession(authResponse);
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
            message: decodedJson['message'] ?? 'حدث خطأ ما',
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

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Helpers.showSnackBar(
        message: "يرجى إدخال جميع الحقول المطلوبة",
        error: true,
      );
      return false;
    }

    var url = Uri.parse(ApiSettings.register);
    LoadingOverlay.showCustomLoading();

    try {
      var response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Accept-Language': 'ar',
            },
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'phone': phone.trim(),
              'password': password,
              'password_confirmation': password,
              'device_name': 'flutter',
            }),
          )
          .timeout(ApiSettings.timeout);

      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decodedJson['success'] == true) {
        final authResponse = AuthResponse.fromJson(decodedJson);
        await _saveSession(authResponse);
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
            message: decodedJson['message'] ?? 'فشل التسجيل، حاول مرة أخرى',
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

  Future<void> logout() async {
    var url = Uri.parse(ApiSettings.logout);
    LoadingOverlay.showCustomLoading();

    try {
      await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              'Authorization': 'Bearer ${UserGetStorage().getToken()}',
            },
          )
          .timeout(ApiSettings.timeout);
    } catch (e) {
      // حتى لو فشل الطلب نخرج محليًا.
    } finally {
      await Get.find<UserProfileGetxController>().clearSession();
      LoadingOverlay.hideCustomLoading();
    }
  }

  Future<void> _saveSession(AuthResponse authResponse) async {
    await UserGetStorage().save(authResponse.user!, token: authResponse.token);
    Get.find<UserProfileGetxController>().userProfile.value = authResponse.user;
    Get.find<CartGetxController>().fetchCart();
    Get.find<FavoritesGetxController>().fetchFavorites();
  }
}
