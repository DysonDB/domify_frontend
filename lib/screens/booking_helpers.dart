import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BOOKING UI HELPERS
// Used by BookingScreen and StayBookingScreen
// ─────────────────────────────────────────────────────────────────────────────

Widget buildFeePill(
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

Widget buildSectionLabel(String label, ColorScheme cs, TextTheme tt) {
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

Widget buildPremiumField({
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

Widget buildPickerTile({
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
                  style:
                      tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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

Widget buildSubmitButton({
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
