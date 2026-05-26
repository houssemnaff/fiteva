// ─────────────────────────────────────────────
// pregnancy_checklist_repository.dart
// ─────────────────────────────────────────────

class ChecklistTask {
  final String id;
  final String title;
  final String description;
  final String emoji;

  const ChecklistTask({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class PregnancyChecklistRepository {
  PregnancyChecklistRepository._();

  static List<ChecklistTask> forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return _data[clamped] ?? _data[_nearest(clamped)]!;
  }

  static int _nearest(int week) {
    return _data.keys.reduce((a, b) =>
        (a - week).abs() < (b - week).abs() ? a : b);
  }

  static const Map<int, List<ChecklistTask>> _data = {
    1: [
      ChecklistTask(id: '1-1', emoji: '💊', title: 'Start prenatal vitamins',
          description: 'Take 400 µg folic acid daily to support neural tube development.'),
      ChecklistTask(id: '1-2', emoji: '🚭', title: 'Eliminate alcohol & smoking',
          description: 'Both are linked to developmental risks — now is the time to stop.'),
      ChecklistTask(id: '1-3', emoji: '☕', title: 'Reduce caffeine',
          description: 'Keep intake under 200 mg per day (about one cup of coffee).'),
    ],
    4: [
      ChecklistTask(id: '4-1', emoji: '🧪', title: 'Take a home pregnancy test',
          description: 'hCG is detectable now. Use first-morning urine for best accuracy.'),
      ChecklistTask(id: '4-2', emoji: '📋', title: 'Book your first prenatal appointment',
          description: 'Most providers schedule the first visit between weeks 8–10.'),
      ChecklistTask(id: '4-3', emoji: '💊', title: 'Continue prenatal vitamins',
          description: 'Folic acid remains critical through the first trimester.'),
    ],
    6: [
      ChecklistTask(id: '6-1', emoji: '🏥', title: 'Confirm OB or midwife',
          description: 'Choose your care provider and confirm your first appointment.'),
      ChecklistTask(id: '6-2', emoji: '🥗', title: 'Review diet & food safety',
          description: 'Avoid raw fish, unpasteurised cheese, deli meats, and undercooked eggs.'),
      ChecklistTask(id: '6-3', emoji: '🧘', title: 'Start gentle movement',
          description: 'Walking or prenatal yoga supports mood and circulation.'),
      ChecklistTask(id: '6-4', emoji: '💤', title: 'Prioritise sleep',
          description: 'Fatigue is intense now. Aim for 8–9 hours and rest without guilt.'),
    ],
    8: [
      ChecklistTask(id: '8-1', emoji: '🩺', title: 'First prenatal visit',
          description: 'Blood work, urine test, dating ultrasound, and health history review.'),
      ChecklistTask(id: '8-2', emoji: '📸', title: 'First ultrasound',
          description: 'Confirms gestational age and checks for a heartbeat.'),
      ChecklistTask(id: '8-3', emoji: '🤢', title: 'Manage morning sickness',
          description: 'Small frequent meals, ginger, and Vitamin B6 can help significantly.'),
    ],
    10: [
      ChecklistTask(id: '10-1', emoji: '🧬', title: 'Discuss genetic screening options',
          description: 'NIPT, nuchal translucency scan, and carrier testing — ask your provider.'),
      ChecklistTask(id: '10-2', emoji: '📢', title: 'Consider sharing your news',
          description: 'Miscarriage risk drops sharply after week 10 — many families share now.'),
      ChecklistTask(id: '10-3', emoji: '🦷', title: 'Schedule a dental check',
          description: 'Hormones increase risk of gum disease. Dental care is safe in pregnancy.'),
    ],
    12: [
      ChecklistTask(id: '12-1', emoji: '📋', title: 'First trimester screening',
          description: 'Blood tests + nuchal translucency ultrasound to assess chromosomal health.'),
      ChecklistTask(id: '12-2', emoji: '🏢', title: 'Notify your employer',
          description: 'Review maternity leave policies and start planning your handover.'),
      ChecklistTask(id: '12-3', emoji: '📖', title: 'Start a pregnancy journal',
          description: 'Document feelings, milestones, and symptoms to look back on later.'),
      ChecklistTask(id: '12-4', emoji: '🎉', title: 'Celebrate the first trimester',
          description: 'You\'ve grown a complete set of organs. That deserves acknowledgment.'),
    ],
    16: [
      ChecklistTask(id: '16-1', emoji: '🩸', title: 'Quad screen blood test',
          description: 'Optional screening for chromosomal conditions — discuss with your provider.'),
      ChecklistTask(id: '16-2', emoji: '👗', title: 'Invest in maternity clothes',
          description: 'Your waistline will keep expanding — comfortable, supportive fits matter.'),
      ChecklistTask(id: '16-3', emoji: '🛏️', title: 'Begin sleeping on your side',
          description: 'Left-side sleeping improves blood flow to the placenta and kidneys.'),
      ChecklistTask(id: '16-4', emoji: '💬', title: 'Talk to your baby',
          description: 'She can start perceiving sound soon. Your voice is already her favourite.'),
    ],
    20: [
      ChecklistTask(id: '20-1', emoji: '🔬', title: 'Anatomy scan (20-week ultrasound)',
          description: 'Detailed check of all organs, limbs, placenta position, and amniotic fluid.'),
      ChecklistTask(id: '20-2', emoji: '🎀', title: 'Learn the sex (if you wish)',
          description: 'The anatomy scan can usually reveal the sex — your choice to find out.'),
      ChecklistTask(id: '20-3', emoji: '🏋️', title: 'Continue regular gentle exercise',
          description: 'Prenatal yoga, swimming, and walking are all excellent choices.'),
      ChecklistTask(id: '20-4', emoji: '🎊', title: 'Halfway milestone',
          description: 'Pause and celebrate — you are exactly halfway through this journey.'),
    ],
    24: [
      ChecklistTask(id: '24-1', emoji: '🍬', title: 'Glucose tolerance test',
          description: 'Screens for gestational diabetes. Fast for 8–12 hours beforehand.'),
      ChecklistTask(id: '24-2', emoji: '💉', title: 'Check iron levels',
          description: 'Anaemia is common now. Iron-rich foods and possible supplements help.'),
      ChecklistTask(id: '24-3', emoji: '🛋️', title: 'Start planning the nursery',
          description: 'Begin researching baby gear — crib safety standards, car seat types, etc.'),
      ChecklistTask(id: '24-4', emoji: '📚', title: 'Enrol in a birth prep class',
          description: 'Classes fill up early. Book now for weeks 32–36.'),
    ],
    28: [
      ChecklistTask(id: '28-1', emoji: '📊', title: 'Begin kick counts',
          description: 'Track fetal movements daily — 10 movements within 2 hours is reassuring.'),
      ChecklistTask(id: '28-2', emoji: '💉', title: 'Tdap vaccine',
          description: 'Protects your baby from whooping cough before they can be vaccinated.'),
      ChecklistTask(id: '28-3', emoji: '🩺', title: 'Rhesus factor check',
          description: 'If Rh-negative, you\'ll receive an anti-D injection around now.'),
      ChecklistTask(id: '28-4', emoji: '🧳', title: 'Start packing hospital bag',
          description: 'Documents, comfort items, baby outfit, snacks — begin the list now.'),
    ],
    32: [
      ChecklistTask(id: '32-1', emoji: '🧳', title: 'Finish hospital bag',
          description: 'Have it ready by week 36. Include your birth plan, ID, and insurance docs.'),
      ChecklistTask(id: '32-2', emoji: '🚗', title: 'Install the car seat',
          description: 'Get it professionally checked — most installations have errors.'),
      ChecklistTask(id: '32-3', emoji: '📝', title: 'Write your birth plan',
          description: 'Pain management preferences, who\'s in the room, delayed cord clamping, etc.'),
      ChecklistTask(id: '32-4', emoji: '🍼', title: 'Attend breastfeeding class',
          description: 'Preparation significantly improves breastfeeding success and confidence.'),
    ],
    36: [
      ChecklistTask(id: '36-1', emoji: '🧬', title: 'Group B Strep (GBS) swab',
          description: 'Routine vaginal/rectal swab. If positive, antibiotics are given in labour.'),
      ChecklistTask(id: '36-2', emoji: '🏥', title: 'Hospital tour',
          description: 'Know where to park, where to enter, and where to go when labour starts.'),
      ChecklistTask(id: '36-3', emoji: '📞', title: 'Set up emergency contacts',
          description: 'Know exactly who to call and have them ready on your lock screen.'),
      ChecklistTask(id: '36-4', emoji: '🛁', title: 'Prepare home comfort kit',
          description: 'Heat pack, TENS machine, birthing ball — whatever is in your birth plan.'),
    ],
    38: [
      ChecklistTask(id: '38-1', emoji: '⏱️', title: 'Learn to time contractions',
          description: 'Regular, intensifying contractions less than 10 min apart = call your team.'),
      ChecklistTask(id: '38-2', emoji: '🤱', title: 'Prepare for feeding',
          description: 'Nursing pads, lanolin cream, and a comfortable feeding chair or cushion.'),
      ChecklistTask(id: '38-3', emoji: '🌙', title: 'Rest as much as possible',
          description: 'Sleep when you can. Your body is conserving energy for labour.'),
    ],
    40: [
      ChecklistTask(id: '40-1', emoji: '📞', title: 'Keep your care team close',
          description: 'Check in with your provider if you go past your due date.'),
      ChecklistTask(id: '40-2', emoji: '🫂', title: 'Accept support',
          description: 'Let people help with meals, errands, and company. You deserve it.'),
      ChecklistTask(id: '40-3', emoji: '✨', title: 'Trust your body',
          description: 'Forty weeks of extraordinary work. You and your baby are ready.'),
    ],
  };
}