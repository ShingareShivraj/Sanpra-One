import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/services.dart';

import '../../../constants.dart';
import '../../../model/addquotation_model.dart';
import '../../../widgets/full_screen_loader.dart';
import 'items_model.dart';

class QuotationItemScreen extends StatelessWidget {
  final List<Items> items;

  const QuotationItemScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<QuotationItemListModel>.reactive(
      viewModelBuilder: () => QuotationItemListModel(),
      onViewModelReady: (model) => model.initialise(context, items),
      builder: (context, model, child) => Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: const Text('Select Items'),
          centerTitle: true,
          elevation: 0,
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  controller: model.searchController,
                  hintText: 'Search items',
                  leading: const Icon(Icons.search_rounded),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHigh,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  onChanged: model.searchItems,
                ),
              ),
              Expanded(
                child: model.filteredItems.isEmpty
                    ? _EmptyState(theme: theme)
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  itemCount: model.filteredItems.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = model.filteredItems[index];
                    final isSelected = model.isSelected(item);

                    return _ItemCard(
                      item: item,
                      isSelected: isSelected,
                      quantity:
                      model.getQuantity(item).toInt(),
                      onTap: () =>
                          model.toggleSelection(item),
                      onAdd: () => model.additem(index),
                      onRemove: () {
                        if ((item.qty ?? 0) > 1) {
                          model.removeitem(index);
                        }
                      },
                      onQuantityChanged: (val) {
                        model.updateQuantity(index, val);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomActionBar(model: model),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Items item;
  final bool isSelected;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Function(int)? onQuantityChanged;

  const _ItemCard({
    required this.item,
    required this.isSelected,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primaryContainer.withOpacity(.35)
                  : cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: '$baseurl${item.image ?? ""}',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),
                ),

                const SizedBox(width: 10),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName ?? "Item",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.itemCode ?? "Item",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "₹ ${item.rate ?? 0}",
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.green,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "UOM ${item.uom ?? 0}",
                            style:
                            theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// QTY STEPPER
                /// QTY INPUT ONLY (NO + -)
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      child: TextFormField(
                        initialValue: quantity.toString(),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) return;

                          int? val = int.tryParse(value);
                          if (val != null && val > 0) {
                            onQuantityChanged?.call(val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// CHECKMARK
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 200),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? cs.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final QuotationItemListModel model;

  const _BottomActionBar({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount =
        model.isSelecteditems.length;

    return SafeArea(
      top: false,
      child: Container(
        padding:
        const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
                color:
                theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme
                      .surfaceContainerHigh,
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        color:
                        theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "$selectedCount item(s) selected",
                        style: theme
                            .textTheme.titleSmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                    context, model.isSelecteditems);
              },
              icon:
              const Icon(Icons.check_rounded),
              label: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56,
                color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              "No items found",
              style: theme.textTheme.titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try searching with a different keyword.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                color: theme.colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}