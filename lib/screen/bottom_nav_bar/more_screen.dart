import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_api_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/auth/login_screen.dart';
import 'package:rivo_store/screen/home/store_details_screen.dart';
import 'package:rivo_store/screen/setting/more/edit_profile_screen.dart';
import 'package:rivo_store/screen/setting/order_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileGetxController profile = Get.find();
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: Obx(() {
        final customer = profile.userProfile.value;
        if (customer == null) {
          return EmptyView(
            icon: Icons.person_outline_rounded,
            title: 'أهلًا بكِ في متجرنا',
            body: 'سجّلي الدخول لمتابعة طلباتك وحفظ مفضلتك.',
            action: 'تسجيل الدخول',
            onAction: () => Get.to(() => const LoginScreen()),
          );
        }
        return ListView(
          padding: centeredPadding(
            MediaQuery.sizeOf(context).width,
            maxWidth: Responsive.readingMaxWidth,
            top: 8,
            bottom: Responsive.bottomClearance(context),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.ink,
                    Color.lerp(AppColors.ink, primary, 0.35)!,
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: primary,
                    child: Text(
                      customer.initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // البريد بلا مسافات فلا يلتف، فنقصّ نهايته إن طال جدًا.
                        Text(
                          customer.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.sp,
                          ),
                        ),
                        if (customer.phone != null)
                          Text(
                            customer.phone!,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Tile(
              icon: Icons.receipt_long_outlined,
              title: 'طلباتي',
              subtitle: 'تتبعي حالة طلباتك',
              onTap: () => Get.to(() => const OrderScreen()),
            ),
            _Tile(
              icon: Icons.favorite_border_rounded,
              title: 'المفضلة',
              onTap: () => MainScreenController.to.go(3),
            ),
            _Tile(
              icon: Icons.edit_outlined,
              title: 'تعديل بياناتي',
              onTap: () => Get.to(() => const EditProfileScreen()),
            ),
            _Tile(
              icon: Icons.storefront_outlined,
              title: 'عن المتجر وتواصل معنا',
              onTap: () => Get.to(() => const StoreDetailsScreen()),
            ),
            const SizedBox(height: 10),
            _Tile(
              icon: Icons.logout_rounded,
              title: 'تسجيل الخروج',
              danger: true,
              onTap: () async {
                final ok = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text('هل تريدين تسجيل الخروج من حسابك؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text(
                          'خروج',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) await UserApiController().logout();
              },
            ),
          ],
        );
      }),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.line),
          ),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color:
                  (danger
                          ? AppColors.danger
                          : Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: danger
                  ? AppColors.danger
                  : Theme.of(context).colorScheme.primary,
              size: 21,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 15.sp,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.muted),
                ),
          trailing: danger
              ? null
              : const Icon(Icons.chevron_right_rounded, color: AppColors.subtle),
        ),
      ),
    );
  }
}
