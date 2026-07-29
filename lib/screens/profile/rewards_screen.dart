import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../home/referral_card.dart';

class _P {
  _P._();
  static const forest  = Color(0xFF1B5E3B);
  static const sage    = Color(0xFF7ABB98);
  static const gold    = Color(0xFFB8860B);

  static Color bg(bool d)     => d ? const Color(0xFF0F1A14) : Colors.white;
  static Color surf(bool d)   => d ? const Color(0xFF162119) : Colors.white;
  static Color bdr(bool d)    => d ? const Color(0xFF253D2E) : const Color(0xFFE8ECE9);
  static Color ink(bool d)    => d ? const Color(0xFFF0F0EE) : const Color(0xFF1A1A1A);
  static Color muted(bool d)  => d ? const Color(0xFF8A9B92) : const Color(0xFF6B7B73);
  static Color accent(bool d) => d ? sage : forest;
}

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d     = ref.watch(themeModeProvider) == ThemeMode.dark;
    final l10n  = ref.watch(l10nProvider);
    final bg    = _P.bg(d);
    final ink   = _P.ink(d);
    final muted = _P.muted(d);
    final accent = _P.accent(d);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Top bar ─────────────────────────────────────────────────────
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
                        color: _P.surf(d), shape: BoxShape.circle,
                        border: Border.all(color: _P.bdr(d), width: 0.5)),
                      child: Icon(LucideIcons.arrowLeft, size: 18, color: ink)),
                  ),
                  const Spacer(),
                  Text(
                    l10n.isFrench ? 'Récompenses' : 'Rewards',
                    style: GoogleFonts.outfit(fontSize: 18,
                      fontWeight: FontWeight.w700, color: ink, letterSpacing: -0.3)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ]),
              ),
            ),
          ),

          // ── Hero banner ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: d
                      ? [const Color(0xFF1A3322), const Color(0xFF0F1A14)]
                      : [const Color(0xFFF0F7F2), const Color(0xFFFFFFFF)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                  boxShadow: [BoxShadow(
                    color: accent.withValues(alpha: d ? 0.12 : 0.08),
                    blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: _P.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                    child: Icon(LucideIcons.gift, size: 26,
                      color: _P.gold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.isFrench
                        ? 'Invite tes amies,\ngagne des récompenses'
                        : 'Invite friends,\nearn rewards',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 22,
                      fontWeight: FontWeight.w800, color: ink,
                      height: 1.2, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.isFrench
                        ? 'Partage ton code, et débloque des récompenses exclusives à chaque amie qui rejoint FitEva.'
                        : 'Share your code and unlock exclusive rewards for every friend who joins FitEva.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13.5,
                      color: muted, height: 1.5),
                  ),
                ]),
              ),
            ),
          ),

          // ── Referral card (code + scratch) ──────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: ReferralCard(),
            ),
          ),

          // ── How it works ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _P.surf(d),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _P.bdr(d), width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8)),
                      child: Icon(LucideIcons.helpCircle, size: 14, color: accent)),
                    const SizedBox(width: 10),
                    Text(
                      l10n.isFrench ? 'Comment ça marche' : 'How it works',
                      style: GoogleFonts.outfit(fontSize: 15,
                        fontWeight: FontWeight.w700, color: ink)),
                  ]),
                  const SizedBox(height: 18),
                  _HowStep(
                    number: '1',
                    title: l10n.isFrench ? 'Partage ton code' : 'Share your code',
                    subtitle: l10n.isFrench
                        ? 'Envoie ton code unique à tes amies'
                        : 'Send your unique code to friends',
                    color: accent, d: d,
                  ),
                  const SizedBox(height: 14),
                  _HowStep(
                    number: '2',
                    title: l10n.isFrench ? 'Elles s\'inscrivent' : 'They sign up',
                    subtitle: l10n.isFrench
                        ? 'Tes amies téléchargent FitEva avec ton code'
                        : 'Your friends download FitEva with your code',
                    color: accent, d: d,
                  ),
                  const SizedBox(height: 14),
                  _HowStep(
                    number: '3',
                    title: l10n.isFrench ? 'Débloque ta récompense' : 'Unlock your reward',
                    subtitle: l10n.isFrench
                        ? 'Gratte la carte pour révéler ton cadeau'
                        : 'Scratch the card to reveal your gift',
                    color: _P.gold, d: d,
                  ),
                ]),
              ),
            ),
          ),

          // ── All rewards tiers ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _P.surf(d),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _P.bdr(d), width: 0.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: d ? 0.18 : 0.04),
                    blurRadius: 12, offset: const Offset(0, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _P.gold.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8)),
                      child: Icon(LucideIcons.trophy, size: 14, color: _P.gold)),
                    const SizedBox(width: 10),
                    Text(
                      l10n.isFrench ? 'Paliers de récompenses' : 'Reward tiers',
                      style: GoogleFonts.outfit(fontSize: 15,
                        fontWeight: FontWeight.w700, color: ink)),
                  ]),
                  const SizedBox(height: 18),
                  _RewardTier(
                    icon: LucideIcons.star, need: 1,
                    title: '+50 Points',
                    subtitle: l10n.isFrench ? '1 ami invité' : '1 friend invited',
                    color: accent, d: d,
                    ref: ref,
                  ),
                  Divider(height: 20, color: _P.bdr(d), indent: 44),
                  _RewardTier(
                    icon: LucideIcons.flame, need: 3,
                    title: 'Premium 24h',
                    subtitle: l10n.isFrench ? '3 amis invités' : '3 friends invited',
                    color: const Color(0xFFE0703C), d: d,
                    ref: ref,
                  ),
                  Divider(height: 20, color: _P.bdr(d), indent: 44),
                  _RewardTier(
                    icon: LucideIcons.trophy, need: 5,
                    title: l10n.isFrench ? 'Badge exclusif' : 'Exclusive badge',
                    subtitle: l10n.isFrench ? '5 amis invités' : '5 friends invited',
                    color: _P.gold, d: d,
                    ref: ref,
                  ),
                  Divider(height: 20, color: _P.bdr(d), indent: 44),
                  _RewardTier(
                    icon: LucideIcons.crown, need: 10,
                    title: l10n.isFrench ? 'Premium 1 mois' : 'Premium 1 month',
                    subtitle: l10n.isFrench ? '10 amis invités' : '10 friends invited',
                    color: const Color(0xFF9333EA), d: d,
                    ref: ref,
                  ),
                ]),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

