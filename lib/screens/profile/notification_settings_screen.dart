// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/notification_preferences_provider.dart';
import '../../services/local_reminder_service.dart';

class _T {
  _T._();
  static const main   = Color(0xFF1C4D30);
  static const sage   = Color(0xFF7ABB98);
  static const bgL    = Color(0xFFF7F8F6);
  static const cardL  = Colors.white;
  static const borderL = Color(0xFFE8ECE9);
  static const t1L    = Color(0xFF1A1A1A);
  static const t2L    = Color(0xFF6B7B73);
  static const bgD    = Color(0xFF0F1A14);
  static const cardD  = Color(0xFF162119);
  static const borderD = Color(0xFF253D2E);
  static const t1D    = Color(0xFFF0F0EE);
  static const t2D    = Color(0xFF8A9B92);
  static Color bg(bool d)     => d ? bgD : bgL;
  static Color card(bool d)   => d ? cardD : cardL;
  static Color border(bool d) => d ? borderD : borderL;
  static Color t1(bool d)     => d ? t1D : t1L;
  static Color t2(bool d)     => d ? t2D : t2L;
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d     = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(notifPrefsProvider);

    final bg    = _T.bg(d);
    final ink   = _T.t1(d);
    final muted = _T.t2(d);
    final surf  = _T.card(d);
    final bdr   = _T.border(d);

    Widget toggle(bool on, ValueChanged<bool> onChanged) => GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onChanged(!on); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 26,
        decoration: BoxDecoration(
          color: on ? _T.main : (d ? const Color(0xFF2A3A30) : const Color(0xFFD4DDD8)),
          borderRadius: BorderRadius.circular(13)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(width: 22, height: 22,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Top bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: surf, shape: BoxShape.circle,
                        border: Border.all(color: bdr, width: 0.5)),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: ink)),
                  ),
                  const Spacer(),
                  Text('Notifications',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                      color: ink, letterSpacing: -0.3)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ]),
              ),
            ),
          ),

          // ── Subtitle ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _T.sage.withValues(alpha: d ? 0.08 : 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _T.sage.withValues(alpha: 0.15))),
                child: Row(children: [
                  Icon(LucideIcons.bellRing, size: 18, color: _T.sage),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'Personnalise tes rappels quotidiens pour rester sur la bonne voie.',
                    style: GoogleFonts.inter(fontSize: 13, color: muted, height: 1.4))),
                ]),
              ),
            ),
          ),

          // ── Hydratation ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _NotifSection(
                icon: LucideIcons.droplets,
                label: 'Hydratation',
                accentColor: const Color(0xFF4AADE8),
                enabled: prefs.waterEnabled,
                d: d,
                onToggle: toggle,
                onChanged: (v) {
                  ref.read(notifPrefsProvider.notifier).setWaterEnabled(v);
                  _reschedule(ref);
                },
                children: prefs.waterEnabled ? [
                  _TimeSlot(label: 'Rappel 1', minutes: prefs.waterTime1, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setWaterTime1(v); _reschedule(ref); }),
                  _TimeSlot(label: 'Rappel 2', minutes: prefs.waterTime2, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setWaterTime2(v); _reschedule(ref); }),
                  _TimeSlot(label: 'Rappel 3', minutes: prefs.waterTime3, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setWaterTime3(v); _reschedule(ref); }),
                ] : [],
              ),
            ),
          ),

          // ── Repas ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _NotifSection(
                icon: LucideIcons.utensils,
                label: 'Repas',
                accentColor: const Color(0xFFE8A44A),
                enabled: prefs.mealsEnabled,
                d: d,
                onToggle: toggle,
                onChanged: (v) {
                  ref.read(notifPrefsProvider.notifier).setMealsEnabled(v);
                  _reschedule(ref);
                },
                children: prefs.mealsEnabled ? [
                  _TimeSlot(label: 'Petit-déjeuner', minutes: prefs.breakfastTime, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setBreakfastTime(v); _reschedule(ref); }),
                  _TimeSlot(label: 'Déjeuner', minutes: prefs.lunchTime, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setLunchTime(v); _reschedule(ref); }),
                  _TimeSlot(label: 'Dîner', minutes: prefs.dinnerTime, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setDinnerTime(v); _reschedule(ref); }),
                ] : [],
              ),
            ),
          ),

          // ── Séance ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _NotifSection(
                icon: LucideIcons.dumbbell,
                label: 'Séance d\'entraînement',
                accentColor: _T.main,
                enabled: prefs.workoutEnabled,
                d: d,
                onToggle: toggle,
                onChanged: (v) {
                  ref.read(notifPrefsProvider.notifier).setWorkoutEnabled(v);
                  _reschedule(ref);
                },
                children: prefs.workoutEnabled ? [
                  _TimeSlot(label: 'Rappel séance', minutes: prefs.workoutTime, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setWorkoutTime(v); _reschedule(ref); }),
                ] : [],
              ),
            ),
          ),

          // ── Cycle ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _NotifSection(
                icon: LucideIcons.heart,
                label: 'Rappels cycle',
                accentColor: const Color(0xFFD46B8C),
                enabled: prefs.cycleEnabled,
                d: d,
                onToggle: toggle,
                onChanged: (v) {
                  ref.read(notifPrefsProvider.notifier).setCycleEnabled(v);
                  _reschedule(ref);
                },
                children: prefs.cycleEnabled ? [
                  _TimeSlot(label: 'Rappel phase', minutes: prefs.cycleTime, d: d,
                    onPick: (v) { ref.read(notifPrefsProvider.notifier).setCycleTime(v); _reschedule(ref); }),
                ] : [],
                hint: prefs.cycleEnabled
                  ? 'Tu recevras un rappel adapté à ta phase du cycle (conseils d\'entraînement, récupération, nutrition).'
                  : null,
              ),
            ),
          ),

          // ── Inactivité ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _NotifSection(
                icon: LucideIcons.alarmClock,
                label: 'Rappels d\'inactivité',
                accentColor: const Color(0xFFD45B5B),
                enabled: prefs.inactivityEnabled,
                d: d,
                onToggle: toggle,
                onChanged: (v) {
                  ref.read(notifPrefsProvider.notifier).setInactivityEnabled(v);
                  _reschedule(ref);
                },
                children: const [],
                hint: prefs.inactivityEnabled
                  ? 'Si tu ne t\'entraînes pas pendant 3 jours, on t\'enverra un petit rappel de motivation.'
                  : null,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  void _reschedule(WidgetRef ref) {
    final prefs = ref.read(notifPrefsProvider);
    LocalReminderService.scheduleFromPrefs(prefs);
  }
}

