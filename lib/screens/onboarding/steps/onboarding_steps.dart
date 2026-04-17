import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─── Shared Design Constants ───────────────────────────────────────────────
const _kGreen = Color(0xFF2D4A2D);
const _kBg = Color(0xFFF0F0EC);

// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar: back arrow + "X / 7" counter + green progress line
class _OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;

  const _OnboardingTopBar({
    required this.step,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  child: const Icon(Icons.arrow_back, size: 22, color: Colors.black87),
                ),
                Text(
                  '$step / $total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Thin progress line
        LinearProgressIndicator(
          value: step / total,
          minHeight: 2,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
        ),
      ],
    );
  }
}

/// Icon badge (grey rounded square with dark green icon)
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: _kGreen, size: 28),
    );
  }
}

/// Step title + subtitle
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

/// Bottom CTA button (dark green, full width)
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  const _CtaButton({
    required this.label,
    this.onPressed,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed != null ? _kGreen : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  Icon(trailingIcon, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared text field style
InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kGreen, width: 1.5),
      ),
    );


// ══════════════════════════════════════════════════════════════════════════════
// STEP 0 — StepIntro
// ══════════════════════════════════════════════════════════════════════════════



class StepIntro extends StatelessWidget {
  final VoidCallback onNext;

  const StepIntro({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF244D2A), // vert principal
        ),
        child: Stack(
          children: [
            // 🔵 Background circles (design moderne)
            Positioned(
              top: -100,
              left: -80,
              child: _circle(300, const Color(0xFF2E5E35)),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _circle(280, const Color(0xFF2E5E35)),
            ),

            // 🔥 CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // 🔷 Logo + brand centered in page
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/logfiteva.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "FITEVA",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "fit, c'est moi.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 🚀 BUTTON
                  SafeArea(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: onNext,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Commencer",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF244D2A),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, color: Color(0xFF244D2A)),
                              ],
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 16),
            
                        const Text(
                          "J'ai déjà un compte",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
            
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 Background circle
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Bienvenue (Prénom + Âge)
// ══════════════════════════════════════════════════════════════════════════════

class StepWelcome extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  // ✅ Controllers venant du parent
  final TextEditingController nameController;
  final TextEditingController ageController;

  const StepWelcome({
    super.key,
    required this.onNext,
    this.onBack,
    required this.nameController,
    required this.ageController,
  });

  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<StepWelcome> {

  bool get _canContinue =>
      widget.nameController.text.trim().isNotEmpty &&
      widget.ageController.text.trim().isNotEmpty;

  String get _initial =>
      widget.nameController.text.trim().isNotEmpty
          ? widget.nameController.text.trim()[0].toUpperCase()
          : 'S';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 1, total: 7, onBack: widget.onBack),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  const _StepHeader(
                    title: 'Bienvenue dans FITEVA',
                    subtitle: 'Personnalise ton expérience en quelques étapes',
                  ),

                  const SizedBox(height: 32),

                  // ✅ Avatar dynamique
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E4D6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _initial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _kGreen,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🔹 NAME
                  const Text('Ton prénom',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: widget.nameController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: _fieldDecoration('Sophie'),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 AGE
                  const Text('Ton âge',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: widget.ageController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: _fieldDecoration('28'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

// OR divider
Row(
  children: const [
    Expanded(child: Divider()),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "ou continuer avec",
        style: TextStyle(color: Colors.black45, fontSize: 12),
      ),
    ),
    Expanded(child: Divider()),
  ],
),

const SizedBox(height: 16),

// SOCIAL LOGIN BUTTONS
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // GOOGLE
    _SocialLoginButton(
      icon: Icons.g_mobiledata, // tu peux remplacer par logo officiel
      label: "Google",
      color: Colors.redAccent,
      onTap: () {
        print("Google login");
        // TODO: Google Sign-In
      },
    ),

    const SizedBox(width: 16),

    // APPLE
    _SocialLoginButton(
      icon: Icons.apple,
      label: "Apple",
      color: Colors.black,
      onTap: () {
        print("Apple login");
        // TODO: Apple Sign-In
      },
    ),
  ],
),

const SizedBox(height: 16),

          // ✅ BUTTON
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}
// ══════════════════════════════════════════════════════════════════════════════
// STEP 2 — Objectifs
// ══════════════════════════════════════════════════════════════════════════════
class StepGoals extends StatelessWidget {
  final List<String> selectedGoals;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleGoal;
  final VoidCallback onNext;

