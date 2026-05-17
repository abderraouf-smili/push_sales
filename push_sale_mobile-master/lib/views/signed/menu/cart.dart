import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppPageHeader(
            title: "cart".tr,
            subtitle: "Commandes en preparation",
            icon: Icons.shopping_bag_outlined,
          ),
          const AppEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: "Aucun panier actif",
            message:
                "Les commandes en cours apparaitront ici lorsqu'un panier sera ouvert.",
          ),
        ],
      ),
    );
  }
}
