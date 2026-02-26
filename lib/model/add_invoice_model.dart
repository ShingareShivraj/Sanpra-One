class AddInvoiceModel {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? title;
  String? namingSeries;
  String? customer;
  String? customerName;
  String? eWaybillStatus;

  String? postingDate;
  String? postingTime;
  int? setPostingTime;
  String? dueDate;
  int? isPos;
  int? isConsolidated;
  int? isReturn;
  String? reasonForIssuingDocument;
  int? updateBilledAmountInSalesOrder;
  int? updateBilledAmountInDeliveryNote;
  int? isDebitNote;
  int? isReverseCharge;
  int? isExportWithGst;
  String? currency;
  double? conversionRate;
  String? sellingPriceList;
  String? priceListCurrency;
  double? plcConversionRate;
  int? ignorePricingRule;
  int? updateStock;
  String? setWarehouse;
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
  int? useCompanyRoundoffCostCenter;
  double? roundedTotal;
  String? inWords;
  double? totalAdvance;
  double? outstandingAmount;
  int? disableRoundedTotal;
  String? applyDiscountOn;
  double? baseDiscountAmount;
  int? isCashOrNonTradeDiscount;
  double? additionalDiscountPercentage;
  double? discountAmount;
  String? otherChargesCalculation;
  double? totalBillingHours;
  double? totalBillingAmount;
  double? basePaidAmount;
  double? paidAmount;
  double? baseChangeAmount;
  double? changeAmount;
  int? allocateAdvancesAutomatically;
  int? onlyIncludeAllocatedPayments;
  double? writeOffAmount;
  double? baseWriteOffAmount;
  int? writeOffOutstandingAmountAutomatically;
  int? redeemLoyaltyPoints;
  int? loyaltyPoints;
  double? loyaltyAmount;
  String? customerAddress;
  String? addressDisplay;
  String? billingAddressGstin;
  String? gstCategory;
  String? placeOfSupply;
  String? territory;
  String? companyAddress;
  String? companyGstin;
  String? companyAddressDisplay;
  int? ignoreDefaultPaymentTermsTemplate;
  String? poNo;
  String? debitTo;
  String? partyAccountCurrency;
  String? isOpening;
  String? againstIncomeAccount;
  double? amountEligibleForCommission;
  double? commissionRate;
  double? totalCommission;
  int? groupSameItems;
  String? invoiceCopy;
  String? language;
  int? distance;
  String? modeOfTransport;
  String? lrDate;
  String? gstVehicleType;
  String? status;
  String? einvoiceStatus;
  String? customerGroup;
  int? isInternalCustomer;
  int? isDiscounted;
  String? remarks;
  int? repostRequired;
  String? doctype;
  List<Taxes>? taxes;
  List<PaymentSchedule>? paymentSchedule;
  List<InvoiceItems>? items;

  AddInvoiceModel(
      {this.name,
        this.owner,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.title,
        this.namingSeries,
        this.customer,
        this.customerName,
        this.eWaybillStatus,

        this.postingDate,
        this.postingTime,
        this.setPostingTime,
        this.dueDate,
        this.isPos,
        this.isConsolidated,
        this.isReturn,
        this.reasonForIssuingDocument,
        this.updateBilledAmountInSalesOrder,
        this.updateBilledAmountInDeliveryNote,
        this.isDebitNote,
        this.isReverseCharge,
        this.isExportWithGst,
        this.currency,
        this.conversionRate,
        this.sellingPriceList,
        this.priceListCurrency,
        this.plcConversionRate,
        this.ignorePricingRule,
        this.updateStock,
        this.setWarehouse,
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
        this.useCompanyRoundoffCostCenter,
        this.roundedTotal,
        this.inWords,
        this.totalAdvance,
        this.outstandingAmount,
        this.disableRoundedTotal,
        this.applyDiscountOn,
        this.baseDiscountAmount,
        this.isCashOrNonTradeDiscount,
        this.additionalDiscountPercentage,
        this.discountAmount,
        this.otherChargesCalculation,
        this.totalBillingHours,
        this.totalBillingAmount,
        this.basePaidAmount,
        this.paidAmount,
        this.baseChangeAmount,
        this.changeAmount,
        this.allocateAdvancesAutomatically,
        this.onlyIncludeAllocatedPayments,
        this.writeOffAmount,
        this.baseWriteOffAmount,
        this.writeOffOutstandingAmountAutomatically,
        this.redeemLoyaltyPoints,
        this.loyaltyPoints,
        this.loyaltyAmount,
        this.customerAddress,
        this.addressDisplay,
        this.billingAddressGstin,
        this.gstCategory,
        this.placeOfSupply,
        this.territory,
        this.companyAddress,
        this.companyGstin,
        this.companyAddressDisplay,
        this.ignoreDefaultPaymentTermsTemplate,
        this.poNo,
        this.debitTo,
        this.partyAccountCurrency,
        this.isOpening,
        this.againstIncomeAccount,
        this.amountEligibleForCommission,
        this.commissionRate,
        this.totalCommission,
        this.groupSameItems,
        this.invoiceCopy,
        this.language,
        this.distance,
        this.modeOfTransport,
        this.lrDate,
        this.gstVehicleType,
        this.status,
        this.einvoiceStatus,
        this.customerGroup,
        this.isInternalCustomer,
        this.isDiscounted,
        this.remarks,
        this.repostRequired,
        this.doctype,
        this.taxes,
        this.paymentSchedule,
        this.items});

  AddInvoiceModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    title = json['title'];
    namingSeries = json['naming_series'];
    customer = json['customer'];
    customerName = json['customer_name'];
    eWaybillStatus = json['e_waybill_status'];

    postingDate = json['posting_date'];
    postingTime = json['posting_time'];
    setPostingTime = json['set_posting_time'];
    dueDate = json['due_date'];
    isPos = json['is_pos'];
    isConsolidated = json['is_consolidated'];
    isReturn = json['is_return'];
    reasonForIssuingDocument = json['reason_for_issuing_document'];
    updateBilledAmountInSalesOrder =
    json['update_billed_amount_in_sales_order'];
    updateBilledAmountInDeliveryNote =
    json['update_billed_amount_in_delivery_note'];
    isDebitNote = json['is_debit_note'];
    isReverseCharge = json['is_reverse_charge'];
    isExportWithGst = json['is_export_with_gst'];
    currency = json['currency'];
    conversionRate = json['conversion_rate'];
    sellingPriceList = json['selling_price_list'];
    priceListCurrency = json['price_list_currency'];
    plcConversionRate = json['plc_conversion_rate'];
    ignorePricingRule = json['ignore_pricing_rule'];
    updateStock = json['update_stock'];
    setWarehouse = json['set_warehouse'];
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
    useCompanyRoundoffCostCenter = json['use_company_roundoff_cost_center'];
    roundedTotal = json['rounded_total'];
    inWords = json['in_words'];
    totalAdvance = json['total_advance'];
    outstandingAmount = json['outstanding_amount'];
    disableRoundedTotal = json['disable_rounded_total'];
    applyDiscountOn = json['apply_discount_on'];
    baseDiscountAmount = json['base_discount_amount'];
    isCashOrNonTradeDiscount = json['is_cash_or_non_trade_discount'];
    additionalDiscountPercentage = json['additional_discount_percentage'];
    discountAmount = json['discount_amount'];
    otherChargesCalculation = json['other_charges_calculation'];
    totalBillingHours = json['total_billing_hours'];
    totalBillingAmount = json['total_billing_amount'];
    basePaidAmount = json['base_paid_amount'];
    paidAmount = json['paid_amount'];
    baseChangeAmount = json['base_change_amount'];
    changeAmount = json['change_amount'];
    allocateAdvancesAutomatically = json['allocate_advances_automatically'];
    onlyIncludeAllocatedPayments = json['only_include_allocated_payments'];
    writeOffAmount = json['write_off_amount'];
    baseWriteOffAmount = json['base_write_off_amount'];
    writeOffOutstandingAmountAutomatically =
    json['write_off_outstanding_amount_automatically'];
    redeemLoyaltyPoints = json['redeem_loyalty_points'];
    loyaltyPoints = json['loyalty_points'];
    loyaltyAmount = json['loyalty_amount'];
    customerAddress = json['customer_address'];
    addressDisplay = json['address_display'];
    billingAddressGstin = json['billing_address_gstin'];
    gstCategory = json['gst_category'];
    placeOfSupply = json['place_of_supply'];
    territory = json['territory'];
    companyAddress = json['company_address'];
    companyGstin = json['company_gstin'];
    companyAddressDisplay = json['company_address_display'];
    ignoreDefaultPaymentTermsTemplate =
    json['ignore_default_payment_terms_template'];
    poNo = json['po_no'];
    debitTo = json['debit_to'];
    partyAccountCurrency = json['party_account_currency'];
    isOpening = json['is_opening'];
    againstIncomeAccount = json['against_income_account'];
    amountEligibleForCommission = json['amount_eligible_for_commission'];
    commissionRate = json['commission_rate'];
    totalCommission = json['total_commission'];
    groupSameItems = json['group_same_items'];
    invoiceCopy = json['invoice_copy'];
    language = json['language'];
    distance = json['distance'];
    modeOfTransport = json['mode_of_transport'];
    lrDate = json['lr_date'];
    gstVehicleType = json['gst_vehicle_type'];
    status = json['status'];
    einvoiceStatus = json['einvoice_status'];
    customerGroup = json['customer_group'];
    isInternalCustomer = json['is_internal_customer'];
    isDiscounted = json['is_discounted'];
    remarks = json['remarks'];
    repostRequired = json['repost_required'];
    doctype = json['doctype'];
    if (json['taxes'] != null) {
      taxes = <Taxes>[];
      json['taxes'].forEach((v) {
        taxes!.add(Taxes.fromJson(v));
      });
    }
    if (json['payment_schedule'] != null) {
      paymentSchedule = <PaymentSchedule>[];
      json['payment_schedule'].forEach((v) {
        paymentSchedule!.add(PaymentSchedule.fromJson(v));
      });
    }
    if (json['items'] != null) {
      items = <InvoiceItems>[];
      json['items'].forEach((v) {
        items!.add(InvoiceItems.fromJson(v));
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
    data['customer'] = customer;
    data['customer_name'] = customerName;
    data['e_waybill_status'] = eWaybillStatus;

    data['posting_date'] = postingDate;
    data['posting_time'] = postingTime;
    data['set_posting_time'] = setPostingTime;
    data['due_date'] = dueDate;
    data['is_pos'] = isPos;
    data['is_consolidated'] = isConsolidated;
    data['is_return'] = isReturn;
    data['reason_for_issuing_document'] = reasonForIssuingDocument;
    data['update_billed_amount_in_sales_order'] =
        updateBilledAmountInSalesOrder;
    data['update_billed_amount_in_delivery_note'] =
        updateBilledAmountInDeliveryNote;
    data['is_debit_note'] = isDebitNote;
    data['is_reverse_charge'] = isReverseCharge;
    data['is_export_with_gst'] = isExportWithGst;
    data['currency'] = currency;
    data['conversion_rate'] = conversionRate;
    data['selling_price_list'] = sellingPriceList;
    data['price_list_currency'] = priceListCurrency;
    data['plc_conversion_rate'] = plcConversionRate;
    data['ignore_pricing_rule'] = ignorePricingRule;
    data['update_stock'] = updateStock;
    data['set_warehouse'] = setWarehouse;
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
    data['use_company_roundoff_cost_center'] =
        useCompanyRoundoffCostCenter;
    data['rounded_total'] = roundedTotal;
    data['in_words'] = inWords;
    data['total_advance'] = totalAdvance;
    data['outstanding_amount'] = outstandingAmount;
    data['disable_rounded_total'] = disableRoundedTotal;
    data['apply_discount_on'] = applyDiscountOn;
    data['base_discount_amount'] = baseDiscountAmount;
    data['is_cash_or_non_trade_discount'] = isCashOrNonTradeDiscount;
    data['additional_discount_percentage'] = additionalDiscountPercentage;
    data['discount_amount'] = discountAmount;
    data['other_charges_calculation'] = otherChargesCalculation;
    data['total_billing_hours'] = totalBillingHours;
    data['total_billing_amount'] = totalBillingAmount;
    data['base_paid_amount'] = basePaidAmount;
    data['paid_amount'] = paidAmount;
    data['base_change_amount'] = baseChangeAmount;
    data['change_amount'] = changeAmount;
    data['allocate_advances_automatically'] =
        allocateAdvancesAutomatically;
    data['only_include_allocated_payments'] = onlyIncludeAllocatedPayments;
    data['write_off_amount'] = writeOffAmount;
    data['base_write_off_amount'] = baseWriteOffAmount;
    data['write_off_outstanding_amount_automatically'] =
        writeOffOutstandingAmountAutomatically;
    data['redeem_loyalty_points'] = redeemLoyaltyPoints;
    data['loyalty_points'] = loyaltyPoints;
    data['loyalty_amount'] = loyaltyAmount;
    data['customer_address'] = customerAddress;
    data['address_display'] = addressDisplay;
    data['billing_address_gstin'] = billingAddressGstin;
    data['gst_category'] = gstCategory;
    data['place_of_supply'] = placeOfSupply;
    data['territory'] = territory;
    data['company_address'] = companyAddress;
    data['company_gstin'] = companyGstin;
    data['company_address_display'] = companyAddressDisplay;
    data['ignore_default_payment_terms_template'] =
        ignoreDefaultPaymentTermsTemplate;
    data['po_no'] = poNo;
    data['debit_to'] = debitTo;
    data['party_account_currency'] = partyAccountCurrency;
    data['is_opening'] = isOpening;
    data['against_income_account'] = againstIncomeAccount;
    data['amount_eligible_for_commission'] = amountEligibleForCommission;
    data['commission_rate'] = commissionRate;
    data['total_commission'] = totalCommission;
    data['group_same_items'] = groupSameItems;
    data['invoice_copy'] = invoiceCopy;
    data['language'] = language;
    data['distance'] = distance;
    data['mode_of_transport'] = modeOfTransport;
    data['lr_date'] = lrDate;
    data['gst_vehicle_type'] = gstVehicleType;
    data['status'] = status;
    data['einvoice_status'] = einvoiceStatus;
    data['customer_group'] = customerGroup;
    data['is_internal_customer'] = isInternalCustomer;
    data['is_discounted'] = isDiscounted;
    data['remarks'] = remarks;
    data['repost_required'] = repostRequired;
    data['doctype'] = doctype;
    if (taxes != null) {
      data['taxes'] = taxes!.map((v) => v.toJson()).toList();
    }
    if (paymentSchedule != null) {
      data['payment_schedule'] =
          paymentSchedule!.map((v) => v.toJson()).toList();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Taxes {
  String? name;
  String? owner;
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

class PaymentSchedule {
  String? name;
  String? owner;
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

class InvoiceItems {
  String? name;
  String? owner;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  int? hasItemScanned;
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
  double? amount;
  String? itemTaxTemplate;
  double? baseRate;
  double? baseAmount;
  double? stockUomRate;
  int? isFreeItem;
  int? grantCommission;
  double? netRate;
  double? netAmount;
  double? baseNetRate;
  double? baseNetAmount;
  double? taxableValue;
  int? deliveredBySupplier;
  String? incomeAccount;
  int? isFixedAsset;
  String? expenseAccount;
  int? enableDeferredRevenue;
  double? weightPerUnit;
  double? totalWeight;
  String? warehouse;
  double? incomingRate;
  int? allowZeroValuationRate;
  String? itemTaxRate;
  double? actualBatchQty;
  double? actualQty;
  String? salesOrder;
  String? soDetail;
  double? deliveredQty;
  String? costCenter;
  int? pageBreak;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  InvoiceItems(
      {this.name,
        this.owner,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.hasItemScanned,
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
        this.amount,
        this.itemTaxTemplate,
        this.baseRate,
        this.baseAmount,
        this.stockUomRate,
        this.isFreeItem,
        this.grantCommission,
        this.netRate,
        this.netAmount,
        this.baseNetRate,
        this.baseNetAmount,
        this.taxableValue,
        this.deliveredBySupplier,
        this.incomeAccount,
        this.isFixedAsset,
        this.expenseAccount,
        this.enableDeferredRevenue,
        this.weightPerUnit,
        this.totalWeight,
        this.warehouse,
        this.incomingRate,
        this.allowZeroValuationRate,
        this.itemTaxRate,
        this.actualBatchQty,
        this.actualQty,
        this.salesOrder,
        this.soDetail,
        this.deliveredQty,
        this.costCenter,
        this.pageBreak,
        this.parent,
        this.parentfield,
        this.parenttype,
        this.doctype});

  InvoiceItems.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    hasItemScanned = json['has_item_scanned'];
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
    amount = json['amount'];
    itemTaxTemplate = json['item_tax_template'];
    baseRate = json['base_rate'];
    baseAmount = json['base_amount'];
    stockUomRate = json['stock_uom_rate'];
    isFreeItem = json['is_free_item'];
    grantCommission = json['grant_commission'];
    netRate = json['net_rate'];
    netAmount = json['net_amount'];
    baseNetRate = json['base_net_rate'];
    baseNetAmount = json['base_net_amount'];
    taxableValue = json['taxable_value'];
    deliveredBySupplier = json['delivered_by_supplier'];
    incomeAccount = json['income_account'];
    isFixedAsset = json['is_fixed_asset'];
    expenseAccount = json['expense_account'];
    enableDeferredRevenue = json['enable_deferred_revenue'];
    weightPerUnit = json['weight_per_unit'];
    totalWeight = json['total_weight'];
    warehouse = json['warehouse'];
    incomingRate = json['incoming_rate'];
    allowZeroValuationRate = json['allow_zero_valuation_rate'];
    itemTaxRate = json['item_tax_rate'];
    actualBatchQty = json['actual_batch_qty'];
    actualQty = json['actual_qty'];
    salesOrder = json['sales_order'];
    soDetail = json['so_detail'];
    deliveredQty = json['delivered_qty'];
    costCenter = json['cost_center'];
    pageBreak = json['page_break'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['has_item_scanned'] = hasItemScanned;
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
    data['amount'] = amount;
    data['item_tax_template'] = itemTaxTemplate;
    data['base_rate'] = baseRate;
    data['base_amount'] = baseAmount;
    data['stock_uom_rate'] = stockUomRate;
    data['is_free_item'] = isFreeItem;
    data['grant_commission'] = grantCommission;
    data['net_rate'] = netRate;
    data['net_amount'] = netAmount;
    data['base_net_rate'] = baseNetRate;
    data['base_net_amount'] = baseNetAmount;
    data['taxable_value'] = taxableValue;
    data['delivered_by_supplier'] = deliveredBySupplier;
    data['income_account'] = incomeAccount;
    data['is_fixed_asset'] = isFixedAsset;
    data['expense_account'] = expenseAccount;
    data['enable_deferred_revenue'] = enableDeferredRevenue;
    data['weight_per_unit'] = weightPerUnit;
    data['total_weight'] = totalWeight;
    data['warehouse'] = warehouse;
    data['incoming_rate'] = incomingRate;
    data['allow_zero_valuation_rate'] = allowZeroValuationRate;
    data['item_tax_rate'] = itemTaxRate;
    data['actual_batch_qty'] = actualBatchQty;
    data['actual_qty'] = actualQty;
    data['sales_order'] = salesOrder;
    data['so_detail'] = soDetail;
    data['delivered_qty'] = deliveredQty;
    data['cost_center'] = costCenter;
    data['page_break'] = pageBreak;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}
