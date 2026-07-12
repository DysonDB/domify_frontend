import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../providers/appointments_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'booking_confirmation_screen.dart';

enum BookingType { viewing, stay }

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE VIEWING SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BookingScreen extends StatefulWidget {
  final Property property;
  final BookingType bookingType;

  const BookingScreen({
    super.key,
    required this.property,
    this.bookingType = BookingType.viewing,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedDuration = '1 hour';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _durations = [
    '30 minutes',
    '1 hour',
    '1.5 hours',
    '2 hours',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final appointment = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await ApiService.bookAppointment(
        propertyId: widget.property.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        appointmentTime: appointment,
        duration: _selectedDuration,
        purpose: 'Viewing',
        notes: '',
      );

      // Persist locally for the Appointments screen
      // Persist locally for the Appointments screen
      if (mounted) {
        final settings = context.read<SettingsProvider>();
        await context.read<AppointmentsProvider>().addAppointment(
          Appointment(
            id: '${widget.property.id}_${appointment.millisecondsSinceEpoch}',
            propertyId: widget.property.id,
            propertyTitle: widget.property.title,
            propertyLocation: widget.property.location,
            propertyImageUrl: widget.property.images.isNotEmpty
                ? widget.property.images.first
                : '',
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            appointmentTime: appointment,
            duration: _selectedDuration,
            purpose: 'Viewing',
            status: AppointmentStatus.pending,
            bookedAt: DateTime.now(),
          ),
        );

        if (settings.appointmentRemindersEnabled) {
          // 1. Instantly trigger a local notification to confirm booking
          await NotificationService.showNotification(
            id: appointment.millisecondsSinceEpoch ~/ 100000 % 10000,
            title: 'Viewing Scheduled! 🏠',
            body: 'You have booked a viewing at ${widget.property.title} for ${DateFormat('EEE, d MMM yyyy h:mm a').format(appointment)}.',
          );

          // 2. Schedule a reminder 1 hour before the appointment
          final reminderDate = appointment.subtract(const Duration(hours: 1));
          if (reminderDate.isAfter(DateTime.now())) {
            await NotificationService.scheduleNotification(
              id: (appointment.millisecondsSinceEpoch ~/ 100000 % 10000) + 1,
              title: 'Viewing Coming Up! ⏰',
              body: 'Reminder: Your viewing at ${widget.property.title} is scheduled in 1 hour.',
              scheduledDate: reminderDate,
            );
          }
        }
      }

      if (!mounted) return;

      // Navigate to confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            property: widget.property,
            guestName: _nameController.text.trim(),
            bookingType: 'Viewing',
            bookingDate: appointment,
            duration: _selectedDuration,
            amountPaid: widget.property.appointmentFee,
            isFullPayment: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.property.images.isNotEmpty)
                    Image.network(
                      widget.property.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.primaryContainer,
                        child: Icon(Icons.home, size: 60, color: cs.primary),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SCHEDULE VIEWING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.property.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.property.location,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
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
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Form Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appointment fee pill
                      _feePill(
                        'Viewing Fee',
                        'UGX ${NumberFormat('#,###').format(widget.property.appointmentFee)}',
                        Icons.receipt_long_outlined,
                        cs,
                      ),
                      const SizedBox(height: 32),

                      // ── Personal Info ──────────────────────────────
                      _sectionLabel('Your Details', cs, tt),
                      const SizedBox(height: 16),
                      _premiumField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        context: context,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _premiumField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        context: context,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _premiumField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.mail_outline_rounded,
                        context: context,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── Appointment Details ────────────────────────
                      _sectionLabel('Appointment Details', cs, tt),
                      const SizedBox(height: 16),

                      // Date Picker Row
                      _pickerTile(
                        icon: Icons.calendar_month_outlined,
                        label: 'Date',
                        value: DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                        onTap: _pickDate,
                        cs: cs,
                        tt: tt,
                      ),
                      const SizedBox(height: 12),

                      // Time Picker Row
                      _pickerTile(
                        icon: Icons.schedule_outlined,
                        label: 'Time',
                        value: _selectedTime.format(context),
                        onTap: _pickTime,
                        cs: cs,
                        tt: tt,
                      ),
                      const SizedBox(height: 12),

                      // Duration
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: cs.outline.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDuration,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.timer_outlined,
                                  color: cs.primary, size: 20),
                              labelText: 'Duration',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            items: _durations
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDuration = v!),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Submit ─────────────────────────────────────
                      _submitButton(
                        label: 'Confirm Viewing',
                        onPressed: _isSubmitting ? null : _submit,
                        isLoading: _isSubmitting,
                        cs: cs,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _feePill(
    String label, String amount, IconData icon, ColorScheme cs) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: cs.primaryContainer.withOpacity(0.6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(amount,
                style: TextStyle(
                    color: cs.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _sectionLabel(String label, ColorScheme cs, TextTheme tt) {
  return Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    ],
  );
}

Widget _premiumField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required BuildContext context,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  final cs = Theme.of(context).colorScheme;
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    style: Theme.of(context).textTheme.bodyMedium,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cs.primary, size: 20),
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

Widget _pickerTile({
  required IconData icon,
  required String label,
  required String value,
  required VoidCallback onTap,
  required ColorScheme cs,
  required TextTheme tt,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          Icon(Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant, size: 20),
        ],
      ),
    ),
  );
}

Widget _submitButton({
  required String label,
  required VoidCallback? onPressed,
  required bool isLoading,
  required ColorScheme cs,
}) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: cs.onPrimary,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
    ),
  );
}