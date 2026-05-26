// ─────────────────────────────────────────────
// pregnancy_insight_repository.dart
// ─────────────────────────────────────────────

import 'daily_insight_model.dart';

class PregnancyInsightRepository {
  PregnancyInsightRepository._();

  static DailyInsight forWeek(int week) {
    final clamped = week.clamp(1, 40);
    return _insights.firstWhere(
      (i) => i.week == clamped,
      orElse: () => _insights.last,
    );
  }

  static const List<DailyInsight> _insights = [
    // ── WEEK 1 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 1,
      title: 'The Journey Begins',
      babyInsight:
          'At week 1, pregnancy is counted from the first day of your last '
          'menstrual period. Conception hasn\'t happened yet — your body is '
          'quietly preparing, releasing hormones that will soon orchestrate '
          'an extraordinary transformation.',
      momTip:
          'Start taking a prenatal vitamin with at least 400 µg of folic acid '
          'every day. Folic acid taken before conception dramatically reduces '
          'the risk of neural-tube defects.',
      poeticLine: 'Before the first word, there is a breath — and in that '
          'breath, everything.',
    ),

    // ── WEEK 2 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 2,
      title: 'The Spark of Ovulation',
      babyInsight:
          'Your body is approaching ovulation. The egg that may become your '
          'baby is maturing inside a follicle about the size of a blueberry. '
          'In just days, it will be released on its extraordinary journey.',
      momTip:
          'If you haven\'t already, now is a great time to cut back on '
          'caffeine and eliminate alcohol entirely. Your body is about to '
          'become a sanctuary.',
      poeticLine: 'Every ocean begins with a single, perfect drop.',
    ),

    // ── WEEK 3 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 3,
      title: 'A New Life Ignites',
      babyInsight:
          'Fertilization has occurred! A single sperm has united with your '
          'egg, creating a zygote with a completely unique set of DNA. In '
          'these first 24 hours, the blueprint for an entire person — eye '
          'color, temperament, talents — is already written.',
      momTip:
          'Avoid hot tubs and saunas this trimester. Elevated core body '
          'temperature in early pregnancy can affect fetal development. '
          'Warm baths are perfectly fine.',
      poeticLine: 'From two, one. From nothing, everything.',
    ),

    // ── WEEK 4 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 4,
      title: 'Implantation — You Are Home',
      babyInsight:
          'Your embryo, now a hollow ball of about 100 cells called a '
          'blastocyst, is burrowing into the lush lining of your uterus. '
          'This is implantation — the moment your baby officially calls '
          'your body home.',
      momTip:
          'A home pregnancy test can now detect the hCG hormone. Take it '
          'with first-morning urine for the most accurate result. Whatever '
          'the result, breathe — you are exactly where you need to be.',
      poeticLine: 'She found the softest place and stayed.',
    ),

    // ── WEEK 5 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 5,
      title: 'The Heartbeat Prepares',
      babyInsight:
          'Your embryo is about the size of an apple seed — 1.5 mm — yet '
          'three distinct layers are already forming: the ectoderm (skin, '
          'brain), mesoderm (heart, muscles), and endoderm (lungs, gut). '
          'A tiny tube that will become the heart is beginning to pulse.',
      momTip:
          'Nausea may begin this week. Small, frequent meals and bland '
          'snacks like crackers keep blood sugar stable. Ginger — in tea, '
          'candy, or capsules — is a well-studied natural remedy.',
      poeticLine: 'Somewhere between hope and certainty, a heart learns to '
          'beat.',
    ),

    // ── WEEK 6 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 6,
      title: 'A Heart That Flutters',
      babyInsight:
          'Your baby\'s heart is now beating at about 110 beats per minute — '
          'twice yours. Tiny arm and leg buds are emerging. The neural tube '
          'is closing, forming the foundation of the brain and spinal cord. '
          'It\'s the size of a lentil, but endlessly complex.',
      momTip:
          'Fatigue can feel overwhelming right now — that\'s progesterone at '
          'work. Honor the tiredness. Sleep when you can, and don\'t '
          'apologize for it.',
      poeticLine: 'A lentil-sized universe, already beating its own rhythm.',
    ),

    // ── WEEK 7 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 7,
      title: 'Hands Are Forming',
      babyInsight:
          'Tiny paddle-shaped hand plates are visible, and the brain is '
          'growing so fast it\'s beginning to fold. Your baby is about '
          '10 mm — the size of a blueberry — and has doubled in size since '
          'last week. The face is beginning to take shape with dark spots '
          'where eyes will be.',
      momTip:
          'If you haven\'t booked your first prenatal appointment, do it '
          'this week. Most providers schedule the first visit between '
          'weeks 8 and 10. Early care is one of the greatest gifts '
          'you can give.',
      poeticLine: 'The first sketch of hands that will one day hold the '
          'whole world.',
    ),

    // ── WEEK 8 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 8,
      title: 'Fingers Begin to Form',
      babyInsight:
          'Your baby — now officially called a fetus — is about the size '
          'of a raspberry. Webbed fingers and toes are forming, eyelids '
          'are developing, and the tiny nose is taking shape. The '
          'intestines are growing so rapidly they temporarily extend into '
          'the umbilical cord.',
      momTip:
          'This is often the peak of morning sickness. Vitamin B6 (10–25 mg '
          'three times a day) has strong evidence for reducing nausea. '
          'Talk to your provider before starting any supplement.',
      poeticLine: 'What once was sea is now growing fingers to touch the '
          'shore.',
    ),

    // ── WEEK 9 ──────────────────────────────────────────────────────────
    DailyInsight(
      week: 9,
      title: 'Every Organ Is Present',
      babyInsight:
          'All essential organs are now in place — heart, brain, lungs, '
          'kidneys — waiting to mature. Your baby can flex tiny limbs and '
          'is about the size of a grape. The tail-like structure has '
          'completely disappeared, and your baby looks undeniably human.',
      momTip:
          'Your uterus has grown from the size of a pear to an orange. '
          'You may notice your waistband feeling snug. This is not fat — '
          'it\'s life, expanding to make room.',
      poeticLine: 'All the instruments are in place. Soon, the music '
          'will begin.',
    ),

    // ── WEEK 10 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 10,
      title: 'Tiny Movements Begin',
      babyInsight:
          'Your baby is now making small, spontaneous movements — though '
          'you won\'t feel them yet. Fingernails and hair follicles are '
          'forming. At about 3 cm, the size of a strawberry, all the '
          'foundational structures are complete. The next 30 weeks are '
          'about growth and refinement.',
      momTip:
          'The risk of miscarriage drops significantly after week 10. '
          'Many parents choose this week to begin sharing their news '
          'with loved ones. Share it in whatever way feels right for you.',
      poeticLine: 'She dances already, in a room too small to see.',
    ),

    // ── WEEK 11 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 11,
      title: 'Hiccups in the Deep',
      babyInsight:
          'Your baby is practicing breathing movements, and you may '
          'eventually see hiccups on an ultrasound. The head is still '
          'about half the body\'s length, housing a brain that\'s '
          'developing at an astonishing rate. Tooth buds are appearing '
          'beneath the gums.',
      momTip:
          'Skin changes are common now — some women glow, others experience '
          'breakouts. Both are caused by increased blood flow and hormones. '
          'Use gentle, fragrance-free skincare and stay hydrated.',
      poeticLine: 'Even in darkness, she finds her own small rhythms.',
    ),

    // ── WEEK 12 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 12,
      title: 'The First Trimester Triumph',
      babyInsight:
          'You\'ve reached the end of the first trimester — a milestone '
          'worth honoring. Your baby is about 6 cm and 14 grams, with '
          'reflexes developing rapidly. The digestive system is practicing '
          'peristalsis. The face is fully formed and unmistakably '
          'beautiful.',
      momTip:
          'Many expecting mothers report a notable lift in energy and mood '
          'around week 12. The worst of nausea often fades. Celebrate '
          'this shift — you\'ve done something remarkable.',
      poeticLine: 'Three months of becoming. Look how far you\'ve both '
          'already come.',
    ),

    // ── WEEK 13 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 13,
      title: 'Welcome to the Second Trimester',
      babyInsight:
          'Your baby is now about the size of a peach — 7 cm and growing '
          'fast. Fingerprints are forming on those tiny fingertips, '
          'as unique as any that have ever existed. Vocal cords are '
          'developing. The placenta is now fully functioning, taking '
          'over hormone production.',
      momTip:
          'Second trimester is often the most comfortable. Use this energy '
          'window to set up your birth plan, attend a prenatal class, '
          'or simply rest and enjoy. This is your golden period.',
      poeticLine: 'A peach-sized philosopher, already leaving '
          'her mark on the world.',
    ),

    // ── WEEK 14 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 14,
      title: 'Expressions of the Unborn',
      babyInsight:
          'Your baby can now squint, frown, and make sucking movements. '
          'The liver is producing bile; the spleen is making red blood '
          'cells. At about 9 cm, she\'s the length of your clenched fist — '
          'a tiny being already practicing the full range of human emotion.',
      momTip:
          'Round ligament pain — sharp, brief twinges in the lower abdomen '
          '— is very common now as your uterus grows. Slow down when '
          'changing positions, and rest when it flares. It\'s normal, '
          'and it passes.',
      poeticLine: 'She is practicing joy before she even knows the word.',
    ),

    // ── WEEK 15 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 15,
      title: 'Bones Growing Strong',
      babyInsight:
          'Your baby\'s bones are hardening, and her skeleton is becoming '
          'visible on ultrasound. Fine lanugo hair covers the body for '
          'warmth. The ears are almost in their final position — she may '
          'be beginning to hear the low rumble of your voice.',
      momTip:
          'Calcium is critical now. Aim for 1,000 mg daily through dairy, '
          'fortified plant milks, leafy greens, or almonds. If your baby '
          'doesn\'t get enough from your diet, she\'ll take it from '
          'your bones.',
      poeticLine: 'Your voice is the first song she will ever know.',
    ),

    // ── WEEK 16 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 16,
      title: 'First Flutters',
      babyInsight:
          'This week, many mothers feel the first fetal movements — a '
          'sensation like butterflies, bubbles, or a gentle tapping. '
          'Your baby is about 11 cm, the size of an avocado, and '
          'increasingly coordinated. The eyes are sensitive to light '
          'even through closed lids.',
      momTip:
          'If this isn\'t your first pregnancy, you may have felt movement '
          'already. First-time mothers typically feel it between weeks '
          '18–20. Every flutter is a hello — answer it with your hand '
          'on your belly.',
      poeticLine: 'The first knock on the door of the world — '
          'so gentle, so certain.',
    ),

    // ── WEEK 17 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 17,
      title: 'Fat Builds, Dreams Begin',
      babyInsight:
          'Your baby is starting to accumulate fat — the same fat that '
          'will keep her warm and provide energy after birth. The sweat '
          'glands are forming. She weighs about 140 grams — as much '
          'as a turnip — and sleep cycles are beginning, meaning '
          'she may now be dreaming.',
      momTip:
          'Your blood volume has increased by about 50%. This can cause '
          'occasional dizziness — especially when standing quickly. '
          'Rise slowly, stay hydrated, and don\'t skip meals.',
      poeticLine: 'In the warmth of you, she dreams of light she hasn\'t '
          'seen yet.',
    ),

    // ── WEEK 18 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 18,
      title: 'Anatomy Scan Week',
      babyInsight:
          'The anatomy scan is typically scheduled around now — one of the '
          'most detailed windows into your baby\'s world. At 14 cm, she '
          'has a fully formed face with yawning, grimacing, and smiling. '
          'The nervous system is rapidly maturing.',
      momTip:
          'Prepare emotionally for the anatomy scan. It\'s an exciting '
          'appointment, but it can also surface unexpected news. '
          'Bring a support person, write down your questions in advance, '
          'and trust your care team.',
      poeticLine: 'The first portrait, taken in sound and shadow.',
    ),

    // ── WEEK 19 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 19,
      title: 'Senses Coming Alive',
      babyInsight:
          'Your baby\'s brain is designating specialized areas for smell, '
          'taste, hearing, vision, and touch. She can hear your heartbeat, '
          'your breathing, and the outside world. Vernix caseosa — a '
          'protective waxy coating — is forming on her skin.',
      momTip:
          'Talk to your baby. Read aloud, play music, narrate your day. '
          'Research shows that babies recognize familiar voices at birth '
          'and are calmed by them. Your voice is already her favorite sound.',
      poeticLine: 'She is learning the world through every sound you make.',
    ),

    // ── WEEK 20 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 20,
      title: 'Halfway There — Celebrate',
      babyInsight:
          'You\'re at the halfway point. Your baby weighs about 300 grams '
          'and measures 25 cm from head to toe — the length of a banana. '
          'She is swallowing amniotic fluid (good practice for feeding), '
          'and her movements are becoming stronger and more purposeful.',
      momTip:
          'This is a meaningful milestone. Pause and acknowledge it. '
          'Twenty weeks of growing a human — of nausea, exhaustion, hope, '
          'and wonder. You deserve to mark this moment with something '
          'that feels celebratory to you.',
      poeticLine: 'Halfway to hello. Already, you are each other\'s '
          'whole world.',
    ),

    // ── WEEK 21 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 21,
      title: 'Kicks You Can Share',
      babyInsight:
          'Movements are now strong enough for a partner to feel from '
          'outside the belly. Your baby has a sleep-wake cycle and '
          'is most active when you\'re still — often at night. '
          'Taste buds are fully developed; she can taste the flavors '
          'in your amniotic fluid.',
      momTip:
          'Leg cramps at night are extremely common in the second trimester. '
          'Stretching your calves before bed, staying well-hydrated, '
          'and increasing magnesium-rich foods (spinach, nuts, seeds) '
          'can provide real relief.',
      poeticLine: 'She kicks at the walls of her small world, already '
          'impatient to grow.',
    ),

    // ── WEEK 22 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 22,
      title: 'A Face Worth Dreaming Of',
      babyInsight:
          'Your baby\'s face is fully formed — lips, eyebrows, eyelids '
          'all in place. The eyes are still fused shut, but she can '
          'perceive light. At about 27 cm and 430 grams, she has the '
          'proportions of a newborn, just much smaller.',
      momTip:
          'Swelling in feet and ankles (edema) often begins around now. '
          'Elevate your feet when resting, choose comfortable wide shoes, '
          'and avoid standing for long periods. Sudden, severe swelling '
          'in the face or hands warrants immediate medical attention.',
      poeticLine: 'A face that has never seen the sun, already '
          'luminous with life.',
    ),

    // ── WEEK 23 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 23,
      title: 'Listening to the World',
      babyInsight:
          'Your baby can now hear sounds from outside your body — '
          'music, voices, even traffic. Loud sounds may startle her. '
          'The pancreas is maturing and beginning to produce insulin. '
          'She weighs just over 500 grams — more than a pound.',
      momTip:
          'Heartburn often intensifies now as the uterus pushes against '
          'the stomach. Eat smaller meals, avoid lying down right after '
          'eating, and elevate the head of your bed slightly. '
          'Antacids safe in pregnancy can be discussed with your provider.',
      poeticLine: 'Every lullaby you hum finds its way to her.',
    ),

    // ── WEEK 24 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 24,
      title: 'Viability — A Sacred Milestone',
      babyInsight:
          'Week 24 is considered the threshold of viability — the point '
          'at which a baby born prematurely has a meaningful chance of '
          'survival with medical support. The lungs are producing surfactant, '
          'the substance that will allow them to inflate after birth. '
          'This is a profound milestone.',
      momTip:
          'The glucose tolerance test is typically scheduled between '
          'weeks 24 and 28 to screen for gestational diabetes. '
          'It\'s a routine test — fast for 8–12 hours beforehand '
          'and bring a snack for after.',
      poeticLine: 'She has crossed the threshold — between possibility '
          'and promise.',
    ),

    // ── WEEK 25 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 25,
      title: 'Hair and Handprints',
      babyInsight:
          'Your baby now has hair on her head — the color and texture '
          'may change after birth, but it\'s there. The capillaries '
          'beneath her skin are forming, giving her a pink tint. '
          'Her hands are now fully functional; she grasps, explores, '
          'and touches her own face.',
      momTip:
          'Pelvic girdle pain is common as relaxin loosens your joints '
          'in preparation for birth. A physiotherapist specializing in '
          'women\'s health can offer targeted exercises and a support '
          'belt that makes a significant difference.',
      poeticLine: 'She touches her own face, discovering the shape of '
          'who she is.',
    ),

    // ── WEEK 26 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 26,
      title: 'Eyes Open for the First Time',
      babyInsight:
          'Your baby\'s eyes are opening for the first time. She can '
          'see light filtering through the uterine wall. Her pupils '
          'respond to light and dark. She blinks. The brain is '
          'responding to touch with increasing sophistication.',
      momTip:
          'Braxton Hicks contractions — irregular, painless tightenings '
          '— often begin around now. They\'re your uterus rehearsing '
          'for labor. Stay hydrated, change positions, and rest. '
          'If they become regular or painful, contact your provider.',
      poeticLine: 'She opens her eyes and finds only warmth, only you.',
    ),

    // ── WEEK 27 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 27,
      title: 'The Last Week of the Second Trimester',
      babyInsight:
          'Your baby weighs nearly 900 grams and measures about 36 cm. '
          'She is sleeping up to 75% of the time, and her sleep includes '
          'REM phases — she is almost certainly dreaming. '
          'The immune system is building, receiving antibodies through '
          'the placenta.',
      momTip:
          'Sleep becomes increasingly difficult as the belly grows. '
          'A pregnancy pillow supporting the belly and back can '
          'transform sleep quality. Sleeping on your left side improves '
          'blood flow to the placenta and kidneys.',
      poeticLine: 'She sleeps, and in her sleep, she dreams of the '
          'voice she already loves.',
    ),

    // ── WEEK 28 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 28,
      title: 'Third Trimester — The Final Chapter',
      babyInsight:
          'Welcome to the third trimester. Your baby now weighs about '
          '1 kg and has a very good chance of survival if born now. '
          'The brain is developing rapidly, forming the complex folds '
          'that increase its surface area. She can regulate her own '
          'body temperature.',
      momTip:
          'Begin kick counts this week. Most providers recommend tracking '
          'fetal movements once a day — 10 movements within 2 hours is '
          'reassuring. Trust your instincts: if something feels different, '
          'call your provider.',
      poeticLine: 'The final chapter begins — and it will be the most '
          'beautiful of all.',
    ),

    // ── WEEK 29 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 29,
      title: 'Muscles and Bones Strengthening',
      babyInsight:
          'Your baby\'s muscles and lungs are maturing rapidly. '
          'She\'s absorbing about 250 mg of calcium a day to harden '
          'her skeleton. The head is in proportion with the body now. '
          'At 1.1 kg, she\'s gaining about 200 grams each week.',
      momTip:
          'Shortness of breath is very common now as the uterus '
          'presses against the diaphragm. Sitting straight, sleeping '
          'propped up, and avoiding heavy meals helps. '
          'It eases noticeably once the baby drops in the final weeks.',
      poeticLine: 'She is building herself, bone by beautiful bone.',
    ),

    // ── WEEK 30 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 30,
      title: 'Ten Weeks Left',
      babyInsight:
          'Your baby is about 40 cm and 1.3 kg — the size of a '
          'large cabbage. Her bone marrow has taken over red blood '
          'cell production. The lanugo — the fine body hair — is '
          'starting to fall away as fat accumulates beneath her skin.',
      momTip:
          'Prenatal classes, hospital tours, and birth plan writing '
          'are ideally completed by week 36. Use this window of '
          'relative comfort to prepare. Knowledge is one of the '
          'greatest tools you have for labor.',
      poeticLine: 'Ten weeks. Each one a gift, each one a goodbye '
          'to who you were before.',
    ),

    // ── WEEK 31 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 31,
      title: 'Processing Five Senses',
      babyInsight:
          'Your baby\'s brain can now process information from all '
          'five senses simultaneously. She responds to light, sound, '
          'taste, touch, and smell. The irises — the colored part '
          'of her eyes — are fully pigmented, though color may '
          'change after birth.',
      momTip:
          'Frequency of urination increases dramatically as the baby '
          'presses on your bladder. Kegel exercises strengthen the '
          'pelvic floor and help with leakage now and after birth. '
          'Do them anywhere, anytime — no one will know.',
      poeticLine: 'She tastes your world, hears your world, '
          'dreams your world.',
    ),

    // ── WEEK 32 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 32,
      title: 'Practicing Every Breath',
      babyInsight:
          'Your baby is now practicing breathing movements for up to '
          '30 minutes at a time — inhaling and exhaling amniotic fluid. '
          'The lungs are nearly mature. She weighs about 1.7 kg '
          'and her skin is soft and filled with fat.',
      momTip:
          'Pack your hospital bag this week — not because birth is '
          'imminent, but because having it ready reduces anxiety. '
          'Include documents, comfort items, snacks, a going-home outfit '
          'for baby, and whatever makes you feel at ease.',
      poeticLine: 'She practices the breath she will take when she '
          'first meets the air.',
    ),

    // ── WEEK 33 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 33,
      title: 'The Baby Drops',
      babyInsight:
          'Your baby is rapidly gaining weight — about 250 grams '
          'per week now. The skull bones remain soft and flexible, '
          'designed to compress gently during birth and expand '
          'afterward. She may be moving toward a head-down position '
          'in preparation for birth.',
      momTip:
          'Colostrum — the golden, nutrient-dense first milk — may '
          'begin leaking from your breasts. This is completely normal. '
          'Nursing pads in your bra can help. Whether you plan to '
          'breastfeed or not, this is your body readying itself.',
      poeticLine: 'She turns toward the light, ready before we are.',
    ),

    // ── WEEK 34 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 34,
      title: 'Almost Ready to Breathe Air',
      babyInsight:
          'Your baby\'s lungs are well-developed and would function '
          'independently with minimal medical support if she were born '
          'now. The central nervous system and digestive system are '
          'nearly complete. She weighs about 2.1 kg — the size of '
          'a cantaloupe.',
      momTip:
          'Discuss your pain management preferences for labor with '
          'your provider. Understanding your options — epidural, '
          'gas and air, water birth, movement — helps you feel '
          'empowered rather than swept along.',
      poeticLine: 'She is ready for the world before the world '
          'is ready for her.',
    ),

    // ── WEEK 35 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 35,
      title: 'Filling Out, Rounding Up',
      babyInsight:
          'Your baby is gaining about 250 grams every week now as '
          'fat deposits fill in the last contours. Her kidneys are '
          'fully developed; her liver processes waste products. '
          'At about 46 cm and 2.4 kg, she\'s running out of '
          'room to stretch.',
      momTip:
          'Group B Streptococcus (GBS) swab is typically done '
          'between weeks 35 and 37. It\'s a routine, painless '
          'vaginal/rectal swab. If positive, you\'ll receive '
          'antibiotics during labor to protect your baby — simple '
          'and very effective.',
      poeticLine: 'She fills every corner of the space she was given — '
          'already abundant.',
    ),

    // ── WEEK 36 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 36,
      title: 'One Month Away',
      babyInsight:
          'Your baby is considered late preterm this week. Most '
          'of the lanugo has disappeared; vernix is still present '
          'in the skin folds. She is likely head-down, engaged '
          'in the pelvis. At about 2.6 kg, she has the face '
          'and proportions she\'ll have at birth.',
      momTip:
          'The pressure of the baby\'s head on your pelvis may cause '
          'a feeling called "lightning crotch" — sharp, shooting pain '
          'down the inner thighs. Uncomfortable, but a sign your '
          'baby is descending. Warmth and rest help.',
      poeticLine: 'One month from now, you will know her face.',
    ),

    // ── WEEK 37 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 37,
      title: 'Early Term — Any Day',
      babyInsight:
          'Your baby is now considered early term. The brain '
          'and lungs, while functional, are still actively maturing — '
          'every day in the womb still matters. She weighs about '
          '2.9 kg and is practicing suckling, which she\'s been '
          'doing for months.',
      momTip:
          'Learn to recognize the signs of labor: regular contractions '
          'that intensify, pressure in the lower back, your water '
          'breaking, or a "bloody show." Knowing the difference between '
          'early labor and active labor helps you stay calm and '
          'make confident decisions.',
      poeticLine: 'Any night now, any morning — she will choose '
          'her moment.',
    ),

    // ── WEEK 38 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 38,
      title: 'Full Term — She Is Ready',
      babyInsight:
          'Your baby is full term. She weighs between 3–3.5 kg '
          'and is about 49 cm long. Her organs are mature. '
          'Her grip reflex is strong. The vernix has largely '
          'disappeared. She is physiologically ready for life '
          'outside the womb.',
      momTip:
          'You may feel a "nesting" urge — a compelling drive to '
          'clean, organize, and prepare. Trust it and follow it, '
          'but rest equally. Your body is preparing you, and '
          'you are more ready than you know.',
      poeticLine: 'She is done becoming — now she only needs to arrive.',
    ),

    // ── WEEK 39 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 39,
      title: 'The Waiting',
      babyInsight:
          'Your baby\'s brain is still growing rapidly — she adds '
          'about 30% more brain mass in the last four weeks alone. '
          'Her immune system is receiving a final transfer of '
          'antibodies through the placenta. She is as ready '
          'as she will ever be.',
      momTip:
          'The waiting is one of the hardest parts. Be patient with '
          'yourself and your body. Walk if it feels good, rest if '
          'you\'re tired, eat nourishing food. You cannot do this '
          'wrong — you can only do it.',
      poeticLine: 'The most profound things in life make you wait.',
    ),

    // ── WEEK 40 ─────────────────────────────────────────────────────────
    DailyInsight(
      week: 40,
      title: 'The Door Is Open',
      babyInsight:
          'You have grown a complete human being. Your baby — '
          'perhaps 3–4 kg, about 50 cm — is coiled and ready, '
          'her lungs full of amniotic fluid that will clear with '
          'her first cry. Everything that needs to be there is there. '
          'She is ready. So are you.',
      momTip:
          'If you go past your due date, know that it\'s very common '
          '— only 5% of babies arrive on their due date. Stay in '
          'close contact with your care team, continue kick counts, '
          'and trust the process. The story has a beautiful ending.',
      poeticLine: 'After forty weeks of becoming — she opens her eyes, '
          'and the whole world begins.',
    ),
  ];
}