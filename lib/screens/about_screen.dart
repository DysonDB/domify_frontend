import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/legal_page_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
    final gold = const Color(0xFFA17324);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B111E) : const Color(0xFFF6F8F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B111E) : Colors.white,
            leading: const LegalBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, navy],
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
                          child: Text('dnb Homes • v1.0.0',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              )),
                        ),
                        const SizedBox(height: 12),
                        Text('Find your next home\nwith confidence.',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            )),
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome to dnb Homes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800, color: primary)),
                    const SizedBox(height: 12),
                    LegalBodyText(
                      'dnb Homes is a modern property platform built to make buying, renting and discovering real estate simple, transparent and reliable.\n\n'
                      "Finding property shouldn't involve endless phone calls, misleading listings or uncertainty. dnb Homes was created to give people one trusted place where they can discover verified properties, compare options, connect with agents and make informed decisions.\n\n"
                      "Whether you're looking for your first apartment, a family home, commercial space, land, or a short stay, dnb Homes helps you search faster and with greater confidence.",
                      isDark: isDark,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                LegalCard(
                  isDark: isDark,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LegalSectionTitle('What We Do', icon: Icons.apartment_rounded, color: navy),
                    const SizedBox(height: 12),
                    LegalBodyText('dnb Homes brings together property seekers, agents, brokers, developers and property owners on one trusted platform.', isDark: isDark),
                    const SizedBox(height: 12),
                    ...[
                      'Browse verified property listings',
                      'Search by location, budget and property type',
                      'Save favourite properties',
                      'Compare multiple properties side by side',
                      'Book property viewings',
                      'Connect directly with property representatives',
                      'Discover new opportunities across Uganda',
                    ].map((s) => LegalBulletPoint(text: s, isDark: isDark, color: primary)),
                  ]),
                ),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(
                    child: LegalCard(
                      isDark: isDark,
                      accentColor: primary,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.flag_rounded, color: primary, size: 28),
                        const SizedBox(height: 10),
                        Text('Our Mission',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        LegalBodyText('To make property discovery simple, transparent and accessible for everyone.', isDark: isDark, size: 13),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LegalCard(
                      isDark: isDark,
                      accentColor: navy,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.visibility_rounded, color: navy, size: 28),
                        const SizedBox(height: 10),
                        Text('Our Vision',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        LegalBodyText("To become Africa's most trusted digital real estate platform.", isDark: isDark, size: 13),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                LegalCard(
                  isDark: isDark,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LegalSectionTitle('Why dnb Homes?', icon: Icons.star_rounded, color: gold),
                    const SizedBox(height: 12),
                    LegalBodyText(
                      'We believe trust is the foundation of every property transaction.\n\n'
                      "That's why we're building tools that help users make informed decisions through better information, verified listings and modern technology.\n\n"
                      'As the platform grows, dnb Homes will introduce intelligent recommendations, fraud detection, neighbourhood insights and AI-powered property analytics.',
                      isDark: isDark,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                LegalCard(
                  isDark: isDark,
                  accentColor: primary,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.code_rounded, color: primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Built by NileBit Labs',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        LegalBodyText(
                          'dnb Homes is proudly designed and developed by NileBit Labs, a Ugandan technology company focused on building innovative digital products through software, artificial intelligence and blockchain technology.',
                          isDark: isDark,
                          size: 13,
                        ),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                LegalCard(
                  isDark: isDark,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LegalSectionTitle('Contact', icon: Icons.contact_support_rounded, color: navy),
                    const SizedBox(height: 16),
                    LegalContactRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'dnbtechnologies@gmail.com',
                      onTap: () => _launch('mailto:dnbtechnologies@gmail.com'),
                      color: primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    LegalContactRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone / WhatsApp',
                      value: '0747 877 740',
                      onTap: () => _launch('tel:0747877740'),
                      color: primary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    LegalContactRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: 'Kampala, Uganda',
                      color: primary,
                      isDark: isDark,
                    ),
                  ]),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text('© 2025 dnb Homes. All rights reserved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
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
