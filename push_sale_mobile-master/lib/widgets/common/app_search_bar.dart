import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilter;
  final bool filterActive;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onFilter,
    this.filterActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'search'.tr,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                tooltip: 'clear'.tr,
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
            if (onFilter != null)
              IconButton(
                tooltip: 'filter'.tr,
                icon: Icon(
                  filterActive
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  color: filterActive ? AppColors.primary : AppColors.muted,
                ),
                onPressed: onFilter,
              ),
          ],
        ),
      ),
    );
  }
}
