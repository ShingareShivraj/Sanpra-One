import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/full_screen_loader.dart';
import '../../constants.dart';
import '../../router.router.dart';
import 'profile_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (model) => model.initialise(context),
      builder: (context, model, child) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], // Blue Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          title: const Text(
            "My Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: fullScreenLoader(
          loader: model.isBusy,
          context: context,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 Profile Header (blue background)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0), // Blue background
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => model.selectPdf(ImageSource.gallery),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            width: 80,
                            height: 80,
                            imageUrl: model.employeedetail.employeeImage ?? '',
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/profile.png',
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.employeedetail.employeeName ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              model.employeedetail.companyEmail ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              model.employeedetail.designation ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 👉 Section Title
                const Text(
                  "Profile Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),

                // 👉 Profile Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileDetail(
                          "Employee ID",
                          model.employeedetail.name ?? "N/A",
                          Icons.badge_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Date of Joining",
                          model.employeedetail.dateOfJoining ?? "N/A",
                          Icons.calendar_month_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Date of Birth",
                          model.employeedetail.dateOfBirth ?? "N/A",
                          Icons.cake_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Gender",
                          model.employeedetail.gender ?? "N/A",
                          Icons.people_alt_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Official Email",
                          model.employeedetail.companyEmail ?? "N/A",
                          Icons.email_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Personal Email",
                          model.employeedetail.personalEmail ?? "N/A",
                          Icons.alternate_email_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Contact Number",
                          model.employeedetail.cellNumber ?? "N/A",
                          Icons.phone_outlined),
                      _buildDivider(),
                      _buildProfileDetail(
                          "Emergency Contact",
                          model.employeedetail.emergencyPhoneNumber ?? "N/A",
                          Icons.contact_phone_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 👉 Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0), // Blue button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pushNamed(
                        context, Routes.changePasswordScreen),
                    icon: const Icon(Icons.lock_outline, color: Colors.white),
                    label: const Text(
                      "Change Password",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _showLogoutDialog(context, model),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD), // Light blue bg
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AutoSizeText(
                value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                minFontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      const Divider(thickness: 1, height: 20, color: Color(0xFFEAEAEA));

  void _showLogoutDialog(BuildContext context, ProfileViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                logout(context);
              },
              child: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
