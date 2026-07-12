import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'safety_tips_screen.dart';
import 'profile_screen.dart';
import 'viewing_history_screen.dart';
import 'appointments_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color scaffoldColor = theme.brightness == Brightness.dark
        ? const Color(0xFF0B111E)
        : const Color(0xFFF6F8F7);

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _SettingsHeader(theme: theme)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    const _AppearanceSection(),
                    const SizedBox(height: 14),
                    const _NotificationsSection(),
                    const SizedBox(height: 14),
                    const _AccountSection(),
                    const SizedBox(height: 14),
                    const _AppSettingsSection(),
                    const SizedBox(height: 14),
                    const _AboutSection(),
                    const SizedBox(height: 18),
                    _DangerZone(
                      onSignOut: () => _confirmSignOut(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SettingsProvider>().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    }
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (
        BuildContext context,
        ThemeProvider themeProvider,
        SettingsProvider settings,
        Widget? child,
      ) {
        return _SettingsSection(
          title: settings.translate('appearance_txt'),
          icon: Icons.palette_outlined,
          accentColor: const Color(0xFF178F5B),
          children: <Widget>[
            _ThemeModeSelector(
              selectedMode: themeProvider.themeMode,
              onChanged: themeProvider.setThemeMode,
            ),
          ],
        );
      },
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (
        BuildContext context,
        SettingsProvider settings,
        Widget? child,
      ) {
        return _SettingsSection(
          title: 'Notifications', // Or translate if needed
          icon: Icons.notifications_none_rounded,
          accentColor: const Color(0xFF1A3C6E),
          children: <Widget>[
            _SettingsSwitchTile(
              icon: Icons.home_work_outlined,
              title: settings.translate('property_updates'),
              subtitle: 'New verified listings and market matches',
              value: settings.propertyUpdatesEnabled,
              onChanged: settings.setPropertyUpdatesEnabled,
            ),
            _SettingsDivider(),
            _SettingsSwitchTile(
              icon: Icons.event_available_outlined,
              title: settings.translate('appointment_reminders'),
              subtitle: 'Viewing reminders before scheduled visits',
              value: settings.appointmentRemindersEnabled,
              onChanged: settings.setAppointmentRemindersEnabled,
            ),
            _SettingsDivider(),
            _SettingsSwitchTile(
              icon: Icons.trending_up_rounded,
              title: settings.translate('price_changes'),
              subtitle: 'Alerts when saved property prices move',
              value: settings.priceChangesEnabled,
              onChanged: settings.setPriceChangesEnabled,
            ),
          ],
        );
      },
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (BuildContext context, SettingsProvider settings, Widget? child) {
        return _SettingsSection(
          title: 'Account',
          icon: Icons.account_circle_outlined,
          accentColor: const Color(0xFFA17324),
          children: <Widget>[
            _SettingsActionTile(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              subtitle: settings.profileName,
              onTap: () => _push(context, const ProfileScreen()),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.history_rounded,
              title: settings.translate('viewing_history'),
              subtitle: 'Properties you have recently viewed',
              onTap: () => _push(context, const ViewingHistoryScreen()),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.calendar_today_outlined,
              title: settings.translate('appointments'),
              subtitle: 'Manage your property viewing bookings',
              onTap: () => _push(context, const AppointmentsScreen()),
            ),
          ],
        );
      },
    );
  }
}

