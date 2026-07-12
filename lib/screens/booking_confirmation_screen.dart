import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/property_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING CONFIRMATION + RECEIPT + QR SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BookingConfirmationScreen extends StatefulWidget {
  final Property property;
  final String guestName;
  final String bookingType; // 'Viewing' | 'Stay'
  final DateTime bookingDate;
  final DateTime? checkOut;
  final String duration;
  final double amountPaid;
  final bool isFullPayment;
  final int guests;

  const BookingConfirmationScreen({
    super.key,
    required this.property,
    required this.guestName,
    required this.bookingType,
    required this.bookingDate,
    this.checkOut,
    required this.duration,
    required this.amountPaid,
    required this.isFullPayment,
    this.guests = 1,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _cardController;
  late Animation<double> _checkAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  late final String _bookingRef;

  @override
  void initState() {
    super.initState();

    // Generate a short booking reference
    final rand = Random();
    _bookingRef =
        'DNB-${widget.bookingType.toUpperCase()[0]}${(rand.nextInt(900000) + 100000)}';

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _checkAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _cardController, curve: Curves.easeOutCubic));

    // Staggered animation
    _checkController.forward().then((_) {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _copyRef() {
    Clipboard.setData(ClipboardData(text: _bookingRef));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking reference copied!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = NumberFormat('#,###');
    final isStay = widget.bookingType == 'Stay';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                // Pop all the way back to the property detail
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            title: const Text('Booking Confirmed'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Animated Checkmark ───────────────────────────────
                  ScaleTransition(
                    scale: _checkAnim,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.green.shade200, width: 2),
                      ),
                      child: Icon(Icons.check_rounded,
                          color: Colors.green.shade600, size: 44),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isStay
                        ? 'Your Stay is Reserved!'
                        : 'Viewing Confirmed!',
                    style: tt.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isStay && !widget.isFullPayment
                        ? 'Your deposit has been received. The remaining balance is due on check-in.'
                        : 'We\'ll see you soon. A confirmation email is on its way.',
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Receipt Card ─────────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _buildReceiptCard(cs, tt, fmt, isStay),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── QR Code ──────────────────────────────────────────
                  SlideTransition(
                    position: _slideAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _buildQrCard(cs, tt),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Actions ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyRef,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy Ref'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home_rounded, size: 18),
                          label: const Text('Go Home'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(
      ColorScheme cs, TextTheme tt, NumberFormat fmt, bool isStay) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isStay ? Icons.hotel_rounded : Icons.calendar_month_rounded,
                    color: cs.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStay ? 'Stay Booking' : 'Viewing Appointment',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.property.title,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CONFIRMED',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dashed separator
          _dashedDivider(cs),

          // Receipt rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                _receiptRow('Booking Ref', _bookingRef, cs, tt,
                    isBold: true, isMonospace: true),
                _receiptRow('Guest', widget.guestName, cs, tt),
                if (isStay) ...[
                  _receiptRow(
                      'Check-in',
                      DateFormat('EEE, MMM d, yyyy').format(widget.bookingDate),
                      cs,
                      tt),
                  _receiptRow(
                      'Check-out',
                      DateFormat('EEE, MMM d, yyyy')
                          .format(widget.checkOut!),
                      cs,
                      tt),
                  _receiptRow(
                      'Duration', widget.duration, cs, tt),
                  _receiptRow(
                      'Guests', '${widget.guests} guest${widget.guests > 1 ? 's' : ''}',
                      cs, tt),
                ] else ...[
                  _receiptRow(
                      'Date',
                      DateFormat('EEE, MMM d, yyyy  HH:mm')
                          .format(widget.bookingDate),
                      cs,
                      tt),
                  _receiptRow(
                      'Duration', widget.duration, cs, tt),
                ],
                _receiptRow(
                    'Payment Type',
                    widget.isFullPayment
                        ? 'Full Payment'
                        : 'Booking Deposit (Non-refundable)',
                    cs,
                    tt),
                _receiptRow('Property', widget.property.location, cs, tt),
              ],
            ),
          ),

          // Dashed separator
          _dashedDivider(cs),

          // Total
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount Paid',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'UGX ${fmt.format(widget.amountPaid)}',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Your Booking QR Code',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Show this at the property entrance',
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),

          // QR Code visual (custom painted)
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: cs.outline.withOpacity(0.2), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(
                painter: _QrPainter(_bookingRef, cs),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ref label
          GestureDetector(
            onTap: _copyRef,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _bookingRef,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.copy_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: List.generate(
          36,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 1,
              color: i.isEven
                  ? cs.outline.withOpacity(0.25)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(
      String label, String value, ColorScheme cs, TextTheme tt,
      {bool isBold = false, bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontFamily: isMonospace ? 'monospace' : null,
                letterSpacing: isMonospace ? 1.2 : 0,
                color: isBold ? cs.primary : cs.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR Painter — deterministic pixel grid based on booking ref
// ─────────────────────────────────────────────────────────────────────────────
class _QrPainter extends CustomPainter {
  final String data;
  final ColorScheme cs;

  _QrPainter(this.data, this.cs);

  @override
  void paint(Canvas canvas, Size size) {
    const modules = 21;
    final cellSize = size.width / modules;
    final paint = Paint()..color = cs.onSurface;
    final bgPaint = Paint()..color = cs.surface;

    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Seed random from hashed data
    var seed = data.codeUnits.fold(0, (prev, c) => prev + c);

    // Draw finder patterns (fixed corners)
    for (final pos in [
      const Offset(0, 0),
      const Offset(14, 0),
      const Offset(0, 14),
    ]) {
      _drawFinder(canvas, paint, pos, cellSize);
    }

    // Draw data pixels
    final rand = Random(seed);
    for (int row = 0; row < modules; row++) {
      for (int col = 0; col < modules; col++) {
        // Skip finder pattern areas
        if ((row < 8 && col < 8) ||
            (row < 8 && col > 12) ||
            (row > 12 && col < 8)) continue;
        if (rand.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                col * cellSize + 0.5,
                row * cellSize + 0.5,
                cellSize - 1,
                cellSize - 1,
              ),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinder(
      Canvas canvas, Paint paint, Offset pos, double cell) {
    final outerPaint = Paint()..color = paint.color;
    final dotPaint = Paint()..color = paint.color;
    final clearPaint = Paint()
      ..color = (paint.color == cs.onSurface) ? cs.surface : cs.surface;

    // Outer 7×7
    canvas.drawRect(
      Rect.fromLTWH(pos.dx * cell, pos.dy * cell, cell * 7, cell * 7),
      outerPaint,
    );
    // Clear inner 5×5
    canvas.drawRect(
      Rect.fromLTWH(
          (pos.dx + 1) * cell, (pos.dy + 1) * cell, cell * 5, cell * 5),
      clearPaint,
    );
    // Inner 3×3
    canvas.drawRect(
      Rect.fromLTWH(
          (pos.dx + 2) * cell, (pos.dy + 2) * cell, cell * 3, cell * 3),
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data;
}
