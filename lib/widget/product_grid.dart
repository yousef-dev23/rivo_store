import 'package:flutter/material.dart';

import 'package:rivo_store/utils/responsive.dart';

/// صف واحد من الشبكة: أعمدة متساوية العرض، وارتفاع الصف يتبع أطول بطاقة،
/// فلا تُقص الأسماء أو الأسعار عند تكبير الخط (بعكس childAspectRatio الثابت).
class ProductGridRow extends StatelessWidget {
  const ProductGridRow({
    super.key,
    required this.columns,
    required this.start,
    required this.count,
    required this.itemBuilder,
    this.spacing = 14,
  });

  final int columns;
  final int start;
  final int count;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(
            child: start + c < count
                ? itemBuilder(context, start + c)
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

/// شبكة منتجات قابلة للتمرير؛ عدد الأعمدة حسب العرض المتاح لها.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.top = 8,
    this.bottom = 40,
    this.rowSpacing = 18,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double top;
  final double bottom;
  final double rowSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = centeredPadding(
          constraints.maxWidth,
          horizontal: 16,
          top: top,
          bottom: bottom,
        );
        final columns = Responsive.productColumns(
          constraints.maxWidth - padding.horizontal,
        );
        final rows = (itemCount / columns).ceil();
        return ListView.separated(
          controller: controller,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          shrinkWrap: shrinkWrap,
          padding: padding,
          itemCount: rows,
          separatorBuilder: (_, _) => SizedBox(height: rowSpacing),
          itemBuilder: (context, r) => ProductGridRow(
            columns: columns,
            start: r * columns,
            count: itemCount,
            itemBuilder: itemBuilder,
          ),
        );
      },
    );
  }
}

/// نفس الشبكة كـ Sliver داخل CustomScrollView (الرئيسية).
/// [maxRows] يحدد عدد الصفوف المعروضة (مثلًا «وصل حديثًا»).
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxRows,
    this.rowSpacing = 18,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int? maxRows;
  final double rowSpacing;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final padding = centeredPadding(
          constraints.crossAxisExtent,
          horizontal: 16,
        );
        final columns = Responsive.productColumns(
          constraints.crossAxisExtent - padding.horizontal,
        );
        var count = itemCount;
        if (maxRows != null) count = count.clamp(0, columns * maxRows!);
        final rows = (count / columns).ceil();
        return SliverPadding(
          padding: padding,
          sliver: SliverList.separated(
            itemCount: rows,
            separatorBuilder: (_, _) => SizedBox(height: rowSpacing),
            itemBuilder: (context, r) => ProductGridRow(
              columns: columns,
              start: r * columns,
              count: count,
              itemBuilder: itemBuilder,
            ),
          ),
        );
      },
    );
  }
}

/// قائمة أفقية: البطاقات بعرض ثابت وارتفاعها طبيعي حسب المحتوى.
class HorizontalProducts extends StatelessWidget {
  const HorizontalProducts({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            SizedBox(width: itemWidth, child: itemBuilder(context, i)),
          ],
        ],
      ),
    );
  }
}
