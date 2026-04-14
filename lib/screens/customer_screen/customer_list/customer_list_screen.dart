import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:stacked/stacked.dart';
import 'package:geolocation/screens/customer_screen/add_customer/add_customer_view.dart';
import 'customer_list_viewmodel.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomerListViewModel>.reactive(
      viewModelBuilder: () => CustomerListViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          title: const Text("Customer Details"),
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCustomer(id: ""),
              ),
            );
            model.refresh();
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: Column(
            children: [
              /// 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: model.setCustomerFilter,
                    decoration: const InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              /// 📋 Customer List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: model.refresh,
                  child: model.filterCustomerList.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: model.filterCustomerList.length,
                          itemBuilder: (_, index) {
                            final customer = model.filterCustomerList[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () =>
                                    model.onRowClick(context, customer),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// 🔹 Header
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            customer.customerName ?? '',
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        if (customer.customerGroup != null)
                                          _badge(customer.customerGroup!),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    /// 🔹 Info Grid
                                    Row(
                                      children: [
                                        _infoTile(
                                          Icons.location_on_outlined,
                                          "TERRITORY",
                                          customer.territory ?? "N/A",
                                        ),
                                        _infoTile(
                                          Icons.receipt_long,
                                          "GST CATEGORY",
                                          customer.gstCategory ?? "N/A",
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        _infoTile(
                                          Icons.person_outline,
                                          "SALES PERSON",
                                          customer.salesPerson ?? "-",
                                        ),
                                        TextButton.icon(
                                          onPressed: () => model.onRowClick(
                                              context, customer),
                                          icon: const Icon(Icons.arrow_forward),
                                          label: const Text("View Details"),
                                        ),
                                      ],
                                    ),

                                    /// 🔹 Footer
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : _buildEmptyState(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Badge
  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 🔹 Info Tile
  Expanded _infoTile(IconData icon, String title, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_2_rounded, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No Customers Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try adjusting your search or filters.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
