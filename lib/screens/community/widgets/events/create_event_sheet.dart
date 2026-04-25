import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg = Colors.white;
  static const surface = Colors.white;
  static const card = Colors.white;
  static const border = Colors.white;
  static const borderHigh = Colors.white;
  static const accent = Color(0xFF1C4D30); // electric lime
  static const accentDim = Colors.white;
  static const textPrimary = Color(0xFF2E2E34);
  static const textSecondary = Color(0xFF2E2E34);
  static const textTertiary = Color(0xFF4A4A52);
  static const success = Color(0xFF1C4D30);
  static const danger = Color(0xFFFF4757);
  static const warning = Color(0xFFFFAA00);
}

// ─────────────────────────────────────────────
//  ENTRY POINT (show the sheet)
// ─────────────────────────────────────────────
void showCreateEventSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black87,
    builder: (_) => const CreateEventSheet(),
  );
}

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────
class CreateEventSheet extends StatefulWidget {
  const CreateEventSheet({super.key});

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // State
  int _selectedTypeIndex = 0;
  int _selectedLevelIndex = 1;
  int _spots = 12;
  bool _isPublic = true;
  bool _hasReminder = true;
  bool _isPublishing = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Data ──────────────────────────────────
  static const _types = [
    _ActivityType('Running', _RunningIcon()),
    _ActivityType('Musculation', _GymIcon()),
    _ActivityType('Yoga', _YogaIcon()),
    _ActivityType('Natation', _SwimIcon()),
    _ActivityType('Cyclisme', _BikeIcon()),
    _ActivityType('Autre', _PlusIcon()),
  ];

 
  // ── Lifecycle ─────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _detailsCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────
  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.of(context).pop();
    _showSuccessToast(context);
  }

  static void _showSuccessToast(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _C.border),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(_ProIcons.checkCircle,
                  color: _C.success, size: 16),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Événement publié',
                      style: TextStyle(
                          color: _C.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text('La communauté peut désormais s\'inscrire.',
                      style:
                          TextStyle(color: _C.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_fadeAnim),
        child: Container(
          margin: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildActivityPicker(),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'Titre',
                        controller: _titleCtrl,
                        hint: 'Morning Run — Corniche Sousse',
                        icon: _ProIcons.text,
                      ),
                      const SizedBox(height: 14),
                      _buildDateTimeRow(),
                      const SizedBox(height: 14),
                      _buildField(
                        label: 'Lieu',
                        controller: _locationCtrl,
                        hint: 'Corniche, Sousse',
                        icon: _ProIcons.mapPin,
                      ),
                   
                      const SizedBox(height: 20),
                      _buildSpotsStepper(),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'Description',
                        controller: _detailsCtrl,
                        hint:
                            'Équipement requis, niveau, consignes pratiques...',
                        icon: _ProIcons.alignLeft,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildDivider(),
                     
                    ],
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-builders ─────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.accentDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _C.accent.withOpacity(0.25), width: 0.5),
                ),
                child: const Icon(_ProIcons.zap, color: _C.accent, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Créer un événement',
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Organise ta session, invite la communauté',
                    style:
                        TextStyle(color: _C.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Type d\'activité'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_types.length, (i) {
            final selected = _selectedTypeIndex == i;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTypeIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? _C.accentDim : _C.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? _C.accent.withOpacity(0.6)
                        : _C.border,
                    width: selected ? 1 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color: selected ? _C.accent : _C.textSecondary,
                        size: 14,
                      ),
                      child: _types[i].icon,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _types[i].label,
                      style: TextStyle(
                        color: selected ? _C.accent : _C.textSecondary,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
            child: _DateTimeCard(
          label: 'Date',
          value: 'Sam 3 Mai',
          sub: '2025',
          icon: _ProIcons.calendar,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _DateTimeCard(
          label: 'Heure',
          value: '06:30',
          sub: 'du matin',
          icon: _ProIcons.clock,
        )),
      ],
    );
  }

  Widget _buildSpotsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(_ProIcons.users,
                color: _C.textSecondary, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Places disponibles',
                    style: TextStyle(
                        color: _C.textSecondary, fontSize: 11)),
                Text(
                  '$_spots participants',
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(
            icon: _ProIcons.minus,
            onTap: () {
              if (_spots > 2) setState(() => _spots--);
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$_spots',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _StepperButton(
            icon: _ProIcons.plus,
            onTap: () {
              if (_spots < 100) setState(() => _spots++);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        _ProTextField(
          controller: controller,
          hint: hint,
          icon: icon,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.bg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _C.border, width: 0.5),
          ),
          child: Icon(icon, color: _C.textTertiary, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(sub,
                  style: const TextStyle(
                      color: _C.textTertiary, fontSize: 11)),
            ],
          ),
        ),
        _ProSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDivider() => Container(
        height: 0.5,
        color: _C.border,
      );

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _C.border, width: 0.5)),
        color: _C.surface,
      ),
      child: Row(
        children: [
          _CancelButton(onTap: () => Navigator.of(context).pop()),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _PublishButton(
              isLoading: _isPublishing,
              onTap: _publish,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _C.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
        ),
      );
}

