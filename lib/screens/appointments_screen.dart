// 📁 lib/screens/appointments_screen.dart — bookings management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/appointments_provider.dart';
import 'property_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppointmentsScreen({
    super.key,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B111E) : const Color(0xFFF6F8F7),
      body: Consumer<AppointmentsProvider>(
        builder: (context, aProvider, _) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _BookingsHeader(
                  showBackButton: widget.showBackButton,
                  onBack: widget.onBack,
                  upcomingCount: aProvider.upcoming.length,
                  pastCount: aProvider.past.length,
                ),
                _BookingsTabs(controller: _tabCtrl),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _ApptList(
                        appointments: aProvider.upcoming,
                        emptyTitle: 'No upcoming bookings',
                        emptySubtitle:
                            'Book a viewing and it will appear here.',
                        isDark: isDark,
                        onCancel: (id) =>
                            _confirmCancel(context, aProvider, id),
                        onTap: (appt) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: appt.propertyId,
                            ),
                          ),
                        ),
                      ),
                      _ApptList(
                        appointments: aProvider.past,
                        emptyTitle: 'No past bookings',
                        emptySubtitle:
                            'Completed and cancelled bookings will appear here.',
                        isDark: isDark,
                        onDelete: (id) => aProvider.removeAppointment(id),
                        onTap: (appt) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(
                              propertyId: appt.propertyId,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext ctx, AppointmentsProvider p, String id) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text(
            'Are you sure you want to cancel this booking? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep it')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel booking',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) await p.cancelAppointment(id);
  }
}

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader({
    required this.showBackButton,
    required this.onBack,
    required this.upcomingCount,
    required this.pastCount,
  });

  final bool showBackButton;
  final VoidCallback? onBack;
  final int upcomingCount;
  final int pastCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF101828);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const <Color>[Color(0xFF101625), Color(0xFF111E18)]
                : const <Color>[Colors.white, Color(0xFFEFFDF5)],
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2D3B) : const Color(0xFFDCFCE7),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            if (showBackButton) ...[
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                color: textColor,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF178F5B), Color(0xFF1A3C6E)],
                ),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bookings',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$upcomingCount upcoming · $pastCount past',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.58),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _BookingsTabs extends StatelessWidget {
  const _BookingsTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE4E7EC),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.58),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const <Widget>[
          Tab(text: 'Upcoming'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }
}

// ── Appointment list ─────────────────────────────────────────────────────────

class _ApptList extends StatelessWidget {
  const _ApptList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isDark,
    required this.onTap,
    this.onCancel,
    this.onDelete,
  });
  final List<Appointment> appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isDark;
  final void Function(Appointment) onTap;
  final void Function(String)? onCancel;
  final void Function(String)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _EmptyBookings(title: emptyTitle, subtitle: emptySubtitle);
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
      itemCount: appointments.length,
      itemBuilder: (context, i) {
        final appt = appointments[i];
        return _AppointmentCard(
          appt: appt,
          isDark: isDark,
          onTap: () => onTap(appt),
          onCancel: onCancel != null ? () => onCancel!(appt.id) : null,
          onDelete: onDelete != null ? () => onDelete!(appt.id) : null,
        );
      },
    );
  }
}

// ── Single booking card ──────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appt,
    required this.isDark,
    required this.onTap,
    this.onCancel,
    this.onDelete,
  });
  final Appointment appt;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return const Color(0xFF178F5B);
      case AppointmentStatus.cancelled:
        return const Color(0xFFDC2626);
      case AppointmentStatus.completed:
        return const Color(0xFF1A3C6E);
      case AppointmentStatus.pending:
        return const Color(0xFFA17324);
    }
  }

  String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = const Color(0xFF178F5B);
    final statusColor = _statusColor(appt.status);
    final dateStr = DateFormat('EEE, d MMM yyyy').format(appt.appointmentTime);
    final timeStr = DateFormat('h:mm a').format(appt.appointmentTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B2E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  isDark ? const Color(0xFF1E293B) : const Color(0xFFE4E7EC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.045),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.event_available_rounded,
                      color: primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.propertyTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.45),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                appt.propertyLocation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(appt.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withOpacity(0.12)),
                ),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: dateStr,
                      color: primary,
                    ),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: timeStr,
                      color: primary,
                    ),
                    _InfoChip(
                      icon: Icons.timelapse_rounded,
                      label: appt.duration,
                      color: primary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(label: appt.purpose),
                    if (appt.notes != null && appt.notes!.isNotEmpty)
                      _Tag(
                        label: appt.notes!.length > 30
                            ? '${appt.notes!.substring(0, 30)}…'
                            : appt.notes!,
                      ),
                  ],
                ),
              ),
              if (onCancel != null || onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 15,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      if (onCancel != null)
                        TextButton.icon(
                          onPressed: onCancel,
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 14,
                            color: Colors.red.shade400,
                          ),
                          label: Text(
                            'Cancel booking',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (onCancel == null && onDelete == null)
                const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF1A3C6E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: navy.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_outlined,
                  size: 48, color: navy.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
