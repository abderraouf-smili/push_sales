import 'package:flutter/material.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';

class AppStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppStatusChip({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
  });

  factory AppStatusChip.fromState(String state) {
    final normalized = state.toLowerCase();
    final color = switch (normalized) {
      'paid' || 'shipped' || 'done' || 'confirmed' => AppColors.success,
      'in_way' || 'taken' || 'ready' => AppColors.info,
      'new' || 'draft' => AppColors.warning,
      'cancelled' || 'canceled' || 'fail' => AppColors.danger,
      _ => AppColors.primary,
    };
    return AppStatusChip(label: state, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
