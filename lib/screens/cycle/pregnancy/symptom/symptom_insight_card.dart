// ─────────────────────────────────────────────
// symptom_insight_card.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'symptom_insight_engine.dart';

class SymptomInsightCard extends StatefulWidget {
  const SymptomInsightCard({
    super.key,
    required this.insight,
    required this.accentColor,
  });

  final SymptomInsight insight;
  final Color accentColor;

  @override
  State<SymptomInsightCard> createState() => _SymptomInsightCardState();
}

class _SymptomInsightCardState extends State<SymptomInsightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final Color accent = widget.accentColor;
    final SymptomInsight insight = widget.insight;

    final (Color tagBg, Color tagText, IconData tagIcon) = switch (
      insight.severity
    ) {
      InsightSeverity.reassuring => (
          const Color(0xFFEAF4EC),
          const Color(0xFF4A8A5A),
          Icons.favorite_rounded,
        ),
      InsightSeverity.informational => (
          const Color(0xFFEFF3F8),
          const Color(0xFF4A6A8A),
          Icons.info_outline_rounded,
        ),
      InsightSeverity.watchful => (
          const Color(0xFFF8F3E8),
          const Color(0xFF8A6A2A),
          Icons.visibility_outlined,
        ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top gradient band
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.4),
                    accent,
                    accent.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 15,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'AI INSIGHT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: accent,
                        ),
                      ),
                      const Spacer(),
                      // Severity badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tagIcon, size: 11, color: tagText),
                            const SizedBox(width: 4),
                            Text(
                              insight.tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: tagText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Insight text
                  Text(
                    insight.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.65,
                      color: Color(0xFF4A4A5A),
                      letterSpacing: 0.1,
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