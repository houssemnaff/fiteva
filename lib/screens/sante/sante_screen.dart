// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/nutrition/health_nutrition_widgets.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';

const _kMint  = Color(0xFF7ABB98);
const _kCream = Color(0xFFFAFAF8);

// Static expert data shown in the Santé screen
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

class SanteScreen extends StatelessWidget {
  const SanteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SharedAppHeader.sliver(
            eyebrow: 'Santé',
            title: 'Mon bien-être',
            accentColor: _kMint,
            bgColor: _kCream,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: DynamicCalorieCard(phase: CyclePhase.folliculaire),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: WaterTrackerCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: DailyRecommendationCard(
                phase: CyclePhase.folliculaire,
                foodTags: const [
                  'Légumes verts', 'Protéines', 'Oméga-3',
                  'Fer', 'Magnésium',
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CycleNutritionSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: DailyNutrientTipCard(phase: CyclePhase.folliculaire),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: ExpertAdviceSection(experts: _experts),
            ),
          ),
        ],
      ),
    );
  }
}
