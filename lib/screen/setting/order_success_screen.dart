import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/screen/setting/order_details_screen.dart';

/// شاشة النجاح بعد إتمام الطلب.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        // يتمدد لملء الشاشة (Spacer تعمل)، ويصبح قابلًا للتمرير إن ضاقت المساحة.
        child: LayoutBuilder(
          // العرض الأقصى قبل IntrinsicHeight حتى يُحسب الارتفاع على العرض الفعلي.
          builder: (context, constraints) => SingleChildScrollView(
            child: MaxWidthBox(
              maxWidth: Responsive.formMaxWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        const Spacer(),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.elasticOut,
                          builder: (_, v, child) =>
                              Transform.scale(scale: v, child: child),
                          child: Container(
                            width: 130.r,
                            height: 130.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  primary.withValues(alpha: 0.25),
                                  primary.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 44.r,
                                backgroundColor: primary,
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 52.r,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'تم استلام طلبك 🎉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'شكرًا لتسوقك معنا! سنؤكد طلبك قريبًا، وتستطيعين متابعة كل مرحلة من صفحة الطلب.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted, height: 1.7),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'رقم الطلب',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12.5.sp,
                                      ),
                                    ),
                                    Text(
                                      order.number,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'الإجمالي',
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12.5.sp,
                                    ),
                                  ),
                                  Text(
                                    Fmt.money(order.total),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.sp,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            Get.until((route) => route.isFirst);
                            Get.to(() => OrderDetailsScreen(id: order.id));
                          },
                          child: const Text('تتبّع الطلب'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => Get.until((route) => route.isFirst),
                          child: const Text('متابعة التسوق'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
