// 📁 lib/widgets/legal_page_widgets.dart — shared widgets for all legal/info pages
import 'package:flutter/material.dart';

// ── Back button that overlays the SliverAppBar hero ─────────────────────────
class LegalBackButton extends StatelessWidget {
  const LegalBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ── Frosted card container ───────────────────────────────────────────────────
class LegalCard extends StatelessWidget {
  const LegalCard({
    super.key,
    required this.child,
    required this.isDark,
    this.accentColor,
  });
  final Widget child;
  final bool isDark;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor?.withOpacity(0.18) ??
              (isDark ? const Color(0xFF1E293B) : const Color(0xFFE4E7EC)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section title row with icon ──────────────────────────────────────────────
class LegalSectionTitle extends StatelessWidget {
  const LegalSectionTitle(this.text, {super.key, required this.icon, required this.color});
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 8),
      Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    ]);
  }
}

// ── Flowing body text ────────────────────────────────────────────────────────
class LegalBodyText extends StatelessWidget {
  const LegalBodyText(this.text, {super.key, required this.isDark, this.size = 14.5});
  final String text;
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        height: 1.65,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(isDark ? 0.8 : 0.7),
      ),
    );
  }
}

// ── Bullet list item ─────────────────────────────────────────────────────────
class LegalBulletPoint extends StatelessWidget {
  const LegalBulletPoint({super.key, required this.text, required this.isDark, required this.color});
  final String text;
  final bool isDark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(isDark ? 0.8 : 0.7),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Sub heading (bold label inside a section) ────────────────────────────────
class LegalSubHeading extends StatelessWidget {
  const LegalSubHeading(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
      ),
    );
  }
}

// ── Highlighted callout box ───────────────────────────────────────────────────
class LegalHighlightBox extends StatelessWidget {
  const LegalHighlightBox({super.key, required this.text, required this.color, required this.isDark});
  final String text;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(Icons.check_circle_rounded, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ]),
    );
  }
}

// ── Contact tap row ───────────────────────────────────────────────────────────
class LegalContactRow extends StatelessWidget {
  const LegalContactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 0.3,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onTap != null ? color : Theme.of(context).colorScheme.onSurface,
              )),
        ]),
      ),
      if (onTap != null)
        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
    ]);

    return onTap != null
        ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: row)
        : row;
  }
}
