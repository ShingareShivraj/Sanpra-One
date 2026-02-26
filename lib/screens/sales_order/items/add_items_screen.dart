import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/widgets/customtextfield.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../model/add_order_model.dart';
import 'add_item_model.dart';

class ItemScreen extends StatelessWidget {
  final String warehouse;
  final List<Items> selectedItems;
  final List<Items> items;

  const ItemScreen({
    super.key,
    required this.warehouse,
    required this.items,
    required this.selectedItems,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ItemListModel>.reactive(
      viewModelBuilder: () => ItemListModel(),
      onViewModelReady: (model) =>
          model.initialise(context, warehouse, items, selectedItems),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(title: const Text('Select Items')),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CustomSmallTextFormField(
                  controller: model.searchController,
                  labelText: 'Search',
                  hintText: 'Type here to search',
                  onChanged: model.searchItems,
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: model.filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = model.filteredItems[index];
                      return ItemRowWidget(
                        key: ValueKey(item.itemCode),
                        item: item,
                        isSelected: model.isSelected(item),
                        onAdd: () => model.addItem(item),
                        onRemove: () => model.removeItem(item),
                        onToggle: (_) => model.toggleSelection(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: BottomSheetWidget(model: model),
      ),
    );
  }
}

class ItemRowWidget extends StatelessWidget {
  final Items item;
  final bool isSelected;
  final Function(bool?) onToggle;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ItemRowWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.image != null && item.image!.isNotEmpty
                    ? '$baseurl${item.image}'
                    : '', // ✅ prevents invalid URL
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/image.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),

            // Info + Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // ✅ prevent overflow
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${item.itemCode ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rate: ${item.rate}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Stock: ${item.actualQty ?? 0}',
                          style: TextStyle(
                            color: (item.actualQty ?? 0) < 0
                                ? Colors.redAccent
                                : Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: onToggle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSheetWidget extends StatelessWidget {
  final ItemListModel model;

  const BottomSheetWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: MaterialButton(
          onPressed: () {
            Navigator.pop(context, model.selectedItems);
          },
          minWidth: 200.0,
          height: 48.0,
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: const Text(
            "Done",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