class _HowStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final bool d;

  const _HowStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.d,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle),
          child: Center(
            child: Text(number, style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: _P.ink(d))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(
              fontSize: 12.5, color: _P.muted(d))),
          ],
        )),
      ],
    );
  }
}

class _RewardTier extends StatelessWidget {
  final IconData icon;
  final int need;
  final String title;
  final String subtitle;
  final Color color;
  final bool d;
  final WidgetRef ref;

  const _RewardTier({
    required this.icon,
    required this.need,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.d,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(referralCountProvider).asData?.value ?? 0;
    final revealed = ref.watch(revealedRewardsProvider).asData?.value ?? <int>{};
    final unlocked = count >= need;
    final claimed = revealed.contains(need);

    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: unlocked ? color.withValues(alpha: 0.12) : _P.bdr(d),
            shape: BoxShape.circle),
          child: Icon(
            claimed ? Icons.check_rounded : (unlocked ? icon : LucideIcons.lock),
            size: 16,
            color: unlocked ? color : _P.muted(d).withValues(alpha: 0.5)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: unlocked ? _P.ink(d) : _P.muted(d))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(
              fontSize: 12, color: _P.muted(d))),
          ],
        )),
        if (claimed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8)),
            child: Text(
              ref.watch(l10nProvider).isFrench ? 'Obtenu' : 'Claimed',
              style: GoogleFonts.inter(fontSize: 11,
                fontWeight: FontWeight.w700, color: color)),
          )
        else if (unlocked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8)),
            child: Text(
              ref.watch(l10nProvider).isFrench ? 'Gratter' : 'Scratch',
              style: GoogleFonts.inter(fontSize: 11,
                fontWeight: FontWeight.w700, color: color)),
          ),
      ],
    );
  }
}
