// ============================================================
//  symptom_insight_card.dart
//  AI Insight Preview Card + Daily Summary Mini Card
// ============================================================

import 'package:flutter/material.dart';
import 'symptom_models.dart';
import 'symptom_suggestion_engine.dart';

// ─── Daily Summary Mini Card ─────────────────────────────────

class SymptomSummaryCard extends StatelessWidget {
  final SymptomSummaryData data;
  final Color phaseColor;

  const SymptomSummaryCard({
    super.key,
    required this.data,
    required this.phaseColor,
  });

  String get _trendLabel {
    switch (data.trend) {
      case SymptomTrend.increasing:
        return 'Increasing ↑';
      case SymptomTrend.decreasing:
        return 'Easing ↓';
      case SymptomTrend.stable:
        return 'Stable →';
      case SymptomTrend.newToday:
        return 'First log today';
    }
  }

  Color get _trendColor {
    switch (data.trend) {
      case SymptomTrend.increasing:
        return const Color(0xFFFF6B8A);
      case SymptomTrend.decreasing:
        return const Color(0xFF6BCFB0);
      case SymptomTrend.stable:
        return Colors.black.withOpacity(0.5);
      case SymptomTrend.newToday:
        return phaseColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.count == 0) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Count badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: phaseColor.withOpacity(0.15),
              border: Border.all(color: phaseColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${data.count}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: phaseColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.count} symptom${data.count == 1 ? '' : 's'} logged today',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                if (data.mostCommon != null)
                  Text(
                    'Most intense: ${data.mostCommon}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
              ],
            ),
          ),
          // Trend pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _trendLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _trendColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI Insight Preview Card ─────────────────────────────────

class SymptomInsightCard extends StatefulWidget {
  final String phase;
  final String insight;
  final Color phaseColor;

  const SymptomInsightCard({
    super.key,
    required this.phase,
    required this.insight,
    required this.phaseColor,
  });

  @override
  State<SymptomInsightCard> createState() => _SymptomInsightCardState();
}

class _SymptomInsightCardState extends State<SymptomInsightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.phaseColor.withOpacity(0.12),
                widget.phaseColor.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.phaseColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.phaseColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: widget.phaseColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI Insight',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.phaseColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.phase,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.phaseColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.phaseColor.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              // Collapsed preview
              const SizedBox(height: 10),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 260),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  // Truncated teaser
                  widget.insight.length > 80
                      ? '${widget.insight.substring(0, 80)}…'
                      : widget.insight,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
                secondChild: Text(
                  widget.insight,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.black.withOpacity(0.72),
                  ),
                ),
              ),
              if (!_expanded) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _expanded = true),
                  child: Text(
                    'Read more',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.phaseColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}