  const StepGoals({
    super.key,
    required this.selectedGoals,
    this.onBack,
    required this.onToggleGoal,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      'Perdre du poids',
      'Prendre du muscle',
      'Améliorer l\'endurance',
      'Réduire le stress',
      'Équilibrer hormones',
      'Améliorer le sommeil',
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 2, total: 7, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.trophy),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Quels sont tes objectifs ?',
                    subtitle: 'Sélectionne tout ce qui s\'applique',
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: options.map((option) {
                      final selected = selectedGoals.contains(option);
                      return GestureDetector(
                        onTap: () => onToggleGoal(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? _kGreen : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: selected ? _kGreen : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedGoals.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 3 — Niveau de fitness
// ══════════════════════════════════════════════════════════════════════════════
class StepFitnessLevel extends StatelessWidget {
  final String? selectedLevel;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFitnessLevel({
    super.key,
    required this.selectedLevel,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {
        'label': 'Débutant',
        'sub': 'Moins de 6 mois d\'expérience',
        'icon': LucideIcons.leaf,
      },
      {
        'label': 'Intermédiaire',
        'sub': '6 mois à 2 ans d\'expérience',
        'icon': LucideIcons.flame,
      },
      {
        'label': 'Avancé',
        'sub': 'Plus de 2 ans d\'expérience',
        'icon': LucideIcons.zap,
      },
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 3, total: 7, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.dumbbell),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Quel est ton niveau ?',
                    subtitle: 'Sois honnête — on s\'adapte à toi',
                  ),
                  const SizedBox(height: 28),
                  ...levels.map((level) {
                    final isSelected = selectedLevel == level['label'];
                    return GestureDetector(
                      onTap: () => onChanged(level['label'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? _kGreen : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                level['icon'] as IconData,
                                color: isSelected ? _kGreen : Colors.black45,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  level['sub'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedLevel != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 4 — Équipement
// ══════════════════════════════════════════════════════════════════════════════
class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipment;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleEquipment;
  final VoidCallback onNext;

  const StepEquipment({
    super.key,
    required this.selectedEquipment,
    this.onBack,
    required this.onToggleEquipment,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      'Aucun matériel',
      'Haltères',
      'Barre & poids',
      'Machines',
      'Résistances',
      'Tapis de yoga',
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 4, total: 7, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.package),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Quel matériel as-tu ?',
                    subtitle: 'Sélectionne ce dont tu disposes',
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: options.map((option) {
                      final selected = selectedEquipment.contains(option);
                      return GestureDetector(
                        onTap: () => onToggleEquipment(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? _kGreen : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: selected ? _kGreen : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedEquipment.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 5 — Fréquence (jours par semaine)
// ══════════════════════════════════════════════════════════════════════════════
class StepFrequency extends StatelessWidget {
  final String? selectedFrequency;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFrequency({
    super.key,
    required this.selectedFrequency,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      '2 jours par semaine',
      '3 jours par semaine',
      '4 jours par semaine',
      '5 jours par semaine',
      '6 jours par semaine',
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 5, total: 7, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.calendarDays),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Combien de fois par semaine ?',
                    subtitle: 'Établissons un planning réaliste',
                  ),
                  const SizedBox(height: 28),
                  ...options.map((option) {
                    final isSelected = selectedFrequency == option;
                    return GestureDetector(
                      onTap: () => onChanged(option),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? _kGreen : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 15,
                                color: isSelected ? _kGreen : Colors.black87,
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: _kGreen, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedFrequency != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 6 — Profil santé (Taille + Poids)
// ══════════════════════════════════════════════════════════════════════════════
class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepHealthProfile({super.key, required this.onNext, this.onBack});

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  bool get _canContinue =>
      _heightCtrl.text.trim().isNotEmpty && _weightCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 6, total: 7, onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.shieldCheck),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Profil santé',
                    subtitle: 'Ces informations restent privées',
                  ),
                  const SizedBox(height: 20),
                  // Privacy notice
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.lock, color: _kGreen, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tes données de santé sont chiffrées et ne sont jamais partagées.',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Taille (cm)', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _heightCtrl,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: _fieldDecoration('165'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Poids (kg)', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightCtrl,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    decoration: _fieldDecoration('60'),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 7 — Cycle menstruel
// ══════════════════════════════════════════════════════════════════════════════
class StepCycle extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepCycle({super.key, required this.onNext, this.onBack});

  @override
  State<StepCycle> createState() => _StepCycleState();
}

class _StepCycleState extends State<StepCycle> {
  String? _selectedDuration = '28 jours';
  DateTime _lastPeriodDate = DateTime(2026, 4, 5);

  final List<String> _durations = [
    '24 jours',
    '26 jours',
    '28 jours',
    '30 jours',
    '32 jours',
  ];

  String _formatDate(DateTime d) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 7, total: 7, onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.moon),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ton cycle menstruel',
                    subtitle: 'La clé du cycle syncing',
                  ),
                  const SizedBox(height: 20),
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Durée de ton cycle',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _kGreen,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'La moyenne est de 28 jours mais chaque femme est unique',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Durée habituelle',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? _kGreen : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            d,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Début de tes dernières règles',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendarDays,
                              size: 20, color: Colors.black45),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_lastPeriodDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Commencer FITEVA',
            trailingIcon: Icons.check,
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
