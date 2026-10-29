import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/getx_controller/user_profile_getx_controller.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/utils/app_colors.dart';

class LunchScreen extends StatefulWidget {
  const LunchScreen({super.key});

  @override
  State<LunchScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<LunchScreen> {
  String? _error;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_isStarting) return;

    _isStarting = true;

    if (mounted) {
      setState(() => _error = null);
    }

    try {
      final app = Get.find<AppGetxController>();

      final results = await Future.wait([
        app.fetchStore(),
        Get.find<UserProfileGetxController>().fetchUserProfile(),
        Future.delayed(const Duration(milliseconds: 1400)),
      ]);

      if (!mounted) return;

      if (results.first == true) {
        Get.offAll(() => const MainScreen(), transition: Transition.fadeIn);
      } else {
        setState(() {
          _error = app.errorMessage.value.isNotEmpty
              ? app.errorMessage.value
              : 'Unable to load the store. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
        });
      }
    } finally {
      _isStarting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(color: AppColors.brand, size: 340),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _Glow(
              color: AppColors.brand.withValues(alpha: 0.6),
              size: 300,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutBack,
                        builder: (_, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 0.85 + 0.15 * value,
                              child: child,
                            ),
                          );
                        },
                        child: Obx(() {
                          final store =
                              Get.find<AppGetxController>().store.value;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 112.r,
                                height: 112.r,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.brand,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brand.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        color: AppColors.brand,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.checkroom_rounded,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                store?.name ?? 'Rivo Store',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                store?.tagline ?? 'Technology Simplified',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: _error == null
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.brand,
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _start,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
