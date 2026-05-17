import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/delivery/main_delivery_page.dart';
import 'package:push_sale/views/signed/widgets/products/product_main_page.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppPageHeader(
              title: "favorite".tr,
              subtitle: "Acces rapide terrain",
              icon: Icons.favorite_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const AppEmptyState(
                    icon: Icons.bookmark_add_outlined,
                    title: "Aucun favori enregistre",
                    message:
                        "Utilisez cette page comme raccourci vers les actions les plus frequentes.",
                  ),
                  _QuickActionCard(
                    title: "Produits",
                    subtitle: "Consulter le catalogue et les prix",
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    onTap: () => Get.to(() => ProductMainPage()),
                  ),
                  _QuickActionCard(
                    title: "Livraison",
                    subtitle: "Voir les commandes a livrer",
                    icon: Icons.delivery_dining_outlined,
                    color: AppColors.secondary,
                    onTap: () => Get.to(() => MainDeliveryPage()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontSize: 17)),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
