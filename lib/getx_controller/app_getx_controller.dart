import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/store_info.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/helpers.dart';

/// معلومات المتجر (الاسم، الشعار، اللون، التوصيل) — تُحمّل مرة عند فتح التطبيق.
class AppGetxController extends GetxController {
  var isLoading = false.obs;
  var store = Rxn<StoreInfo>();
  var primary = const Color(0xFFF59E0B).obs;
  final RxString errorMessage = ''.obs;

  Future<bool> fetchStore() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http
          .get(
            Uri.parse(ApiSettings.store),
            headers: {'Accept': 'application/json', 'Accept-Language': 'ar'},
          )
          .timeout(ApiSettings.timeout);

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final info = StoreInfoResponse.fromJson(body).data!;
        store.value = info;
        Fmt.symbol = info.currencySymbol;
        if (info.primaryColor != primary.value) {
          primary.value = info.primaryColor;
          Get.changeTheme(AppTheme.build(info.primaryColor));
        }
        return true;
      } else {
        errorMessage.value = body['message'] ?? 'فشل في جلب بيانات المتجر';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