// ─────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────

class _DateTimeCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;

  const _DateTimeCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: _C.textTertiary, size: 15),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: _C.textTertiary, fontSize: 10)),
                Text(value,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    )),
                Text(sub,
                    style: const TextStyle(
                        color: _C.textTertiary, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _ProTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  State<_ProTextField> createState() => _ProTextFieldState();
}

class _ProTextFieldState extends State<_ProTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused ? _C.accent.withOpacity(0.45) : _C.border,
            width: _focused ? 1 : 0.5,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: const TextStyle(
            color: _C.textPrimary,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                const TextStyle(color: _C.textTertiary, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(widget.icon,
                  color: _focused ? _C.accent.withOpacity(0.7) : _C.textTertiary,
                  size: 15),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 42, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _ProSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? _C.accent : _C.bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: value ? Colors.transparent : _C.border,
            width: 0.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment:
              value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: value ? _C.bg : _C.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.borderHigh, width: 0.5),
        ),
        child: Icon(icon, color: _C.textSecondary, size: 14),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: 0.5),
        ),
        child: const Text(
          'Annuler',
          style: TextStyle(
            color: _C.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _PublishButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _C.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.bg,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(_ProIcons.send, color: _C.bg, size: 15),
                    SizedBox(width: 8),
                    Text(
                      'Publier l\'événement',
                      style: TextStyle(
                        color: _C.bg,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class _ActivityType {
  final String label;
  final Widget icon;
  const _ActivityType(this.label, this.icon);
}

class _Level {
  final String label;
  final Color color;
  const _Level(this.label, this.color);
}

// ─────────────────────────────────────────────
//  ICON WIDGETS (custom SVG paths via CustomPaint)
//  Using Flutter's built-in Icons as fallback — swap
//  with your icon package (lucide, phosphor, etc.)
// ─────────────────────────────────────────────

class _ProIcons {
  static const IconData zap = Icons.bolt_outlined;
  static const IconData text = Icons.title_rounded;
  static const IconData mapPin = Icons.location_on_outlined;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData clock = Icons.access_time_outlined;
  static const IconData users = Icons.group_outlined;
  static const IconData globe = Icons.public_outlined;
  static const IconData bell = Icons.notifications_none_outlined;
  static const IconData minus = Icons.remove;
  static const IconData plus = Icons.add;
  static const IconData send = Icons.north_east_rounded;
  static const IconData checkCircle = Icons.check_circle_outline_rounded;
  static const IconData alignLeft = Icons.notes_rounded;
}

// ── Activity icon wrappers ───────────────────

class _RunningIcon extends StatelessWidget {
  const _RunningIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.directions_run_rounded);
}

class _GymIcon extends StatelessWidget {
  const _GymIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.fitness_center_rounded);
}

class _YogaIcon extends StatelessWidget {
  const _YogaIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.self_improvement_rounded);
}

class _SwimIcon extends StatelessWidget {
  const _SwimIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.pool_rounded);
}

class _BikeIcon extends StatelessWidget {
  const _BikeIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.directions_bike_rounded);
}

class _PlusIcon extends StatelessWidget {
  const _PlusIcon();
  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.add_rounded);
}