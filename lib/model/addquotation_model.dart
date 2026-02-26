class AddQuotation {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? title;
  String? namingSeries;
  String? quotationTo;
  String? partyName;
  String? customerName;
  int? isReverseCharge;
  int? isExportWithGst;
  String? transactionDate;
  String? validTill;
  String? orderType;
  String? company;
  String? currency;
  double? conversionRate;
  String? sellingPriceList;
  String? priceListCurrency;
  double? plcConversionRate;
  int? ignorePricingRule;
  double? totalQty;
  double? totalNetWeight;
  double? baseTotal;
  double? baseNetTotal;
  double? total;
  double? netTotal;
  String? taxCategory;
  String? taxesAndCharges;
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
  String? applyDiscountOn;
  double? baseDiscountAmount;
  double? additionalDiscountPercentage;
  double? discountAmount;
  String? otherChargesCalculation;
  String? gstCategory;
  String? placeOfSupply;
  String? contactDisplay;
  String? contactMobile;
  String? contactEmail;
  String? companyAddress;
  String? companyGstin;
  String? companyAddressDisplay;
  int? groupSameItems;
  String? language;
  String? status;
  String? customerGroup;
  String? territory;
  String? doctype;
  List<PaymentSchedule>? paymentSchedule;
  List<Items>? items;
  List<Taxes>? taxes;

  AddQuotation(
      {this.name,
        this.owner,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.title,
        this.namingSeries,
        this.quotationTo,
        this.partyName,
        this.customerName,
        this.isReverseCharge,
        this.isExportWithGst,
        this.transactionDate,
        this.validTill,
        this.orderType,
        this.company,
        this.currency,
        this.conversionRate,
        this.sellingPriceList,
        this.priceListCurrency,
        this.plcConversionRate,
        this.ignorePricingRule,
        this.totalQty,
        this.totalNetWeight,
        this.baseTotal,
        this.baseNetTotal,
        this.total,
        this.netTotal,
        this.taxCategory,
        this.taxesAndCharges,
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
        this.applyDiscountOn,
        this.baseDiscountAmount,
        this.additionalDiscountPercentage,
        this.discountAmount,
        this.otherChargesCalculation,
        this.gstCategory,
        this.placeOfSupply,
        this.contactDisplay,
        this.contactMobile,
        this.contactEmail,
        this.companyAddress,
        this.companyGstin,
        this.companyAddressDisplay,
        this.groupSameItems,
        this.language,
        this.status,
        this.customerGroup,
        this.territory,
        this.doctype,
        this.paymentSchedule,
        this.items,
        this.taxes});

  AddQuotation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    title = json['title'];
    namingSeries = json['naming_series'];
    quotationTo = json['quotation_to'];
    partyName = json['party_name'];
    customerName = json['customer_name'];
    isReverseCharge = json['is_reverse_charge'];
    isExportWithGst = json['is_export_with_gst'];
    transactionDate = json['transaction_date'];
    validTill = json['valid_till'];
    orderType = json['order_type'];
    company = json['company'];
    currency = json['currency'];
    conversionRate = json['conversion_rate'];
    sellingPriceList = json['selling_price_list'];
    priceListCurrency = json['price_list_currency'];
    plcConversionRate = json['plc_conversion_rate'];
    ignorePricingRule = json['ignore_pricing_rule'];
    totalQty = json['total_qty'];
    totalNetWeight = json['total_net_weight'];
    baseTotal = json['base_total'];
    baseNetTotal = json['base_net_total'];
    total = json['total'];
    netTotal = json['net_total'];
    taxCategory = json['tax_category'];
    taxesAndCharges = json['taxes_and_charges'];
    baseTotalTaxesAndCharges = json['base_total_taxes_and_charges'];
    totalTaxesAndCharges = json['total_taxes_and_charges'];
    baseGrandTotal = json['base_grand_total'];
    baseRoundingAdjustment = json['base_rounding_adjustment'];
    baseRoundedTotal = json['base_rounded_total'];
    baseInWords = json['base_in_words'];
    grandTotal = json['grand_total'];
    roundingAdjustment = json['rounding_adjustment'];
    roundedTotal = json['rounded_total'];
    inWords = json['in_words'];
    applyDiscountOn = json['apply_discount_on'];
    baseDiscountAmount = json['base_discount_amount'];
    additionalDiscountPercentage = json['additional_discount_percentage'];
    discountAmount = json['discount_amount'];
    otherChargesCalculation = json['other_charges_calculation'];
    gstCategory = json['gst_category'];
    placeOfSupply = json['place_of_supply'];
    contactDisplay = json['contact_display'];
    contactMobile = json['contact_mobile'];
    contactEmail = json['contact_email'];
    companyAddress = json['company_address'];
    companyGstin = json['company_gstin'];
    companyAddressDisplay = json['company_address_display'];
    groupSameItems = json['group_same_items'];
    language = json['language'];
    status = json['status'];
    customerGroup = json['customer_group'];
    territory = json['territory'];
    doctype = json['doctype'];
    if (json['payment_schedule'] != null) {
      paymentSchedule = <PaymentSchedule>[];
      json['payment_schedule'].forEach((v) {
        paymentSchedule!.add(PaymentSchedule.fromJson(v));
      });
    }
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    if (json['taxes'] != null) {
      taxes = <Taxes>[];
      json['taxes'].forEach((v) {
        taxes!.add(Taxes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['title'] = title;
    data['naming_series'] = namingSeries;
    data['quotation_to'] = quotationTo;
    data['party_name'] = partyName;
    data['customer_name'] = customerName;
    data['is_reverse_charge'] = isReverseCharge;
    data['is_export_with_gst'] = isExportWithGst;
    data['transaction_date'] = transactionDate;
    data['valid_till'] = validTill;
    data['order_type'] = orderType;
    data['company'] = company;
    data['currency'] = currency;
    data['conversion_rate'] = conversionRate;
    data['selling_price_list'] = sellingPriceList;
    data['price_list_currency'] = priceListCurrency;
    data['plc_conversion_rate'] = plcConversionRate;
    data['ignore_pricing_rule'] = ignorePricingRule;
    data['total_qty'] = totalQty;
    data['total_net_weight'] = totalNetWeight;
    data['base_total'] = baseTotal;
    data['base_net_total'] = baseNetTotal;
    data['total'] = total;
    data['net_total'] = netTotal;
    data['tax_category'] = taxCategory;
    data['taxes_and_charges'] = taxesAndCharges;
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
    data['apply_discount_on'] = applyDiscountOn;
    data['base_discount_amount'] = baseDiscountAmount;
    data['additional_discount_percentage'] = additionalDiscountPercentage;
    data['discount_amount'] = discountAmount;
    data['other_charges_calculation'] = otherChargesCalculation;
    data['gst_category'] = gstCategory;
    data['place_of_supply'] = placeOfSupply;
    data['contact_display'] = contactDisplay;
    data['contact_mobile'] = contactMobile;
    data['contact_email'] = contactEmail;
    data['company_address'] = companyAddress;
    data['company_gstin'] = companyGstin;
    data['company_address_display'] = companyAddressDisplay;
    data['group_same_items'] = groupSameItems;
    data['language'] = language;
    data['status'] = status;
    data['customer_group'] = customerGroup;
    data['territory'] = territory;
    data['doctype'] = doctype;
    if (paymentSchedule != null) {
      data['payment_schedule'] =
          paymentSchedule!.map((v) => v.toJson()).toList();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (taxes != null) {
      data['taxes'] = taxes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentSchedule {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? dueDate;
  double? invoicePortion;
  double? discount;
  double? paymentAmount;
  double? outstanding;
  double? paidAmount;
  double? discountedAmount;
  double? basePaymentAmount;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  PaymentSchedule(
      {this.name,
        this.owner,
        this.creation,
        this.modified,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.dueDate,
        this.invoicePortion,
        this.discount,
        this.paymentAmount,
        this.outstanding,
        this.paidAmount,
        this.discountedAmount,
        this.basePaymentAmount,
        this.parent,
        this.parentfield,
        this.parenttype,
        this.doctype});

  PaymentSchedule.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    dueDate = json['due_date'];
    invoicePortion = json['invoice_portion'];
    discount = json['discount'];
    paymentAmount = json['payment_amount'];
    outstanding = json['outstanding'];
    paidAmount = json['paid_amount'];
    discountedAmount = json['discounted_amount'];
    basePaymentAmount = json['base_payment_amount'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['due_date'] = dueDate;
    data['invoice_portion'] = invoicePortion;
    data['discount'] = discount;
    data['payment_amount'] = paymentAmount;
    data['outstanding'] = outstanding;
    data['paid_amount'] = paidAmount;
    data['discounted_amount'] = discountedAmount;
    data['base_payment_amount'] = basePaymentAmount;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}

class Items {
  // String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? itemCode;
  String? itemName;
  String? description;
  String? gstHsnCode;
  int? isNilExempt;
  int? isNonGst;
  String? itemGroup;
  String? image;
  double? qty;
  String? stockUom;
  String? uom;
  double? conversionFactor;
  double? stockQty;
  double? priceListRate;
  double? basePriceListRate;
  String? marginType;
  double? marginRateOrAmount;
  double? rateWithMargin;
  double? discountPercentage;
  double? discountAmount;
  double? baseRateWithMargin;
  double? rate;
  double? netRate;
  double? amount;
  double? netAmount;
  String? itemTaxTemplate;
  double? baseRate;
  double? baseNetRate;
  double? baseAmount;
  double? baseNetAmount;
  String? pricingRules;
  double? stockUomRate;
  int? isFreeItem;
  int? isAlternative;
  int? hasAlternativeItem;
  double? valuationRate;
  double? grossProfit;
  double? weightPerUnit;
  double? totalWeight;
  int? againstBlanketOrder;
  double? blanketOrderRate;
  double? projectedQty;
  double? actualQty;
  String? itemTaxRate;
  int? pageBreak;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  Items(
      {
        // this.name,
        this.owner,
        this.creation,
        this.modified,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.itemCode,
        this.itemName,
        this.description,
        this.gstHsnCode,
        this.isNilExempt,
        this.isNonGst,
        this.itemGroup,
        this.image,
        this.qty,
        this.stockUom,
        this.uom,
        this.conversionFactor,
        this.stockQty,
        this.priceListRate,
        this.basePriceListRate,
        this.marginType,
        this.marginRateOrAmount,
        this.rateWithMargin,
        this.discountPercentage,
        this.discountAmount,
        this.baseRateWithMargin,
        this.rate,
        this.netRate,
        this.amount,
        this.netAmount,
        this.itemTaxTemplate,
        this.baseRate,
        this.baseNetRate,
        this.baseAmount,
        this.baseNetAmount,
        this.pricingRules,
        this.stockUomRate,
        this.isFreeItem,
        this.isAlternative,
        this.hasAlternativeItem,
        this.valuationRate,
        this.grossProfit,
        this.weightPerUnit,
        this.totalWeight,
        this.againstBlanketOrder,
        this.blanketOrderRate,
        this.projectedQty,
        this.actualQty,
        this.itemTaxRate,
        this.pageBreak,
        this.parent,
        this.parentfield,
        this.parenttype,
        this.doctype});

  Items.fromJson(Map<String, dynamic> json) {
    // name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    description = json['description'];
    gstHsnCode = json['gst_hsn_code'];
    isNilExempt = json['is_nil_exempt'];
    isNonGst = json['is_non_gst'];
    itemGroup = json['item_group'];
    image = json['image'];
    qty = json['qty'];
    stockUom = json['stock_uom'];
    uom = json['uom'];
    conversionFactor = json['conversion_factor'];
    stockQty = json['stock_qty'];
    priceListRate = json['price_list_rate'];
    basePriceListRate = json['base_price_list_rate'];
    marginType = json['margin_type'];
    marginRateOrAmount = json['margin_rate_or_amount'];
    rateWithMargin = json['rate_with_margin'];
    discountPercentage = json['discount_percentage'];
    discountAmount = json['discount_amount'];
    baseRateWithMargin = json['base_rate_with_margin'];
    rate = json['rate'];
    netRate = json['net_rate'];
    amount = json['amount'];
    netAmount = json['net_amount'];
    itemTaxTemplate = json['item_tax_template'];
    baseRate = json['base_rate'];
    baseNetRate = json['base_net_rate'];
    baseAmount = json['base_amount'];
    baseNetAmount = json['base_net_amount'];
    pricingRules = json['pricing_rules'];
    stockUomRate = json['stock_uom_rate'];
    isFreeItem = json['is_free_item'];
    isAlternative = json['is_alternative'];
    hasAlternativeItem = json['has_alternative_item'];
    valuationRate = json['valuation_rate'];
    grossProfit = json['gross_profit'];
    weightPerUnit = json['weight_per_unit'];
    totalWeight = json['total_weight'];
    againstBlanketOrder = json['against_blanket_order'];
    blanketOrderRate = json['blanket_order_rate'];
    projectedQty = json['projected_qty'];
    actualQty = json['actual_qty'];
    itemTaxRate = json['item_tax_rate'];
    pageBreak = json['page_break'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['name'] = this.name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['description'] = description;
    data['gst_hsn_code'] = gstHsnCode;
    data['is_nil_exempt'] = isNilExempt;
    data['is_non_gst'] = isNonGst;
    data['item_group'] = itemGroup;
    data['image'] = image;
    data['qty'] = qty;
    data['stock_uom'] = stockUom;
    data['uom'] = uom;
    data['conversion_factor'] = conversionFactor;
    data['stock_qty'] = stockQty;
    data['price_list_rate'] = priceListRate;
    data['base_price_list_rate'] = basePriceListRate;
    data['margin_type'] = marginType;
    data['margin_rate_or_amount'] = marginRateOrAmount;
    data['rate_with_margin'] = rateWithMargin;
    data['discount_percentage'] = discountPercentage;
    data['discount_amount'] = discountAmount;
    data['base_rate_with_margin'] = baseRateWithMargin;
    data['rate'] = rate;
    data['net_rate'] = netRate;
    data['amount'] = amount;
    data['net_amount'] = netAmount;
    data['item_tax_template'] = itemTaxTemplate;
    data['base_rate'] = baseRate;
    data['base_net_rate'] = baseNetRate;
    data['base_amount'] = baseAmount;
    data['base_net_amount'] = baseNetAmount;
    data['pricing_rules'] = pricingRules;
    data['stock_uom_rate'] = stockUomRate;
    data['is_free_item'] = isFreeItem;
    data['is_alternative'] = isAlternative;
    data['has_alternative_item'] = hasAlternativeItem;
    data['valuation_rate'] = valuationRate;
    data['gross_profit'] = grossProfit;
    data['weight_per_unit'] = weightPerUnit;
    data['total_weight'] = totalWeight;
    data['against_blanket_order'] = againstBlanketOrder;
    data['blanket_order_rate'] = blanketOrderRate;
    data['projected_qty'] = projectedQty;
    data['actual_qty'] = actualQty;
    data['item_tax_rate'] = itemTaxRate;
    data['page_break'] = pageBreak;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}

class Taxes {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? chargeType;
  String? accountHead;
  String? description;
  int? includedInPrintRate;
  int? includedInPaidAmount;
  String? costCenter;
  double? rate;
  double? taxAmount;
  double? total;
  double? taxAmountAfterDiscountAmount;
  double? baseTaxAmount;
  double? baseTotal;
  double? baseTaxAmountAfterDiscountAmount;
  String? itemWiseTaxDetail;
  int? dontRecomputeTax;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  Taxes(
      {this.name,
        this.owner,
        this.creation,
        this.modified,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.chargeType,
        this.accountHead,
        this.description,
        this.includedInPrintRate,
        this.includedInPaidAmount,
        this.costCenter,
        this.rate,
        this.taxAmount,
        this.total,
        this.taxAmountAfterDiscountAmount,
        this.baseTaxAmount,
        this.baseTotal,
        this.baseTaxAmountAfterDiscountAmount,
        this.itemWiseTaxDetail,
        this.dontRecomputeTax,
        this.parent,
        this.parentfield,
        this.parenttype,
        this.doctype});

  Taxes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    chargeType = json['charge_type'];
    accountHead = json['account_head'];
    description = json['description'];
    includedInPrintRate = json['included_in_print_rate'];
    includedInPaidAmount = json['included_in_paid_amount'];
    costCenter = json['cost_center'];
    rate = json['rate'];
    taxAmount = json['tax_amount'];
    total = json['total'];
    taxAmountAfterDiscountAmount = json['tax_amount_after_discount_amount'];
    baseTaxAmount = json['base_tax_amount'];
    baseTotal = json['base_total'];
    baseTaxAmountAfterDiscountAmount =
    json['base_tax_amount_after_discount_amount'];
    itemWiseTaxDetail = json['item_wise_tax_detail'];
    dontRecomputeTax = json['dont_recompute_tax'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['charge_type'] = chargeType;
    data['account_head'] = accountHead;
    data['description'] = description;
    data['included_in_print_rate'] = includedInPrintRate;
    data['included_in_paid_amount'] = includedInPaidAmount;
    data['cost_center'] = costCenter;
    data['rate'] = rate;
    data['tax_amount'] = taxAmount;
    data['total'] = total;
    data['tax_amount_after_discount_amount'] =
        taxAmountAfterDiscountAmount;
    data['base_tax_amount'] = baseTaxAmount;
    data['base_total'] = baseTotal;
    data['base_tax_amount_after_discount_amount'] =
        baseTaxAmountAfterDiscountAmount;
    data['item_wise_tax_detail'] = itemWiseTaxDetail;
    data['dont_recompute_tax'] = dontRecomputeTax;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}
