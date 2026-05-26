import 'package:flutter/material.dart';

class PregnancyWeekData {
  final int week;
  final String babySize;
  final double lengthCm;
  final double weightG;
  final String description;
  final String poeticLine;
  final String milestone;
  final int trimester;
  final int fetalHeartRateBpm;

  const PregnancyWeekData({
    required this.week,
    required this.babySize,
    required this.lengthCm,
    required this.weightG,
    required this.description,
    required this.poeticLine,
    required this.milestone,
    required this.trimester,
    required this.fetalHeartRateBpm,
  });

  String get weightLabel {
    if (weightG < 1000) return '${weightG.round()} g';
    return '${(weightG / 1000).toStringAsFixed(1)} kg';
  }

  String get sizeLabel => '${lengthCm.toStringAsFixed(1)} cm · $weightLabel';
Color get threadColor {
  if (week <= 13) {
    final t = (week - 1) / 12.0;

    return Color.lerp(
      const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  } else if (week <= 27) {
    final t = (week - 14) / 13.0;

    return Color.lerp(
      const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  } else {
    final t = (week - 28) / 12.0;

    return Color.lerp(
        const Color(0xFF1C4D30), // deep primary green
      const Color(0xFF4F7D66), // balanced forest green
      t,
    )!;
  }
}

  Color get glowColor => threadColor.withOpacity(0.4);
}

class PregnancyDataRepository {
  static const List<PregnancyWeekData> weeks = [
    PregnancyWeekData(
      week: 1, babySize: 'Poppy seed', lengthCm: 0.1, weightG: 0,
      description: 'The journey begins. A single cell holds the blueprint of an entire person.',
      poeticLine: '"From one, everything."',
      milestone: 'Conception',
      trimester: 1, fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 2, babySize: 'Sesame seed', lengthCm: 0.2, weightG: 0,
      description: 'The fertilised egg is travelling toward the uterus, dividing as it goes.',
      poeticLine: '"Dividing to multiply."',
      milestone: 'Implantation begins',
      trimester: 1, fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 3, babySize: 'Grain of rice', lengthCm: 0.15, weightG: 0,
      description: 'Implantation is complete. The placenta is beginning to form.',
      poeticLine: '"She has found her home."',
      milestone: 'Implantation complete',
      trimester: 1, fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 4, babySize: 'Poppy seed', lengthCm: 0.4, weightG: 0,
      description: 'The embryo is now visible. Three distinct layers are forming — brain, heart, bones.',
      poeticLine: '"Three layers of becoming."',
      milestone: 'Neural tube forming',
      trimester: 1, fetalHeartRateBpm: 0,
    ),
    PregnancyWeekData(
      week: 5, babySize: 'Apple seed', lengthCm: 0.5, weightG: 0,
      description: 'The heart is forming and may have begun to beat. Tiny arm and leg buds appear.',
      poeticLine: '"The first beat. Everything starts here."',
      milestone: 'Heart begins forming',
      trimester: 1, fetalHeartRateBpm: 80,
    ),
    PregnancyWeekData(
      week: 6, babySize: 'Blueberry', lengthCm: 0.6, weightG: 0,
      description: 'The heart is beating for the first time. Two tiny hands are beginning to form.',
      poeticLine: '"A heartbeat the size of a whisper."',
      milestone: 'Heartbeat detectable',
      trimester: 1, fetalHeartRateBpm: 110,
    ),
    PregnancyWeekData(
      week: 7, babySize: 'Raspberry', lengthCm: 1.3, weightG: 1,
      description: 'Tiny fingers are starting to form. The brain is growing rapidly.',
      poeticLine: '"Hands that will one day hold yours."',
      milestone: 'Fingers forming',
      trimester: 1, fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 8, babySize: 'Kidney bean', lengthCm: 1.6, weightG: 1,
      description: 'She is now officially a fetus. Every essential organ has started forming.',
      poeticLine: '"Unmistakably a beginning."',
      milestone: 'Embryo → fetus',
      trimester: 1, fetalHeartRateBpm: 150,
    ),
    PregnancyWeekData(
      week: 9, babySize: 'Cherry', lengthCm: 2.3, weightG: 2,
      description: 'Tiny muscles are forming. She can make small movements — though you won\'t feel them yet.',
      poeticLine: '"Moving in secret."',
      milestone: 'First movements',
      trimester: 1, fetalHeartRateBpm: 165,
    ),
    PregnancyWeekData(
      week: 10, babySize: 'Strawberry', lengthCm: 3.1, weightG: 4,
      description: 'All organs are formed. Tiny fingers and toes are clearly visible and separating.',
      poeticLine: '"Ten fingers. Ten possibilities."',
      milestone: 'All organs formed',
      trimester: 1, fetalHeartRateBpm: 170,
    ),
    PregnancyWeekData(
      week: 11, babySize: 'Lime', lengthCm: 4.1, weightG: 7,
      description: 'Her bones are beginning to harden. Tooth buds are forming beneath the gums.',
      poeticLine: '"Growing stronger, quietly."',
      milestone: 'Bones hardening',
      trimester: 1, fetalHeartRateBpm: 165,
    ),
    PregnancyWeekData(
      week: 12, babySize: 'Plum', lengthCm: 5.4, weightG: 14,
      description: 'Reflexes are developing. She can open and close her fists.',
      poeticLine: '"The first chapter, nearly complete."',
      milestone: 'Reflexes developing',
      trimester: 1, fetalHeartRateBpm: 160,
    ),
    PregnancyWeekData(
      week: 13, babySize: 'Peach', lengthCm: 7.4, weightG: 23,
      description: 'Fingerprints are forming — completely unique to her. Vocal cords are developing.',
      poeticLine: '"Already, irreplaceable."',
      milestone: 'Fingerprints forming',
      trimester: 1, fetalHeartRateBpm: 155,
    ),
    PregnancyWeekData(
      week: 14, babySize: 'Lemon', lengthCm: 8.7, weightG: 43,
      description: 'She can squint, frown, and grimace. Lanugo — fine downy hair — covers her skin.',
      poeticLine: '"The second chapter begins."',
      milestone: 'First trimester complete',
      trimester: 2, fetalHeartRateBpm: 150,
    ),
    PregnancyWeekData(
      week: 15, babySize: 'Apple', lengthCm: 10.1, weightG: 70,
      description: 'She can sense light through her closed eyelids. Bones are visible on ultrasound.',
      poeticLine: '"Light reaches her now."',
      milestone: 'Light sensitivity',
      trimester: 2, fetalHeartRateBpm: 148,
    ),
    PregnancyWeekData(
      week: 16, babySize: 'Avocado', lengthCm: 11.6, weightG: 100,
      description: 'Her legs are now longer than her arms. She\'s beginning to hear muffled sounds.',
      poeticLine: '"She is listening."',
      milestone: 'Hearing begins',
      trimester: 2, fetalHeartRateBpm: 145,
    ),
    PregnancyWeekData(
      week: 17, babySize: 'Pear', lengthCm: 13.0, weightG: 140,
      description: 'Fat deposits are forming — they\'ll help regulate her body temperature after birth.',
      poeticLine: '"Preparing for the world."',
      milestone: 'Fat deposits forming',
      trimester: 2, fetalHeartRateBpm: 143,
    ),
    PregnancyWeekData(
      week: 18, babySize: 'Sweet potato', lengthCm: 14.2, weightG: 190,
      description: 'Yawning, hiccupping, and swallowing. You may feel flutters for the first time.',
      poeticLine: '"Her first language: movement."',
      milestone: 'Quickening possible',
      trimester: 2, fetalHeartRateBpm: 142,
    ),
    PregnancyWeekData(
      week: 19, babySize: 'Mango', lengthCm: 15.3, weightG: 240,
      description: 'Vernix — a waxy coating — protects her skin in the amniotic fluid.',
      poeticLine: '"Shielded and safe."',
      milestone: 'Vernix forming',
      trimester: 2, fetalHeartRateBpm: 140,
    ),
    PregnancyWeekData(
      week: 20, babySize: 'Banana', lengthCm: 25.0, weightG: 300,
      description: 'Halfway there. She sleeps and wakes on her own rhythm. You feel her kicks now.',
      poeticLine: '"She dances when you laugh."',
      milestone: 'Halfway milestone',
      trimester: 2, fetalHeartRateBpm: 140,
    ),
    PregnancyWeekData(
      week: 21, babySize: 'Carrot', lengthCm: 26.7, weightG: 360,
      description: 'She can taste the amniotic fluid — and through it, what you eat.',
      poeticLine: '"Sharing your table already."',
      milestone: 'Taste sense active',
      trimester: 2, fetalHeartRateBpm: 138,
    ),
    PregnancyWeekData(
      week: 22, babySize: 'Papaya', lengthCm: 27.8, weightG: 430,
      description: 'Her eyebrows and lashes are growing. Lips are becoming more distinct.',
      poeticLine: '"The face she will wear forever."',
      milestone: 'Facial features defined',
      trimester: 2, fetalHeartRateBpm: 138,
    ),
    PregnancyWeekData(
      week: 23, babySize: 'Grapefruit', lengthCm: 28.9, weightG: 501,
      description: 'She responds to your voice with movement. Her skin is still translucent.',
      poeticLine: '"Your voice is her lullaby."',
      milestone: 'Voice recognition',
      trimester: 2, fetalHeartRateBpm: 137,
    ),
    PregnancyWeekData(
      week: 24, babySize: 'Ear of corn', lengthCm: 30.0, weightG: 600,
      description: 'Baby\'s face is fully formed. Taste buds are developing — she can sense what you eat.',
      poeticLine: '"She can hear your heartbeat now."',
      milestone: 'Viability milestone',
      trimester: 2, fetalHeartRateBpm: 136,
    ),
    PregnancyWeekData(
      week: 25, babySize: 'Rutabaga', lengthCm: 34.6, weightG: 660,
      description: 'Her hands are fully developed. She may suck her thumb.',
      poeticLine: '"Comfort found within."',
      milestone: 'Thumb sucking',
      trimester: 2, fetalHeartRateBpm: 135,
    ),
    PregnancyWeekData(
      week: 26, babySize: 'Scallion', lengthCm: 35.6, weightG: 760,
      description: 'Her eyes begin to open for the first time. She can blink.',
      poeticLine: '"The first glimpse of light."',
      milestone: 'Eyes open',
      trimester: 2, fetalHeartRateBpm: 134,
    ),
    PregnancyWeekData(
      week: 27, babySize: 'Cauliflower', lengthCm: 36.6, weightG: 875,
      description: 'Brain activity is surging. She dreams — rapid eye movements are visible.',
      poeticLine: '"She already knows how to dream."',
      milestone: 'REM sleep begins',
      trimester: 2, fetalHeartRateBpm: 133,
    ),
    PregnancyWeekData(
      week: 28, babySize: 'Eggplant', lengthCm: 37.6, weightG: 1005,
      description: 'She can open her eyes and see light filtering through. Brain activity increases rapidly.',
      poeticLine: '"The final chapter. Almost home."',
      milestone: 'Third trimester begins',
      trimester: 3, fetalHeartRateBpm: 132,
    ),
    PregnancyWeekData(
      week: 29, babySize: 'Butternut squash', lengthCm: 38.6, weightG: 1153,
      description: 'She is gaining weight rapidly. Muscles and lungs are maturing.',
      poeticLine: '"Growing into herself."',
      milestone: 'Rapid weight gain',
      trimester: 3, fetalHeartRateBpm: 131,
    ),
    PregnancyWeekData(
      week: 30, babySize: 'Cabbage', lengthCm: 39.9, weightG: 1319,
      description: 'Her brain is forming the grooves and indentations that will increase its surface area.',
      poeticLine: '"A mind taking shape."',
      milestone: 'Brain development surge',
      trimester: 3, fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 31, babySize: 'Coconut', lengthCm: 41.1, weightG: 1502,
      description: 'She can turn her head from side to side. Her irises react to light.',
      poeticLine: '"Curious already."',
      milestone: 'Iris response to light',
      trimester: 3, fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 32, babySize: 'Squash', lengthCm: 42.4, weightG: 1702,
      description: 'She\'s practicing breathing. Tiny toenails are fully formed.',
      poeticLine: '"Strong and ready."',
      milestone: 'Breathing practice',
      trimester: 3, fetalHeartRateBpm: 130,
    ),
    PregnancyWeekData(
      week: 33, babySize: 'Pineapple', lengthCm: 43.7, weightG: 1918,
      description: 'Her bones are hardening — except the skull, which stays soft for birth.',
      poeticLine: '"Wisdom in her design."',
      milestone: 'Bone hardening',
      trimester: 3, fetalHeartRateBpm: 129,
    ),
    PregnancyWeekData(
      week: 34, babySize: 'Cantaloupe', lengthCm: 45.0, weightG: 2146,
      description: 'Her central nervous system is maturing rapidly. She recognises your voice.',
      poeticLine: '"She knows you by sound."',
      milestone: 'CNS maturation',
      trimester: 3, fetalHeartRateBpm: 129,
    ),
    PregnancyWeekData(
      week: 35, babySize: 'Honeydew melon', lengthCm: 46.2, weightG: 2383,
      description: 'Her kidneys are fully developed. She\'s running out of room to stretch.',
      poeticLine: '"Almost too big for this world within."',
      milestone: 'Kidneys complete',
      trimester: 3, fetalHeartRateBpm: 128,
    ),
    PregnancyWeekData(
      week: 36, babySize: 'Papaya', lengthCm: 47.4, weightG: 2622,
      description: 'She\'s gaining half a pound a week. Lanugo hair is mostly shed.',
      poeticLine: '"Any day now."',
      milestone: 'Near full term',
      trimester: 3, fetalHeartRateBpm: 128,
    ),
    PregnancyWeekData(
      week: 37, babySize: 'Winter melon', lengthCm: 48.6, weightG: 2859,
      description: 'She is considered early term. Her head may be engaged in the pelvis.',
      poeticLine: '"Poised at the threshold."',
      milestone: 'Early term',
      trimester: 3, fetalHeartRateBpm: 127,
    ),
    PregnancyWeekData(
      week: 38, babySize: 'Leek', lengthCm: 49.8, weightG: 3083,
      description: 'Her grip is strong. She\'s producing hormones that signal the start of labour.',
      poeticLine: '"She is ready before you know it."',
      milestone: 'Labour hormones active',
      trimester: 3, fetalHeartRateBpm: 127,
    ),
    PregnancyWeekData(
      week: 39, babySize: 'Watermelon', lengthCm: 50.7, weightG: 3288,
      description: 'Full term. Her brain and lungs are still developing — every day counts.',
      poeticLine: '"Patience is its own kind of love."',
      milestone: 'Full term',
      trimester: 3, fetalHeartRateBpm: 126,
    ),
    PregnancyWeekData(
      week: 40, babySize: 'Small pumpkin', lengthCm: 51.2, weightG: 3462,
      description: 'She is ready. You are ready. The thread has woven itself complete.',
      poeticLine: '"The thread is complete."',
      milestone: 'Due date',
      trimester: 3, fetalHeartRateBpm: 126,
    ),
  ];

  static PregnancyWeekData forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return weeks[clamped - 1];
  }
}