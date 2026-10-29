import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rivo_store/utils/app_colors.dart';

class Helpers {
  static void showSnackBar({required String message, bool error = false}) {
    final context = Get.context;
    if (context == null) return;
    final color = error ? AppColors.danger : AppColors.success;
    final wide = MediaQuery.sizeOf(context).width > 600;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          // على الشاشات الواسعة عرض ثابت بدل شريط بعرض الشاشة كلها
          // (SnackBar لا يقبل width و margin معًا).
          width: wide ? 560 : null,
          margin: wide ? null : const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Row(
            children: [
              Icon(
                error ? Icons.error_rounded : Icons.check_circle_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

/// تنسيق الأسعار والتواريخ والألوان.
class Fmt {
  Fmt._();

  static String symbol = '₪';

  static String money(num value) {
    final formatted = NumberFormat(
      value % 1 == 0 ? '#,##0' : '#,##0.00',
      'en',
    ).format(value);
    return formatted;
  }

  static String date(String? iso) {
    if (iso == null) return '';
    final d = DateTime.parse(iso).toLocal();
    return DateFormat('d MMMM y', 'ar').format(d);
  }

  static String dateTime(String? iso) {
    if (iso == null) return '';
    final d = DateTime.parse(iso).toLocal();
    return DateFormat('d MMM، h:mm a', 'ar').format(d);
  }

  static String ago(String? iso) {
    if (iso == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(iso).toLocal());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 30) return 'قبل ${diff.inDays} يوم';
    return date(iso);
  }

  /// "#E11D48" → Color
  static Color hex(String? value, [Color fallback = const Color(0xFFF59E0B)]) {
    if (value == null || value.length < 7) return fallback;
    return Color(int.parse('FF${value.substring(1, 7)}', radix: 16));
  }
}
