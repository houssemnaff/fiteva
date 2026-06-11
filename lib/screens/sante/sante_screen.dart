import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/screens/nutrition/health_nutrition_widgets.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kMint         = Color(0xFF7ABB98);
const _kCream        = Color(0xFFFAFAF8);
const _kCurrentPhase = CyclePhase.luteale;

const _experts = [
  ExpertAdvice(
    name: 'Dr. Sophie Lemaire',
    role: 'Nutritionniste',
    initials: 'SL',
    color: Color(0xFF1C4D30),
    bg: Color(0xFFEAF3EC),
    title: 'Manger selon votre cycle',
    body: 'Adaptez vos apports en fer, magnésium et oméga-3 à chaque phase pour un meilleur équilibre hormonal.',
    tag: 'Nutrition',
  ),
  ExpertAdvice(
    name: 'Dr. Marie Collin',
    role: 'Endocrinologue',
    initials: 'MC',
    color: Color(0xFF6B2D8B),
    bg: Color(0xFFF5EEFF),
    title: 'Hormones & alimentation',
    body: 'Un équilibre glycémique stable est la clé pour réduire les sautes d\'humeur liées aux fluctuations hormonales.',
    tag: 'Hormones',
  ),
];

class SanteScreen extends ConsumerWidget {
  const SanteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals  = ref.watch(todayTotalsProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SharedAppHeader.sliver(
            eyebrow:     'Santé',
            title:       'Mon bien-être',
            accentColor: _kMint,
            bgColor:     _kCream,
          ),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: MicronutrientsCard())),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: BodySignalCard())),

          // Objectif calorique — live calories consumed
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: DynamicCalorieCard(
              phase:        _kCurrentPhase,
              baseCalories: profile.dailyKcal,
              consumed:     totals.calories,
            ))),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: DailyNutrientTipCard(phase: _kCurrentPhase))),

          // Water tracker — reads & writes to provider
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: WaterTrackerCard())),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: CycleNutritionSection(initialPhase: _kCurrentPhase))),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: SleepQualityCard())),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: ActiveMinutesCard())),

          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 110),
            child: ExpertAdviceSection(experts: _experts))),
        ],
      ),
    );
  }
}
