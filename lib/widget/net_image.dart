import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/widget/loading.dart';

/// صورة من الإنترنت مع تخزين مؤقت وهيكل تحميل لطيف.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.sand,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.subtle),
    );
    final Widget image;
    if (url == null || url!.isEmpty) {
      image = placeholder;
    } else if (kIsWeb) {
      // على الويب: صور /uploads على الخادم بلا ترويسة CORS فيفشل جلبها كبايتات؛
      // fallback يعرضها كعنصر <img> عادي، والمتصفح يتولى التخزين المؤقت.
      image = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Skeleton(width: width, height: height),
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => Skeleton(width: width, height: height),
        errorWidget: (_, _, _) => placeholder,
      );
    }
    return radius == 0
        ? image
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
