import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/legal_page_widgets.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

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
    final Color danger = const Color(0xFFDC2626);

    final List<_TipData> tips = <_TipData>[
      const _TipData(
        icon: Icons.visibility_rounded,
        color: Color(0xFF178F5B),
        title: 'Always view before you pay',
        body: 'Never pay for a property without first physically visiting and verifying the premises yourself. If viewing is not possible, send a trusted representative.',
      ),
      const _TipData(
        icon: Icons.badge_rounded,
        color: Color(0xFF1A3C6E),
        title: 'Verify the agent or owner',
        body: "Ask for proper identification and verify the agent's credentials or the owner's proof of title before proceeding with any transaction.",
      ),
      const _TipData(
        icon: Icons.place_rounded,
        color: Color(0xFFA17324),
        title: 'Meet at the property',
        body: 'Conduct all property meetings at the actual location. Avoid meeting in unrelated or unofficial venues for property-related discussions.',
      ),
      const _TipData(
        icon: Icons.account_balance_rounded,
        color: Color(0xFF1A3C6E),
        title: 'Use traceable payments',
        body: 'Where possible, avoid large cash transactions. Use mobile money, bank transfers or other traceable payment methods that leave a record.',
      ),
      const _TipData(
        icon: Icons.description_rounded,
        color: Color(0xFF178F5B),
        title: 'Insist on documentation',
        body: 'Request and review all relevant documents before any payment — including land titles, rental agreements, agency mandates or sale agreements.',
      ),
      const _TipData(
        icon: Icons.group_rounded,
        color: Color(0xFFA17324),
        title: 'Bring someone with you',
        body: 'When viewing a property for the first time, bring a friend, family member or legal representative for added safety and a second perspective.',
      ),
      const _TipData(
        icon: Icons.flag_rounded,
        color: Color(0xFFDC2626),
        title: 'Report suspicious listings',
        body: 'If you encounter a listing that appears fraudulent, misleading or suspicious, report it immediately through the app or contact our support team.',
      ),
      const _TipData(
        icon: Icons.lock_rounded,
        color: Color(0xFFDC2626),
        title: 'Protect your account',
        body: 'dnb Homes will never ask for your password, PIN or payment credentials via phone, email or any message. Never share your login details with anyone.',
        isWarning: true,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B111E) : const Color(0xFFF6F8F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B111E) : Colors.white,
            leading: const LegalBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF178F5B), Color(0xFF0D5C3A)],
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
                            'dnb Homes • Property Safety',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Safety Tips',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Protect yourself in every transaction',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
                  accentColor: primary,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.shield_rounded, color: primary, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Your safety is our priority',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LegalBodyText(
                              'Property transactions involve significant decisions. Use these tips to stay safe and protected every step of the way.',
                              isDark: isDark,
                              size: 13.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...tips.map((_TipData tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TipCard(tip: tip, isDark: isDark),
                    )),
                const SizedBox(height: 8),
                LegalCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LegalSectionTitle('Report a concern', icon: Icons.support_agent_rounded, color: primary),
                      const SizedBox(height: 12),
                      LegalBodyText(
                        'Encountered a suspicious listing or experience on dnb Homes? Contact us immediately:',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 14),
                      LegalContactRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: 'dnbtechnologies@gmail.com',
                        onTap: () => _launch('mailto:dnbtechnologies@gmail.com'),
                        color: primary,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      LegalContactRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'WhatsApp',
                        value: '0747 877 740',
                        onTap: () => _launch('https://wa.me/256747877740'),
                        color: primary,
                        isDark: isDark,
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

class _TipData {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool isWarning;
  const _TipData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.isWarning = false,
  });
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.isDark});
  final _TipData tip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tip.isWarning
            ? tip.color.withOpacity(isDark ? 0.12 : 0.06)
            : (isDark ? const Color(0xFF131B2E) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: tip.color.withOpacity(tip.isWarning ? 0.3 : 0.15),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, color: tip.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tip.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tip.isWarning ? tip.color : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.body,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.7 : 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
