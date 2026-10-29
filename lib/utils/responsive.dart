import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// كل ما يخص التجاوب في مكان واحد: مقاس التصميم، نقاط الانتقال، وحدود العرض.
class Responsive {
  Responsive._();

  /// إطارات فيجما كلها 375×812 (وحدات منطقية، وليست بكسلات الصورة).
  static const designSize = Size(375, 812);

  /// أقصى تكبير لـ .w/.r/.sp: بعده لا نكبّر العناصر بل نوزّعها على أعمدة أكثر.
  static const maxScale = 1.2;

  /// نقاط الانتقال حسب العرض المتاح.
  static const tablet = 600.0;
  static const desktop = 1024.0;

  /// حدود عرض المحتوى على الشاشات الواسعة.
  static const contentMaxWidth = 1200.0;
  static const readingMaxWidth = 720.0;
  static const formMaxWidth = 520.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  /// على سطح المكتب يصبح التنقل شريطًا جانبيًا بدل الشريط السفلي العائم.
  static bool useSideNav(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// عدد أعمدة المنتجات حسب العرض المتاح للشبكة نفسها.
  static int productColumns(double width) {
    if (width < 560) return 2;
    if (width < 840) return 3;
    if (width < 1100) return 4;
    return 5;
  }

  /// يُستدعى داخل builder الخاص بـ ScreenUtilInit: يحسب المقياس على شاشة
  /// محدودة الأبعاد حتى لا تتضخم الخطوط والأزرار على التابلت وسطح المكتب.
  static void capScale(BuildContext context) {
    final data = MediaQueryData.fromView(View.of(context));
    ScreenUtil.configure(
      data: data.copyWith(
        size: Size(
          math.min(data.size.width, designSize.width * maxScale),
          math.min(data.size.height, designSize.height * maxScale),
        ),
      ),
    );
  }

  /// الخط يتبع الشاشة بحدود ضيقة، ثم يُطبَّق عليه تكبير الخط من إعدادات النظام.
  static double fontSize(num size, ScreenUtil su) =>
      size * su.scaleText.clamp(0.92, 1.12);

  /// مسافة أسفل المحتوى القابل للتمرير حتى لا يختفي آخره خلف الشريط العائم.
  /// Scaffold الرئيسي (extendBody) يضع ارتفاع الشريط في padding.bottom.
  static double bottomClearance(BuildContext context, [double extra = 24]) =>
      MediaQuery.paddingOf(context).bottom + extra;
}

/// يحصر المحتوى بعرض أقصى ويوسّطه على الشاشات الواسعة.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    this.maxWidth = Responsive.contentMaxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // heightFactor: 1 حتى يأخذ ارتفاع المحتوى فقط؛ بدونه يتمدد لكامل الارتفاع
    // داخل bottomSheet ويغطي الشاشة.
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// padding أفقي يوسّط المحتوى داخل القوائم (ListView/CustomScrollView)
/// بدل تغليفها بـ MaxWidthBox، حتى يبقى التمرير بعرض الشاشة كاملة.
EdgeInsetsDirectional centeredPadding(
  double availableWidth, {
  double maxWidth = Responsive.contentMaxWidth,
  double horizontal = 20,
  double top = 0,
  double bottom = 0,
}) {
  final side = math.max(horizontal, (availableWidth - maxWidth) / 2);
  return EdgeInsetsDirectional.fromSTEB(side, top, side, bottom);
}
