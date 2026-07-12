import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/legal_page_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF178F5B);
    final navy = const Color(0xFF1A3C6E);

    Widget section(String title, IconData icon, Color color, List<Widget> content) =>
        Column(children: [
          LegalCard(
            isDark: isDark,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              LegalSectionTitle(title, icon: icon, color: color),
              const SizedBox(height: 12),
              ...content,
            ]),
          ),
          const SizedBox(height: 16),
        ]);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B111E) : const Color(0xFFF6F8F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B111E) : Colors.white,
            leading: const LegalBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A3C6E), Color(0xFF0D2340)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Effective: July 2025',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              )),
                        ),
                        const SizedBox(height: 12),
                        Text('Privacy Policy',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w800)),
                        Text('How we handle your data',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.75))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                LegalCard(
                  isDark: isDark,
                  child: LegalBodyText(
                    'At dnb Homes, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains what information we collect, why we collect it and how it is used.\n\nBy using dnb Homes, you agree to this Privacy Policy.',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                section('Information We Collect', Icons.storage_rounded, navy, [
                  LegalSubHeading('Account Information'),
                  ...[
                    'Full name', 'Email address', 'Phone number', 'Profile information',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  const SizedBox(height: 10),
                  LegalSubHeading('Property Activity'),
                  ...[
                    'Saved properties', 'Search history', 'Favourite listings',
                    'Property comparisons', 'Appointment requests',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  const SizedBox(height: 10),
                  LegalSubHeading('Device Information'),
                  ...[
                    'Device model and OS version',
                    'Application version',
                    'Crash reports and performance diagnostics',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  const SizedBox(height: 10),
                  LegalSubHeading('Location Data'),
                  LegalBodyText(
                    'If you grant permission, dnb Homes may access your device location to show nearby properties and improve search accuracy. Location access is optional and can be disabled at any time in your device settings.',
                    isDark: isDark,
                  ),
                ]),

                section('How We Use Your Information', Icons.insights_rounded, primary, [
                  ...[
                    'Deliver our services',
                    'Improve search results',
                    'Manage appointments',
                    'Respond to support requests',
                    'Improve application performance',
                    'Prevent fraud and abuse',
                    'Maintain platform security',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  const SizedBox(height: 10),
                  LegalHighlightBox(
                    text: 'We do not sell your personal information.',
                    color: primary,
                    isDark: isDark,
                  ),
                ]),

                section('Property Listings', Icons.home_outlined, navy, [
                  LegalBodyText(
                    'Property information displayed within dnb Homes is provided by property owners, agencies and authorized representatives. Users are encouraged to independently verify all property details before making financial commitments.',
                    isDark: isDark,
                  ),
                ]),

                section('Data Security', Icons.security_rounded, primary, [
                  LegalBodyText(
                    'We use appropriate technical and organizational measures to protect your information from unauthorized access, disclosure, alteration or loss. Although no online system is completely secure, protecting user information remains one of our highest priorities.',
                    isDark: isDark,
                  ),
                ]),

                section('Third-Party Services', Icons.extension_outlined, navy, [
                  LegalBodyText('dnb Homes may use trusted third-party providers to support:', isDark: isDark),
                  const SizedBox(height: 8),
                  ...[
                    'Maps and location services',
                    'Analytics and crash reporting',
                    'Cloud hosting',
                    'Push notifications',
                    'Payment processing (future)',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  const SizedBox(height: 6),
                  LegalBodyText('Each provider operates under its own privacy practices.', isDark: isDark),
                ]),

                section('Your Rights', Icons.verified_user_outlined, primary, [
                  LegalBodyText('You may request to:', isDark: isDark),
                  const SizedBox(height: 8),
                  ...[
                    'Access your personal information',
                    'Update inaccurate information',
                    'Delete your account',
                    'Remove saved preferences',
                    'Contact us regarding privacy concerns',
                  ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                ]),

                section("Children's Privacy", Icons.child_care_rounded, navy, [
                  LegalBodyText(
                    'dnb Homes is not intended for children under the age of 13. We do not knowingly collect personal information from children.',
                    isDark: isDark,
                  ),
                ]),

                LegalCard(
                  isDark: isDark,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LegalSectionTitle('Contact Us', icon: Icons.mail_outline_rounded, color: primary),
                    const SizedBox(height: 12),
                    LegalBodyText('For questions regarding this Privacy Policy, contact:', isDark: isDark),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _launch('mailto:dnbtechnologies@gmail.com'),
                      child: Text('dnbtechnologies@gmail.com',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            decoration: TextDecoration.underline,
                          )),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text('© 2025 dnb Homes. All rights reserved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      textAlign: TextAlign.center),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
