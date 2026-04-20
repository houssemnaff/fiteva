import 'package:flutter/material.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label compact
          Text(
  'INTELLIGENCE',
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: Colors.white.withOpacity(0.45),
    fontFamily: '.SF Pro Display',
  ),
),
            const SizedBox(height: 4),
            Text(
              'Analyse FitEva',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.90),  fontFamily: '.SF Pro Display',
              ),
            ),
            const SizedBox(height: 12),
            // Insight card compacte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.phaseColor.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: widget.phaseColor,
                    size: 16,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.insight.isEmpty
                        ? 'Analyse en cours...'
                        : widget.insight,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      fontStyle: FontStyle.italic,
                        fontFamily: '.SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.phaseColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'CONSEIL DU JOUR',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: widget.phaseColor,
                        letterSpacing: 0.8,
                      ),
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