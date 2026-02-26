import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../constants.dart';
import '../../../model/addquotation_model.dart';
import '../../../router.router.dart';
import '../../../widgets/customtextfield.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/full_screen_loader.dart';
import '../../../widgets/text_button.dart';
import 'add_quotation_viewmodel.dart';

class AddQuotationView extends StatefulWidget {
  final String quotationid;
  const AddQuotationView({super.key, required this.quotationid});

  @override
  State<AddQuotationView> createState() => _AddQuotationViewState();
}

class _AddQuotationViewState extends State<AddQuotationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddQuotationModel>.reactive(
      viewModelBuilder: () => AddQuotationModel(),
      onViewModelReady: (model) =>
          model.initialise(context, widget.quotationid),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: model.isEdit == true
              ? Text(model.quotationdata.name ?? "")
              : const Text('Create Quotation'),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: SingleChildScrollView(
              child: Form(
            key: model.formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomDropdownButton2(
                    value: model.quotationdata.quotationTo,
                    prefixIcon: Icons.person_2,
                    items: model.quotationto,
                    hintText: 'Select Quotation To',
                    labelText: 'Quotation To',
                    onChanged: model.setquotationto,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomDropdownButton2(
                    value: model.quotationdata.partyName,
                    prefixIcon: Icons.person_2,
                    items: model.searchcustomer,
                    hintText: 'Select the customer',
                    labelText: model.customerLabel,
                    onChanged: model.setcustomer,
                    validator: model.validateQuotationTo,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (model.isEdit == true)
                    CustomSmallTextFormField(
                        prefixIcon: Icons.person_pin,
                        controller: model.customernamecontroller,
                        labelText: 'Party Name',
                        hintText: 'Enter the Party'),
                  if (model.isEdit == true)
                    const SizedBox(
                      height: 15,
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomDropdownButton2(
                          value: model.quotationdata.orderType,
                          items: model.ordetype,
                          hintText: 'select order type',
                          onChanged: model.setordertype,
                          labelText: 'Order Type',
                          validator: model.validateordertype,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          readOnly: true,
                          controller: model.validtilldatecontroller,
                          onTap: () => model.selectvalidtillDate(context),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 12.0),
                            labelText: 'Valid till Date',
                            hintText: 'Valid till Date',
                            prefixIcon:
                                const Icon(Icons.calendar_today_rounded),
                            labelStyle: const TextStyle(
                              color:
                                  Colors.black54, // Customize label text color
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey, // Customize hint text color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: const BorderSide(
                                color: Colors
                                    .blue, // Customize focused border color
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              borderSide: const BorderSide(
                                color: Colors
                                    .grey, // Customize enabled border color
                              ),
                            ),
                          ),
                          validator: model.validateValidTill,
                          onChanged: model.onvalidtillDobChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    readOnly: true,
                    key: Key(model.displayString),
                    initialValue: model.displayString,
                    onTap: () async {
                      if (model.quotationdata.partyName == null) {
                        const snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Please select the customer name',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          duration: Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        return;
                      }
                      final SelectedItems = await Navigator.pushNamed(
                        context,
                        Routes.quotationItemScreen,
                        arguments: QuotationItemScreenArguments(
                            items: model.selectedItems),
                      ) as List<Items>?;

                      if (SelectedItems != null) {
                        model.selectedItems.clear();
                        // Update the model or perform any actions with the selected items
                        model.setSelectedItems(SelectedItems);
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                      labelText: 'Items',
                      hintText: 'For select items click here',
                      prefixIcon: const Icon(Icons.shopping_basket),
                      labelStyle: const TextStyle(
                        color: Colors.black54, // Customize label text color
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey, // Customize hint text color
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: const BorderSide(
                          color: Colors.blue, // Customize focused border color
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        borderSide: const BorderSide(
                          color: Colors.grey, // Customize enabled border color
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Item List',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  model.selectedItems.isNotEmpty
                      ? ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: model.selectedItems.length,
                          itemBuilder: (context, index) {
                            final selectedItem = model.selectedItems[index];
                            return Dismissible(
                              key: Key(selectedItem.itemCode
                                  .toString()), // Use a unique key for each item
                              background: Container(
                                color: Colors.red.shade400,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: const Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  bool dismiss = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: const Text(
                                            "Are you sure you want to delete the item"),
                                        title: const Text("Delete Item ?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context,
                                                  false); // Dismiss without deletion
                                            },
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context,
                                                  true); // Confirm deletion
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return dismiss;
                                }
                                return null;
                              },
                              direction: DismissDirection.startToEnd,
                              onDismissed: (direction) {
                                model.deleteitem(
                                    index); // Delete the item from the model
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                          0.5), // Customize the shadow color and opacity
                                      // spreadRadius: 5,
                                      blurRadius: 7,
                                      // offset: const Offset(0, 3), // Customize the shadow offset
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '$baseurl${selectedItem.image}',
                                            width:
                                                70, // Set width to twice the radius for a complete circle
                                            height: 50,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors
                                                                .blueAccent)),
                                            errorWidget:
                                                (context, url, error) => Center(
                                                    child: Image.asset(
                                                        'assets/images/image.png',
                                                        scale: 5)),
                                          ),
                                        ),
                                        AutoSizeText(
                                          'UOM:${selectedItem.uom}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxFontSize: 16.0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 10),
                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedItem.itemName ?? "N/A",
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AutoSizeText(
                                                    'Rate: ₹${selectedItem.rate?.toDouble().toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  AutoSizeText(
                                                    'Amount: ₹${selectedItem.amount?.toDouble().toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
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
                                    ),
                                    // Quantity and Buttons
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(
                              height: 10,
                            );
                          },
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Text(
                              'Items are not selected ',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 8,
                  ),
                  buildbillingsection(model),
                  const SizedBox(
                    height: 25,
                  ),
                  quotationStatus == 2
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CTextButton(
                                text: 'Cancel',
                                onPressed: () {
                                  if (quotationStatus == 1) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Are you want to cancel?"),
                                          content: const Text(
                                              "Permanently Cancelled quotation?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                    false); // Return false when cancel is pressed
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                                model.onCancelPressed(
                                                    context); // Return true when confirm is pressed
                                              },
                                              child: const Text("Confirm"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                buttonColor: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            quotationStatus == 0 ||
                                    model.quotationdata.docstatus == null
                                ? model.isSame == false
                                    ? Expanded(
                                        child: CTextButton(
                                          text: model.isEdit
                                              ? 'Update Quotation'
                                              : 'Create Quotation',
                                          onPressed: () =>
                                              model.onSavePressed(context),
                                          buttonColor:
                                              Colors.blueAccent.shade400,
                                        ),
                                      )
                                    : Expanded(
                                        child: CTextButton(
                                          text: 'Submit Quotation',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Confirm Submit?"),
                                                  content: const Text(
                                                      "Permanently submit quotation?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(
                                                            false); // Return false when cancel is pressed
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                        model.onSubmitPressed(
                                                            context); // Return true when confirm is pressed
                                                      },
                                                      child:
                                                          const Text("Confirm"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          buttonColor:
                                              Colors.blueAccent.shade400,
                                        ),
                                      )
                                : Container()
                          ],
                        )
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  Widget buildImage(String? imageUrl) {
    return Image.network(
      '$baseurl$imageUrl',
      height: 40,
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
        return const Center(
            child: Icon(Icons.broken_image_outlined, size: 36.0));
      },
    );
  }

  Widget buildbillingsection(AddQuotationModel model) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tax and Discount',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          const Divider(
            thickness: 2,
          ),
          buildBillingRow(
              'Subtotal :', model.quotationdata.netTotal?.toString() ?? '0.0'),
          const SizedBox(
            height: 10,
          ),
          buildBillingRow('Total Tax :',
              model.quotationdata.totalTaxesAndCharges?.toString() ?? '0.0'),
          const SizedBox(
            height: 10,
          ),
          buildBillingRow('Discount :',
              model.quotationdata.discountAmount?.toString() ?? '0.0'),
          const Divider(
            thickness: 2,
          ),
          buildBillingRow(
              'Total :', model.quotationdata.grandTotal?.toString() ?? '0.0'),
        ],
      ),
    );
  }

  Widget buildBillingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16.0),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
      ],
    );
  }

  Widget buildItemColumn(String labelText, {required String additionalText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AutoSizeText(labelText),
        AutoSizeText(additionalText),
      ],
    );
  }
}
