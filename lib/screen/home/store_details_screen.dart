import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/widget/net_image.dart';

/// عن المتجر: الغلاف، الوصف، التوصيل، وأزرار الاتصال وواتساب.
class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({super.key});

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Helpers.showSnackBar(message: 'تعذّر فتح التطبيق', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = Get.find<AppGetxController>().store.value;
    if (store == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // 220 على عرض 375 كما في التصميم، مع حد أدنى وأقصى للشاشات الأخرى.
            expandedHeight: (MediaQuery.sizeOf(context).width * 0.587).clamp(
              200,
              340,
            ),
            pinned: true,
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: BackButton(color: AppColors.ink),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: NetImage(store.cover)),
          ),
          SliverToBoxAdapter(
            child: MaxWidthBox(
              maxWidth: Responsive.readingMaxWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.line),
                          ),
                          child: ClipOval(child: NetImage(store.logo)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (store.tagline != null)
                                Text(
                                  store.tagline!,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (store.description != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        store.description!,
                        style: const TextStyle(
                          height: 1.8,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            icon: Icons.local_shipping_outlined,
                            label: 'التوصيل',
                            value: store.deliveryFee == 0
                                ? 'مجاني'
                                : Fmt.money(store.deliveryFee),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Stat(
                            icon: Icons.shopping_cart_checkout_rounded,
                            label: 'الحد الأدنى',
                            value: store.minOrder == 0
                                ? 'بدون'
                                : Fmt.money(store.minOrder),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (store.address != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.location_on_outlined,
                          color: primary,
                        ),
                        title: const Text('العنوان'),
                        subtitle: Text(store.address!),
                      ),
                    const SizedBox(height: 10),
                    if (store.whatsapp != null)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _open(
                          Uri.parse(
                            'https://wa.me/${store.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
                          ),
                        ),
                        icon: const Icon(Icons.chat_rounded),
                        label: const Text('تواصلي معنا عبر واتساب'),
                      ),
                    if (store.phone != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _open(Uri.parse('tel:${store.phone}')),
                        icon: const Icon(Icons.call_outlined),
                        label: Text('اتصال: ${store.phone}'),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'متجر على منصة سوقنا',
                        style: TextStyle(
                          color: AppColors.subtle,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );
}
