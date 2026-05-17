import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/clients/ficheclient.dart';
import 'package:push_sale/widgets/common/app_status_chip.dart';

class ListingList extends StatelessWidget {
  final List<Client> listing;
  final String? posted_id;
  final ClientController clientController = Get.find();

  ListingList(this.listing, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 160,
          onRefresh: () => clientController.getClients(),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            96,
          ),
          sliver: SliverList.separated(
            itemCount: listing.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => ItemClient(
              listing[index],
              posted_id: posted_id,
            ),
          ),
        ),
      ],
    );
  }
}

class ItemClient extends StatelessWidget {
  final Client client;
  final String? posted_id;

  const ItemClient(this.client, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? "fr";
    final isPosted = posted_id != null && posted_id == client.id;
    final city = client.address?.city.getName(locale) ?? "-";
    final wilaya = client.address?.wilaya.getName(locale) ?? "-";
    final type = client.typepv?.getName(locale) ?? "Point de vente";
    final lastVisit =
        client.visits?.isNotEmpty == true ? client.visits!.first : null;
    final hasStockStatus = lastVisit?.code == "S.D";
    final sales = client.sales ?? 0;

    return InkWell(
      onTap: () => Get.to(() => FicheClient(client)),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isPosted ? AppColors.softBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isPosted ? AppColors.primary : AppColors.line,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ClientThumb(client: client),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.muted),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          color: AppColors.muted, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          "$city, $wilaya",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppStatusChip(
                        label: hasStockStatus
                            ? "Stock disponible"
                            : lastVisit?.getDescription(locale) ?? "Non visite",
                        icon: hasStockStatus
                            ? Icons.check_circle_outline_rounded
                            : Icons.info_outline_rounded,
                        color: hasStockStatus
                            ? AppColors.success
                            : AppColors.muted,
                      ),
                      AppStatusChip(
                        label: "$sales vente${sales > 1 ? "s" : ""}",
                        icon: Icons.shopping_cart_outlined,
                        color:
                            sales > 0 ? AppColors.secondary : AppColors.muted,
                      ),
                      if ((client.visitdays ?? []).isNotEmpty)
                        AppStatusChip(
                          label: _visitDaysLabel(client),
                          icon: Icons.event_available_rounded,
                          color: AppColors.info,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _visitDaysLabel(Client client) {
    final days = client.visitdays ?? [];
    final labels = days.take(2).map((day) => day.day.tr).join(", ");
    if (days.length <= 2) {
      return labels;
    }
    return "$labels +${days.length - 2}";
  }
}

class _ClientThumb extends StatelessWidget {
  final Client client;

  const _ClientThumb({required this.client});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: 62,
        height: 72,
        child: client.hasImage
            ? CachedNetworkImage(
                imageUrl: client.image,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const _StoreIcon(),
              )
            : const _StoreIcon(),
      ),
    );
  }
}

class _StoreIcon extends StatelessWidget {
  const _StoreIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softBlue,
      child: const Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