class _AppSettingsSection extends StatelessWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (
        BuildContext context,
        SettingsProvider settings,
        Widget? child,
      ) {
        return _SettingsSection(
          title: 'App Settings',
          icon: Icons.tune_rounded,
          accentColor: const Color(0xFF178F5B),
          children: <Widget>[
            _SettingsActionTile(
              icon: Icons.language_rounded,
              title: settings.translate('language_txt'),
              subtitle: settings.language,
              trailingText: settings.language,
              onTap: () => _showLanguagePicker(context, settings),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.currency_exchange_rounded,
              title: settings.translate('currency_txt'),
              subtitle: settings.currencyName,
              trailingText: settings.currency,
              onTap: () => _showCurrencyPicker(context, settings),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.cleaning_services_outlined,
              title: settings.translate('clear_cache_txt'),
              subtitle: 'Remove recent searches and temporary app data',
              onTap: () => _confirmClearCache(context, settings),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final String? language = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => _ChoiceSheet(
        title: 'Language',
        selectedValue: settings.language,
        choices: SettingsProvider.languages,
      ),
    );
    if (language != null) await settings.setLanguage(language);
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final String? currency = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => _ChoiceSheet(
        title: 'Currency',
        selectedValue: settings.currency,
        choices: SettingsProvider.currencies.keys.toList(),
        labels: SettingsProvider.currencies,
      ),
    );
    if (currency != null) await settings.setCurrency(currency);
  }

  Future<void> _confirmClearCache(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear recent searches and temporary local app data.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await settings.clearCachePreferences();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _rateApp() async {
    // Replace with actual Play Store ID when published
    const String storeUrl =
        'https://play.google.com/store/apps/details?id=com.nilebitlabs.dnbhomes';
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    await Share.share(
      '🏠 Find your next home with dnb Homes!\n\n'
      'Browse thousands of verified properties in Uganda — buy, rent, or stay.\n\n'
      '📲 Download: https://nilebitlabs.com/dnb-homes\n\n'
      'dnb Homes — Where home begins.',
      subject: 'dnb Homes — Property Search App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'About',
      icon: Icons.info_outline_rounded,
      accentColor: const Color(0xFF1A3C6E),
      children: <Widget>[
        _SettingsActionTile(
          icon: Icons.apartment_rounded,
          title: 'About App',
          subtitle: 'dnb Homes — version, mission and team',
          onTap: () => _push(context, const AboutScreen()),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How your data and permissions are handled',
          onTap: () => _push(context, const PrivacyPolicyScreen()),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'Rules for using the platform',
          onTap: () => _push(context, const TermsOfServiceScreen()),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.shield_rounded,
          title: 'Safety Tips',
          subtitle: 'How to stay safe in every transaction',
          onTap: () => _push(context, const SafetyTipsScreen()),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.star_rounded,
          title: 'Rate on Play Store',
          subtitle: 'Love the app? Leave us a 5-star review!',
          trailingText: '⭐',
          onTap: _rateApp,
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.share_rounded,
          title: 'Share App',
          subtitle: 'Invite friends & family to dnb Homes',
          onTap: () => _shareApp(context),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.info_rounded,
          title: 'App Version',
          subtitle: 'dnb Homes v1.0.0 — Build 1',
          trailingText: 'v1.0.0',
          onTap: () {},
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF101828);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? const <Color>[Color(0xFF101827), Color(0xFF13251F)]
                : const <Color>[Colors.white, Color(0xFFEFF8F2)],
          ),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFE4E7EC),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.22 : 0.06,
              ),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Material(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.maybePop(context),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: <Color>[primaryColor, secondaryColor],
                ),
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF178F5B);
    final secondaryColor = const Color(0xFF1A3C6E);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTab(context, ThemeMode.light, Icons.light_mode_rounded, 'Light', primaryColor),
          _buildTab(context, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark', secondaryColor),
          _buildTab(context, ThemeMode.system, Icons.settings_suggest_rounded, 'System', const Color(0xFFA17324)),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, ThemeMode mode, IconData icon, String label, Color accentColor) {
    final isSelected = selectedMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.selectedValue,
    required this.choices,
    this.labels = const <String, String>{},
  });

  final String title;
  final String selectedValue;
  final List<String> choices;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ...choices.map(
              (String value) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(labels[value] ?? value),
                subtitle: labels.containsKey(value) ? Text(value) : null,
                trailing: value == selectedValue
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () => Navigator.pop(context, value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE4E7EC),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.045),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
              child: Row(
                children: <Widget>[
                  _SectionIcon(icon: icon, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsTileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF178F5B),
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? label = trailingText;

    return _SettingsTileShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (label != null) ...<Widget>[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.62),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.38),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsTileShell extends StatelessWidget {
  const _SettingsTileShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF344054),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.58),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      color: Theme.of(context).dividerColor.withOpacity(0.35),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({
    required this.onSignOut,
    this.onOpenAdminPanel,
  });

  final VoidCallback onSignOut;
  final VoidCallback? onOpenAdminPanel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color errorColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171923) : const Color(0xFFFFFBFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: errorColor.withOpacity(0.2)),
      ),
      child: Column(
        children: <Widget>[
          _DangerButton(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'End this session on the device',
            color: errorColor,
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.58),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
