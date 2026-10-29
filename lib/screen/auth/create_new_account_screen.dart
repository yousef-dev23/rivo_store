import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/user_api_controller.dart';
import 'package:rivo_store/utils/app_colors.dart';

class CreateNewAccountScreen extends StatefulWidget {
  const CreateNewAccountScreen({super.key});

  @override
  State<CreateNewAccountScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<CreateNewAccountScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await UserApiController().register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب جديد')),
      body: Form(
        key: _form,
        child: ListView(
          padding: centeredPadding(
            MediaQuery.sizeOf(context).width,
            maxWidth: Responsive.formMaxWidth,
            horizontal: 24,
            top: 8,
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              'انضمي إلينا',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'أنشئي حسابك لتتابعي طلباتك وتحفظي مفضلتك.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'اكتبي اسمك' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (v) => (v ?? '').contains('@')
                  ? null
                  : 'اكتبي بريدًا إلكترونيًا صحيحًا',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v ?? '').trim().length < 7 ? 'رقم الهاتف غير صحيح' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _hide,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                helperText: '8 أحرف على الأقل، تحتوي حروفًا وأرقامًا',
                helperMaxLines: 2,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
              validator: (v) {
                final p = v ?? '';
                if (p.length < 8) return 'كلمة المرور قصيرة';
                if (!RegExp(r'[A-Za-z]').hasMatch(p) ||
                    !RegExp(r'\d').hasMatch(p)) {
                  return 'استخدمي حروفًا وأرقامًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _submit, child: const Text('إنشاء الحساب')),
          ],
        ),
      ),
    );
  }
}
