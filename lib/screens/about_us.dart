import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> launchWebsite() async {
    final url = Uri.parse("https://www.sanpra.co.in");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> launchPhone() async {
    final phone = Uri.parse("tel:+917058927201");
    await launchUrl(phone);
  }

  Future<void> launchEmail(String email) async {
    final emailUri = Uri(scheme: "mailto", path: email);
    await launchUrl(emailUri);
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.redAccent,
        size: 26,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// HEADER CARD
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                      theme.colorScheme.primaryContainer,
                      child: const Icon(
                        Icons.apartment_rounded,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Sanpra Software Solution",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Business Software & Mobile App Solutions",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// CONTACT CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Company Information",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  infoTile(
                    icon: Icons.location_on_outlined,
                    title:
                    "Vijaynagar, Chanakya Chowk, Sangli - 416415",
                  ),

                  infoTile(
                    icon: Icons.language_rounded,
                    title: "www.sanpra.co.in",
                    onTap: launchWebsite,
                  ),

                  infoTile(
                    icon: Icons.phone_rounded,
                    title: "+91 7058 9272 01",
                    onTap: launchPhone,
                  ),

                  infoTile(
                    icon: Icons.mail_outline_rounded,
                    title: "sanprasoftwares@gmail.com",
                    onTap: () =>
                        launchEmail("sanprasoftwares@gmail.com"),
                  ),

                  infoTile(
                    icon: Icons.alternate_email_rounded,
                    title: "contact@sanpra.co.in",
                    onTap: () =>
                        launchEmail("contact@sanpra.co.in"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ABOUT CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "About",
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Sanpra Software Solution provides modern "
                          "business software and mobile applications "
                          "designed to help companies manage sales teams, "
                          "customers, visits, tours, and business "
                          "operations efficiently using a single platform.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            /// FOOTER
            Text(
              "© 2026 Sanpra Software Solution",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}