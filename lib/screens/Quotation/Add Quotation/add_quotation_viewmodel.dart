import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../../model/addquotation_model.dart';
import '../../../model/quotation_details_model.dart';
import '../../../services/add_quotation_services.dart';

class AddQuotationModel extends BaseViewModel {
  final _logger = Logger();
  final _service = AddQuotationServices();

  final formKey = GlobalKey<FormState>();

  DateTime? selectedvalidtillDate;

  List<String> searchcustomer = [];
  final List<String> quotationto = ["Customer", "Lead", "Prospect"];
  final List<String> ordetype = ["Sales", "Maintenance", "Shopping Cart"];

  List<Items> selectedItems = [];
  List<QuotationDetailsModel> quotationdetailsmodel = [];

  bool isEdit = false;
  bool isSame = false;

  final TextEditingController customercontroller = TextEditingController();
  final TextEditingController customernamecontroller = TextEditingController();
  final TextEditingController searchcustomercontroller = TextEditingController();
  final TextEditingController validtilldatecontroller = TextEditingController();

  late String quotationId;
  String name = "";
  String customerLabel = 'Customer';
  String displayString = '';
  int quotationStatus = 0;

  AddQuotation quotationdata = AddQuotation();

  Future<void> initialise(BuildContext context, String quotationid) async {
    setBusy(true);

    try {
      quotationId = quotationid;
      quotationStatus = 0;
      quotationdata.orderType = "Sales";

      if (quotationId.isNotEmpty) {
        isEdit = true;

        final data = await _service.getquotation(quotationid);
        quotationdata = data ?? AddQuotation();

        searchcustomer =
        await _service.getcustomer(quotationdata.quotationTo ?? "Customer");

        quotationStatus = quotationdata.docstatus ?? 0;
        customercontroller.text = quotationdata.partyName ?? "";
        validtilldatecontroller.text = quotationdata.validTill ?? "";
        customernamecontroller.text = quotationdata.customerName ?? "";
        selectedItems = List<Items>.from(quotationdata.items ?? []);

        isSame = true;
      }

      updateTextFieldValue();
    } catch (e) {
      _logger.e(e);
      _showToast("Failed to load quotation", isError: true);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> onSavePressed(BuildContext context) async {
    if (_isSubmitted(message: 'You cannot edit the submitted document')) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    setBusy(true);

    try {
      quotationdata.items = selectedItems;

      if (isEdit) {
        name = await _service.addOrder(quotationdata);
        if (name.isNotEmpty) {
          isSame = true;
          _showToast("Quotation updated successfully");
        }
      } else {
        name = await _service.addOrder(quotationdata);
        if (name.isNotEmpty) {
          _showToast("Quotation created successfully");
          await initialise(context, name);
        }
      }
    } catch (e) {
      _logger.e(e);
      _showToast("Failed to save quotation", isError: true);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> onSubmitPressed(BuildContext context) async {
    if (_isSubmitted(message: 'You cannot submit the submitted document')) {
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) return;

    setBusy(true);

    try {
      quotationdata.items = selectedItems;
      quotationdata.docstatus = 1;

      final res = await _service.updateOrder(quotationdata);
      if (res && context.mounted) {
        _showToast("Quotation submitted successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e(e);
      _showToast("Failed to submit quotation", isError: true);
    } finally {
      setBusy(false);
    }
  }

  Future<void> onCancelPressed(BuildContext context) async {
    setBusy(true);

    try {
      quotationdata.items = selectedItems;
      quotationdata.docstatus = 2;

      final res = await _service.cancelOrder(quotationdata);
      if (res && context.mounted) {
        _showToast("Quotation cancelled successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.e(e);
      _showToast("Failed to cancel quotation", isError: true);
    } finally {
      setBusy(false);
    }
  }

  Future<void> selectvalidtillDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedvalidtillDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    selectedvalidtillDate = picked;
    isSame = false;
    validtilldatecontroller.text = DateFormat('yyyy-MM-dd').format(picked);
    quotationdata.validTill = validtilldatecontroller.text;
    notifyListeners();
  }

  void onvalidtillDobChanged(String value) {
    isSame = false;
    quotationdata.validTill = value;
  }

  void setcustomer(String? customer) {
    isSame = false;
    quotationdata.partyName = customer;
    notifyListeners();
  }

  Future<void> setquotationto(String? quotationTo) async {
    if (quotationTo == null || quotationTo.isEmpty) return;

    isSame = false;
    quotationdata.quotationTo = quotationTo;
    quotationdata.partyName = "";
    searchcustomer = await _service.getcustomer(quotationTo);
    setCustomerLabel(quotationTo);
    notifyListeners();
  }

  void setordertype(String? ordertype) {
    isSame = false;
    quotationdata.orderType = ordertype;
    notifyListeners();
  }

  void setCustomerLabel(String? quotationTo) {
    if (quotationTo == 'Prospect') {
      customerLabel = 'Prospect';
    } else if (quotationTo == 'Lead') {
      customerLabel = 'Lead';
    } else {
      customerLabel = 'Customer';
    }
  }

  void updateTextFieldValue() {
    displayString = selectedItems.isEmpty
        ? 'Items are not selected'
        : '${selectedItems.length} item(s) selected';
  }

  Future<void> setSelectedItems(List<Items> items) async {
    isSame = false;
    selectedItems = items;

    for (final item in selectedItems) {
      item.amount = (item.qty ?? 1.0) * (item.rate ?? 0.0);
    }

    quotationdata.items = selectedItems;
    updateTextFieldValue();

    try {
      final details = await _service.quotationdetails(quotationdata);
      _applyQuotationDetails(details);
    } catch (e) {
      _logger.e(e);
      _showToast("Failed to calculate quotation", isError: true);
    }

    notifyListeners();
  }

  void _applyQuotationDetails(List<QuotationDetailsModel> quotationdetail) {
    quotationdata.totalTaxesAndCharges =
    quotationdetail.isNotEmpty ? quotationdetail[0].totalTaxesAndCharges : 0.0;
    quotationdata.grandTotal =
    quotationdetail.isNotEmpty ? quotationdetail[0].grandTotal : 0.0;
    quotationdata.discountAmount =
    quotationdetail.isNotEmpty ? quotationdetail[0].discountAmount : 0.0;
    quotationdata.total =
    quotationdetail.isNotEmpty ? quotationdetail[0].netTotal : 0.0;
    quotationdata.netTotal =
    quotationdetail.isNotEmpty ? quotationdetail[0].netTotal : 0.0;
  }

  Future<void> updateItemQuantity(int index, int quantityChange) async {
    if (selectedItems.isEmpty || index < 0 || index >= selectedItems.length) {
      return;
    }

    final currentQty = selectedItems[index].qty ?? 0.0;
    final newQty = currentQty + quantityChange;

    if (newQty < 1) return;

    isSame = false;
    selectedItems[index].qty = newQty;
    selectedItems[index].amount =
        (selectedItems[index].qty ?? 0.0) * (selectedItems[index].rate ?? 0.0);

    quotationdata.items = selectedItems;

    try {
      final details = await _service.quotationdetails(quotationdata);
      _applyQuotationDetails(details);
    } catch (e) {
      _logger.e(e);
    }

    notifyListeners();
  }

  num getQuantity(Items item) => item.qty ?? 1.0;

  void additem(int index) {
    updateItemQuantity(index, 1);
  }

  void removeitem(int index) {
    updateItemQuantity(index, -1);
  }

  Future<void> deleteitem(int index) async {
    if (index < 0 || index >= selectedItems.length) return;

    isSame = false;
    selectedItems.removeAt(index);
    quotationdata.items = selectedItems;
    updateTextFieldValue();

    try {
      final details = await _service.quotationdetails(quotationdata);
      _applyQuotationDetails(details);
    } catch (e) {
      _logger.e(e);
    }

    notifyListeners();
  }

  String? validateordertype(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select Order Type';
    }
    return null;
  }

  String? validateQuotationTo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select Customer';
    }
    return null;
  }

  String? validateValidTill(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select Valid-till';
    }
    return null;
  }

  bool _isSubmitted({required String message}) {
    if (quotationStatus == 1) {
      _showToast(message, isError: true);
      return true;
    }
    return false;
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    customercontroller.dispose();
    customernamecontroller.dispose();
    searchcustomercontroller.dispose();
    validtilldatecontroller.dispose();
    super.dispose();
  }
}