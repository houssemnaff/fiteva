  // ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pregnancy_colors.dart';
import 'package:fiteva/l10n/app_localizations.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

// ─── data ─────────────────────────────────────────────────────────────────────

class _BodyData {
  final String changesTitle;
  final String changesText;
  final List<_Tip> tips;
  final List<_Change> changes;

  const _BodyData({
    required this.changesTitle,
    required this.changesText,
    required this.tips,
    required this.changes,
  });
}

class _Tip {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String body;
  const _Tip({required this.icon, required this.color,
      required this.bg, required this.title, required this.body});
}

class _Change {
  final String label;
  final String detail;
  final IconData icon;
  const _Change({required this.label, required this.detail,
      required this.icon});
}

_BodyData _dataForWeek(int week, BuildContext context) {
  // ── 1er trimestre ──────────────────────────────────────────────────────────
  if (week <= 4) {
    return _BodyData(
      changesTitle: 'Les premières semaines',
      changesText:
          'Ton corps commence à produire des hormones de grossesse. '
          'Tu peux te sentir légèrement différente, mais beaucoup de femmes '
          'ne remarquent encore rien. L\'utérus est à peine plus grand qu\'une prune.',
      changes: [
        _Change(label: 'Poitrine sensible', icon: Icons.favorite_outline_rounded,
            detail: 'Les hormones préparent les glandes mammaires.'),
        _Change(label: 'Légère fatigue', icon: Icons.bedtime_outlined,
            detail: 'La progestérone monte — ton corps travaille fort.'),
        _Change(label: 'Urinaire plus fréquent', icon: Icons.water_drop_outlined,
            detail: 'hCG stimule les reins dès les premières semaines.'),
      ],
      tips: [
        _Tip(icon: Icons.eco_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Acide folique',
            body: '400 µg par jour, indispensable pour le tube neural de bébé.'),
        _Tip(icon: Icons.local_drink_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Hydratation',
            body: 'Vise 2 litres d\'eau par jour. Commence tôt le matin.'),
        _Tip(icon: Icons.nights_stay_outlined, color: context._p.textMid, bg: context._p.amberSoft,
            title: 'Dors en écoutant ton corps',
            body: 'La fatigue du 1er trimestre est normale. Repose-toi sans culpabilité.'),
      ],
    );
  }

  if (week <= 8) {
    return _BodyData(
      changesTitle: 'Semaines 5 à 8',
      changesText:
          'Les nausées matinales peuvent apparaître (ou toute la journée). '
          'Ton utérus commence à grossir. La poitrine peut devenir plus lourde. '
          'Certaines femmes ressentent des ballonnements et une légère constipation.',
      changes: [
        _Change(label: 'Nausées', icon: Icons.sick_outlined,
            detail: 'hCG atteint son pic — gingembre et petits repas aident.'),
        _Change(label: 'Poitrine qui gonfle', icon: Icons.favorite_outline_rounded,
            detail: 'Les canaux galactophores se développent.'),
        _Change(label: 'Ballonnements', icon: Icons.bubble_chart_outlined,
            detail: 'La progestérone ralentit la digestion.'),
        _Change(label: 'Salivation excessive', icon: Icons.water_drop_outlined,
            detail: 'Ptyalisme — courant au 1er trimestre, inoffensif.'),
      ],
      tips: [
        _Tip(icon: Icons.restaurant_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Petits repas fréquents',
            body: 'Mange toutes les 2–3h pour éviter la nausée à jeun.'),
        _Tip(icon: Icons.spa_outlined, color: context._p.warmPink, bg: context._p.pinkSoft,
            title: 'Gingembre',
            body: 'Tisane, bonbons ou capsules — efficace contre les nausées.'),
        _Tip(icon: Icons.self_improvement_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Mouvement doux',
            body: '20 min de marche par jour maintient l\'énergie et réduit les nausées.'),
      ],
    );
  }

  if (week <= 13) {
    return _BodyData(
      changesTitle: 'Semaines 9 à 13',
      changesText:
          'L\'utérus sort du bassin et commence à se voir. '
          'Les nausées commencent souvent à diminuer. '
          'Ton volume sanguin augmente de 50 % — d\'où la fatigue et parfois des vertiges.',
      changes: [
        _Change(label: 'Ventre qui pointe', icon: Icons.pregnant_woman_outlined,
            detail: 'L\'utérus dépasse le bassin vers la fin de cette période.'),
        _Change(label: 'Veines visibles', icon: Icons.water_outlined,
            detail: 'Volume sanguin +50 % — les veines bleues apparaissent sur la poitrine.'),
        _Change(label: 'Peau qui change', icon: Icons.face_outlined,
            detail: 'Éclat ou imperfections — les deux sont normaux.'),
        _Change(label: 'Taille de pantalon', icon: Icons.straighten_outlined,
            detail: 'La taille épaissit avant que le ventre soit visible.'),
      ],
      tips: [
        _Tip(icon: Icons.fitness_center_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Yoga prénatal',
            body: 'Soulage les lombaires et maintient la souplesse pelvienne.'),
        _Tip(icon: Icons.opacity_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Crème hydratante',
            body: 'Commence maintenant sur le ventre, les seins et les hanches — prévention des vergetures.'),
        _Tip(icon: Icons.monitor_heart_outlined, color: context._p.warmPink, bg: context._p.pinkSoft,
            title: 'Dépistage T1',
            body: 'Clarté nucale et prises de sang — assure-toi d\'avoir ton rendez-vous.'),
      ],
    );
  }

  // ── 2e trimestre ──────────────────────────────────────────────────────────
  if (week <= 17) {
    return _BodyData(
      changesTitle: 'Semaines 14 à 17',
      changesText:
          'Le "beau trimestre" commence souvent maintenant. '
          'L\'énergie revient, les nausées s\'estompent. '
          'Ton ventre est désormais visible. La ronde ligamentaire peut apparaître — '
          'douleurs courtes et vives sur les côtés de l\'utérus.',
      changes: [
        _Change(label: 'Ventre arrondi', icon: Icons.pregnant_woman_outlined,
            detail: 'L\'utérus atteint le nombril vers la semaine 20.'),
        _Change(label: 'Douleurs ligamentaires', icon: Icons.bolt_outlined,
            detail: 'Tiraillements courts sur les côtés — normaux et bénins.'),
        _Change(label: 'Retour d\'énergie', icon: Icons.bolt_rounded,
            detail: 'La progestérone se stabilise — profite-en !'),
        _Change(label: 'Gain de poids', icon: Icons.monitor_weight_outlined,
            detail: '300–400 g par semaine est dans la normale.'),
      ],
      tips: [
        _Tip(icon: Icons.pool_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Natation',
            body: 'Zéro impact. Soulage le dos et maintient la condition physique.'),
        _Tip(icon: Icons.checkroom_outlined, color: context._p.amber, bg: context._p.amberSoft,
            title: 'Vêtements de maternité',
            body: 'Investis dans un bon soutien-gorge de grossesse — le confort change tout.'),
        _Tip(icon: Icons.spa_outlined, color: context._p.warmPink, bg: context._p.pinkSoft,
            title: 'Massages',
            body: 'Massages doux du ventre avec huile de rose musquée ou argan.'),
      ],
    );
  }

  if (week <= 22) {
    return _BodyData(
      changesTitle: 'Semaines 18 à 22',
      changesText:
          'Tu vas sentir bébé bouger pour la première fois — '
          'une sensation comme des ailes de papillon. '
          'Le ventre devient clairement visible. '
          'L\'échographie morphologique a lieu cette semaine.',
      changes: [
        _Change(label: 'Premiers mouvements', icon: Icons.child_care_outlined,
            detail: 'Quickening — papillons, bulles, petits coups.'),
        _Change(label: 'Ligne brune (linea nigra)', icon: Icons.straighten_outlined,
            detail: 'Ligne foncée du nombril au pubis — disparaît après l\'accouchement.'),
        _Change(label: 'Dos et bassin', icon: Icons.accessibility_new_outlined,
            detail: 'La relaxine assouplit les articulations — attention à la posture.'),
        _Change(label: 'Gencives sensibles', icon: Icons.sentiment_dissatisfied_outlined,
            detail: 'Les hormones rendent les gencives plus fragiles — hygiène douce.'),
      ],
      tips: [
        _Tip(icon: Icons.accessibility_new_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Posture & dos',
            body: 'Évite de rester debout longtemps. Utilise un coussin lombaire au bureau.'),
        _Tip(icon: Icons.local_dining_outlined, color: context._p.amber, bg: context._p.amberSoft,
            title: 'Calcium & fer',
            body: 'Augmente les légumes verts, légumineuses et produits laitiers.'),
        _Tip(icon: Icons.nightlight_outlined, color: context._p.textMid, bg: context._p.amberSoft,
            title: 'Coussin de grossesse',
            body: 'Commence à dormir avec un coussin en C entre les genoux — soulagement immédiat.'),
      ],
    );
  }

  if (week <= 26) {
    return _BodyData(
      changesTitle: 'Semaines 23 à 26',
      changesText:
          'Ton ventre grossit rapidement. Les muscles abdominaux s\'écartent '
          '(diastasis) — c\'est normal. Les brûlures d\'estomac peuvent apparaître '
          'car l\'utérus pousse sur l\'estomac. La peau sur le ventre peut tirer.',
      changes: [
        _Change(label: 'Brûlures d\'estomac', icon: Icons.local_fire_department_outlined,
            detail: 'L\'utérus comprime l\'estomac — mange moins mais plus souvent.'),
        _Change(label: 'Varices possibles', icon: Icons.water_outlined,
            detail: 'Volume sanguin élevé — bas de contention si besoin.'),
        _Change(label: 'Vergetures', icon: Icons.linear_scale_outlined,
            detail: 'La peau s\'étire vite — hydrate quotidiennement.'),
        _Change(label: 'Essoufflement léger', icon: Icons.air_outlined,
            detail: 'L\'utérus monte vers les poumons. Normal à ce stade.'),
      ],
      tips: [
        _Tip(icon: Icons.self_improvement_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Pilates prénatal',
            body: 'Renforce le plancher pelvien et stabilise le dos sans effort.'),
        _Tip(icon: Icons.opacity_outlined, color: context._p.warmPink, bg: context._p.pinkSoft,
            title: 'Huile pour le ventre',
            body: 'Matin et soir — argan, rose musquée ou beurre de karité pur.'),
        _Tip(icon: Icons.compress_outlined, color: context._p.amber, bg: context._p.amberSoft,
            title: 'Bas de contention',
            body: 'Préviennent les varices et soulagent la sensation de jambes lourdes.'),
      ],
    );
  }

  // ── 3e trimestre ──────────────────────────────────────────────────────────
  if (week <= 32) {
    return _BodyData(
      changesTitle: 'Semaines 27 à 32',
      changesText:
          'Le troisième trimestre s\'ouvre. Le ventre est bien rond, '
          'les mouvements de bébé sont vigoureux et visibles. '
          'L\'essoufflement, les insomnies et les douleurs dorsales '
          'sont courants — mais chaque semaine t\'approche du grand moment.',
      changes: [
        _Change(label: 'Contractions de Braxton Hicks', icon: Icons.loop_rounded,
            detail: 'Contractions irrégulières, indolores — entraînement de l\'utérus.'),
        _Change(label: 'Insomnie', icon: Icons.bedtime_outlined,
            detail: 'Difficulté à trouver une position + mouvements de bébé la nuit.'),
        _Change(label: 'Œdème des pieds', icon: Icons.water_drop_outlined,
            detail: 'Rétention d\'eau normale — surélève les pieds le soir.'),
        _Change(label: 'Dos et hanches', icon: Icons.accessibility_new_outlined,
            detail: 'La relaxine détend les ligaments — marche et étirements doux.'),
      ],
      tips: [
        _Tip(icon: Icons.airline_seat_recline_extra_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Ballon de grossesse',
            body: 'Rebonds doux 10 min/j — soulage les lombaires et prépare le périnée.'),
        _Tip(icon: Icons.bathtub_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Bain chaud (pas brûlant)',
            body: 'Soulage les douleurs musculaires. Ajoute quelques gouttes de lavande.'),
        _Tip(icon: Icons.directions_walk_outlined, color: context._p.amber, bg: context._p.amberSoft,
            title: 'Marche quotidienne',
            body: '20–30 min le matin — soulage les jambes lourdes et régule le sommeil.'),
      ],
    );
  }

  if (week <= 36) {
    return _BodyData(
      changesTitle: 'Semaines 33 à 36',
      changesText:
          'Bébé se retourne souvent tête en bas. '
          'La descente dans le bassin peut soulager la respiration '
          'mais augmenter la pression pelvienne. '
          'Tu peux avoir envie de "nidifier" — l\'instinct naturel de tout préparer.',
      changes: [
        _Change(label: 'Pression pelvienne', icon: Icons.compress_outlined,
            detail: 'Bébé descend vers le bassin — sensations de pression normales.'),
        _Change(label: 'Fuite colostrum possible', icon: Icons.opacity_outlined,
            detail: 'Le premier lait se prépare — coussinets d\'allaitement utiles.'),
        _Change(label: 'Nidification', icon: Icons.home_outlined,
            detail: 'Envie intense de tout préparer — instinct maternel puissant.'),
        _Change(label: 'Essoufflement réduit', icon: Icons.air_outlined,
            detail: 'La descente de bébé libère de l\'espace pour les poumons.'),
      ],
      tips: [
        _Tip(icon: Icons.health_and_safety_outlined, color: context._p.mint, bg: context._p.mintLight,
            title: 'Plancher pelvien',
            body: 'Exercices de Kegel — 3 séries de 10 contractions par jour.'),
        _Tip(icon: Icons.airline_seat_flat_outlined, color: context._p.warmPink, bg: context._p.pinkSoft,
            title: 'Prépare ta valise',
            body: 'Idéalement prête avant la semaine 36 — juste au cas où.'),
        _Tip(icon: Icons.spa_outlined, color: context._p.green, bg: context._p.mintLight,
            title: 'Périnée',
            body: 'Massage périnéal doux à partir de 36 semaines — réduit les risques de déchirure.'),
      ],
    );
  }

  return _BodyData(
    changesTitle: 'Semaines 37 à 40 — Terme',
    changesText:
        'Tu es à terme. Ton corps se prépare activement à l\'accouchement. '
        'Le col peut commencer à se ramollir et à s\'effacer. '
        'Les contractions de Braxton Hicks sont plus fréquentes. '
        'Chaque jour qui passe est une préparation.',
    changes: [
      _Change(label: 'Col qui s\'efface', icon: Icons.timeline_outlined,
          detail: 'Le col se ramollit, s\'efface et commence à se dilater.'),
      _Change(label: 'Bouchon muqueux', icon: Icons.water_drop_outlined,
          detail: 'Sa perte signale que le travail approche — dans les jours/semaines.'),
      _Change(label: 'Contractions régulières', icon: Icons.loop_rounded,
          detail: 'Régulières, rapprochées et intenses = appelle ta maternité.'),
      _Change(label: 'Légèreté soudaine', icon: Icons.air_outlined,
          detail: 'Bébé bien descendu — respiration plus facile.'),
    ],
    tips: [
      _Tip(icon: Icons.self_improvement_outlined, color: context._p.green, bg: context._p.mintLight,
          title: 'Respiration sophro',
          body: 'Cohérence cardiaque 5 min, matin et soir. Le corps se calme, le travail s\'installe mieux.'),
      _Tip(icon: Icons.directions_walk_outlined, color: context._p.mint, bg: context._p.mintLight,
          title: 'Marche & ballon',
          body: 'Stimule naturellement les contractions et aide bébé à s\'engager.'),
      _Tip(icon: Icons.favorite_rounded, color: context._p.warmPink, bg: context._p.pinkSoft,
          title: 'Fais confiance à ton corps',
          body: '40 semaines de préparation. Ton corps sait. Tu sais. Vous êtes prêtes.'),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class PregnancyBodyScreen extends ConsumerWidget {
  final int currentWeek;
  const PregnancyBodyScreen({super.key, required this.currentWeek});

  String _trimestre(AppL10n l10n) => currentWeek <= 13
      ? l10n.bodyTrim1
      : currentWeek <= 26
          ? l10n.bodyTrim2
          : l10n.bodyTrim3;

  Color _triColor(BuildContext context) => currentWeek <= 13
      ? context._p.mint
      : currentWeek <= 26
          ? context._p.warmPink
          : context._p.amber;

  Color _triBg(BuildContext context) => currentWeek <= 13
      ? context._p.mintLight
      : currentWeek <= 26
          ? context._p.pinkSoft
          : context._p.amberSoft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = ref.watch(l10nProvider);
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final data   = _dataForWeek(currentWeek, context);

    return Scaffold(
      backgroundColor: context._p.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [

          // ── HEADER ──────────────────────────────────────────────────────
          Container(
            color: context._p.surface,
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 20),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: context._p.mintLight,
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.chevron_left_rounded,
                        size: 22, color: context._p.green),
                  ),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.bodyTitle, style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: context._p.textSoft, letterSpacing: 2.5)),
                  const SizedBox(height: 1),
                  Text('${l10n.pregSemaineN(currentWeek)} · ${_trimestre(l10n)}',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: context._p.textDark)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _triBg(context),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(_trimestre(l10n), style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _triColor(context))),
                ),
              ]),

              const SizedBox(height: 18),

              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: [
                  Container(height: 6, color: context._p.mintLight),
                  AnimatedFractionallySizedBox(
                    widthFactor: currentWeek / 40,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [context._p.mint, context._p.green]),
                        borderRadius:
                            BorderRadius.all(Radius.circular(4))),
                    ),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // ── HERO BANNER ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Color.lerp(Theme.of(context).colorScheme.primary, Colors.white, 0.2)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.19),
                  blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.self_improvement_outlined,
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.changesTitle, style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: Colors.white, height: 1.2)),
                      const SizedBox(height: 8),
                      Text(data.changesText, style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white70,
                        height: 1.65)),
                    ],
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── CHANGEMENTS DU CORPS ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: _card(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    child: Row(children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: context._p.pinkSoft,
                          borderRadius: BorderRadius.circular(9)),
                        child: Icon(Icons.pregnant_woman_outlined,
                            size: 15, color: context._p.warmPink),
                      ),
                      const SizedBox(width: 10),
                      Text(l10n.bodyVecuTitle,
                          style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: context._p.textDark)),
                    ]),
                  ),
                  Divider(height: 1, color: context._p.border),
                  ...List.generate(data.changes.length, (i) {
                    final c = data.changes[i];
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: context._p.mintLight,
                                borderRadius: BorderRadius.circular(10)),
                              child: Icon(c.icon, size: 17, color: context._p.green),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.label, style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: context._p.textDark)),
                                const SizedBox(height: 3),
                                Text(c.detail, style: GoogleFonts.inter(
                                  fontSize: 12, color: context._p.textMid,
                                  height: 1.5)),
                              ],
                            )),
                          ],
                        ),
                      ),
                      if (i < data.changes.length - 1)
                        Divider(height: 1, indent: 70, color: context._p.border),
                    ]);
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── CONSEILS BIEN-ÊTRE ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 2),
                  child: Text(l10n.bodyConseils,
                      style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w600,
                        color: context._p.textSoft, letterSpacing: 2)),
                ),
                ...data.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TipCard(tip: tip),
                )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── POIDS DE RÉFÉRENCE ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeightCard(week: currentWeek, l10n: l10n),
          ),

          SizedBox(height: bottom + 40),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TIP CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final _Tip tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context._p.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(
          color: Color(0x081C4D30),
          blurRadius: 14, offset: Offset(0, 3))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: tip.bg,
            borderRadius: BorderRadius.circular(12)),
          child: Icon(tip.icon, size: 19, color: tip.color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tip.title, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: context._p.textDark)),
            const SizedBox(height: 4),
            Text(tip.body, style: GoogleFonts.inter(
              fontSize: 12, color: context._p.textMid, height: 1.55)),
          ],
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEIGHT GUIDE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _WeightCard extends StatelessWidget {
  final int week;
  final AppL10n l10n;
  const _WeightCard({required this.week, required this.l10n});

  // prise de poids recommandée (IMC normal)
  String get _weightRange {
    if (week <= 12) return '0 – 2 kg';
    if (week <= 20) return '2 – 6 kg';
    if (week <= 28) return '6 – 10 kg';
    if (week <= 36) return '10 – 13 kg';
    return '11 – 16 kg';
  }

  String get _weightNote {
    if (week <= 12) return 'Premier trimestre — prise de poids minimale.';
    if (week <= 20) return 'Croissance progressive — 300–400 g/semaine.';
    if (week <= 28) return 'Bébé grossit rapidement — suivi régulier.';
    if (week <= 36) return 'Troisième trimestre — prise plus marquée.';
    return 'Terme — la prise de poids se stabilise.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context._p.amberSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: context._p.surface,
            borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.monitor_weight_outlined,
              size: 19, color: context._p.amber),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bodyPoids,
                style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: context._p.amber, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text(_weightRange, style: GoogleFonts.outfit(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: context._p.textDark)),
            const SizedBox(height: 4),
            Text(_weightNote, style: GoogleFonts.inter(
              fontSize: 12, color: context._p.textMid, height: 1.5)),
            const SizedBox(height: 8),
            Text('* Ces chiffres sont indicatifs pour un IMC normal avant la grossesse. '
                'Ton médecin adaptera le suivi à ta situation.',
                style: GoogleFonts.inter(
                  fontSize: 10, color: context._p.textSoft,
                  fontStyle: FontStyle.italic, height: 1.5)),
          ],
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _card(BuildContext context) => BoxDecoration(
  color: context._p.surface,
  borderRadius: BorderRadius.circular(20),
  boxShadow: const [BoxShadow(
    color: Color(0x081C4D30),
    blurRadius: 16, offset: Offset(0, 4))],
);
