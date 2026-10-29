import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rivo_store/utils/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 99,
    this.busy = false,
    this.compact = false,
  });

  final int value;
  final int max;
  final bool busy;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 30.0 : 40.0;

    Widget button(IconData icon, VoidCallback? onTap) {
      return InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: compact ? 16 : 20,
            color: onTap == null ? AppColors.subtle : AppColors.ink,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            Icons.add_rounded,
            value < max ? () => onChanged(value + 1) : null,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: busy
                ? const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
          ),
          button(
            Icons.remove_rounded,
            value > 1 ? () => onChanged(value - 1) : null,
          ),
        ],
      ),
    );
  }
}
