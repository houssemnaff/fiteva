import 'package:fiteva/screens/cycle/pregnancy/pregnancy_week.dart';
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
import 'package:flutter/material.dart';


/// A floating detail card that reveals week-specific information.
/// Shown inside a DraggableScrollableSheet anchored to the tapped week.
class WeekDetailCard extends StatelessWidget {
  final PregnancyWeekData data;
  final bool isCurrentWeek;
  final VoidCallback? onSelectAsCurrentWeek;

  const WeekDetailCard({
    super.key,
    required this.data,
    required this.isCurrentWeek,
    this.onSelectAsCurrentWeek,
  });

  @override
  Widget build(BuildContext context) {
    final color = data.threadColorOf(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: ThreadTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(data: data, color: color),
          const Divider(color: ThreadTheme.bgCardBorder, height: 1),
          _Body(data: data, color: color),
          if (!isCurrentWeek && onSelectAsCurrentWeek != null)
            _SetCurrentButton(color: color, onTap: onSelectAsCurrentWeek!),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PregnancyWeekData data;
  final Color color;
  const _Header({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trimester pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              'Trimester ${data.trimester}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Spacer(),
          // Week badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Week',
                style: TextStyle(
                  color: color.withOpacity(0.5),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${data.week}',
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                  height: 0.9,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PregnancyWeekData data;
  final Color color;
  const _Body({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baby size
          Row(
            children: [
              _InfoChip(label: 'Size of a', value: data.babySize, color: color),
              const SizedBox(width: 12),
              _InfoChip(label: 'Length', value: '${data.lengthCm.toStringAsFixed(1)} cm', color: color),
            ],
          ),
          const SizedBox(height: 16),

          // Milestone
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.milestone,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            data.description,
            style: const TextStyle(
              color: ThreadTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),

          // Poetic line
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              data.poeticLine,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Heart rate (if available)
          if (data.fetalHeartRateBpm > 0) ...[
            const SizedBox(height: 16),
            _HeartRateRow(bpm: data.fetalHeartRateBpm, color: color),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ThreadTheme.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThreadTheme.bgCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: ThreadTheme.textTertiary,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartRateRow extends StatelessWidget {
  final int bpm;
  final Color color;
  const _HeartRateRow({required this.bpm, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.favorite, color: color.withOpacity(0.7), size: 14),
        const SizedBox(width: 8),
        Text(
          'Fetal heart rate ~$bpm bpm',
          style: TextStyle(
            color: ThreadTheme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _SetCurrentButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _SetCurrentButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.35), width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Set as current week',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}