import 'package:fiteva/screens/cycle/pregnancy/pregnancy_week.dart';
import 'package:flutter/material.dart';


class PregnancySymptomsCard extends StatefulWidget {
  final PregnancyWeek week;
  final Set<int> selectedSymptoms;
  final ValueChanged<int> onToggle;

  const PregnancySymptomsCard({
    super.key,
    required this.week,
    required this.selectedSymptoms,
    required this.onToggle,
  });

  @override
  State<PregnancySymptomsCard> createState() => _PregnancySymptomsCardState();
}

class _PregnancySymptomsCardState extends State<PregnancySymptomsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  size: 16, color: widget.week.phaseColor),
              const SizedBox(width: 6),
              const Text(
                'Symptômes de la semaine',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D2033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionne ce que tu ressens',
            style: TextStyle(
              fontSize: 11,
              color: widget.week.phaseColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              widget.week.symptoms.length,
              (i) {
                final isSelected = widget.selectedSymptoms.contains(i);
                return GestureDetector(
                  onTap: () => widget.onToggle(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.week.phaseColor
                          : widget.week.phaseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? widget.week.phaseColor
                            : widget.week.phaseColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.week.symptoms[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : widget.week.phaseColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.selectedSymptoms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.week.phaseColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: widget.week.phaseColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.selectedSymptoms.length == 1
                          ? '1 symptôme noté — pense à en parler à ta sage-femme.'
                          : '${widget.selectedSymptoms.length} symptômes notés — note-les pour ta prochaine consultation.',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.week.phaseColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}