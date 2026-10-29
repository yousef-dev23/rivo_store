import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/order_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/setting/order_screen.dart';
import 'package:rivo_store/screen/home/product_details_screen.dart';

/// تفاصيل الطلب مع شريط تتبع مراحل الطلب (timeline).
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.id});

  final int id;

  @override
  State<OrderDetailsScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderDetailsScreen> {
  final OrderGetxController _orderController = Get.find();

  @override
  void initState() {
    super.initState();
    _orderController.fetchOrderDetails(id: widget.id);
  }

  Future<void> _load() => _orderController.fetchOrderDetails(id: widget.id);

  Future<void> _cancel() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنتِ متأكدة من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'إلغاء الطلب',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _orderController.cancelOrder(id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final o = _orderController.orderDetails.value;
      final cancelling = _orderController.isCancelling.value;
      return _buildBody(o, cancelling);
    });
  }

  Widget _buildBody(Order? o, bool cancelling) {
    return Scaffold(
      appBar: AppBar(title: Text(o?.number ?? 'تفاصيل الطلب')),
      body: o == null
          ? (_orderController.detailsErrorMessage.value.isNotEmpty
                ? ErrorView(
                    message: _orderController.detailsErrorMessage.value,
                    onRetry: _load,
                  )
                : const Center(child: CircularProgressIndicator()))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: centeredPadding(
                  MediaQuery.sizeOf(context).width,
                  maxWidth: Responsive.readingMaxWidth,
                  top: 8,
                  bottom: 40 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  _StatusHero(o),
                  const SizedBox(height: 18),
                  _Card(
                    title: 'تتبّع الطلب',
                    child: _Timeline(
                      o.timeline,
                      cancelled: o.status == 'cancelled',
                    ),
                  ),
                  _Card(
                    title: 'المنتجات (${o.itemsCount})',
                    child: Column(
                      children: o.items
                          .map(
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: i.productId == null
                                    ? null
                                    : () => Get.to(
                                        () => ProductDetailsScreen(
                                          id: i.productId!,
                                        ),
                                      ),
                                child: Row(
                                  children: [
                                    NetImage(
                                      i.image,
                                      width: 58,
                                      height: 68,
                                      radius: 12,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            i.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                '${i.quantity} × ${Fmt.money(i.price)}',
                                                style: TextStyle(
                                                  color: AppColors.muted,
                                                  fontSize: 12.5.sp,
                                                ),
                                              ),
                                              if (i.options['size'] != null)
                                                Text(
                                                  '  ·  ${i.options['size']}',
                                                  style: TextStyle(
                                                    color: AppColors.muted,
                                                    fontSize: 12.5.sp,
                                                  ),
                                                ),
                                              if (i.options['color'] !=
                                                  null) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                    color: Fmt.hex(
                                                      i.options['color'],
                                                    ),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors.line,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Fmt.money(i.total),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _Card(
                    title: 'التوصيل',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Info(Icons.person_outline_rounded, o.customerName),
                        _Info(Icons.phone_outlined, o.phone, ltr: true),
                        _Info(Icons.location_on_outlined, o.address),
                        if (o.notes != null)
                          _Info(Icons.sticky_note_2_outlined, o.notes!),
                        _Info(Icons.payments_outlined, o.paymentLabel),
                      ],
                    ),
                  ),
                  _Card(
                    title: 'الدفع',
                    child: Column(
                      children: [
                        _Row('المجموع', Fmt.money(o.subtotal)),
                        if (o.discount > 0)
                          _Row(
                            'الخصم${o.couponCode != null ? ' (${o.couponCode})' : ''}',
                            '- ${Fmt.money(o.discount)}',
                            color: AppColors.success,
                          ),
                        _Row('التوصيل', Fmt.money(o.deliveryFee)),
                        const Divider(height: 20),
                        _Row('الإجمالي', Fmt.money(o.total), bold: true),
                      ],
                    ),
                  ),
                  if (o.canCancel)
                    OutlinedButton.icon(
                      onPressed: cancelling ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(cancelling ? 'جارٍ الإلغاء…' : 'إلغاء الطلب'),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero(this.o);

  final Order o;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(o.status);
    final message = switch (o.status) {
      'pending' => 'استلمنا طلبك وننتظر تأكيده',
      'confirmed' => 'تم تأكيد طلبك وسنبدأ بتجهيزه',
      'preparing' => 'نجهّز طلبك بكل حب',
      'shipped' => 'طلبك في الطريق إليكِ 🚚',
      'delivered' => 'تم تسليم طلبك، نتمنى أن ينال إعجابك',
      _ => 'تم إلغاء هذا الطلب',
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, AppColors.ink, 0.35)!],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(
              orderStatusIcon(o.status),
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.statusLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.sp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Fmt.dateTime(o.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline(this.steps, {required this.cancelled});

  final List<TimelineStep> steps;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;
        final color = s.status == 'cancelled'
            ? AppColors.danger
            : (s.done ? primary : AppColors.line);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: s.done ? color : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: s.done
                        ? Icon(
                            s.status == 'cancelled'
                                ? Icons.close_rounded
                                : Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: steps[i + 1].done ? primary : AppColors.line,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: s.done ? AppColors.ink : AppColors.subtle,
                        ),
                      ),
                      if (s.at != null)
                        Text(
                          Fmt.dateTime(s.at),
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.sp,
                          ),
                        ),
                      if (s.note != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s.note!,
                            style: TextStyle(fontSize: 12.5.sp),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text, {this.ltr = false});

  final IconData icon;
  final String text;
  final bool ltr;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(text, textDirection: ltr ? TextDirection.ltr : null),
          ),
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color, this.bold = false});

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? AppColors.ink : AppColors.muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.ink,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: (bold ? 16 : 14).sp,
          ),
        ),
      ],
    ),
  );
}
