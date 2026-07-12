import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/legal_page_widgets.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primary = const Color(0xFF178F5B);
    final Color navy = const Color(0xFF1A3C6E);
    final Color gold = const Color(0xFFA17324);

    Widget section(String title, IconData icon, Color color, List<Widget> content) {
      return Column(
        children: <Widget>[
          LegalCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LegalSectionTitle(title, icon: icon, color: color),
                const SizedBox(height: 12),
                ...content,
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B111E) : const Color(0xFFF6F8F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B111E) : Colors.white,
            leading: const LegalBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[gold, const Color(0xFF7A5518)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Effective: July 2025',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Terms of Service',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Rules for using the platform',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
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
              delegate: SliverChildListDelegate(<Widget>[
                LegalCard(
                  isDark: isDark,
                  child: LegalBodyText(
                    'Welcome to dnb Homes.\n\nBy accessing or using this application, you agree to these Terms of Service. If you do not agree with these terms, please discontinue use of the application.',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),
                section('Using dnb Homes', Icons.gavel_rounded, navy, <Widget>[
                  LegalBodyText(
                    'You agree to use the platform responsibly and in accordance with applicable laws. You must not:',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  ...<String>[
                    'Provide false information',
                    'Attempt unauthorized access to the platform',
                    'Disrupt platform operations',
                    'Upload misleading property information',
                    'Use the platform for unlawful activities',
                  ].map((String s) => LegalBulletPoint(text: s, isDark: isDark, color: gold)),
                ]),
                section('User Accounts', Icons.manage_accounts_outlined, primary, <Widget>[
                  LegalBodyText(
                    'You are responsible for maintaining the security of your account and any activity performed under it. Please keep your login credentials secure.',
                    isDark: isDark,
                  ),
                ]),
                section('Property Listings', Icons.home_outlined, navy, <Widget>[
                  LegalBodyText(
                    'dnb Homes serves as a marketplace connecting property seekers with property owners, agents and agencies. We do not own, sell or lease the listed properties unless explicitly stated.\n\nListing information is supplied by third parties and may occasionally change. Users should perform reasonable due diligence before entering into agreements or making payments.',
                    isDark: isDark,
                  ),
                ]),
                section('Appointments', Icons.event_outlined, primary, <Widget>[
                  LegalBodyText(
                    'Appointment requests submitted through dnb Homes do not guarantee property availability. Property owners and agents are responsible for confirming appointments.',
                    isDark: isDark,
                  ),
                ]),
                section('Payments', Icons.payment_rounded, gold, <Widget>[
                  LegalBodyText(
                    'Unless otherwise stated, dnb Homes is not responsible for payments made outside the platform.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  LegalHighlightBox(
                    text: 'Never make payments without verifying the authenticity of the property and the identity of the seller or agent.',
                    color: gold,
                    isDark: isDark,
                  ),
                ]),
                section('Intellectual Property', Icons.copyright_rounded, navy, <Widget>[
                  LegalBodyText(
                    'All application content, branding, logos, software, designs and technology remain the intellectual property of dnb Homes and NileBit Labs unless otherwise stated. No part of the platform may be copied, reproduced or redistributed without written permission.',
                    isDark: isDark,
                  ),
                ]),
                section('Limitation of Liability', Icons.balance_rounded, primary, <Widget>[
                  LegalBodyText(
                    'While we work to provide accurate information and reliable services, dnb Homes cannot guarantee that every listing is complete, current or error-free.\n\nUsers remain responsible for conducting their own inspections, legal verification and financial due diligence before completing any property transaction.',
                    isDark: isDark,
                  ),
                ]),
                section('Suspension of Accounts', Icons.block_rounded, gold, <Widget>[
                  LegalBodyText(
                    'We reserve the right to suspend or remove accounts that violate these Terms of Service or engage in fraudulent, abusive or unlawful behaviour.',
                    isDark: isDark,
                  ),
                ]),
                section('Governing Law', Icons.location_city_rounded, navy, <Widget>[
                  LegalBodyText(
                    'These Terms shall be governed by the laws of the Republic of Uganda.',
                    isDark: isDark,
                  ),
                ]),
                LegalCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LegalSectionTitle('Contact', icon: Icons.mail_outline_rounded, color: primary),
                      const SizedBox(height: 12),
                      LegalBodyText('For legal or general enquiries regarding these Terms, contact:', isDark: isDark),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _launch('mailto:dnbtechnologies@gmail.com'),
                        child: Text(
                          'dnbtechnologies@gmail.com',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '© 2025 dnb Homes. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
