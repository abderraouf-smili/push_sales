import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/filter_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/position_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';
import 'package:push_sale/views/signed/widgets/clients/editclient.dart';
import 'package:push_sale/views/signed/widgets/clients/listingicon.dart';
import 'package:push_sale/views/signed/widgets/clients/listinglist.dart';
import 'package:push_sale/views/signed/widgets/clients/listingmaps.dart';
import 'package:push_sale/widgets/common/app_empty_state.dart';
import 'package:push_sale/widgets/common/app_error_state.dart';
import 'package:push_sale/widgets/common/app_loading_state.dart';
import 'package:push_sale/widgets/common/app_page_header.dart';

class Clients extends StatelessWidget {
  final String postedId;

  const Clients(this.postedId, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListClients(postedId);
  }
}

class ListClients extends StatelessWidget {
  final String postedId;

  ListClients(this.postedId, {super.key});

  final ClientController clientController = Get.put(ClientController("get"));
  final FilterController filterController = Get.put(FilterController());
  final PositionController posController = Get.put(PositionController());
  final PermissionsController perm = Get.find();
  final PageController pageController = PageController();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: Column(
        children: [
          AppPageHeader(
            title: "clients".tr,
            subtitle: "Recherche rapide, filtres et carte terrain",
            icon: Icons.groups_outlined,
          ),
          _SearchAndFilters(
            searchController: searchController,
            clientController: clientController,
            filterController: filterController,
            pageController: pageController,
            countBuilder: () => _filteredClients().length,
          ),
          Expanded(
            child: Obx(
              () {
                if (!clientController.ready.value) {
                  return const AppLoadingState(
                    message: "Chargement des clients...",
                  );
                }

                if (clientController.error.value.isNotEmpty) {
                  return AppErrorState(
                    title: "Clients indisponibles",
                    message: clientController.error.value,
                    onRetry: clientController.getClients,
                  );
                }

                final clients = _filteredClients();
                if (clients.isEmpty && clientController.page.value != 2) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      AppEmptyState(
                        icon: Icons.groups_outlined,
                        title: "Aucun client visible",
                        message:
                            "Ajustez la recherche ou affichez tous les jours de visite.",
                        action: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSpacing.sm,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                clientController.visit_day_only.value = false;
                                filterController.selectedCity.value = 0;
                                filterController.selectedTPV.value = 0;
                                clientController.filter = "";
                                searchController.clear();
                                clientController.ready.refresh();
                              },
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text("Afficher tout"),
                            ),
                            FilledButton.icon(
                              onPressed: clientController.getClients,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text("Recharger"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListingList(clients, posted_id: postedId),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: ListingIcon(clients, posted_id: postedId),
                    ),
                    ListingMaps(
                      clientController.clientsList,
                      filter: clientController.filter,
                      filterTPV: filterController.selectedTPV.value,
                      filterCity: filterController.selectedCity.value,
                    ),
                  ],
                );
              },
            ),
          ),
          perm.check(
            Align(
              alignment: Get.locale!.languageCode == "ar"
                  ? Alignment.bottomLeft
                  : Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: FloatingActionButton.extended(
                  heroTag: "add-client",
                  onPressed: () => Get.to(() => EditClient()),
                  icon: const Icon(Icons.add_rounded),
                  label: Text("new.client".tr),
                ),
              ),
            ),
            "Clients.add",
          ),
        ],
      ),
    );
  }

  List<Client> _filteredClients() {
    final nowDay = DateFormat("EEEE").format(DateTime.now()).toLowerCase();
    final query = clientController.filter.trim().toLowerCase();

    return clientController.clientsList.where((client) {
      final matchesSearch =
          query.isEmpty || client.name.toLowerCase().contains(query);
      final matchesCity = filterController.selectedCity.value == 0 ||
          client.address?.city.id == filterController.selectedCity.value;
      final matchesType = filterController.selectedTPV.value == 0 ||
          client.typepv?.id == filterController.selectedTPV.value;
      final matchesVisitDay = !clientController.visit_day_only.value ||
          (client.visitdays != null &&
              client.visitdays!.any((item) => item.day == nowDay));
      return matchesSearch && matchesCity && matchesType && matchesVisitDay;
    }).toList();
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final ClientController clientController;
  final FilterController filterController;
  final PageController pageController;
  final int Function() countBuilder;

  const _SearchAndFilters({
    required this.searchController,
    required this.clientController,
    required this.filterController,
    required this.pageController,
    required this.countBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "search".tr,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  clientController.filter = "";
                  searchController.clear();
                  clientController.ready.refresh();
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
            onChanged: (value) {
              clientController.filter = value;
              clientController.ready.refresh();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(
            () => AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(child: TypePVSearchDropDown()),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: CitiesSearchDropDown()),
                    IconButton(
                      onPressed: () {
                        filterController.selectedCity.value = 0;
                        filterController.selectedTPV.value = 0;
                        filterController.searchKeyCity.currentState?.reset();
                        filterController.searchKeyTPV.currentState?.reset();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              crossFadeState: filterController.filter_button.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Obx(
                () => Container(
                  width: 42,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    countBuilder().toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: [
                        _ClientModeChip(
                          label: "Jour visite",
                          icon: Icons.today_rounded,
                          selected: clientController.visit_day_only.value,
                          onTap: () {
                            clientController.visit_day_only.value =
                                !clientController.visit_day_only.value;
                          },
                        ),
                        _ClientModeChip(
                          label: "Filtres",
                          icon: Icons.filter_alt_rounded,
                          selected: filterController.filter_button.value,
                          onTap: () {
                            filterController.filter_button.value =
                                !filterController.filter_button.value;
                          },
                        ),
                        _ClientModeChip(
                          label: "Liste",
                          icon: Icons.view_headline_rounded,
                          selected: clientController.page.value == 0,
                          onTap: () {
                            clientController.page.value = 0;
                            pageController.jumpToPage(0);
                          },
                        ),
                        _ClientModeChip(
                          label: "Grille",
                          icon: Icons.grid_view_rounded,
                          selected: clientController.page.value == 1,
                          onTap: () {
                            clientController.page.value = 1;
                            pageController.jumpToPage(1);
                          },
                        ),
                        _ClientModeChip(
                          label: "Carte",
                          icon: Icons.language_rounded,
                          selected: clientController.page.value == 2,
                          onTap: () {
                            clientController.page.value = 2;
                            pageController.jumpToPage(2);
                          },
                        ),
                        IconButton(
                          onPressed: clientController.getClients,
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ClientModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.muted,
        ),
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.softBlue,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? AppColors.primary : AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