class _NotifSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool enabled;
  final bool d;
  final Widget Function(bool, ValueChanged<bool>) onToggle;
  final ValueChanged<bool> onChanged;
  final List<Widget> children;
  final String? hint;

  const _NotifSection({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.enabled,
    required this.d,
    required this.onToggle,
    required this.onChanged,
    this.children = const [],
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final surf = _T.card(d);
    final bdr  = _T.border(d);
    final ink  = _T.t1(d);
    final muted = _T.t2(d);

    return Container(
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled ? accentColor.withValues(alpha: 0.2) : bdr, width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
          blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: enabled ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 17,
                color: enabled ? accentColor : muted.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                color: enabled ? ink : muted))),
            onToggle(enabled, onChanged),
          ]),
        ),
        if (children.isNotEmpty) ...[
          Divider(height: 0.5, thickness: 0.5, color: bdr, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(children: children),
          ),
        ],
        if (hint != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(hint!,
              style: GoogleFonts.inter(fontSize: 11, color: muted, height: 1.5)),
          ),
      ]),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String label;
  final int minutes;
  final bool d;
  final ValueChanged<int> onPick;

  const _TimeSlot({
    required this.label,
    required this.minutes,
    required this.d,
    required this.onPick,
  });

  String get _formatted {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bdr  = _T.border(d);
    final ink  = _T.t1(d);
    final muted = _T.t2(d);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
          );
          if (picked != null) onPick(picked.hour * 60 + picked.minute);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: d ? const Color(0xFF1A2A20) : const Color(0xFFF5F7F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bdr, width: 0.5)),
          child: Row(children: [
            Icon(LucideIcons.clock, size: 14, color: muted),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
              style: GoogleFonts.inter(fontSize: 13, color: ink))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _T.main.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8)),
              child: Text(_formatted,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                  color: _T.main)),
            ),
          ]),
        ),
      ),
    );
  }
}
