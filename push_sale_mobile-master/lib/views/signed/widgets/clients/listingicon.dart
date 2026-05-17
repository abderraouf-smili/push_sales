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

class ListingIcon extends StatelessWidget {
  final List<Client> listing;
  final String? posted_id;
  final ClientController clientController = Get.find();

  ListingIcon(this.listing, {super.key, this.posted_id});

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
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            96,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.86,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => IconClient(
                listing[index],
                posted_id: posted_id,
              ),
              childCount: listing.length,
            ),
          ),
        ),
      ],
    );
  }
}

class IconClient extends StatelessWidget {
  final Client client;
  final String? posted_id;

  const IconClient(this.client, {super.key, this.posted_id});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? "fr";
    final isPosted = posted_id != null && posted_id == client.id;
    final city = client.address?.city.getName(locale) ?? "-";
    final lastVisit =
        client.visits?.isNotEmpty == true ? client.visits!.first : null;
    final stockOk = lastVisit?.code == "S.D";

    return InkWell(
      onTap: () => Get.to(() => FicheClient(client)),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: isPosted ? AppColors.softBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border:
              Border.all(color: isPosted ? AppColors.primary : AppColors.line),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: client.hasImage
                      ? CachedNetworkImage(
                          imageUrl: client.image,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const _StorePoster(),
                        )
                      : const _StorePoster(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppStatusChip(
                    label: stockOk ? "Stock OK" : "${client.sales ?? 0} vente",
                    icon: stockOk
                        ? Icons.check_circle_outline_rounded
                        : Icons.shopping_cart_outlined,
                    color: stockOk ? AppColors.success : AppColors.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePoster extends StatelessWidget {
  const _StorePoster();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softBlue,
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: 42,
        ),
      ),
    );
  }
}
