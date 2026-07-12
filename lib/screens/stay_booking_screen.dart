import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property_model.dart';
import '../services/api_service.dart';
import 'booking_helpers.dart';
import 'booking_confirmation_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STAY BOOKING SCREEN  
// Full stay payment OR non-refundable booking fee
// ─────────────────────────────────────────────────────────────────────────────
class StayBookingScreen extends StatefulWidget {
  final Property property;

  const StayBookingScreen({super.key, required this.property});

  @override
  State<StayBookingScreen> createState() => _StayBookingScreenState();
}

class _StayBookingScreenState extends State<StayBookingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 3));
  int _guests = 1;
  bool _isSubmitting = false;

  // Payment choice: 'full' or 'deposit'
  String _paymentChoice = 'deposit';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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

  int get _nights => _checkOut.difference(_checkIn).inDays.clamp(1, 365);

  double get _pricePerNight => widget.property.price;

  double get _totalAmount => _pricePerNight * _nights;

  /// Non-refundable booking deposit (20% of total or min 50,000)
  double get _depositAmount {
    final deposit = _totalAmount * 0.20;
    return deposit < 50000 ? 50000 : deposit;
  }

  double get _amountDue =>
      _paymentChoice == 'full' ? _totalAmount : _depositAmount;

  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut.isBefore(_checkIn.add(const Duration(days: 1)))) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _checkOut = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ApiService.bookAppointment(
        propertyId: widget.property.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        appointmentTime: _checkIn,
        duration: '$_nights nights',
        purpose: 'Stay',
        notes: 'Guests: $_guests | Payment: $_paymentChoice',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            property: widget.property,
            guestName: _nameController.text.trim(),
            bookingType: 'Stay',
            bookingDate: _checkIn,
            checkOut: _checkOut,
            duration: '$_nights night${_nights > 1 ? 's' : ''}',
            amountPaid: _amountDue,
            isFullPayment: _paymentChoice == 'full',
            guests: _guests,
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
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
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
                        color: cs.secondaryContainer,
                        child: Icon(Icons.hotel, size: 60, color: cs.secondary),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.75),
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
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BOOK YOUR STAY',
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
                                    color: Colors.white70, fontSize: 13),
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
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────
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
                      // Rate card
                      _rateCard(fmt, cs, tt),
                      const SizedBox(height: 28),

                      // ── Stay Dates ──────────────────────────────────
                      buildSectionLabel('Your Stay', cs, tt),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: buildPickerTile(
                              icon: Icons.flight_land_outlined,
                              label: 'Check-in',
                              value: DateFormat('MMM d, yyyy').format(_checkIn),
                              onTap: _pickCheckIn,
                              cs: cs,
                              tt: tt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildPickerTile(
                              icon: Icons.flight_takeoff_outlined,
                              label: 'Check-out',
                              value:
                                  DateFormat('MMM d, yyyy').format(_checkOut),
                              onTap: _pickCheckOut,
                              cs: cs,
                              tt: tt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nights badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.nightlight_round,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              '$_nights night${_nights > 1 ? 's' : ''} · UGX ${fmt.format(_pricePerNight)}/night',
                              style: tt.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Guests
                      _guestSelector(cs, tt),
                      const SizedBox(height: 32),

                      // ── Guest Details ───────────────────────────────
                      buildSectionLabel('Guest Details', cs, tt),
                      const SizedBox(height: 16),
                      buildPremiumField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        context: context,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      buildPremiumField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        context: context,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 14),
                      buildPremiumField(
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

                      // ── Payment Options ─────────────────────────────
                      buildSectionLabel('Payment Option', cs, tt),
                      const SizedBox(height: 16),
                      _paymentOptions(fmt, cs, tt),
                      const SizedBox(height: 32),

                      // ── Order Summary ───────────────────────────────
                      _orderSummary(fmt, cs, tt),
                      const SizedBox(height: 32),

                      // ── Submit Button ───────────────────────────────
                      buildSubmitButton(
                        label: _paymentChoice == 'full'
                            ? 'Pay UGX ${fmt.format(_totalAmount)} · Confirm Stay'
                            : 'Pay UGX ${fmt.format(_depositAmount)} · Reserve Now',
                        onPressed: _isSubmitting ? null : _submit,
                        isLoading: _isSubmitting,
                        cs: cs,
                      ),

                      if (_paymentChoice == 'deposit') ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                'Booking fee is non-refundable',
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
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

  Widget _rateCard(NumberFormat fmt, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withOpacity(0.7),
            cs.secondaryContainer.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Per Night',
                    style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('UGX ${fmt.format(_pricePerNight)}',
                    style: tt.headlineSmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('$_nights',
                    style: tt.titleLarge?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold)),
                Text(_nights == 1 ? 'night' : 'nights',
                    style: tt.bodySmall?.copyWith(color: cs.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestSelector(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded,
              color: cs.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guests',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
                Text('$_guests guest${_guests > 1 ? 's' : ''}',
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _counterBtn(Icons.remove_rounded, () {
            if (_guests > 1) setState(() => _guests--);
          }, cs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$_guests',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          _counterBtn(Icons.add_rounded, () {
            if (_guests < 20) setState(() => _guests++);
          }, cs),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, ColorScheme cs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 16, color: cs.primary),
      ),
    );
  }

  Widget _paymentOptions(NumberFormat fmt, ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        _paymentCard(
          title: 'Reserve with Deposit',
          subtitle: 'Non-refundable booking fee (20%)',
          amount: 'UGX ${fmt.format(_depositAmount)}',
          badge: 'NON-REFUNDABLE',
          badgeColor: Colors.orange.shade700,
          value: 'deposit',
          selected: _paymentChoice == 'deposit',
          icon: Icons.lock_outline_rounded,
          cs: cs,
          tt: tt,
        ),
        const SizedBox(height: 12),
        _paymentCard(
          title: 'Pay in Full',
          subtitle: 'Complete payment for $_nights night${_nights > 1 ? 's' : ''}',
          amount: 'UGX ${fmt.format(_totalAmount)}',
          badge: 'FULL PAYMENT',
          badgeColor: Colors.green.shade700,
          value: 'full',
          selected: _paymentChoice == 'full',
          icon: Icons.verified_outlined,
          cs: cs,
          tt: tt,
        ),
      ],
    );
  }

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required String amount,
    required String badge,
    required Color badgeColor,
    required String value,
    required bool selected,
    required IconData icon,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _paymentChoice = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withOpacity(0.06)
              : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withOpacity(0.25),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary.withOpacity(0.12)
                    : cs.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20,
                  color: selected ? cs.primary : cs.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: selected ? cs.primary : null)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                color: badgeColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(amount,
                      style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selected ? cs.primary : null)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentChoice,
              onChanged: (v) => setState(() => _paymentChoice = v!),
              activeColor: cs.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderSummary(NumberFormat fmt, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Breakdown',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _summaryRow(
              'UGX ${fmt.format(_pricePerNight)} × $_nights night${_nights > 1 ? 's' : ''}',
              'UGX ${fmt.format(_totalAmount)}',
              cs,
              tt),
          if (_paymentChoice == 'deposit') ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            _summaryRow(
                'Booking deposit (20%)',
                '−UGX ${fmt.format(_totalAmount - _depositAmount)}',
                cs,
                tt,
                isDeduction: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due now',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('UGX ${fmt.format(_amountDue)}',
                  style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ColorScheme cs, TextTheme tt,
      {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(value,
              style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDeduction ? Colors.orange.shade700 : null)),
        ],
      ),
    );
  }
}
