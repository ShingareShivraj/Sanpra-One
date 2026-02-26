// delivery_note_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:geolocation/services/order_services.dart';
import 'package:stacked/stacked.dart';

class DeliveryNoteViewModel extends BaseViewModel {
  final OrderServices _service = OrderServices();

  DeliveryNote deliveryNoteData = DeliveryNote();

  /// Load Delivery Note details
  Future<void> initialise(String dnId) async {
    setBusy(true);

    try {
      final data = await _service.getOrder(dnId);

      // If API returns null, keep an empty model instead of null
      deliveryNoteData = data ?? DeliveryNote();
    } catch (e) {
      debugPrint("Error fetching Delivery Note: $e");
    }

    setBusy(false);
  }
}

class DeliveryNote {
  String? name;
  String? owner;
  String? title;
  String? namingSeries;
  String? customer;
  String? customerName;
  String? postingDate;
  String? postingTime;
  String? setWarehouse;
  double? totalQty;
  double? totalNetWeight;
  double? baseTotal;
  double? baseNetTotal;
  double? total;
  double? netTotal;
  String? taxCategory;
  double? baseTotalTaxesAndCharges;
  double? totalTaxesAndCharges;
  double? baseGrandTotal;
  double? baseRoundingAdjustment;
  double? baseRoundedTotal;
  String? baseInWords;
  double? grandTotal;
  double? roundingAdjustment;
  double? roundedTotal;
  String? inWords;
  String? customerAddress;
  String? addressDisplay;
  String? gstCategory;
  String? placeOfSupply;
  String? status;

  List<Items>? items;

  DeliveryNote({
    this.name,
    this.owner,
    this.title,
    this.namingSeries,
    this.customer,
    this.customerName,
    this.postingDate,
    this.postingTime,
    this.setWarehouse,
    this.totalQty,
    this.totalNetWeight,
    this.baseTotal,
    this.baseNetTotal,
    this.total,
    this.netTotal,
    this.taxCategory,
    this.baseTotalTaxesAndCharges,
    this.totalTaxesAndCharges,
    this.baseGrandTotal,
    this.baseRoundingAdjustment,
    this.baseRoundedTotal,
    this.baseInWords,
    this.grandTotal,
    this.roundingAdjustment,
    this.roundedTotal,
    this.inWords,
    this.customerAddress,
    this.addressDisplay,
    this.gstCategory,
    this.placeOfSupply,
    this.status,
    this.items,
  });

  DeliveryNote.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    title = json['title'];
    namingSeries = json['naming_series'];
    customer = json['customer'];
    customerName = json['customer_name'];
    postingDate = json['posting_date'];
    postingTime = json['posting_time'];
    setWarehouse = json['set_warehouse'];

    totalQty = json['total_qty'];
    totalNetWeight = _toDouble(json['total_net_weight']);

    baseTotal = _toDouble(json['base_total']);
    baseNetTotal = _toDouble(json['base_net_total']);
    total = _toDouble(json['total']);
    netTotal = _toDouble(json['net_total']);

    taxCategory = json['tax_category'];
    baseTotalTaxesAndCharges = _toDouble(json['base_total_taxes_and_charges']);
    totalTaxesAndCharges = _toDouble(json['total_taxes_and_charges']);
    baseGrandTotal = _toDouble(json['base_grand_total']);
    baseRoundingAdjustment = _toDouble(json['base_rounding_adjustment']);
    baseRoundedTotal = _toDouble(json['base_rounded_total']);
    baseInWords = json['base_in_words'];

    grandTotal = _toDouble(json['grand_total']);
    roundingAdjustment = _toDouble(json['rounding_adjustment']);
    roundedTotal = _toDouble(json['rounded_total']);
    inWords = json['in_words'];

    customerAddress = json['customer_address'];
    addressDisplay = json['address_display'];
    gstCategory = json['gst_category'];
    placeOfSupply = json['place_of_supply'];
    status = json['status'];

