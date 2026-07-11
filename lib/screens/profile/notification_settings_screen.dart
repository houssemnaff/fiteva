// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../services/local_reminder_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final prefs = ref.watch(notifPrefsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.arrowLeft, size: 16, color: cs.onSurface),
          ),
        ),
        title: Text('Notifications', style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Personnalise tes rappels quotidiens',
            style: GoogleFonts.inter(
              fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 24),

          // ── Hydratation ────────────────────────────────────────
          _SectionHeader(
            icon: LucideIcons.droplets,
            label: 'Hydratation',
            color: const Color(0xFF0EA5E9),
            enabled: prefs.waterEnabled,
            onToggle: (v) {
              ref.read(notifPrefsProvider.notifier).setWaterEnabled(v);
              _reschedule(ref);
            },
          ),
          if (prefs.waterEnabled) ...[
            _TimeRow(label: 'Rappel 1', minutes: prefs.waterTime1, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setWaterTime1(v);
              _reschedule(ref);
            }),
            _TimeRow(label: 'Rappel 2', minutes: prefs.waterTime2, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setWaterTime2(v);
              _reschedule(ref);
            }),
            _TimeRow(label: 'Rappel 3', minutes: prefs.waterTime3, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setWaterTime3(v);
              _reschedule(ref);
            }),
          ],
          const SizedBox(height: 20),

          // ── Repas ──────────────────────────────────────────────
          _SectionHeader(
            icon: LucideIcons.utensils,
            label: 'Repas',
            color: const Color(0xFFF59E0B),
            enabled: prefs.mealsEnabled,
            onToggle: (v) {
              ref.read(notifPrefsProvider.notifier).setMealsEnabled(v);
              _reschedule(ref);
            },
          ),
          if (prefs.mealsEnabled) ...[
            _TimeRow(label: 'Petit-déjeuner', minutes: prefs.breakfastTime, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setBreakfastTime(v);
              _reschedule(ref);
            }),
            _TimeRow(label: 'Déjeuner', minutes: prefs.lunchTime, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setLunchTime(v);
              _reschedule(ref);
            }),
            _TimeRow(label: 'Dîner', minutes: prefs.dinnerTime, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setDinnerTime(v);
              _reschedule(ref);
            }),
          ],
          const SizedBox(height: 20),

          // ── Séance ─────────────────────────────────────────────
          _SectionHeader(
            icon: LucideIcons.dumbbell,
            label: 'Séance d\'entraînement',
            color: const Color(0xFF22C55E),
            enabled: prefs.workoutEnabled,
            onToggle: (v) {
              ref.read(notifPrefsProvider.notifier).setWorkoutEnabled(v);
              _reschedule(ref);
            },
          ),
          if (prefs.workoutEnabled)
            _TimeRow(label: 'Rappel séance', minutes: prefs.workoutTime, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setWorkoutTime(v);
              _reschedule(ref);
            }),
          const SizedBox(height: 20),

          // ── Cycle ──────────────────────────────────────────────
          _SectionHeader(
            icon: LucideIcons.heart,
            label: 'Rappels cycle',
            color: const Color(0xFFEC4899),
            enabled: prefs.cycleEnabled,
            onToggle: (v) {
              ref.read(notifPrefsProvider.notifier).setCycleEnabled(v);
              _reschedule(ref);
            },
          ),
          if (prefs.cycleEnabled) ...[
            _TimeRow(label: 'Rappel phase', minutes: prefs.cycleTime, onPick: (v) {
              ref.read(notifPrefsProvider.notifier).setCycleTime(v);
              _reschedule(ref);
            }),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                'Tu recevras un rappel adapté à ta phase du cycle '
                '(conseils d\'entraînement, récupération, nutrition).',
                style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ── Inactivité ─────────────────────────────────────────
          _SectionHeader(
            icon: LucideIcons.alarmClock,
            label: 'Rappels d\'inactivité',
            color: const Color(0xFFEF4444),
            enabled: prefs.inactivityEnabled,
            onToggle: (v) {
              ref.read(notifPrefsProvider.notifier).setInactivityEnabled(v);
              _reschedule(ref);
            },
          ),
          if (prefs.inactivityEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                'Si tu ne t\'entraînes pas pendant 3 jours, '
                'on t\'enverra un petit rappel de motivation.',
                style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ),
        ],
      ),
    );
  }

  void _reschedule(WidgetRef ref) {
    final prefs = ref.read(notifPrefsProvider);
    LocalReminderService.scheduleFromPrefs(prefs);
  }
}

// ═════════════════════════════════════════════════════════════════
// SECTION HEADER — toggle + titre
// ═════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: enabled
            ? color.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? color.withValues(alpha: 0.25)
              : cs.outline),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.15 : 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18,
            color: enabled ? color : cs.onSurface.withValues(alpha: 0.3)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: enabled
              ? cs.onSurface
              : cs.onSurface.withValues(alpha: 0.4)))),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(!enabled);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42, height: 24,
            decoration: BoxDecoration(
              color: enabled ? color : cs.outline,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// TIME ROW — horaire personnalisable
// ═════════════════════════════════════════════════════════════════

class _TimeRow extends StatelessWidget {
  final String label;
  final int minutes; // total minutes since midnight
  final ValueChanged<int> onPick;

  const _TimeRow({
    required this.label,
    required this.minutes,
    required this.onPick,
  });

  String get _formatted {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
          );
          if (picked != null) {
            onPick(picked.hour * 60 + picked.minute);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline),
          ),
          child: Row(children: [
            Icon(LucideIcons.clock, size: 14,
              color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: GoogleFonts.inter(
              fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7)))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_formatted, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: cs.primary)),
            ),
          ]),
        ),
      ),
    );
  }
}
