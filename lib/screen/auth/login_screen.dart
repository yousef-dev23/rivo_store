import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rivo_store/utils/responsive.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_api_controller.dart';
import 'package:rivo_store/screen/auth/create_new_account_screen.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/widget/net_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await UserApiController().login(
      email: _email.text,
      password: _password.text,
    );
    if (ok) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final store = Get.find<AppGetxController>().store.value;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: centeredPadding(
              MediaQuery.sizeOf(context).width,
              maxWidth: Responsive.formMaxWidth,
              horizontal: 24,
              bottom: 24,
            ),
            children: [
              Center(
                child: Container(
                  width: 84.r,
                  height: 84.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: ClipOval(child: NetImage(store?.logo)),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'أهلًا بعودتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'سجّلي الدخول إلى ${store?.name ?? 'المتجر'}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.email],
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
                controller: _password,
                obscureText: _hide,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
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
                validator: (v) =>
                    (v ?? '').isEmpty ? 'اكتبي كلمة المرور' : null,
              ),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: _submit,
                child: const Text('تسجيل الدخول'),
              ),
              const SizedBox(height: 18),
              // Wrap: على الشاشات الضيقة أو مع خط كبير ينزل الرابط لسطر جديد.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'ليس لديكِ حساب؟',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () async {
                      final ok = await Get.to(
                        () => const CreateNewAccountScreen(),
                      );
                      if (ok == true) Get.back(result: true);
                    },
                    child: const Text(
                      'أنشئي حسابًا',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
