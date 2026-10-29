import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/models/cart.dart';
import 'package:rivo_store/widget/net_image.dart';
import 'package:rivo_store/widget/quantity_stepper.dart';
import 'package:rivo_store/widget/states.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/auth/login_screen.dart';
import 'package:rivo_store/screen/home/product_details_screen.dart';
import 'package:rivo_store/screen/setting/payment_screen.dart';

/// السلة: المنتجات، الكوبون، الملخص، والانتقال لإتمام الطلب.
class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartGetxController cart = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(cart.count > 0 ? 'السلة (${cart.count})' : 'السلة'),
        ),
      ),
      body: Obx(() {
        if (!Get.find<UserProfileGetxController>().isLoggedIn) {
          return EmptyView(
            icon: Icons.lock_outline_rounded,
            title: 'سجّلي الدخول لعرض سلتك',
            body: 'احفظي منتجاتك وأكملي طلبك من أي جهاز.',
            action: 'تسجيل الدخول',
            onAction: () => Get.to(() => const LoginScreen()),
          );
        }
        if (cart.isLoading.value && cart.summary.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = cart.summary.value;
        if (s.isEmpty) {
          return EmptyView(
            icon: Icons.shopping_bag_outlined,
            title: 'سلتك فارغة',
            body: 'تصفحي أحدث القطع وأضيفي ما يعجبك.',
            action: 'ابدئي التسوق',
            onAction: () => MainScreenController.to.go(0),
          );
        }
        return RefreshIndicator(
          onRefresh: cart.fetchCart,
          child: ListView(
            // المسافة السفلية = الشريط العائم + ورقة «إتمام الطلب» فوقه.
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.readingMaxWidth,
              top: 8,
              bottom: Responsive.bottomClearance(context, 150),
            ),
            children: [
              ...s.items.map((item) => _CartLine(item)),
              const SizedBox(height: 8),
              _CouponBox(s),
              const SizedBox(height: 16),
              _Summary(s),
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        final s = cart.summary.value;
        if (!Get.find<UserProfileGetxController>().isLoggedIn || s.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: MaxWidthBox(
            maxWidth: Responsive.readingMaxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!s.meetsMinOrder)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'أضيفي منتجات بقيمة ${Fmt.money(s.minOrder - s.subtotal)} للوصول للحد الأدنى للطلب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                FilledButton(
                  onPressed: s.meetsMinOrder
                      ? () => Get.to(() => const PaymentScreen())
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(child: Text('إتمام الطلب')),
                      const SizedBox(width: 12),
                      Text(Fmt.money(s.total)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine(this.item);

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final CartGetxController cart = Get.find();
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => cart.removeItem(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () =>
                  Get.to(() => ProductDetailsScreen(id: item.productId)),
              child: NetImage(
                item.image,
                width: 86.r,
                height: 100.r,
                radius: 14.r,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _OptionsRow(item.options),
                  if (!item.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'الكمية المطلوبة غير متوفرة',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Fmt.money(item.lineTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      Obx(
                        () => QuantityStepper(
                          compact: true,
                          value: item.quantity,
                          max: item.stock,
                          busy: cart.busyItemId.value == item.id, onChanged: (int value) {

                        },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsRow extends StatelessWidget {
  const _OptionsRow(this.options);

  final Map<String, String> options;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (options['size'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'المقاس: ${options['size']}',
              style: TextStyle(fontSize: 11.5.sp),
            ),
          ),
        if (options['color'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('اللون ', style: TextStyle(fontSize: 11.5.sp)),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Fmt.hex(options['color']),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CouponBox extends StatefulWidget {
  const _CouponBox(this.summary);

  final CartSummary summary;

  @override
  State<_CouponBox> createState() => _CouponBoxState();
}

class _CouponBoxState extends State<_CouponBox> {
  final _code = TextEditingController();
  final CartGetxController cart = Get.find();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final ok = await cart.applyCoupon(_code.text);
    if (ok) {
      _code.clear();
      if (mounted) FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final primary = Theme.of(context).colorScheme.primary;
    if (s.couponCode != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (s.couponError == null ? AppColors.success : AppColors.danger)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                (s.couponError == null ? AppColors.success : AppColors.danger)
                    .withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_rounded,
              color: s.couponError == null
                  ? AppColors.success
                  : AppColors.danger,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.couponCode!,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    s.couponError ?? 'وفّرتِ ${Fmt.money(s.discount)}',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: s.couponError == null
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: cart.removeCoupon,
              child: const Text('إزالة'),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'كود الخصم',
              prefixIcon: Icon(Icons.local_offer_outlined),
            ),
            onSubmitted: (_) => _apply(),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 54,
          child: Obx(
            () => FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(90, 54),
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
              ),
              onPressed: cart.isSubmitting.value ? null : _apply,
              child: cart.isSubmitting.value
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    )
                  : const Text('تطبيق'),
            ),
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(this.s);

  final CartSummary s;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {Color? color, bool bold = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: bold ? AppColors.ink : AppColors.muted,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    fontSize: (bold ? 16 : 14).sp,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color ?? AppColors.ink,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  fontSize: (bold ? 17 : 14).sp,
                ),
              ),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          row('المجموع (${s.itemsCount} قطعة)', Fmt.money(s.subtotal)),
          if (s.discount > 0)
            row(
              'الخصم',
              '- ${Fmt.money(s.discount)}',
              color: AppColors.success,
            ),
          row(
            'التوصيل',
            s.deliveryFee == 0 ? 'مجاني' : Fmt.money(s.deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          row('الإجمالي', Fmt.money(s.total), bold: true),
        ],
      ),
    );
  }
}
