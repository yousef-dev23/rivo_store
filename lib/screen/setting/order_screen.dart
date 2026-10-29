import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/order_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/widget/loading.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/setting/order_details_screen.dart';

/// ألوان حالات الطلب.
Color orderStatusColor(String status) => switch (status) {
  'pending' => const Color(0xFFF59E0B),
  'confirmed' => const Color(0xFF0EA5E9),
  'preparing' => const Color(0xFF8B5CF6),
  'shipped' => const Color(0xFF6366F1),
  'delivered' => AppColors.success,
  _ => AppColors.danger,
};

IconData orderStatusIcon(String status) => switch (status) {
  'pending' => Icons.hourglass_top_rounded,
  'confirmed' => Icons.thumb_up_alt_outlined,
  'preparing' => Icons.inventory_2_outlined,
  'shipped' => Icons.local_shipping_outlined,
  'delivered' => Icons.check_circle_outline_rounded,
  _ => Icons.cancel_outlined,
};

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrderScreen> {
  final OrderGetxController c = Get.find();

  @override
  void initState() {
    super.initState();
    c.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: Obx(() {
        if (c.isLoading.value) {
          return ListView(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.readingMaxWidth,
              top: 20,
            ),
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Skeleton(height: 96, radius: 20),
              ),
            ),
          );
        }
        if (c.errorMessage.value.isNotEmpty) {
          return ErrorView(
            message: c.errorMessage.value,
            onRetry: c.fetchOrders,
          );
        }
        if (c.ordersList.isEmpty) {
          return EmptyView(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد طلبات بعد',
            body: 'عندما تطلبين، ستجدين طلباتك وتتبعها هنا.',
            action: 'تسوّقي الآن',
            onAction: Get.back,
          );
        }
        return RefreshIndicator(
          onRefresh: c.fetchOrders,
          child: ListView.separated(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.readingMaxWidth,
              top: 20,
              bottom: 20 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: c.ordersList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(c.ordersList[i]),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(order.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Get.to(() => OrderDetailsScreen(id: order.id));
          Get.find<OrderGetxController>().fetchOrders();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(orderStatusIcon(order.status), color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wrap بدل Row: رقم الطلب + الحالة لا يتسعان معًا تحت 400 تقريبًا.
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          order.number,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.statusLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Fmt.date(order.createdAt)} · ${order.itemsCount} قطعة',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Fmt.money(order.total),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
