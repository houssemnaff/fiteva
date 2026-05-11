import 'package:flutter/material.dart';
import 'pregnancy_week.dart';

const _t1 = Color(0xFFE8A0BF); // Trimestre 1 – rose doux
const _t2 = Color(0xFF9BC4CB); // Trimestre 2 – bleu vert
const _t3 = Color(0xFFB5A0D6); // Trimestre 3 – violet doux

final List<PregnancyWeek> pregnancyData = [
  // ── TRIMESTRE 1 (SA 1–13) ────────────────────────────────────────────
  PregnancyWeek(
    week: 1, babySize: 'Graine de sésame', babySizeEmoji: '🌱',
    babyCm: 0.1, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Fécondation en cours. Le zygote se divise rapidement.',
    symptoms: ['Pas encore de symptômes visibles', 'Légère fatigue possible'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Commence l\'acide folique dès maintenant.', icon: Icons.eco_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Santé', text: 'Évite l\'alcool et le tabac.', icon: Icons.favorite_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 2, babySize: 'Graine de pavot', babySizeEmoji: '🌸',
    babyCm: 0.2, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'L\'ovule est fécondé et s\'implante dans l\'utérus.',
    symptoms: ['Légères crampes d\'implantation', 'Seins sensibles'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Écoute ton corps, repose-toi si besoin.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Nutrition', text: 'Hydrate-toi bien, 1,5 L d\'eau/jour.', icon: Icons.water_drop_rounded, color: Color(0xFF2196F3)),
    ],
  ),
  PregnancyWeek(
    week: 3, babySize: 'Grain de riz', babySizeEmoji: '🌾',
    babyCm: 0.5, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Le cœur commence à se former. Le système nerveux émerge.',
    symptoms: ['Nausées matinales légères', 'Fatigue', 'Envies fréquentes d\'uriner'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Fractionne tes repas pour limiter les nausées.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Marche douce 20 min/jour recommandée.', icon: Icons.directions_walk_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 4, babySize: 'Grain de poivre', babySizeEmoji: '🫘',
    babyCm: 0.8, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Le tube neural se ferme. Le cœur bat pour la première fois.',
    symptoms: ['Nausées', 'Seins gonflés', 'Émotions intenses'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Première consultation médicale à planifier.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Dors 8 à 9 heures, la fatigue est normale.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 5, babySize: 'Pépite de maïs', babySizeEmoji: '🌽',
    babyCm: 1.2, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Les membres commencent à apparaître. Le cerveau se développe.',
    symptoms: ['Nausées fréquentes', 'Hypersensibilité aux odeurs', 'Fatigue intense'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Gingembre en infusion contre les nausées.', icon: Icons.local_cafe_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Yoga prénatal doux si tu te sens bien.', icon: Icons.self_improvement_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 6, babySize: 'Myrtille', babySizeEmoji: '🫐',
    babyCm: 1.6, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Le visage prend forme. Les yeux et les oreilles sont visibles.',
    symptoms: ['Nausées matinales et soir', 'Salivation excessive', 'Seins très sensibles'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Privilégie les aliments froids si les odeurs te gênent.', icon: Icons.ac_unit_rounded, color: Color(0xFF2196F3)),
      PregnancyTip(category: 'Repos', text: 'Sieste de 20 min si fatigue en journée.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 7, babySize: 'Framboise', babySizeEmoji: '🫐',
    babyCm: 2.0, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Les doigts commencent à se former. Le cerveau se développe rapidement.',
    symptoms: ['Nausées', 'Constipation', 'Humeur changeante'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Augmente les fibres : fruits, légumes, céréales complètes.', icon: Icons.eco_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Santé', text: 'Évite les fromages au lait cru.', icon: Icons.no_food_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 8, babySize: 'Haricot', babySizeEmoji: '🫘',
    babyCm: 2.5, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Tous les organes principaux sont en place. Les mouvements débutent.',
    symptoms: ['Nausées en pic', 'Vertiges', 'Augmentation du rythme cardiaque'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Natation douce : excellente à ce stade.', icon: Icons.pool_rounded, color: Color(0xFF2196F3)),
      PregnancyTip(category: 'Nutrition', text: 'Fer et vitamines B12 à surveiller.', icon: Icons.medication_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 9, babySize: 'Raisin', babySizeEmoji: '🍇',
    babyCm: 3.0, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Le bébé est officiellement un fœtus. Les organes génitaux se forment.',
    symptoms: ['Nausées', 'Besoin fréquent d\'uriner', 'Ballonnements'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Évite les activités physiques intenses.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Santé', text: '1ère écho prévue entre SA 11 et SA 13.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 10, babySize: 'Kumquat', babySizeEmoji: '🍊',
    babyCm: 4.0, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Les dents de lait commencent à se former. Les organes vitaux fonctionnent.',
    symptoms: ['Nausées en diminution', 'Légère constipation', 'Fatigue persistante'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Calcium important : produits laitiers ou alternatives végétales.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Pilates prénatal doux pour le dos.', icon: Icons.fitness_center_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 11, babySize: 'Figue', babySizeEmoji: '🫐',
    babyCm: 5.4, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Le bébé peut ouvrir et fermer les poings. Les ongles poussent.',
    symptoms: ['Nausées qui s\'atténuent', 'Regain d\'énergie léger', 'Seins moins douloureux'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Dépistage de la trisomie 21 à prévoir.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Nutrition', text: 'Oméga-3 : noix, poissons gras (bien cuits).', icon: Icons.eco_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 12, babySize: 'Citron vert', babySizeEmoji: '🍋',
    babyCm: 6.5, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Les réflexes se développent. Le bébé bouge mais tu ne le sens pas encore.',
    symptoms: ['Fin des nausées pour beaucoup', 'Ventre légèrement arrondi', 'Énergie retrouvée'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Tu peux reprendre une activité modérée.', icon: Icons.directions_run_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Repos', text: 'Profite de ce regain d\'énergie du T2.', icon: Icons.star_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 13, babySize: 'Pêche', babySizeEmoji: '🍑',
    babyCm: 8.0, trimestre: 'Trimestre 1', phaseColor: _t1,
    babyDevelopment: 'Les empreintes digitales se forment. Le bébé peut sucer son pouce.',
    symptoms: ['Léger essoufflement', 'Appétit qui revient', 'Moins de fatigue'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Augmente légèrement les apports caloriques (+100-200 kcal).', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Santé', text: 'Fin du premier trimestre : risque de fausse couche diminue.', icon: Icons.favorite_rounded, color: Color(0xFFE91E63)),
    ],
  ),

  // ── TRIMESTRE 2 (SA 14–27) ───────────────────────────────────────────
  PregnancyWeek(
    week: 14, babySize: 'Citron', babySizeEmoji: '🍋',
    babyCm: 9.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le visage est pleinement formé. Le bébé peut grimacer.',
    symptoms: ['Énergie retrouvée', 'Ventre visible', 'Légères douleurs ligamentaires'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Marche, natation, yoga : le trio idéal du T2.', icon: Icons.directions_walk_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Nutrition', text: 'Protéines importantes : œufs, légumineuses, viandes maigres.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 15, babySize: 'Orange', babySizeEmoji: '🍊',
    babyCm: 10.5, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé entend les sons extérieurs. Il réagit à ta voix.',
    symptoms: ['Douleurs dans les hanches', 'Légères brûlures d\'estomac', 'Meilleur sommeil'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Parle à ton bébé, il t\'entend !', icon: Icons.record_voice_over_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Nutrition', text: 'Évite de manger trop épicé pour les brûlures.', icon: Icons.no_food_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 16, babySize: 'Avocat', babySizeEmoji: '🥑',
    babyCm: 12.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé peut faire des mouvements coordonnés. Les yeux bougent.',
    symptoms: ['Premiers mouvements ressentis', 'Dos qui commence à faire mal', 'Congestion nasale'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Exercices pour renforcer le plancher pelvien.', icon: Icons.fitness_center_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Repos', text: 'Coussin de grossesse recommandé pour dormir.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 17, babySize: 'Poire', babySizeEmoji: '🍐',
    babyCm: 13.5, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'La graisse corporelle commence à se former. Le squelette se durcit.',
    symptoms: ['Courbatures dans le dos', 'Vergetures possibles', 'Légère essoufflement'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Huile de calendula ou beurre de karité contre les vergetures.', icon: Icons.spa_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Étirements doux pour le bas du dos.', icon: Icons.self_improvement_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 18, babySize: 'Poivron', babySizeEmoji: '🫑',
    babyCm: 15.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: '2ème échographie à planifier. Le sexe peut être déterminé.',
    symptoms: ['Mouvements plus fréquents', 'Douleurs ligamentaires rondes', 'Jambes lourdes'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Échographie morphologique entre SA 18 et SA 22.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Surélève tes jambes le soir pour les jambes lourdes.', icon: Icons.airline_seat_flat_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 19, babySize: 'Mangue', babySizeEmoji: '🥭',
    babyCm: 16.5, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé développe son sens du goût. Le vernix caseosa apparaît.',
    symptoms: ['Brûlures d\'estomac', 'Nez bouché', 'Légère fatigue du milieu de journée'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Repas en petites quantités, 5 à 6 fois par jour.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'La natation soulage toutes les douleurs.', icon: Icons.pool_rounded, color: Color(0xFF2196F3)),
    ],
  ),
  PregnancyWeek(
    week: 20, babySize: 'Banane', babySizeEmoji: '🍌',
    babyCm: 18.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Mi-grossesse ! Le bébé a des cycles veille-sommeil réguliers.',
    symptoms: ['Ventre bien visible', 'Mouvements actifs', 'Possible douleur pubienne'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Félicitations : tu es à mi-parcours !', icon: Icons.celebration_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Prépare ton plan de naissance si ce n\'est pas fait.', icon: Icons.note_alt_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 21, babySize: 'Carotte', babySizeEmoji: '🥕',
    babyCm: 20.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé avale du liquide amniotique. Ses sourcils sont formés.',
    symptoms: ['Crampes nocturnes', 'Brûlures d\'estomac', 'Léger essoufflement'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Magnésium contre les crampes nocturnes (avec avis médical).', icon: Icons.medication_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Continue le yoga prénatal pour la respiration.', icon: Icons.self_improvement_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 22, babySize: 'Papaye', babySizeEmoji: '🍈',
    babyCm: 21.5, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Les poumons commencent à se préparer pour la respiration.',
    symptoms: ['Gonflement des chevilles', 'Fatigue de fin de journée', 'Mouvements visibles'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Surélève les pieds pour les gonflements.', icon: Icons.airline_seat_flat_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Nutrition', text: 'Réduis le sel pour limiter la rétention d\'eau.', icon: Icons.no_food_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 23, babySize: 'Pamplemousse', babySizeEmoji: '🍋',
    babyCm: 23.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé peut entendre la musique. Il réagit aux sons forts.',
    symptoms: ['Douleurs de dos plus fréquentes', 'Insomnies légères', 'Besoin fréquent d\'uriner'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Mets de la musique douce pour ton bébé.', icon: Icons.music_note_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Repos', text: 'Coussin de corps pour mieux dormir sur le côté.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 24, babySize: 'Épi de maïs', babySizeEmoji: '🌽',
    babyCm: 25.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé est viable en cas d\'accouchement prématuré. Les yeux s\'ouvrent.',
    symptoms: ['Contractions de Braxton Hicks', 'Essoufflement', 'Maux de tête légers'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Test de dépistage du diabète gestationnel prévu.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Contractions irrégulières = Braxton Hicks, c\'est normal.', icon: Icons.info_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 25, babySize: 'Rutabaga', babySizeEmoji: '🫛',
    babyCm: 27.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'La peau du bébé se lisse. Il répond aux stimulations tactiles.',
    symptoms: ['Douleur pubienne', 'Reflux gastrique', 'Fatigue croissante'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Petits repas fréquents contre les reflux.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Sport', text: 'Marche courte mais régulière chaque jour.', icon: Icons.directions_walk_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 26, babySize: 'Laitue romaine', babySizeEmoji: '🥬',
    babyCm: 28.5, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le cerveau se développe rapidement. Des rêves sont possibles.',
    symptoms: ['Douleurs pelviennes', 'Jambes lourdes', 'Légère dyspnée'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Dors sur le côté gauche pour la circulation.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Nutrition', text: 'Vérifie ton taux de fer avec ton médecin.', icon: Icons.medication_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 27, babySize: 'Chou-fleur', babySizeEmoji: '🥦',
    babyCm: 30.0, trimestre: 'Trimestre 2', phaseColor: _t2,
    babyDevelopment: 'Le bébé cligne des yeux et peut distinguer le clair du sombre.',
    symptoms: ['Varices possibles', 'Hémorroïdes', 'Contractions de Braxton Hicks plus fréquentes'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Évite de rester debout trop longtemps.', icon: Icons.airline_seat_recline_normal_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Santé', text: 'Fin du T2 : bilan sanguin complet recommandé.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
    ],
  ),

  // ── TRIMESTRE 3 (SA 28–40) ───────────────────────────────────────────
  PregnancyWeek(
    week: 28, babySize: 'Aubergine', babySizeEmoji: '🍆',
    babyCm: 32.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé peut rêver. Ses pupilles réagissent à la lumière.',
    symptoms: ['Essoufflement fréquent', 'Douleurs dans le dos', 'Insomnie'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Commence à préparer ta valise de maternité.', icon: Icons.luggage_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Sport', text: 'Exercices de respiration pour l\'accouchement.', icon: Icons.air_rounded, color: Color(0xFF4CAF50)),
    ],
  ),
  PregnancyWeek(
    week: 29, babySize: 'Butternut', babySizeEmoji: '🎃',
    babyCm: 34.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le crâne se développe pour laisser la place au cerveau grandissant.',
    symptoms: ['Fatigue importante', 'Difficultés à dormir', 'Brûlures d\'estomac intenses'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: '500 kcal supplémentaires par jour nécessaires.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Santé', text: '3ème écho entre SA 30 et SA 35 à planifier.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 30, babySize: 'Concombre', babySizeEmoji: '🥒',
    babyCm: 36.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé se retourne. Il se positionne pour l\'accouchement.',
    symptoms: ['Douleur pubienne forte', 'Essoufflement', 'Envies d\'uriner très fréquentes'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Préparation à l\'accouchement à envisager.', icon: Icons.pregnant_woman_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Repos', text: 'Diminue la charge de travail si possible.', icon: Icons.work_off_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 31, babySize: 'Ananas', babySizeEmoji: '🍍',
    babyCm: 37.5, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Les poumons mûrissent. Le bébé prend du poids rapidement.',
    symptoms: ['Difficultés à respirer', 'Œdèmes aux jambes', 'Mal de dos constant'],
    tips: [
      PregnancyTip(category: 'Nutrition', text: 'Vitamine D et calcium pour les os du bébé.', icon: Icons.medication_rounded, color: Color(0xFFFF9800)),
      PregnancyTip(category: 'Repos', text: 'Bains tièdes pour soulager les douleurs.', icon: Icons.bathtub_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 32, babySize: 'Melon', babySizeEmoji: '🍈',
    babyCm: 39.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Les ongles atteignent le bout des doigts. La peau est moins ridée.',
    symptoms: ['Contractions de Braxton Hicks', 'Seins qui coulent (colostrum)', 'Fatigue extrême'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Compte les mouvements : 10 mouvements par heure minimum.', icon: Icons.favorite_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Repos strict si signes de prééclampsie.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 33, babySize: 'Ananas mûr', babySizeEmoji: '🍍',
    babyCm: 40.5, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé se prépare à la position tête en bas. Les os se durcissent.',
    symptoms: ['Douleurs pelviennes', 'Difficultés à marcher', 'Pression sur la vessie'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Ballon de grossesse pour soulager le bassin.', icon: Icons.sports_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Nutrition', text: 'Maintiens une bonne hydratation : 2L/jour.', icon: Icons.water_drop_rounded, color: Color(0xFF2196F3)),
    ],
  ),
  PregnancyWeek(
    week: 34, babySize: 'Butternut géant', babySizeEmoji: '🎃',
    babyCm: 42.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le système immunitaire se renforce. Le cerveau se complexifie.',
    symptoms: ['Envies fréquentes d\'uriner la nuit', 'Brûlures d\'estomac', 'Insomnies'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Prépare le plan de naissance et la chambre bébé.', icon: Icons.home_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Santé', text: 'Consulte si les contractions deviennent régulières.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 35, babySize: 'Citrouille', babySizeEmoji: '🎃',
    babyCm: 43.5, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé est presque prêt. La graisse sous-cutanée se forme.',
    symptoms: ['Grande fatigue', 'Envie de « faire le nid »', 'Contractions fréquentes'],
    tips: [
      PregnancyTip(category: 'Repos', text: 'Prépare ta valise de maternité si ce n\'est pas fait.', icon: Icons.luggage_rounded, color: Color(0xFF9C27B0)),
      PregnancyTip(category: 'Santé', text: 'Prélèvement streptocoque B à prévoir.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
    ],
  ),
  PregnancyWeek(
    week: 36, babySize: 'Melon d\'eau', babySizeEmoji: '🍉',
    babyCm: 45.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé descend dans le bassin. Presque à terme.',
    symptoms: ['Respiration plus facile', 'Pression pelvienne forte', 'Envies fréquentes d\'uriner'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Marche quotidienne pour favoriser la descente.', icon: Icons.directions_walk_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Nutrition', text: 'Continue l\'alimentation équilibrée et hydratée.', icon: Icons.restaurant_rounded, color: Color(0xFFFF9800)),
    ],
  ),
  PregnancyWeek(
    week: 37, babySize: 'Céleri-rave', babySizeEmoji: '🌿',
    babyCm: 46.5, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Le bébé est à terme ! Il est prêt à naître à tout moment.',
    symptoms: ['Contractions irrégulières', 'Perte du bouchon muqueux possible', 'Nesting instinct'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'La valise doit être prête. Reste proche de la maternité.', icon: Icons.local_hospital_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Économise ton énergie pour l\'accouchement.', icon: Icons.bedtime_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 38, babySize: 'Poireau', babySizeEmoji: '🌿',
    babyCm: 47.5, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Les poumons sont totalement matures. Le bébé grossit toujours.',
    symptoms: ['Contractions plus régulières', 'Douleurs pelviennes', 'Pression dans le bassin'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Surveille les signes du travail : contractions régulières, perte des eaux.', icon: Icons.warning_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Repos maximum, le grand jour approche.', icon: Icons.star_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 39, babySize: 'Pastèque', babySizeEmoji: '🍉',
    babyCm: 49.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Tout est prêt. Le bébé attend le signal pour naître.',
    symptoms: ['Grande impatience', 'Douleurs dans le dos', 'Difficultés à dormir'],
    tips: [
      PregnancyTip(category: 'Sport', text: 'Marche quotidienne pour déclencher le travail naturellement.', icon: Icons.directions_walk_rounded, color: Color(0xFF4CAF50)),
      PregnancyTip(category: 'Repos', text: 'Méditation et respiration pour rester calme.', icon: Icons.self_improvement_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
  PregnancyWeek(
    week: 40, babySize: 'Citrouille ronde', babySizeEmoji: '🎃',
    babyCm: 50.0, trimestre: 'Trimestre 3', phaseColor: _t3,
    babyDevelopment: 'Terme officiel ! Ton bébé peut naître d\'un moment à l\'autre.',
    symptoms: ['Grande impatience', 'Contractions possibles', 'Perte des eaux possible'],
    tips: [
      PregnancyTip(category: 'Santé', text: 'Si pas d\'accouchement à SA 41, une surveillance sera mise en place.', icon: Icons.medical_services_rounded, color: Color(0xFFE91E63)),
      PregnancyTip(category: 'Repos', text: 'Profite des derniers moments à deux avant l\'arrivée du bébé.', icon: Icons.favorite_rounded, color: Color(0xFF9C27B0)),
    ],
  ),
];

PregnancyWeek getPregnancyWeek(int week) {
  final clamped = week.clamp(1, 40);
  return pregnancyData.firstWhere((w) => w.week == clamped,
      orElse: () => pregnancyData.last);
}