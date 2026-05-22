import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class InsightSection extends StatefulWidget {
  final String insight;
  final Color phaseColor;

  const InsightSection({
    super.key,
    required this.insight,
    required this.phaseColor,
  });

  @override
  State<InsightSection> createState() => _InsightSectionState();
}

class _InsightSectionState extends State<InsightSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    _controller.forward();
  }

  @override
  void didUpdateWidget(InsightSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insight != widget.insight) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Label compact
          Text(
  'INTELLIGENCE',
  style: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: FitEvaColors.textMuted.withOpacity(0.5),
    fontFamily: '.SF Pro Display',
  ),
),
            const SizedBox(height: 2),
            Text(
              'Analyse FitEva',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FitEvaColors.text,  fontFamily: '.SF Pro Display',
              ),
            ),
            const SizedBox(height: 8),
            // Insight card compacte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FitEvaColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.phaseColor.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: widget.phaseColor,
                    size: 14,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.insight.isEmpty
                        ? 'Analyse en cours...'
                        : widget.insight,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: FitEvaColors.text,
                      fontStyle: FontStyle.italic,
                        fontFamily: '.SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.phaseColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'CONSEIL DU JOUR',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: widget.phaseColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}