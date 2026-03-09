import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:iconsax/iconsax.dart';
import 'package:stacked/stacked.dart';

import 'stock_viewmodel.dart';

class ItemStockScreen extends StatelessWidget {
  const ItemStockScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ViewModelBuilder<ItemStockViewModel>.reactive(
      viewModelBuilder: () => ItemStockViewModel(),
      onViewModelReady: (model) => model.fetchStock(),
      builder: (context, model, child) {
        return Scaffold(
          body: RefreshIndicator(
                  onRefresh: () async => model.fetchStock(),
                  child: fullScreenLoader(
                    context: context,
                    loader: model.isBusy,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          elevation: 0,
                          title: const Text('Item Stock'),
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(112),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                children: [
                                  // Search (in AppBar area)
                                  TextField(
                                    onChanged: model.updateSearch,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: 'Search by item name / code',
                                      prefixIcon:
                                          const Icon(Iconsax.search_normal_1),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Summary + Filter row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SummaryPill(
                                          icon: Iconsax.box,
                                          title: 'Items',
                                          value: model.filteredItems.length
                                              .toString(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _FilterButton(
                                          label: model.selectedWarehouse ??
                                              'Warehouse',
                                          onTap: () => _showWarehouseSheet(
                                            context: context,
                                            model: model,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (model.filteredItems.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyInventory(
                              warehouse: model.selectedWarehouse,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            sliver: SliverList.separated(
                              itemCount: model.filteredItems.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 16,
                                thickness: 1,
                              ),
                              itemBuilder: (_, index) {
                                final item = model.filteredItems[index];
                                return _InventoryRow(item: item);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showWarehouseSheet({
    required BuildContext context,
    required ItemStockViewModel model,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              Text(
                'Select Warehouse',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ...model.warehouses.map((w) {
                final selected = model.selectedWarehouse == w;
                return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading:
                      Icon(selected ? Iconsax.tick_circle : Iconsax.building_3),
                  title: Text(w, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing:
                      selected ? Icon(Icons.check, color: cs.primary) : null,
                  onTap: () {
                    model.updateWarehouse(w);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Iconsax.filter, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.item});

  final dynamic item; // keep dynamic as your VM type isn’t shared

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final String name = item.itemName ?? '';
    final String code = item.itemCode ?? '';
    final String wh = item.warehouse ?? '';
    final double qty = (item.actualQty as num?)?.toDouble() ?? 0;

    Color badgeColor() {
      if (qty <= 0) return cs.errorContainer;
      if (qty < 5) return Colors.orange.shade100;
      return Colors.green.shade100;
    }

    Color badgeTextColor() {
      if (qty <= 0) return cs.onErrorContainer;
      if (qty < 5) return Colors.orange.shade900;
      return Colors.green.shade900;
    }

    return Row(
      children: [
        // Left: Name + code + warehouse
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                code,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Iconsax.building_3,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      wh,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Right: Qty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor(),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'QTY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeTextColor().withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                qty.toStringAsFixed(2),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: badgeTextColor(),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory({this.warehouse});
  final String? warehouse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.box_search, size: 34, color: cs.primary),
              const SizedBox(height: 10),
              Text(
                'No stock found',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                warehouse == null
                    ? 'Try changing warehouse or search.'
                    : 'No items in "$warehouse". Try another warehouse or search.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemStock {
  final String itemCode;
  final String itemName;
  final double actualQty;
  final String warehouse;

  ItemStock({
    required this.itemCode,
    required this.itemName,
    required this.actualQty,
    required this.warehouse,
  });

  factory ItemStock.fromJson(Map<String, dynamic> json) {
    return ItemStock(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      actualQty: (json['actual_qty'] ?? 0).toDouble(),
      warehouse: json['warehouse'] ?? '',
    );
  }
}
