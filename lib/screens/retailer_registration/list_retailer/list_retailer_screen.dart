import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../add_retailer/add_retailer_screen.dart';
import 'list_retailer_viewmodel.dart';

class RetailerListView extends StatelessWidget {
  const RetailerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RetailerListViewModel>.reactive(
      viewModelBuilder: () => RetailerListViewModel(),
      onViewModelReady: (model) => model.fetchRetailers(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Retailers"),
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
        backgroundColor: Colors.grey[100],
        body: model.isBusy
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent))
            : model.retailers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_mall_directory_outlined,
                            size: 60, color: Colors.grey[500]),
                        const SizedBox(height: 16),
                        const Text(
                          "No retailers found",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: model.retailers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final retailer = model.retailers[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Text(
                            retailer.name1 ?? 'No Name',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            retailer.city ?? 'No City',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: Colors.blueAccent),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RetailerFormView(
                                    retailerId: retailer.name ?? ""),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RetailerFormView(retailerId: ''),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Retailer"),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }
}
