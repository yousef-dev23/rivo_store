import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rivo_store/models/review.dart';
import 'package:rivo_store/utils/app_colors.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/widget/price.dart';

/// تقييم واحد: اسم العميلة، النجوم، التعليق والوقت.
class ReviewCard extends StatelessWidget {
  const ReviewCard(this.review, {super.key});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final r = review;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.sand,
                child: Text(
                  r.initials,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Stars(r.rating.toDouble(), size: 13),
            ],
          ),
          if (r.comment != null) ...[
            const SizedBox(height: 8),
            Text(r.comment!, style: const TextStyle(height: 1.6)),
          ],
          const SizedBox(height: 4),
          Text(
            Fmt.ago(r.createdAt),
            style: TextStyle(color: AppColors.subtle, fontSize: 11.5.sp),
          ),
        ],
      ),
    );
  }
}
