import 'package:flutter/cupertino.dart';
import 'package:geolocation/services/add_quotation_services.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../model/addquotation_model.dart';



class QuotationItemListModel extends BaseViewModel {
  List<Items> selecteditems = [];
  List<Items> isSelecteditems = [];
  double quantity = 0.0;
  final TextEditingController searchController = TextEditingController();
  List<Items> get selectedItems => selecteditems;
  List<Items> filteredItems = [];
  bool isSelected(Items item) {
    return isSelecteditems.contains(item);
  }

  void initialise(BuildContext context, List<Items> itemlist) async {
    setBusy(true);
    Logger().i(itemlist.length);
    selecteditems = await AddQuotationServices().fetchitems();
    filteredItems = selectedItems;
    for (var selectedItem in itemlist) {
      var originalItem =
      filteredItems.firstWhere((item) => item.itemCode == selectedItem.itemCode);
      originalItem.qty = selectedItem.qty;
      toggleSelection(originalItem);
    }
    Logger().i(isSelecteditems.length);

    notifyListeners();
    setBusy(false);
  }

  void toggleSelection(Items item) {
    if (isSelected(item)) {
      isSelecteditems.remove(item);
    } else {
      isSelecteditems.add(item);
    }
    // Remove unnecessary print statement
    notifyListeners();
  }
  void additem(int index) {
    selecteditems[index].qty = (selecteditems[index].qty ?? 0) + 1;
    notifyListeners();
  }

  void removeitem(int index) {
    if (selecteditems[index].qty != null && selecteditems[index].qty! > 0) {
      selecteditems[index].qty = (selecteditems[index].qty!) - 1;
      notifyListeners();
    }
  }


  void searchItems(String query) {
    final lowerCaseQuery = query.toLowerCase();
    filteredItems = selecteditems
        .where((item) => item.itemName.toString().toLowerCase().contains(lowerCaseQuery))
        .toList();
    notifyListeners();
  }

  double getQuantity(Items item) {
    return item.qty ?? 1.0;
  }
}
