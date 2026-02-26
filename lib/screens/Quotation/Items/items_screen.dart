import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants.dart';
import '../../../model/addquotation_model.dart';
import '../../../widgets/customtextfield.dart';
import '../../../widgets/full_screen_loader.dart';
import 'items_model.dart';



class QuotationItemScreen extends StatelessWidget {

  final List<Items> items;
  const QuotationItemScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuotationItemListModel>.reactive(
      viewModelBuilder: () => QuotationItemListModel(),
      onViewModelReady: (model) => model.initialise(context, items),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            title: const Text('Select Items'),
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  CustomSmallTextFormField(prefixIcon: Icons.search,controller: model.searchController, labelText: 'Search', hintText: 'Type here to search',onChanged: model.searchItems,),
                  const SizedBox(height: 15),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: model.filteredItems.length,
                    itemBuilder: (context, index) {
                      final selectedItem = model.filteredItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12), // Increased padding for better spacing
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // Smooth rounded corners
                          color: model.isSelected(selectedItem) ? Colors.blue.shade200 : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2), // Lighter shadow for better contrast
                              blurRadius: 8,
                              spreadRadius: 2, // Slight spread for more subtle effect
                              offset: const Offset(0, 4), // Offset the shadow slightly
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with rounded corners
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: '$baseurl${selectedItem.image}',
                                width: 80, // Increased size for better visibility
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(color: Colors.blueAccent),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16), // Increased spacing between image and text

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                   selectedItem.itemName ?? "N/A",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Slightly larger font for better readability
                                    ),
                                    maxFontSize: 16.0,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8), // Added more spacing for better balance
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        'Rate: ${selectedItem.rate.toString()}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14, // Adjusted font size for rate
                                        ),
                                      ),
                                      const Spacer(), // Ensures the text and qty align correctly
                                      AutoSizeText(
                                        'Qty: ${selectedItem.actualQty}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14, // Adjusted font size for quantity
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity and Buttons Section
                            Column(
                              children: [
                                // Styled checkbox
                                GestureDetector(
                                  onTap: () {
                                    model.toggleSelection(selectedItem);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: model.isSelected(selectedItem)
                                          ? Colors.blueAccent.shade100
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: model.isSelected(selectedItem)
                                            ? Colors.blueAccent
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      model.isSelected(selectedItem)
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: model.isSelected(selectedItem)
                                          ? Colors.blueAccent
                                          : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10), // Added spacing between checkbox and buttons

                                // Quantity control buttons with a modern design
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors
                                            .blueAccent.shade400,
                                        width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove,
                                          color:
                                          Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          // Decrease quantity when the remove button is pressed
                                          if (selectedItem.qty !=
                                              null &&
                                              (selectedItem.qty ??
                                                  0) >
                                                  1) {
                                            model.removeitem(
                                                index);
                                          }
                                        },
                                      ),
                                      Text(
                                        model
                                            .getQuantity(
                                            selectedItem)
                                            .toInt()
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color:
                                          Colors.blueAccent,
                                        ),
                                        onPressed: () {
                                          model.additem(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      );

                      // IconButton(
                                //   icon: Icon(Icons.delete, size: 20.0),
                                //   onPressed: () {
                                //     // Handle delete button action
                                //   },
                                // ),
                            //   ],
                            // ),
                          // ],
                        // ),
                      // );
                    },separatorBuilder: (BuildContext context, int index) {
                    return const Divider(thickness: 1,);
                  },

                  ),
                ],
              ),
            ),
          ),
          bottomSheet: BottomSheetWidget(
            model: model,
          )),
    );
  }

  Widget buildImage(String? imageUrl) {
    return Image.network(
      '$baseurl$imageUrl',
      height: 36,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          // Image is done loading
          return child;
        } else {
          // Image is still loading
          return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        // Handle the error by displaying a broken image icon
        return const Icon(Icons.broken_image,size: 36,);
      },
    );
  }

  Widget buildItemColumn(String label, {String? additionalText}) {
    return Column(
      children: [
        AutoSizeText(label),
        if (additionalText != null) AutoSizeText(additionalText),
      ],
    );
  }
}

class BottomSheetWidget extends StatefulWidget {
  final QuotationItemListModel model;

  const BottomSheetWidget({super.key, required this.model});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: Colors.white38,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              color: Colors.white38,
            ),
            child: Center(
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context, widget.model.isSelecteditems);
                },
                minWidth: 200.0,
                height: 48.0,
                color: Colors.blueAccent,
                textColor: Colors.white,
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
