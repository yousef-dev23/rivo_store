import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/getx_controller/cart_getx_controller.dart';
import 'package:rivo_store/getx_controller/order_getx_controller.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/screen/setting/order_success_screen.dart';
import 'package:rivo_store/utils/app_colors.dart';

/// إتمام الطلب: بيانات التوصيل، طريقة الدفع، والملخص النهائي.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<PaymentScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(
    text: Get.find<UserProfileGetxController>().userProfile.value?.name,
  );
  final _phone = TextEditingController(
    text: Get.find<UserProfileGetxController>().userProfile.value?.phone,
  );
  final _address = TextEditingController();
  final _notes = TextEditingController();
  String _payment = 'cash';

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final OrderGetxController orderController = Get.find();
    final order = await orderController.checkout(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
      notes: _notes.text,
      payment: _payment,
    );
    if (order != null) {
      Get.off(
        () => OrderSuccessScreen(order: order),
        transition: Transition.zoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Get.find<CartGetxController>().summary.value;
    final store = Get.find<AppGetxController>().store.value;
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _form,
        child: ListView(
          padding: centeredPadding(
            MediaQuery.sizeOf(context).width,
            maxWidth: Responsive.readingMaxWidth,
            top: 8,
            bottom: 140 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const _StepTitle(number: 1, title: 'بيانات التوصيل'),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: 'اسم المستلم',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'اكتبي اسم المستلم' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 7 ? 'رقم الهاتف غير صحيح' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'العنوان بالتفصيل',
                hintText: 'المدينة — الحي، الشارع، رقم العمارة',
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 5 ? 'اكتبي العنوان بالتفصيل' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'ملاحظات للتوصيل (اختياري)',
                prefixIcon: Icon(Icons.sticky_note_2_outlined),
              ),
            ),
            const _StepTitle(number: 2, title: 'طريقة الدفع'),
            _PaymentOption(
              value: 'cash',
              group: _payment,
              icon: Icons.payments_outlined,
              title: 'الدفع عند الاستلام',
              subtitle: 'ادفعي نقدًا للمندوب',
              onChanged: (v) => setState(() => _payment = v),
            ),
            const SizedBox(height: 10),
            _PaymentOption(
              value: 'card_demo',
              group: _payment,
              icon: Icons.credit_card_rounded,
              title: 'بطاقة (تجريبي)',
              subtitle: 'دفع تجريبي لأغراض التعلم',
              onChanged: (v) => setState(() => _payment = v),
            ),
            const _StepTitle(number: 3, title: 'ملخص الطلب'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  ...s.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            '${i.quantity}×',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              i.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Fmt.money(i.lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 22),
                  _Line('المجموع', Fmt.money(s.subtotal)),
                  if (s.discount > 0)
                    _Line(
                      'الخصم (${s.couponCode})',
                      '- ${Fmt.money(s.discount)}',
                      color: AppColors.success,
                    ),
                  _Line(
                    'التوصيل',
                    s.deliveryFee == 0 ? 'مجاني' : Fmt.money(s.deliveryFee),
                  ),
                  const Divider(height: 22),
                  _Line('الإجمالي', Fmt.money(s.total), bold: true),
                ],
              ),
            ),
            if (store?.address != null) ...[
              const SizedBox(height: 12),
              Text(
                'الطلبات تُشحن من: ${store!.address}',
                style: TextStyle(color: AppColors.muted, fontSize: 12.5.sp),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          14 + MediaQuery.paddingOf(context).bottom,
        ),
        color: Colors.white,
        child: MaxWidthBox(
          maxWidth: Responsive.readingMaxWidth,
          child: FilledButton(
            onPressed: _submit,
            child: Text(
              'تأكيد الطلب · ${Fmt.money(s.total)}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: primary,
            child: Text(
              '$number',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final String value;
  final String group;
  final IconData icon;
  final String title;
  final String subtitle;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value == group;
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? primary.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? primary : AppColors.line,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? primary : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.muted, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Icon(
              active
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: active ? primary : AppColors.subtle,
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.color, this.bold = false});

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
}
