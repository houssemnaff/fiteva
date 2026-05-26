// ============================================================
//  BabyStoryRepository — Full 40-week content
//  Features: Baby Voice · Micro-Moment · Inside/Outside Split
// ============================================================

class BabyStoryData {
  final String title;

  /// Classic story paragraph (kept for backward compat)
  final String story;

  /// ① Baby Voice — first-person message from the baby
  final String babyVoice;

  /// ② Micro-Moment — one absurd-tender developmental fact
  final String microMoment;

  /// ③ Inside — what's happening in the womb (poetic + medical)
  final String inside;

  /// ③ Outside — what's changing for the mother
  final String outside;

  /// Legacy fact line (your existing UI card)
  final String fact;

  const BabyStoryData({
    required this.title,
    required this.story,
    required this.babyVoice,
    required this.microMoment,
    required this.inside,
    required this.outside,
    required this.fact,
  });
}

class BabyStoryRepository {
  static BabyStoryData forWeek(int week) {
    return _data[week.clamp(1, 40)] ?? _data[1]!;
  }

  static const Map<int, BabyStoryData> _data = {

    // ─────────────────────────────────────────
    //  TRIMESTER 1 — Wonder + Fragility (W1–13)
    // ─────────────────────────────────────────

    1: BabyStoryData(
      title: "The Beginning",
      story: "Everything starts here — a single cell holding the blueprint of an entire human being.",
      babyVoice: "I don't exist yet. And then, suddenly, I do. Something called me into being. I think it was you.",
      microMoment: "Right now, every decision about who they'll be — eye color, laugh, height — was made in a single silent moment.",
      inside: "A single fertilized cell divides and divides again, moving toward the warmth of the uterine wall. The blueprint of an entire person fits inside something invisible to the eye.",
      outside: "You may not feel anything yet. But something has already changed. Your body knows before you do.",
      fact: "A unique human being has just been created — unlike anyone who has ever existed.",
    ),

    2: BabyStoryData(
      title: "Taking Root",
      story: "Your baby is implanting — finding its place, reaching out tiny fingers of cells to anchor itself to you.",
      babyVoice: "I'm looking for somewhere to hold on. I found you. I'm staying.",
      microMoment: "This week, they're burrowing into the wall of your uterus like a seed finding soil. Quietly determined.",
      inside: "Implantation begins. A cluster of cells sends out microscopic tendrils to connect to your blood supply. The placenta — their life support — starts forming.",
      outside: "Some mothers feel a faint twinge. Most feel nothing. Either way, something profound is quietly underway.",
      fact: "The placenta — one of the most complex organs in nature — begins forming this week.",
    ),

    3: BabyStoryData(
      title: "A Flicker of Architecture",
      story: "The neural tube is forming — the beginning of a brain, a spine, a whole nervous system.",
      babyVoice: "I'm building myself from the inside out. I don't know what I'm making yet. But something knows.",
      microMoment: "The structure that will become their brain and spinal cord is already being laid out — before they're the size of a poppy seed.",
      inside: "The neural tube folds and closes — the foundation of every thought, memory, and feeling your child will ever have is being built right now.",
      outside: "Your body is flooding with progesterone, making you tired in a way that feels different. That's the cost of building a nervous system.",
      fact: "The neural tube that becomes the brain and spinal cord begins forming in week 3.",
    ),

    4: BabyStoryData(
      title: "The Heartbeat Begins",
      story: "Somewhere inside you, a tiny cluster of cells has begun to pulse. Not quite a heartbeat yet — but the rhythm is starting.",
      babyVoice: "Something is beating. I don't know what a heartbeat is yet. But I have one.",
      microMoment: "Their heart begins beating at roughly 110 times per minute — faster than yours, quieter than a whisper.",
      inside: "A primitive heart tube forms and starts contracting. It will beat without stopping for the rest of their life, starting now.",
      outside: "The first missed period. The test. The moment the world divides into before and after.",
      fact: "A primitive heart begins beating around day 22 — before most women even know they're pregnant.",
    ),

    5: BabyStoryData(
      title: "The Shape of Things",
      story: "Tiny buds are forming — the very beginning of arms, legs, a face. Your baby is taking the first hints of a human shape.",
      babyVoice: "I'm getting arms. I think. Something is growing on my sides and I don't know what it's for yet.",
      microMoment: "Limb buds appear this week — two tiny stubs that will eventually reach for you.",
      inside: "The embryo curves into a C-shape. Arm and leg buds emerge. The face is beginning — two dark spots where eyes will be.",
      outside: "Nausea may arrive. Your body is producing more HCG than at any other point in pregnancy. It means everything is working.",
      fact: "Arm and leg buds appear this week — the very beginning of the hands that will one day hold yours.",
    ),

    6: BabyStoryData(
      title: "A Face in the Making",
      story: "Eyes, nostrils, and the first curves of a face are emerging. Your baby is beginning to look like someone.",
      babyVoice: "I have eyes now. They're closed. But they're there. I'm starting to look like something.",
      microMoment: "Their nose is forming this week — two tiny pits, placed with quiet precision on a face the size of a lentil.",
      inside: "The optic cups that will become eyes are darkening. The jaw and cheeks curve into place. A face, however small, is becoming.",
      outside: "Fatigue may feel overwhelming. You are growing a face. Rest is not laziness — it's construction work.",
      fact: "The eyes, nose, and mouth begin to form this week — a face smaller than a fingernail.",
    ),

    7: BabyStoryData(
      title: "Tiny Hands",
      story: "Hands are beginning to form — small paddles that will slowly separate into fingers over the coming weeks.",
      babyVoice: "Something is happening at the end of my arms. I think I'll be able to reach with them someday.",
      microMoment: "Hand plates appear this week — flat, mitten-like, with no fingers yet. Just the promise of them.",
      inside: "The brain is growing at an extraordinary rate — 100 new neurons per minute. The hands form as flat paddles, waiting to be carved into fingers.",
      outside: "Your uterus has doubled in size. You may feel bloated or tender. Your body is making room.",
      fact: "The brain grows by 100 new neurons every minute this week.",
    ),

    8: BabyStoryData(
      title: "Everything That Will Be",
      story: "Every organ that will exist in your baby's body has now begun forming. Nothing essential is missing — just time.",
      babyVoice: "I have everything I'll ever have. It's all very small. But it's all here.",
      microMoment: "This week, they develop the ability to frown. Nobody knows exactly why. They're clearly processing something.",
      inside: "All major organ systems are present in primitive form. The embryo transitions to fetus. The hardest work of creation is done.",
      outside: "The most critical period of organ formation is passing. The first trimester caution begins to ease, just slightly.",
      fact: "By week 8, all major organs have begun forming. Your baby is now officially called a fetus.",
    ),

    9: BabyStoryData(
      title: "Learning to Move",
      story: "Your baby is moving — small, jerky movements that you can't feel yet, but that are already becoming their own.",
      babyVoice: "I moved today! I didn't mean to. My arm just went sideways. I'm going to do it again.",
      microMoment: "They can hiccup now. It's one of their first reflexes. You won't feel it for weeks, but it's already happening.",
      inside: "Spontaneous movement begins. Tiny jerks and twitches as the nervous system sends its first motor signals. The muscles respond.",
      outside: "You may be approaching the end of the first trimester. The nausea may begin to lift. Your energy, slowly, may return.",
      fact: "Your baby is making their first spontaneous movements this week — tiny, instinctive, and entirely their own.",
    ),

    10: BabyStoryData(
      title: "Fingers",
      story: "The hands that were paddles are now developing individual fingers — each one a small miracle of cellular precision.",
      babyVoice: "I have fingers now. Five on each side. I keep touching things with them, even though there's nothing to touch yet.",
      microMoment: "The webbing between their fingers is dissolving this week, one precise cell at a time. Ten individual fingers, emerging.",
      inside: "Fingers and toes separate. Nails begin forming. Taste buds appear on the tongue. The fetus is recognizably, unmistakably human.",
      outside: "The first prenatal appointment approaches, or has just passed. Hearing that heartbeat on the monitor for the first time — nothing prepares you for it.",
      fact: "Fingers and toes fully separate this week. Tiny fingernails have already begun to form.",
    ),

    11: BabyStoryData(
      title: "Open Hands",
      story: "Your baby can now open and close their fists — small, reflexive, and somehow already intimate.",
      babyVoice: "I opened my hand today. And closed it. And opened it again. I could do this forever.",
      microMoment: "They're practicing grasping movements in the womb — reaching for something that isn't there yet. Practicing for you.",
      inside: "The fetus floats and kicks in the amniotic fluid, now large enough to bump the walls. Every organ is developing rapidly.",
      outside: "Your blood volume is increasing — your heart is pumping harder. You are sustaining two lives now.",
      fact: "Your baby can open and close their hands this week, practicing the grip that will one day hold your finger.",
    ),

    12: BabyStoryData(
      title: "A Complete Person, In Miniature",
      story: "All the essential parts are in place. The coming months are not about building — they're about growing.",
      babyVoice: "I'm all here. Everything I'll ever have. It's just very, very small. I'm working on that.",
      microMoment: "Their kidneys start producing urine this week, which they release into the amniotic fluid, which they then swallow. They're already recycling.",
      inside: "The fetus is fully formed in miniature. Reflexes are developing. The face has distinct features. At 12 weeks, they look unmistakably like a baby.",
      outside: "The risk of miscarriage drops significantly after week 12. Many parents choose this week to share their news with the world.",
      fact: "By week 12, your baby has all their organs, muscles, limbs and bones. The next 28 weeks are about growing.",
    ),

    13: BabyStoryData(
      title: "The Last Week of the First",
      story: "The first trimester closes. What was fragile is becoming strong. What was a possibility is becoming a person.",
      babyVoice: "I've been here for three months. I'm still very small. But I feel more real now. I think you do too.",
      microMoment: "Their vocal cords are forming this week — the same ones they'll use to cry the moment they meet you, and to say your name years from now.",
      inside: "Vocal cords begin forming. Fingerprints are developing — a unique identity, encoded in the ridges of fingertips no larger than a pinhead.",
      outside: "The first trimester ends. The nausea, the fatigue, the hypervigilance — you carried all of that. You're through it now.",
      fact: "Unique fingerprints begin forming this week — an identity that belongs to no one else in history.",
    ),

    // ──────────────────────────────────────────────
    //  TRIMESTER 2 — Playful + Expansive (W14–27)
    // ──────────────────────────────────────────────

    14: BabyStoryData(
      title: "Hello, Second Trimester",
      story: "The second trimester opens with energy returning and a baby that is growing fast, moving freely, and becoming more themselves.",
      babyVoice: "Something changed. I feel more room. More space. I'm going to use all of it.",
      microMoment: "They can now squint. Researchers believe it's a reaction to light. We believe they just look appropriately skeptical.",
      inside: "The fetus practices breathing movements — inhaling and exhaling amniotic fluid to strengthen the lungs. The liver is producing bile. Everything is speeding up.",
      outside: "Energy often returns in the second trimester. The bump may begin to show. Strangers may start to notice.",
      fact: "Your baby is now practicing breathing movements — training the lungs for their first breath of air.",
    ),

    15: BabyStoryData(
      title: "Light Through the Wall",
      story: "Your baby can detect light now — not see it, but sense it. A glow through the skin. Their first sensory experience of the world.",
      babyVoice: "Something warm reaches me sometimes. From far away. I don't know what it is. I like it.",
      microMoment: "If you shine a light on your belly, they'll move away from it. They have opinions about brightness already.",
      inside: "Light sensitivity begins. The eyes remain fused shut, but photoreceptors are forming. Eyebrows and eyelashes are growing.",
      outside: "You might start to feel a fluttering — or you might not yet. First-time mothers often don't feel movement until weeks 18–22. Both are normal.",
      fact: "Your baby can sense light through the womb — the first hint of a world beyond.",
    ),

    16: BabyStoryData(
      title: "The Rhythm Between You",
      story: "Your baby has synced to your heartbeat. They know your rhythm. They are already living inside the music of you.",
      babyVoice: "There's a sound. Deep and steady. It never stops. I think it's the most important sound there is.",
      microMoment: "Their heart now beats at twice the speed of yours — like a small drum playing double-time to your steady beat.",
      inside: "The cardiovascular system is fully functional. The baby's heart pumps blood through a closed loop — independent, but entirely dependent on yours.",
      outside: "The halfway point of pregnancy is approaching. Many parents choose week 16–20 for the anatomy scan — the first real look at who's in there.",
      fact: "Your baby's heart now beats 120–160 times per minute — synchronized to the rhythm of life inside you.",
    ),

    17: BabyStoryData(
      title: "Fat and Warmth",
      story: "Your baby is beginning to store fat — the soft, warm layer that will keep them cozy and give them their newborn roundness.",
      babyVoice: "I'm getting softer. Something is filling in around me. I think this is what warm feels like.",
      microMoment: "Brown fat is forming this week — a special type that generates heat. They're building their own internal warmth before they've ever felt cold.",
      inside: "Brown adipose tissue forms around the neck and chest. The skeleton is hardening from cartilage to bone. The baby is becoming more solid.",
      outside: "You may notice your center of gravity shifting. Small adjustments in how you walk, how you sit. Your body is accommodating someone new.",
      fact: "Your baby is building fat stores this week — preparing to stay warm in a world they haven't entered yet.",
    ),

    18: BabyStoryData(
      title: "Fingerprints of the Soul",
      story: "The fingerprints are fully formed now — unique to this person, unlike anyone who has ever lived or will ever live.",
      babyVoice: "I have fingerprints. I don't know what they're for yet. But they're mine. Only mine.",
      microMoment: "No one in history — not a single person across all of recorded time — has ever had fingerprints like theirs. That fact is true right now.",
      inside: "The fingerprint patterns are permanently set. The ears move into their final position. Myelin — the insulation around nerve fibers — begins forming.",
      outside: "The anatomy scan is often scheduled around now. The moment an image of your baby appears on screen — real, moving, theirs — is one that stays forever.",
      fact: "Your baby's fingerprints are completely formed — their first truly unique mark on the world.",
    ),

    19: BabyStoryData(
      title: "A Coat of Velvet",
      story: "Your baby is covered in vernix — a white, creamy coating that protects their skin in the amniotic fluid. Soft and strange and perfect.",
      babyVoice: "I'm covered in something. It's soft. I think it's protecting me. I don't mind it.",
      microMoment: "Vernix — the waxy coating on their skin — is made partly of shed skin cells and fine hair. It's essentially a custom-made moisturizer they've been producing for weeks.",
      inside: "Vernix caseosa coats the entire body. The baby's senses are sharpening. They can now hear sounds from outside the womb — muffled, but present.",
      outside: "They can hear your voice now. It reaches them warm and low, like sound through water. They already know it, even if they can't name it.",
      fact: "Your baby can now hear sounds from outside the womb — and your voice is already their favorite.",
    ),

    20: BabyStoryData(
      title: "Halfway",
      story: "Twenty weeks. The exact midpoint. Half of everything is behind you. Half is still ahead. Your baby is the size of a small melon and full of opinions.",
      babyVoice: "Halfway. I've been here for five months and I still haven't seen your face. I'm very curious about it.",
      microMoment: "They kicked when you played that song. Make of that what you will. They have taste already.",
      inside: "The baby is swallowing amniotic fluid regularly, developing the digestive system. Movement is strong and increasingly coordinated.",
      outside: "Most mothers feel regular movement by now. Each kick is a small hello — a reminder that you are not alone in your own body.",
      fact: "Halfway there. Your baby is fully formed and growing fast — the second half of pregnancy is all about strength and preparation.",
    ),

    21: BabyStoryData(
      title: "The Taste of the World",
      story: "Your baby is tasting everything you eat — flavor compounds pass through the amniotic fluid. They're already developing preferences.",
      babyVoice: "Something new today. Something sweet, I think. And yesterday something sharp. I'm keeping track.",
      microMoment: "Studies show babies born to mothers who ate a variety of foods in pregnancy are more likely to accept those flavors after birth. They're already learning to like what you like.",
      inside: "Taste buds are fully functional. The baby swallows amniotic fluid that carries the flavors of the mother's diet. Neural connections for taste are strengthening.",
      outside: "What you eat right now is their first taste of food. Not metaphorically — literally. Their palate is forming around your meals.",
      fact: "Your baby can taste the flavors of your diet in the amniotic fluid — their very first food experiences.",
    ),

    22: BabyStoryData(
      title: "The Sound of Home",
      story: "Sound is their world now. Your voice, your heartbeat, music, the rumble of daily life — all of it reaches them, muffled and warm.",
      babyVoice: "I can hear so much now. There's a voice that comes more than the others. That one is my favorite. I think it's you.",
      microMoment: "They can hear your voice now, filtered through water and warmth. They don't understand the words yet. But they already know the sound of home.",
      inside: "The inner ear is fully developed. The baby responds to sound with movement — a kick at a loud noise, a stillness when music plays. They are listening.",
      outside: "Talking to your bump is not silly. It's neuroscience. Your voice is already mapping neural pathways in a brain that's learning to recognize you.",
      fact: "Your baby's hearing is fully developed. They recognize your voice — it's the most familiar sound in their world.",
    ),

    23: BabyStoryData(
      title: "Learning Faces",
      story: "Your baby's face is now fully formed — the one you'll recognize the moment you see it for the first time and somehow already know.",
      babyVoice: "I have a face. I know this because I can feel it. I wonder if it looks like yours.",
      microMoment: "Their face is already making expressions — furrowing the brow, opening the mouth. No one has seen these expressions yet. You'll be the first.",
      inside: "Facial muscles are practicing expressions. The eyes are still fused but moving beneath the lids. The face that will greet you is rehearsing.",
      outside: "Braxton Hicks contractions may begin — mild, irregular tightenings. Your uterus is practicing too.",
      fact: "Your baby's face is fully formed and already making expressions — a preview of the face you'll fall in love with.",
    ),

    24: BabyStoryData(
      title: "The Breath Rehearsal",
      story: "Your baby is practicing breathing — inhaling and exhaling amniotic fluid to prepare the lungs for the moment they meet air for the first time.",
      babyVoice: "I'm practicing something. In and out. In and out. I don't know what it's for yet. But I keep doing it.",
      microMoment: "They hiccup regularly now, and you'll probably feel it — a rhythmic, gentle tapping from the inside. Say hello back.",
      inside: "The lungs are rehearsing inflation and deflation with amniotic fluid. Surfactant — the substance that keeps the lungs from collapsing — begins forming.",
      outside: "You might feel short of breath this week. Your lungs are sharing space now. Two sets of lungs, learning the same rhythm.",
      fact: "Your baby is practicing breathing movements this week, preparing for the first breath they'll take in the outside world.",
    ),

    25: BabyStoryData(
      title: "A Favorite Position",
      story: "Your baby has begun to develop preferences — positions they favor, sounds they respond to, rhythms that calm them. Personality is forming.",
      babyVoice: "I have a favorite spot now. I keep coming back to it. And I think I recognize your laugh. It moves everything.",
      microMoment: "They're developing sleep cycles now — distinct periods of rest and activity. You may notice patterns. They're already becoming a schedule person, or not.",
      inside: "The brain's surface begins folding into gyri and sulci — the characteristic ridges of a human brain. More surface area means more capacity for thought.",
      outside: "You may start to notice a pattern to the kicks — morning activity, evening quiet, or vice versa. They're showing you who they are.",
      fact: "Your baby is developing a sleep-wake cycle this week — the beginning of their own personal rhythm.",
    ),

    26: BabyStoryData(
      title: "Eyes Open",
      story: "For the first time, your baby opens their eyes. They see only warm, dim light — but they're looking now.",
      babyVoice: "I opened my eyes. Everything is orange and soft. I think I'm inside something. Something that loves me.",
      microMoment: "Their eyes open for the first time this week. The first thing they see: diffused light through your skin. Warm and amber. The most beautiful thing they've ever seen, which is also the only thing they've ever seen.",
      inside: "The eyes open. Retinal cells begin responding to light. The optic nerves are transmitting signals to the brain. Vision, however primitive, begins.",
      outside: "They can see light and shadow through the belly. Shining a light on your skin may provoke a kick — they're responding to your world now.",
      fact: "Your baby's eyes open for the first time this week — and for the first time, they are looking.",
    ),

    27: BabyStoryData(
      title: "The Last Week of the Second",
      story: "The second trimester ends. Your baby is active, aware, and unmistakably themselves. The final stretch begins.",
      babyVoice: "I've been here six months. I know your voice, your laugh, your heartbeat, the way you walk. I know you. I just haven't met you.",
      microMoment: "They can recognize lullabies played in the womb after birth — and they respond to them with calm. The songs you play now will matter later.",
      inside: "The brain is growing rapidly. Fat continues to accumulate. The lungs are nearly — but not quite — ready. The baby is viable outside the womb, but not yet ready.",
      outside: "Heartburn. Back pain. Sleeping positions. The third trimester is already making its presence felt. Your body is working harder than it looks.",
      fact: "Your baby has been listening to music, voice, and sound for months. The sounds they hear now will be familiar to them after birth.",
    ),

    // ──────────────────────────────────────────
    //  TRIMESTER 3 — Weight + Reverence (W28–40)
    // ──────────────────────────────────────────

    28: BabyStoryData(
      title: "Dreams Begin",
      story: "Your baby has entered REM sleep. They are dreaming — of what, no one knows. But somewhere inside you, a small mind is wandering.",
      babyVoice: "I went somewhere today. While I was sleeping. I don't remember it. But I think it was good.",
      microMoment: "REM sleep has begun. They are dreaming. We have no idea what a 28-week-old fetus dreams about, and that mystery is one of the most beautiful things in the world.",
      inside: "Rapid eye movement sleep begins. The brain is consolidating experience, though what a fetus experiences in the womb remains one of neuroscience's most tender open questions.",
      outside: "You may be dreaming more vividly too. Some researchers believe mothers and babies begin synchronizing sleep rhythms in late pregnancy. You may already be dreaming together.",
      fact: "Your baby has entered REM sleep and is dreaming — their interior life has officially begun.",
    ),

    29: BabyStoryData(
      title: "A Body Filling In",
      story: "Fat deposits are filling out your baby's face and body — the round cheeks, the soft folds, the newborn plumpness is forming.",
      babyVoice: "I'm getting rounder. Softer. I think I'm getting ready to be held.",
      microMoment: "The bones in their skull are still soft and not yet fused — designed to flex during birth. The body is engineering its own exit.",
      inside: "The brain is developing the capacity for temperature regulation. Bone marrow takes over red blood cell production from the liver. The baby is becoming self-sufficient, piece by piece.",
      outside: "Kicks may feel sharper now — elbows and heels pressing against the wall. You're starting to feel their specific shape.",
      fact: "Your baby's skull bones are still soft and movable — perfectly designed for the journey of birth.",
    ),

    30: BabyStoryData(
      title: "Ten Weeks to Go",
      story: "The countdown changes shape. Each week now feels different — heavier, fuller, more weighted with anticipation.",
      babyVoice: "I can feel things pressing in from outside now. Sometimes something warm presses back. I press harder when that happens.",
      microMoment: "If you press gently on your belly, they will push back. They've known your touch for weeks. They're answering it.",
      inside: "The lanugo — the fine downy hair that covered the body — begins to shed. The vernix thickens. The baby is preparing to emerge.",
      outside: "Sleep is changing. Getting comfortable requires engineering. Your body is telling you what your baby already knows: change is coming.",
      fact: "Your baby responds to touch through the belly wall — pressing back against your hand.",
    ),

    31: BabyStoryData(
      title: "All Five Senses",
      story: "Your baby now has all five senses — taste, touch, hearing, sight, and smell. They are experiencing the world, even from inside it.",
      babyVoice: "I can smell something now. Something warm and soft. I think that's what you smell like. I'll remember that.",
      microMoment: "They can smell amniotic fluid — which carries the scent of your body. Studies show newborns instinctively turn toward their mother's scent at birth. They already know you by smell.",
      inside: "All five senses are active. The brain is integrating sensory information at a rapid pace. Who this child will be is being shaped by every sensation they experience now.",
      outside: "The third trimester nesting instinct is real — a biological drive to prepare space for arrival. Trust it.",
      fact: "All five senses are now active. Your baby is tasting, touching, hearing, seeing, and smelling their world.",
    ),

    32: BabyStoryData(
      title: "A Mind Folding",
      story: "The brain is forming its characteristic folds — every ridge a new highway for thought, memory, and feeling.",
      babyVoice: "Something is happening in my head. Everything is getting deeper. More complicated. I think I might be getting smarter.",
      microMoment: "Their brain is folding this week — forming the ridges and valleys that will hold a whole lifetime of thought. The mind that will love you is taking shape.",
      inside: "Gyri and sulci deepen rapidly. The brain is reaching near-newborn complexity. Neural networks are forming that will support language, memory, and emotion.",
      outside: "You might be dreaming more vividly now. Some researchers believe mothers and babies synchronize sleep cycles in late pregnancy. You may already be dreaming together.",
      fact: "Your baby's brain is rapidly developing its folds — building the neural architecture for a lifetime of thought and feeling.",
    ),

    33: BabyStoryData(
      title: "Practicing Everything",
      story: "Your baby is rehearsing — blinking, sucking, breathing, gripping. The body is preparing every skill it will need in the first minutes of life.",
      babyVoice: "I keep doing the same things over and over. I think I'm getting ready for something. Something big.",
      microMoment: "They can coordinate sucking, swallowing, and breathing simultaneously now — the exact skill they'll need to feed for the first time. They've been practicing.",
      inside: "The sucking reflex strengthens. Breathing practice intensifies. The immune system receives a surge of antibodies from the placenta — a biological inheritance.",
      outside: "Every day in the womb matters now. Each week of remaining pregnancy contributes measurably to lung maturity, brain development, and feeding ability.",
      fact: "Your baby is rehearsing the feeding reflex — coordinating sucking and swallowing in preparation for their first meal.",
    ),

    34: BabyStoryData(
      title: "Running Out of Room",
      story: "The womb that once felt enormous is now a tight, warm cocoon. Your baby fills almost all of it — and they know it.",
      babyVoice: "It's getting smaller in here. I have to fold my knees up now. I don't mind. It still feels like the safest place I'll ever know.",
      microMoment: "They've run out of room to do full somersaults. They're still trying anyway. The kicks you feel now are elbows, heels, and determination.",
      inside: "The baby is running low on space. Movements change from full rolls to jabs, stretches, and hiccups. Growth is slowing as the final preparations complete.",
      outside: "You can sometimes see the shape of a heel or elbow moving across your skin. The body that has been invisible is beginning to make itself seen.",
      fact: "Your baby has outgrown the space for somersaults — but they haven't stopped trying.",
    ),

    35: BabyStoryData(
      title: "The Weight of Readiness",
      story: "Your baby is nearly ready. The lungs, the brain, the body — all approaching the threshold of independence.",
      babyVoice: "I'm heavy now. I didn't used to be this heavy. I think that means I'm almost ready.",
      microMoment: "Most of the lanugo has shed. The baby is swallowing it, digesting it, and storing it as their first bowel movement — called meconium. They're already tidying up.",
      inside: "The lungs produce sufficient surfactant for independent breathing. The kidneys are fully mature. The liver can process waste. The body is ready; the brain needs a few more weeks.",
      outside: "Every day feels longer now. And also shorter. Time before a birth has a texture unlike any other — suspended, weighted, anticipatory.",
      fact: "Your baby's lungs are nearly mature enough for independent breathing. The final preparations are underway.",
    ),

    36: BabyStoryData(
      title: "Dropping",
      story: "Your baby may begin to move lower into the pelvis — the position that readies them for birth. Your breath may return. Their arrival is near.",
      babyVoice: "I moved downward today. Something shifted. I don't know what I'm moving toward yet. But I'm not afraid.",
      microMoment: "They're patient now — nestled low, waiting. More wisdom than most adults, honestly.",
      inside: "The baby's head may engage in the pelvis. Movements become fewer but stronger. Every system is mature. They are waiting.",
      outside: "Lightening — the sensation of the baby dropping — may ease your breathing but increase pelvic pressure. Your body is beginning the passage.",
      fact: "Your baby is moving into the birth position — head down, facing your spine, waiting for the moment.",
    ),

    37: BabyStoryData(
      title: "Full Term",
      story: "Your baby is considered full term. They could arrive any day now, and they would be ready. They are complete.",
      babyVoice: "I'm ready. I think. I've been getting ready for a long time. I keep thinking about what's outside. I wonder what you'll look like.",
      microMoment: "They have about 15% body fat now — soft, round, designed to retain heat. The rolls you'll squeeze for years are forming this week.",
      inside: "Every system is mature and functional. The baby is ready to breathe, feed, thermoregulate, and exist in the world. Nature is waiting for the right moment.",
      outside: "Full term. Any day could be the day. Your bag might be packed. Or not. Either way, ready is already built into you.",
      fact: "Your baby is officially full term. They are completely ready to meet the world — and you.",
    ),

    38: BabyStoryData(
      title: "The Last Lessons",
      story: "Inside the womb, your baby is receiving the final transfers — antibodies, nutrients, everything you can give them before the moment of separation.",
      babyVoice: "I've been listening to your heartbeat for months. It's the only song I know. I think I'm ready to hear your voice from the outside.",
      microMoment: "In these final weeks, your body transfers more than 80% of the antibodies your baby will carry into the world. It is, without drama, one of the most generous acts a human body can perform.",
      inside: "Antibody transfer through the placenta reaches its peak. The baby's immune system is being stocked for the first months of life. A biological inheritance, silently given.",
      outside: "You may feel strange combinations — impatient and reluctant. Ready and not. Both are true. This particular intimacy is ending; another is about to begin.",
      fact: "In these final weeks, you're transferring a lifetime of immune protection to your baby — every antibody a gift.",
    ),

    39: BabyStoryData(
      title: "Almost",
      story: "Almost. The word that describes everything right now. Almost born. Almost met. Almost a different life.",
      babyVoice: "Almost. I can feel the difference. The world outside must be extraordinary. You've been carrying it in your voice this whole time.",
      microMoment: "They're covering about half a centimeter per week now, mostly in the torso and legs. Every day is adding a little more of them into existence.",
      inside: "The brain continues to develop — it will continue growing rapidly after birth. A full-term brain is still, in many ways, unfinished. Designed to complete itself in the world.",
      outside: "The due date is near, and it may pass. Only 5% of babies arrive on their due date. But they all arrive. Yours will too.",
      fact: "Your baby's brain will continue growing rapidly after birth — it's designed to finish developing in the world, not the womb.",
    ),

    40: BabyStoryData(
      title: "The Door Opens",
      story: "Forty weeks. A full human being, built from nothing, waiting for the moment the world receives them and you receive each other.",
      babyVoice: "I've been listening to you for forty weeks. Your laugh, your voice, your heartbeat at night when everything is quiet. I know you. I love you. I'm ready.",
      microMoment: "They have been inside you for approximately 280 days. In that time, a single cell became a person with fingerprints, dreams, preferences, and a heartbeat. Every single day of that — you did.",
      inside: "The baby is fully formed, mature in every system, waiting. Labor will begin when the fetal brain sends a hormonal signal — the baby, in a sense, chooses the moment.",
      outside: "Everything you felt in the last forty weeks — the nausea, the fear, the joy, the longing — led here. To this. To them. To you, as a mother. The door is opening.",
      fact: "At 40 weeks, your baby is complete. The moment you've been building toward for nine months is here. You are ready. They are ready.",
    ),
  };
}