import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (
        BuildContext context,
        ThemeProvider themeProvider,
        Widget? child,
      ) {
        return _SettingsSection(
          title: 'Appearance',
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
          title: 'Notifications',
          icon: Icons.notifications_none_rounded,
          accentColor: const Color(0xFF1A3C6E),
          children: <Widget>[
            _SettingsSwitchTile(
              icon: Icons.home_work_outlined,
              title: 'Property Updates',
              subtitle: 'New verified listings and market matches',
              value: settings.propertyUpdatesEnabled,
              onChanged: settings.setPropertyUpdatesEnabled,
            ),
            _SettingsDivider(),
            _SettingsSwitchTile(
              icon: Icons.event_available_outlined,
              title: 'Appointment Reminders',
              subtitle: 'Viewing reminders before scheduled visits',
              value: settings.appointmentRemindersEnabled,
              onChanged: settings.setAppointmentRemindersEnabled,
            ),
            _SettingsDivider(),
            _SettingsSwitchTile(
              icon: Icons.trending_up_rounded,
              title: 'Price Changes',
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (
        BuildContext context,
        SettingsProvider settings,
        Widget? child,
      ) {
        return _SettingsSection(
          title: 'Account',
          icon: Icons.account_circle_outlined,
          accentColor: const Color(0xFFA17324),
          children: <Widget>[
            _SettingsActionTile(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              subtitle: settings.profileName,
              onTap: () => _showProfileEditor(context, settings),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.history_rounded,
              title: 'Viewing History',
              subtitle: 'Review and clear recent searches',
              onTap: () => _showViewingHistory(context),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Appointments',
              subtitle: 'View appointment reminder status',
              onTap: () => _showAppointments(context, settings),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProfileEditor(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final TextEditingController nameController =
        TextEditingController(text: settings.profileName);
    final TextEditingController phoneController =
        TextEditingController(text: settings.profilePhone);
    final TextEditingController emailController =
        TextEditingController(text: settings.profileEmail);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await settings.updateProfile(
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
      );
    }

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }

  Future<void> _showViewingHistory(BuildContext context) async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Viewing History'),
        content: const Text(
          'Recent searches are stored locally on this device and can be cleared from cache.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await settings.clearCachePreferences();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppointments(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Appointments'),
        content: Text(
          settings.appointmentRemindersEnabled
              ? 'Appointment reminders are active for property viewings.'
              : 'Appointment reminders are currently turned off.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
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
              title: 'Language',
              subtitle: settings.language,
              trailingText: settings.language,
              onTap: () => _showLanguagePicker(context, settings),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.currency_exchange_rounded,
              title: 'Currency',
              subtitle: settings.currencyName,
              trailingText: settings.currency,
              onTap: () => _showCurrencyPicker(context, settings),
            ),
            _SettingsDivider(),
            _SettingsActionTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Cache',
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
          subtitle: 'dnb Homes version and product details',
          onTap: () => _showAboutApp(context),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How data and permissions are handled',
          onTap: () => _showLegalDialog(
            context: context,
            title: 'Privacy Policy',
            body:
                'dnb Homes stores preferences locally on this device and uses permissions only for app features such as maps, media, notifications, and property discovery.',
          ),
        ),
        _SettingsDivider(),
        _SettingsActionTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'Rules for using the platform',
          onTap: () => _showLegalDialog(
            context: context,
            title: 'Terms of Service',
            body:
                'Use dnb Homes for lawful property discovery, comparison, and appointment booking. Listing details should be verified before payment or commitment.',
          ),
        ),
      ],
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'dnb Homes',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: Color(0xFF178F5B),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.home_work_rounded, color: Colors.white),
      ),
      applicationLegalese:
          '© 2025 dnb Homes — NileBitLabs. All rights reserved.',
      children: const <Widget>[
        SizedBox(height: 16),
        Text(
          'dnb Homes is a modern real estate platform by NileBitLabs that helps you find your perfect property in Uganda.',
        ),
      ],
    );
  }

  Future<void> _showLegalDialog({
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
      child: SegmentedButton<ThemeMode>(
        segments: const <ButtonSegment<ThemeMode>>[
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Light'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Dark'),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            icon: Icon(Icons.settings_suggest_outlined),
            label: Text('System'),
          ),
        ],
        selected: <ThemeMode>{selectedMode},
        showSelectedIcon: false,
        onSelectionChanged: (Set<ThemeMode> selected) {
          onChanged(selected.first);
        },
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