    if (json['items'] != null) {
      items =
          (json['items'] as List).map((item) => Items.fromJson(item)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['name'] = name;
    data['owner'] = owner;
    data['title'] = title;
    data['naming_series'] = namingSeries;
    data['customer'] = customer;
    data['customer_name'] = customerName;
    data['posting_date'] = postingDate;
    data['posting_time'] = postingTime;
    data['set_warehouse'] = setWarehouse;
    data['total_qty'] = totalQty;
    data['total_net_weight'] = totalNetWeight;
    data['base_total'] = baseTotal;
    data['base_net_total'] = baseNetTotal;
    data['total'] = total;
    data['net_total'] = netTotal;
    data['tax_category'] = taxCategory;
    data['base_total_taxes_and_charges'] = baseTotalTaxesAndCharges;
    data['total_taxes_and_charges'] = totalTaxesAndCharges;
    data['base_grand_total'] = baseGrandTotal;
    data['base_rounding_adjustment'] = baseRoundingAdjustment;
    data['base_rounded_total'] = baseRoundedTotal;
    data['base_in_words'] = baseInWords;
    data['grand_total'] = grandTotal;
    data['rounding_adjustment'] = roundingAdjustment;
    data['rounded_total'] = roundedTotal;
    data['in_words'] = inWords;
    data['customer_address'] = customerAddress;
    data['address_display'] = addressDisplay;
    data['gst_category'] = gstCategory;
    data['place_of_supply'] = placeOfSupply;
    data['status'] = status;

    if (items != null) {
      data['items'] = items!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}

/// Helper to convert int/double safely
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class Items {
  String? name;
  String? owner;
  String? itemCode;
  String? itemName;
  String? description;
  String? gstHsnCode;
  String? itemGroup;
  String? image;
  double? qty;
  String? stockUom;
  String? uom;
  double? conversionFactor;
  double? stockQty;
  double? rate;
  double? amount;
  double? baseRate;
  double? baseAmount;
  String? warehouse;
  String? againstSalesOrder;
  String? soDetail;
  int? useSerialBatchFields;
  double? actualQty;

  Items({
    this.name,
    this.owner,
    this.itemCode,
    this.itemName,
    this.description,
    this.gstHsnCode,
    this.itemGroup,
    this.image,
    this.qty,
    this.stockUom,
    this.uom,
    this.conversionFactor,
    this.stockQty,
    this.rate,
    this.amount,
    this.baseRate,
    this.baseAmount,
    this.warehouse,
    this.againstSalesOrder,
    this.soDetail,
    this.useSerialBatchFields,
    this.actualQty,
  });

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    description = json['description'];
    gstHsnCode = json['gst_hsn_code'];
    itemGroup = json['item_group'];
    image = json['image'];
    qty = _toDouble(json['qty']);
    stockUom = json['stock_uom'];
    uom = json['uom'];
    conversionFactor = _toDouble(json['conversion_factor']);
    stockQty = _toDouble(json['stock_qty']);

    rate = _toDouble(json['rate']);
    amount = _toDouble(json['amount']);
    baseRate = _toDouble(json['base_rate']);
    baseAmount = _toDouble(json['base_amount']);

    warehouse = json['warehouse'];
    againstSalesOrder = json['against_sales_order'];
    soDetail = json['so_detail'];
    useSerialBatchFields = json['use_serial_batch_fields'];
    actualQty = _toDouble(json['actual_qty']);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "owner": owner,
      "item_code": itemCode,
      "item_name": itemName,
      "description": description,
      "gst_hsn_code": gstHsnCode,
      "item_group": itemGroup,
      "image": image,
      "qty": qty,
      "stock_uom": stockUom,
      "uom": uom,
      "conversion_factor": conversionFactor,
      "stock_qty": stockQty,
      "rate": rate,
      "amount": amount,
      "base_rate": baseRate,
      "base_amount": baseAmount,
      "warehouse": warehouse,
      "against_sales_order": againstSalesOrder,
      "so_detail": soDetail,
      "use_serial_batch_fields": useSerialBatchFields,
      "actual_qty": actualQty,
    };
  }
}
