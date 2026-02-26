import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../model/comment_List_model.dart';
import '../../../services/add_customer_services.dart';
import '../../../services/call_services.dart';
import '../../../services/update_customer_services.dart';

class UpdateCustomerViewModel extends BaseViewModel {
  TextEditingController comment = TextEditingController();
  GetCustomer customerData = GetCustomer();
  CallsAndMessagesService service = CallsAndMessagesService();
  List<CommentList> comments = [];
  bool res = false;
  List<Orders> orders = [];
  List<Orders> filterOrders = [];
  List<Visits> visit = [];
  List<String> status = [
    "Not Delivered",
    "Fully Delivered",
    "Partly Delivered",
    "Closed",
    "Not Applicable"
  ];
  Future<void> initialise(BuildContext context, String id) async {
    setBusy(true);

    if (id != "") {
      customerData =
          await AddCustomerServices().getCustomerDetails(id) ?? GetCustomer();
      comments = customerData.comments ?? [];
      orders = customerData.orders ?? [];
      visit = customerData.visits ?? [];
      filterOrders = orders;
    }
    setBusy(false);
  }

  void addComment(String? id, dynamic content) async {
    if (id!.isNotEmpty) {
      res = await UpdateCustomerService().addComment(id, content);
    }
    if (res) {
      comments =
          (await UpdateCustomerService().fetchComments(id)).cast<CommentList>();
    }
    comment.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    comment.dispose();
    super.dispose();
  }
}

class GetCustomer {
  String? name;
  String? phone;
  String? email;
  String? address;
  int? totalVisits;
  int? totalOrders;
  double? totalOrderAmount;
  List<Visits>? visits;
  List<CommentList>? comments;
  List<Orders>? orders;

  GetCustomer(
      {this.name,
      this.phone,
      this.email,
      this.address,
      this.totalVisits,
      this.totalOrders,
      this.totalOrderAmount,
      this.visits,
      this.comments,
      this.orders});

  GetCustomer.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    totalVisits = json['total_visits'];
    totalOrders = json['total_orders'];
    totalOrderAmount = json['total_order_amount'];
    if (json['visits'] != null) {
      visits = <Visits>[];
      json['visits'].forEach((v) {
        visits!.add(new Visits.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = <CommentList>[];
      json['comments'].forEach((v) {
        comments!.add(CommentList.fromJson(v));
      });
    }
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['address'] = this.address;
    data['total_visits'] = this.totalVisits;
    data['total_orders'] = this.totalOrders;
    data['total_order_amount'] = this.totalOrderAmount;
    if (this.visits != null) {
      data['visits'] = this.visits!.map((v) => v.toJson()).toList();
    }
    if (this.comments != null) {
      data['comments'] = this.comments!.map((v) => v.toJson()).toList();
    }
    if (this.orders != null) {
      data['orders'] = this.orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Visits {
  String? visitId;
  String? visitInTime;
  String? visitOutTime;
  String? visitInAddress;
  String? visitOutAddress;
  String? owner;

  Visits(
      {this.visitId,
      this.visitInTime,
      this.visitOutTime,
      this.visitInAddress,
      this.visitOutAddress,
      this.owner});

  Visits.fromJson(Map<String, dynamic> json) {
    visitId = json['visit_id'];
    visitInTime = json['visit_in_time'];
    visitOutTime = json['visit_out_time'];
    visitInAddress = json['visit_in_address'];
    visitOutAddress = json['visit_out_address'];
    owner = json['owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visit_id'] = this.visitId;
    data['visit_in_time'] = this.visitInTime;
    data['visit_out_time'] = this.visitOutTime;
    data['visit_in_address'] = this.visitInAddress;
    data['visit_out_address'] = this.visitOutAddress;
    data['owner'] = this.owner;
    return data;
  }
}

class Comments {
  String? comment;
  String? commentBy;
  String? creation;
  String? commentEmail;
  Null? userImage;
  String? commented;

  Comments(
      {this.comment,
      this.commentBy,
      this.creation,
      this.commentEmail,
      this.userImage,
      this.commented});

  Comments.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    commentBy = json['comment_by'];
    creation = json['creation'];
    commentEmail = json['comment_email'];
    userImage = json['user_image'];
    commented = json['commented'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment'] = this.comment;
    data['comment_by'] = this.commentBy;
    data['creation'] = this.creation;
    data['comment_email'] = this.commentEmail;
    data['user_image'] = this.userImage;
    data['commented'] = this.commented;
    return data;
  }
}

class Orders {
  String? orderId;
  String? date;
  double? amount;
  String? status;

  Orders({this.orderId, this.date, this.amount, this.status});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    date = json['date'];
    amount = json['amount'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['date'] = this.date;
    data['amount'] = this.amount;
    data['status'] = this.status;
    return data;
  }
}
