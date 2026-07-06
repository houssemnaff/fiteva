import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AppL10n — access translations anywhere via AppL10n.of(context)
//  or via ref.watch(l10nProvider) in Riverpod widgets.
// ─────────────────────────────────────────────────────────────────────────────

/// Riverpod provider — use in ConsumerWidget
final l10nProvider = Provider<AppL10n>((ref) {
  final locale = ref.watch(localeProvider);
  return AppL10n(locale.languageCode);
});

class AppL10n {
  final String _lang;
  const AppL10n(this._lang);

  bool get _fr => _lang == 'fr';
  bool get isFrench => _lang == 'fr';

  // ── Navigation ─────────────────────────────────────────────────────────────
  String get navHome        => _fr ? 'Accueil'    : 'Home';
  String get navWorkout     => _fr ? 'Workout'    : 'Workout';
  String get navNutrition   => _fr ? 'Nutrition'  : 'Nutrition';
  String get navCycle       => _fr ? 'Cycle'      : 'Cycle';
  String get navPregnancy   => _fr ? 'Grossesse'  : 'Pregnancy';
  String get navPostpartum  => _fr ? 'Post-partum': 'Postpartum';
  String get navShop        => _fr ? 'Boutique'   : 'Shop';
  String get navCommunity   => _fr ? 'Communauté' : 'Community';
  String get navHealth      => _fr ? 'Santé'      : 'Health';
  String get homeQuickAccess => _fr ? "Tout l'app en un coup d'œil" : 'Everything at a glance';

  // ── Profile ────────────────────────────────────────────────────────────────
  String get profile            => _fr ? 'Profil'            : 'Profile';
  String get settings           => _fr ? 'Paramètres'        : 'Settings';
  String get notifications      => _fr ? 'Notifications'     : 'Notifications';
  String get darkMode           => _fr ? 'Mode sombre'       : 'Dark mode';
  String get darkModeOn         => _fr ? 'Activé'            : 'On';
  String get darkModeOff        => _fr ? 'Désactivé'         : 'Off';
  String get language           => _fr ? 'Langue'            : 'Language';
  String get privacy            => _fr ? 'Confidentialité'   : 'Privacy';
  String get shareApp           => _fr ? "Partager l'app"    : 'Share the app';
  String get helpFaq            => _fr ? 'Aide & FAQ'        : 'Help & FAQ';
  String get about              => _fr ? 'À propos'          : 'About';
  String get connectedHealth    => _fr ? 'Santé connectée'   : 'Connected health';
  String get logout             => _fr ? 'Se déconnecter'    : 'Log out';
  String get logoutConfirm      => _fr ? 'Confirmer la déconnexion' : 'Confirm logout';
  String get logoutMessage      => _fr ? 'Es-tu sûre de vouloir te déconnecter ?' : 'Are you sure you want to log out?';
  String get cancel             => _fr ? 'Annuler'           : 'Cancel';
  String get confirm            => _fr ? 'Confirmer'         : 'Confirm';
  String get level              => _fr ? 'Niveau'            : 'Level';
  String get elite              => _fr ? 'Élite'             : 'Elite';

  // ── Common ─────────────────────────────────────────────────────────────────
  String get continueBtn  => _fr ? 'Continuer'    : 'Continue';
  String get save         => _fr ? 'Enregistrer'  : 'Save';
  String get back         => _fr ? 'Retour'       : 'Back';
  String get yes          => _fr ? 'Oui'          : 'Yes';
  String get no           => _fr ? 'Non'          : 'No';
  String get loading      => _fr ? 'Chargement…'  : 'Loading…';
  String get search       => _fr ? 'Rechercher'   : 'Search';
  String get seeAll       => _fr ? 'Voir tout'    : 'See all';
  String get today        => _fr ? "Aujourd'hui"  : 'Today';
  String get week         => _fr ? 'Semaine'      : 'Week';
  String get month        => _fr ? 'Mois'         : 'Month';

  // ── Home ───────────────────────────────────────────────────────────────────
  String get homeGreeting     => _fr ? 'Bonjour'        : 'Hello';
  String get homeSteps        => _fr ? 'Pas'            : 'Steps';
  String get homeCalories     => _fr ? 'Calories'       : 'Calories';
  String get homeWater        => _fr ? 'Eau'            : 'Water';
  String get homeSleep        => _fr ? 'Sommeil'        : 'Sleep';
  String get homeQuickActions => _fr ? 'Actions rapides': 'Quick actions';
  String get homeProgress     => _fr ? 'Ma progression' : 'My progress';

  // ── Workout ────────────────────────────────────────────────────────────────
  String get workoutTitle       => _fr ? 'Entraînements'     : 'Workouts';
  String get workoutPlan        => _fr ? 'Mon programme'     : 'My plan';
  String get workoutStart       => _fr ? 'Démarrer'         : 'Start';
  String get workoutDone        => _fr ? 'Terminé'           : 'Done';
  String get workoutMinutes     => _fr ? 'min'              : 'min';
  String get workoutSets        => _fr ? 'séries'           : 'sets';
  String get workoutReps        => _fr ? 'rép.'             : 'reps';

  // ── Active workout / Exercise player ────────────────────────────────────────
  String get workoutWeekSession     => _fr ? 'Semaine 1 · Séance 1'              : 'Week 1 · Session 1';
  String get workoutEquipment       => _fr ? 'Matériel : '                       : 'Equipment: ';
  String get workoutEquipmentList   => _fr ? 'Tapis de sol, Haltères'            : 'Mat, Dumbbells';
  String get workoutProgress        => _fr ? 'Progression'                       : 'Progress';
  String workoutPossiblePoints(int p) => _fr ? '$p points possibles' : '$p possible points';
  String workoutCompleted(int done, int total) => _fr
      ? '$done / $total complétés' : '$done / $total completed';
  String get workoutExerciseDuration => _fr ? '45 sec · 3 séries'               : '45 sec · 3 sets';
  String get workoutSessionDone     => _fr ? 'Séance terminée ✓'                : 'Workout done ✓';
  String get workoutSessionStart    => _fr ? 'Commencer la séance'              : 'Start workout';

  // exercise player
  String get exSessionComplete      => _fr ? 'Séance terminée ! ✓'              : 'Workout complete! ✓';
  String exPointsEarned(int pts, int total) => _fr  ? '+$pts pts gagnés ! ' : '+$pts pts earned! ';
  String get exWatch80              => _fr ? 'Regardez au moins 80% pour gagner les points'
                                           : 'Watch at least 80% to earn points';
  String get exTagGlutes            => _fr ? 'Fessiers'    : 'Glutes';
  String get exTagMat               => _fr ? 'Tapis'       : 'Mat';
  String get exTagModerate          => _fr ? 'Modéré'      : 'Moderate';
  String get exStatSets             => _fr ? 'Séries'      : 'Sets';
  String get exStatWork             => _fr ? 'Travail'     : 'Work';
  String get exStatRest             => _fr ? 'Repos'       : 'Rest';
  String get exStatPoints           => 'Points';
  String get exTechniqueLabel       => _fr ? 'Technique'   : 'Technique';
  String get exTechniqueDesc        => _fr
      ? 'Debout, pieds écartés largeur épaules. Descends en pliant les genoux à 90° en gardant le dos droit et la poitrine sortie. Pousse sur tes talons pour remonter.'
      : 'Stand with feet shoulder-width apart. Lower by bending your knees to 90°, keeping your back straight and chest up. Push through your heels to rise.';
  String get exFormTipsTitle        => _fr ? 'Conseils de forme'  : 'Form tips';
  String get exTip1                 => _fr ? 'Garde les genoux alignés avec tes orteils.'
                                           : 'Keep your knees aligned with your toes.';
  String get exTip2                 => _fr ? 'Engage ta sangle abdominale pendant tout le mouvement.'
                                           : 'Engage your core throughout the movement.';
  String get exTip3                 => _fr ? 'Expire à la montée, inspire à la descente.'
                                           : 'Exhale on the way up, inhale on the way down.';
  String get exPrev                 => _fr ? 'Précédent'    : 'Previous';
  String get exNext                 => _fr ? 'Suivant'      : 'Next';
  String get exDoneLabel            => _fr ? 'Exercice terminé !'   : 'Exercise done!';
  String get exCompleteBtn          => _fr ? "Terminer l'exercice"  : 'Complete exercise';

  // ── Nutrition ──────────────────────────────────────────────────────────────
  String get nutritionTitle     => _fr ? 'Nutrition'         : 'Nutrition';
  String get nutritionCalTarget => _fr ? 'Objectif calorique': 'Calorie goal';
  String get nutritionBreakfast => _fr ? 'Petit-déjeuner'   : 'Breakfast';
  String get nutritionLunch     => _fr ? 'Déjeuner'         : 'Lunch';
  String get nutritionDinner    => _fr ? 'Dîner'            : 'Dinner';
  String get nutritionSnack     => _fr ? 'Collation'        : 'Snack';
  String get nutritionAddMeal   => _fr ? 'Ajouter un repas' : 'Add a meal';
  String get nutritionProtein   => _fr ? 'Protéines'        : 'Protein';
  String get nutritionCarbs     => _fr ? 'Glucides'         : 'Carbs';
  String get nutritionFat       => _fr ? 'Lipides'          : 'Fat';

  // ── Cycle ──────────────────────────────────────────────────────────────────
  String get cycleTitle     => _fr ? 'Mon Cycle'    : 'My Cycle';
  String get cyclePhase     => _fr ? 'Phase'        : 'Phase';
  String get cycleDay       => _fr ? 'Jour'         : 'Day';
  String get cyclePeriod    => _fr ? 'Règles'       : 'Period';
  String get cycleOvulation => _fr ? 'Ovulation'    : 'Ovulation';
  String get cycleCalendar  => _fr ? 'Calendrier'   : 'Calendar';

  // ── Health / Santé ─────────────────────────────────────────────────────────
  String get healthTitle      => _fr ? 'Santé'              : 'Health';
  String get healthAdvice     => _fr ? 'Conseils'           : 'Advice';
  String get healthResources  => _fr ? 'Ressources'         : 'Resources';
  String get healthQA         => _fr ? 'Q & R'              : 'Q & A';
  String get healthDoctors    => _fr ? 'Médecins'           : 'Doctors';
  String get healthRecord     => _fr ? 'Mon Carnet'         : 'My Record';
  String get healthArticles   => _fr ? 'Articles'           : 'Articles';
  String get healthPodcasts   => _fr ? 'Podcasts'           : 'Podcasts';
  String get healthLexicon    => _fr ? 'Lexique'            : 'Lexicon';

  // ── Language picker ────────────────────────────────────────────────────────
  String get chooseLanguage   => _fr ? 'Choisir la langue'  : 'Choose language';
  String get langFrench       => _fr ? 'Français'           : 'French';
  String get langEnglish      => _fr ? 'Anglais'            : 'English';

  // ── Home screen ────────────────────────────────────────────────────────────
  String get homeStartProgram       => _fr ? 'COMMENCER'             : 'START';
  String get homeProgrammeLabel     => _fr ? 'PROGRAMME'             : 'PROGRAM';
  String get homeWeekPlan           => _fr ? 'PLAN SEMAINE'          : 'WEEK PLAN';
  String get homePlanYourWeek       => _fr ? 'Planifie ta\nsemaine'  : 'Plan Your\nWeek';
  String get homeWeekGoalLabel      => _fr ? 'Objectif'              : 'Goal';
  String get homeEmptyDayTitle      => _fr ? 'Aucune séance prévue'  : 'No workout planned';
  String homeEmptyDaySubtitle(String day) => _fr
      ? 'Profite du repos, ou prévois quelque chose pour $day'
      : 'Take a rest, or plan something for $day';
  String get homeChooseWorkout      => _fr ? 'Choisir une séance'    : 'Choose Workout';
  String get homeAddSuggestion      => _fr ? 'Ajouter'               : 'Add';
  String get homeChooseAnother      => _fr ? 'Choisir une autre séance' : 'Choose another workout instead';
  String get phaseMenstrual         => _fr ? 'Règles'                : 'Period';
  String get phaseFollicular        => _fr ? 'Folliculaire'          : 'Follicular phase';
  String get phaseOvulation         => _fr ? 'Ovulation'             : 'Ovulation';
  String get phaseLuteal            => _fr ? 'Lutéale'               : 'Luteal phase';
  String get phasePregnancy         => _fr ? 'Grossesse'             : 'Pregnancy';
  String get phasePostpartum        => _fr ? 'Post-partum'           : 'Postpartum';
  String get homeDone               => _fr ? 'TERMINÉ'               : 'DONE';
  String get homeMissedBadge        => _fr ? 'Manqué'                : 'Missed';
  String get homeInProgress         => _fr ? 'PROGRAMMES EN COURS'   : 'IN PROGRESS';
  String get homeContinueSection    => _fr ? 'Continuer'             : 'Continue';
  String get homeVoirTout           => _fr ? 'voir tout'             : 'see all';
  String get homePickWorkout        => _fr ? 'Pick a workout'        : 'Pick a workout';
  String get homeStart              => _fr ? 'DÉMARRER'              : 'START';
  String get homeReview             => _fr ? 'REVOIR'                : 'REVIEW';
  String get homeResume             => _fr ? 'RESUME'                : 'RESUME';

  // ── Workout screen ─────────────────────────────────────────────────────────
  String get workoutMyTrainings     => _fr ? 'Mes entraînements'     : 'My workouts';
  String get workoutPhaseFilter     => _fr ? 'Phase du cycle'        : 'Cycle phase';
  String get workoutShowAll         => _fr ? 'Tout afficher'         : 'Show all';
  String get workoutNoProgramFound  => _fr ? 'Aucun programme trouvé'    : 'No program found';
  String get workoutNoWorkoutFound  => _fr ? 'Aucun entraînement trouvé' : 'No workout found';
  String get workoutSearchHint      => _fr ? 'Rechercher...'         : 'Search...';
  String get workoutChipAll         => _fr ? 'Tout'                  : 'All';
  String get workoutChipSalle       => _fr ? 'Salle'                 : 'Gym';
  String get workoutChipMaison      => _fr ? 'Maison'                : 'Home';
  String get workoutChipDance       => _fr ? 'Danse'                 : 'Dance';
  String get workoutChipRecup       => _fr ? 'Récup.'                : 'Recovery';
  String get workoutChipGrossesse   => _fr ? 'Grossesse'             : 'Pregnancy';
  String get workoutSalleTitle      => _fr ? 'Programmes Salle'      : 'Gym Programs';
  String get workoutMaisonTitle     => _fr ? 'Programmes Maison'     : 'Home Programs';
  String get workoutDanceTitle      => _fr ? 'Danse & Cardio'        : 'Dance & Cardio';
  String get workoutRecupTitle      => _fr ? 'Récupération'          : 'Recovery';
  String get workoutGrossesseTitle  => _fr ? 'Grossesse'             : 'Pregnancy';

  // ── Nutrition screen ───────────────────────────────────────────────────────
  String get nutritionMyDiet        => _fr ? 'Mon alimentation'      : 'My diet';
  String get nutritionAdd           => _fr ? 'Ajouter'               : 'Add';
  String get nutritionNewRecipes    => _fr ? 'Nouvelles recettes'     : 'New recipes';
  String get nutritionKcalOver      => _fr ? 'kcal dépassés'         : 'kcal over';
  String get nutritionKcalLeft      => _fr ? 'kcal restantes'        : 'kcal left';
  String get nutritionNoMealsToday  => _fr ? 'Aucun repas aujourd\'hui'                              : 'No meals today';
  String get nutritionStartTracking => _fr ? 'Commence à suivre ton alimentation →'                 : 'Start tracking your food →';
  String get nutritionMyRecipes     => _fr ? 'MES RECETTES'                                          : 'MY RECIPES';
  String get nutritionFavorites     => _fr ? 'Favoris'                                               : 'Favorites';
  String get nutritionNoFavorites   => _fr ? 'Aucun favori'                                          : 'No favorites';
  String get nutritionFavoriteHint  => _fr ? 'Appuie sur ♥ dans une recette\npour la retrouver ici' : 'Tap ♥ on a recipe\nto save it here';
  String get nutritionPhotoRecipes  => _fr ? 'Recettes photos'                                       : 'Photo recipes';
  String get nutritionVideoRecipes  => _fr ? 'Recettes vidéos'                                       : 'Video recipes';
  String get nutritionRecipesEyebrow=> _fr ? 'RECETTES'                                              : 'RECIPES';
  String get nutritionOnTrack       => _fr ? 'Sur la bonne voie'                                     : 'On track';
  String get nutritionDailyLog      => _fr ? 'BILAN DU JOUR'                                         : 'DAILY LOG';
  String get nutritionNoMealLogged  => _fr ? 'Aucun repas enregistré'                                : 'No meals logged';
  String get nutritionKcalConsumed  => _fr ? 'kcal consommées'                                       : 'kcal consumed';
  String get nutritionExceeded      => _fr ? 'Dépassé'                                               : 'Over';
  String get nutritionKcalExceeded  => _fr ? 'kcal dépassées'                                        : 'kcal over';
  String get nutritionKcalRemaining => _fr ? 'kcal restantes'                                        : 'kcal left';
  String get nutritionMyMeals       => _fr ? 'MES REPAS'                                             : 'MY MEALS';
  String get nutritionToday         => _fr ? 'Aujourd\'hui'                                          : 'Today';

  String get nutritionSeeAll        => _fr ? 'Tout voir'                                             : 'See all';
  String get nutritionKcalGoal      => _fr ? 'kcal objectif'                                         : 'kcal goal';
  String get nutritionPhoto         => _fr ? 'Photo'                                                  : 'Photo';
  String get nutritionScanner       => _fr ? 'Scanner'                                               : 'Scanner';
  String get nutritionRecipesAction => _fr ? 'Recettes'                                              : 'Recipes';
  String get nutritionManual        => _fr ? 'Manuel'                                                : 'Manual';
  String get nutritionTracking      => _fr ? 'SUIVI'                                                 : 'TRACKING';
  String get nutritionCaloriesDay   => _fr ? 'CALORIES DU JOUR'                                      : "TODAY'S CALORIES";
  String get nutritionSurplus       => _fr ? 'surplus'                                               : 'surplus';
  String get nutritionLeft          => _fr ? 'restantes'                                             : 'left';
  String get nutritionNoFood        => _fr ? 'Aucun aliment'                                         : 'No food';
  String get nutritionAddFood       => _fr ? 'Ajouter un aliment'                                    : 'Add food';
  String get nutritionTodayLabel    => _fr ? "Aujourd'hui"                                           : 'Today';
  String nutritionFoodItems(int n)  => _fr
      ? '$n aliment${n > 1 ? 's' : ''}'
      : '$n food item${n > 1 ? 's' : ''}';
  List<String> get daysShort => _fr
      ? ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get monthsShort => _fr
      ? ['jan', 'fév', 'mar', 'avr', 'mai', 'juin', 'juil', 'août', 'sep', 'oct', 'nov', 'déc']
      : ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

  // ── Ajout rapide screen ───────────────────────────────────────────────────
  String get addMealTitle       => _fr ? 'AJOUTER'                                          : 'ADD';
  String get addMealSubtitle    => _fr ? 'Un repas'                                         : 'A meal';
  String get addMealSearch      => _fr ? 'Recherche'                                        : 'Search';
  String get addMealManual      => _fr ? 'Manuel'                                           : 'Manual';
  String get addMealScanner     => _fr ? 'Scanner'                                          : 'Scanner';
  String get addMealUpdateQty   => _fr ? 'Mettre à jour la quantité'                       : 'Update quantity';
  String get addMealAddToList   => _fr ? 'Ajouter à la liste'                              : 'Add to list';
  String get addMealFirstAdd    => _fr ? "Ajoutez d'abord des aliments"                    : 'Add foods first';
  String addMealConfirm(int n, int kcal) => _fr
      ? (n == 1 ? 'Confirmer 1 aliment · $kcal kcal' : 'Confirmer $n aliments · $kcal kcal')
      : (n == 1 ? 'Confirm 1 item · $kcal kcal'      : 'Confirm $n items · $kcal kcal');
  String get addMealHint        => _fr ? 'Rechercher un aliment…'                          : 'Search for a food…';
  String addMealResults(int n)  => _fr ? 'RÉSULTATS ($n)'                                  : 'RESULTS ($n)';
  String get addMealPopular     => _fr ? 'POPULAIRES'                                       : 'POPULAR';
  String get addMealBack        => _fr ? 'Retour à la recherche'                           : 'Back to search';
  String get addMealQuantity    => _fr ? 'QUANTITÉ'                                         : 'QUANTITY';
  String get addMealFibers      => _fr ? 'Fibres'                                           : 'Fiber';
  String get addMealInfoTitle   => _fr ? 'INFORMATIONS'                                     : 'INFO';
  String get addMealInfoHint    => _fr ? 'Saisis les informations nutritionnelles manuellement.' : 'Enter nutritional info manually.';
  String get addMealNameLabel   => _fr ? 'Nom du plat *'                                   : 'Dish name *';
  String get addMealNameHint    => _fr ? 'Ex : Riz thaï au poulet'                        : 'E.g. Thai chicken rice';
  String get addMealCalLabel    => _fr ? 'Calories (kcal) *'                               : 'Calories (kcal) *';
  String get addMealCalHint     => _fr ? 'Ex : 450'                                        : 'E.g. 450';
  String get addMealMacros      => _fr ? 'MACRONUTRIMENTS'                                  : 'MACRONUTRIENTS';
  String get addMealOptional    => _fr ? 'Optionnel'                                        : 'Optional';
  String get addMealScanHint    => _fr ? 'Scanne un code-barre ou prends une photo de ton repas.' : 'Scan a barcode or take a photo of your meal.';
  String get addMealScanPress   => _fr ? 'Appuie sur Photo pour analyser'                  : 'Tap Photo to analyze';
  String get addMealAnalyzing   => _fr ? 'Analyse en cours…'                               : 'Analyzing…';
  String get addMealNutrients   => _fr ? 'Identification des nutriments'                   : 'Identifying nutrients';
  String get addMealAiAnalysis  => _fr ? "Analyse de l'image avec l'IA…"                  : 'AI image analysis…';
  String get addMealScanResult  => _fr ? 'Résultat scan'                                   : 'Scan result';
  String get addMealNewPhoto    => _fr ? 'Nouvelle photo'                                  : 'New photo';
  String get addMealQtyLabel    => _fr ? 'Quantité :'                                      : 'Quantity:';
  String get addMealOtherPhoto  => _fr ? 'Autre photo'                                     : 'Other photo';
  String get addMealAdd         => _fr ? 'Ajouter'                                         : 'Add';
  String get addMealMoreIngr    => _fr ? '+ Ajouter des ingrédients'                      : '+ Add ingredients';
  String get addMealBasketTitle => _fr ? "Liste d'aliments"                                : 'Food list';
  String addMealBasketCount(int n) => _fr
      ? '$n aliment${n > 1 ? 's' : ''}'
      : '$n item${n > 1 ? 's' : ''}';
  String get addMealProt        => _fr ? 'prot.'                                            : 'prot.';
  String get addMealGluc        => _fr ? 'gluc.'                                            : 'carbs';
  String get addMealLip         => _fr ? 'lip.'                                             : 'fat';
  String get addMealClose       => _fr ? 'Fermer'                                           : 'Close';
  String get addMealUnitTitle   => _fr ? 'Unité de mesure'                                 : 'Unit of measure';
  String get addMealWhichMeal   => _fr ? 'Quel repas ?'                                    : 'Which meal?';
  String addMealNoResults(String q) => _fr ? 'Aucun résultat pour "$q"'                   : 'No results for "$q"';
  String get addMealTryManual   => _fr ? "Essaie le mode Manuel pour l'ajouter"           : 'Try Manual mode to add it';
  String get unitTbsp           => _fr ? 'c. à soupe'                                      : 'tbsp';
  String get unitTsp            => _fr ? 'c. à café'                                       : 'tsp';
  String get unitPiece          => _fr ? 'pièce'                                           : 'piece';

  // ── Santé screen ───────────────────────────────────────────────────────────
  String get santeTitle             => _fr ? 'Espace Médical'        : 'Medical Space';
  String get santeWellness          => _fr ? 'SANTÉ & BIEN-ÊTRE'     : 'HEALTH & WELLNESS';
  String get santeTabConseils       => _fr ? 'Conseils'              : 'Advice';
  String get santeTabRessources     => _fr ? 'Ressources'            : 'Resources';
  String get santeTabQR             => _fr ? 'Q & R'                 : 'Q & A';
  String get santeTabMedecins       => _fr ? 'Médecins'              : 'Doctors';
  String get santeTabCarnet         => _fr ? 'Mon Carnet'            : 'My Record';
  String get santeVoirProfil        => _fr ? 'Voir le profil'        : 'View profile';
  String get santePoserQuestion     => _fr ? 'Poser une question à un médecin' : 'Ask a doctor a question';
  String get santeVotreQuestion     => _fr ? 'Votre question (anonyme)'        : 'Your question (anonymous)';
  String get santeDecrire           => _fr ? 'Décrivez votre situation...'     : 'Describe your situation...';
  String get santePublicationAnon   => _fr ? "Publication anonyme — votre identité n'est pas révélée." : 'Anonymous post — your identity is not revealed.';
  String get santePosezLaQuestion   => _fr ? 'Poser la question'     : 'Ask the question';
  String get santeAnonymous         => _fr ? 'Anonyme'               : 'Anonymous';
  String get santeEnAttente         => _fr ? 'En attente de réponse...' : 'Awaiting answer...';
  String get santeSpecialists       => _fr ? 'Spécialistes en Tunisie' : 'Specialists in Tunisia';
  String get santeSaisirConstantes  => _fr ? 'Saisir mes constantes' : 'Enter my measurements';
  String get santePoids             => _fr ? 'Poids'                 : 'Weight';
  String get santeTension           => _fr ? 'Tension artérielle'    : 'Blood pressure';
  String get santeEnregistrer       => _fr ? 'Enregistrer'           : 'Save';
  String get santeRappelsSante      => _fr ? 'Rappels santé'         : 'Health reminders';
  String get santeHistorique        => _fr ? 'Historique'            : 'History';
  String get santeArticlesFond      => _fr ? 'Articles de fond'      : 'In-depth articles';
  String get santeVotesUtiles       => _fr ? 'votes utiles'          : 'helpful votes';
  String get santeConsultations     => _fr ? 'consultations'         : 'consultations';

  // ── Community screen ───────────────────────────────────────────────────────
  String get communityTitle         => _fr ? 'Together'              : 'Together';
  String get communityEyebrow       => _fr ? 'COMMUNAUTÉ'            : 'COMMUNITY';
  String get communityCreate        => _fr ? 'Créer'                 : 'Create';

  // ── Boutique screen ────────────────────────────────────────────────────────
  String get boutiqueTitle          => _fr ? 'Récompenses'           : 'Rewards';
  String get boutiqueEyebrow        => _fr ? 'Boutique'              : 'Shop';
  String get boutiqueCatAll         => _fr ? 'Tout'                  : 'All';
  String get boutiqueCatMamans      => _fr ? 'Mamans'                : 'Moms';
  String get boutiqueCatBaby        => _fr ? 'Baby'                  : 'Baby';
  String get boutiqueSortAll        => _fr ? 'Tout'                  : 'All';
  String get boutiqueSortTopDeals   => _fr ? 'Meilleures offres'     : 'Top deals';
  String get boutiqueSortPopular    => _fr ? 'Plus populaires'       : 'Most popular';
  String get boutiqueSortExpiring   => _fr ? 'Expire bientôt'        : 'Expiring soon';
  String get boutiqueSortFilter     => _fr ? 'Trier et filtrer'       : 'Sort & filter';
  String get boutiqueClear          => _fr ? 'Effacer'                : 'Clear';

  // ── Cycle screen ───────────────────────────────────────────────────────────
  String get cycleHowDoYouFeel      => _fr ? 'Comment tu te sens ?'  : 'How are you feeling?';
  String get cycleIAmPregnant       => _fr ? 'Je suis enceinte'      : 'I am pregnant';
  String get cycleWhichWeek         => _fr ? 'A quelle semaine en es-tu ?' : 'Which week are you on?';
  String get cycleWeekLabel         => _fr ? 'Semaine'               : 'Week';
  String get cycleTrimester1        => _fr ? '1er trimestre'         : '1st trimester';
  String get cycleTrimester2        => _fr ? '2e trimestre'          : '2nd trimester';
  String get cycleTrimester3        => _fr ? '3e trimestre'          : '3rd trimester';
  String get cycleGrossesse         => _fr ? 'Grossesse'             : 'Pregnancy';

  // ── Weekly plan screen ─────────────────────────────────────────────────────
  String get weeklyPlanTitle        => _fr ? 'Planning de la semaine' : 'Weekly plan';
  String get weeklyPlanThisWeek     => _fr ? 'Cette semaine'          : 'This week';
  String get weeklyPlanOverview     => _fr ? 'Aperçu de la semaine'   : 'Weekly overview';
  String get weeklyPlanDoneLabel    => _fr ? 'Terminés'               : 'Done';
  String get weeklyPlanPlanned      => _fr ? 'Planifiés'              : 'Planned';
  String get weeklyPlanRest         => _fr ? 'Jour de repos'          : 'Rest day';
  String get weeklyPlanNoWorkout    => _fr ? 'Aucun workout prévu'    : 'No workout planned';
  String get weeklyPlanAddWorkout   => _fr ? 'Ajouter un workout'     : 'Add a workout';
  String get weeklyPlanChoose       => _fr ? 'Choisir un workout'     : 'Choose a workout';
  String get weeklyPlanMarkDone     => _fr ? 'Marquer terminé'        : 'Mark as done';
  String get weeklyPlanChange       => _fr ? 'Changer'                : 'Change';
  String get weeklyPlanStart        => _fr ? 'Démarrer'               : 'Start';
  String get weeklyPlanReview       => _fr ? 'Revoir'                 : 'Review';
  String get weeklyPlanExercises    => _fr ? 'Exercices'              : 'Exercises';
  String get weeklyStatusDone       => _fr ? 'Terminé'                : 'Done';
  String get weeklyStatusPlanned    => _fr ? 'Planifié'               : 'Planned';
  String get weeklyStatusToday      => _fr ? "Aujourd'hui"            : 'Today';
  String get weeklyStatusRest       => _fr ? 'Repos'                  : 'Rest';

  // ── Onboarding steps ──────────────────────────────────────────────────────

  // StepWelcome
  String get welcomeCreateAccount   => _fr ? 'Créer mon compte'        : 'Create your account';
  String get welcomeUsername        => _fr ? 'Ton prénom'              : 'Your username';
  String get welcomeEmail           => _fr ? 'Email'                   : 'Email';
  String get welcomePassword        => _fr ? 'Mot de passe'            : 'Password';
  String get welcomeContinue        => _fr ? 'Continuer →'             : 'Continue →';
  String get welcomeGetStarted      => _fr ? 'Commencer'               : 'Get Started';
  String get welcomeSignUpGoogle    => _fr ? "S'inscrire avec Google"  : 'Sign Up with Google';
  String get welcomeSignUpApple     => _fr ? "S'inscrire avec Apple"   : 'Sign Up with Apple';
  String get welcomeSignUpEmail     => _fr ? "S'inscrire par e-mail"   : 'Sign Up with Email';
  String get welcomeAlreadyAccount  => _fr ? 'Vous avez déjà un compte ? ' : 'Already have an account? ';
  String get welcomeLogIn           => _fr ? 'Se connecter'            : 'Log In';
  String get welcomeBack            => _fr ? 'Retour'                  : 'Welcome back';
  String get welcomeLogInToContinue => _fr ? 'Connectez-vous pour continuer' : 'Log in to continue';
  String get welcomeLogInGoogle     => _fr ? 'Se connecter avec Google' : 'Log In with Google';
  String get welcomeLogInApple      => _fr ? 'Se connecter avec Apple'  : 'Log In with Apple';
  String get welcomeLogInEmail      => _fr ? 'Se connecter par e-mail'  : 'Log In with Email';
  String get welcomeNoAccount       => _fr ? "Nouveau ici ? S'inscrire" : 'New here? Sign up';
  String get welcomeOrContinueWith  => _fr ? 'ou continuer avec'        : 'or continue with';

  // StepGoals — objectif de poids (perte / maintien / prise)
  String get goalsTopBarTitle       => _fr ? 'OBJECTIF'                : 'GOAL';
  String get goalsTitle             => _fr ? 'Quel est ton objectif\nprincipal en ce moment ?' : 'What is your main\ngoal right now?';
  String get goalsHint              => _fr ? 'Touche un cercle pour choisir' : 'Tap a circle to choose';
  String get goal1                  => _fr ? '🔥 Perdre\ndu poids'      : '🔥 Lose\nweight';
  String get goal2                  => _fr ? '⚖️ Maintenir\nle poids'   : '⚖️ Maintain\nweight';
  String get goal3                  => _fr ? '💪 Prendre du poids\n/ muscle' : '💪 Gain weight\n/ muscle';

  // StepFitnessLevel
  String get fitnessTopBarTitle     => _fr ? 'NIVEAU'                   : 'LEVEL';
  String get fitnessTitle           => _fr ? 'Quel est ton niveau\nde forme actuel ?' : 'What is your current\nfitness level?';
  String get fitnessHint            => _fr ? 'Touche un cercle pour choisir' : 'Tap a circle to choose';
  String get fitnessLevelBeginner   => _fr ? 'Débutant'                : 'Beginner';
  String get fitnessLevelIntermediate => _fr ? 'Intermédiaire'         : 'Intermediate';
  String get fitnessLevelAdvanced   => _fr ? 'Avancé'                  : 'Advanced';

  // StepEquipment
  String get equipmentTopBarTitle   => _fr ? 'ÉQUIPEMENT'              : 'EQUIPMENT';
  String get equipmentTitle         => _fr ? 'Quel équipement\nas-tu à disposition ?' : 'What equipment\ndo you have available?';
  String get equipmentHint          => _fr ? "Sélectionne tout ce qui s'applique" : 'Select all that apply';
  String get equipmentNone          => _fr ? 'Aucun matériel'          : 'No equipment';
  String get equipmentDumbbells     => _fr ? 'Haltères'                : 'Dumbbells';
  String get equipmentBarbell       => _fr ? 'Barre & poids'           : 'Barbell & weights';
  String get equipmentMachines      => _fr ? 'Machines'                : 'Machines';
  String get equipmentBands         => _fr ? 'Résistances'             : 'Resistance bands';
  String get equipmentYogaMat       => _fr ? 'Tapis de yoga'           : 'Yoga mat';
  String get equipmentContinue      => _fr ? 'CONTINUER'               : 'CONTINUE';
  String get equipmentSelectAtLeastOne => _fr ? 'SÉLECTIONNE AU MOINS UN' : 'SELECT AT LEAST ONE';

  // StepTrainingLocation
  String get locationTopBarTitle    => _fr ? "LIEU D'ENTRAÎNEMENT"     : 'TRAINING LOCATION';
  String get locationTitle          => _fr ? "Où tu t'entraînes ?"     : 'Where do you train?';
  String get locationSubtitle       => _fr ? 'Choisis ton environnement de prédilection' : 'Choose your preferred environment';
  String get locationGym            => _fr ? 'Salle de sport'          : 'Gym';
  String get locationGymDetail      => _fr ? 'Machines, câbles, haltères' : 'Machines, cables, dumbbells';
  String get locationHome           => _fr ? 'À la maison'             : 'At home';
  String get locationHomeDetail     => _fr ? 'Poids du corps'          : 'Bodyweight';
  String get locationBoth           => _fr ? 'Les deux'                : 'Both';
  String get locationBothDetail     => _fr ? 'Flexibilité totale'      : 'Total flexibility';

  // StepFrequency
  String get frequencyTopBarTitle   => _fr ? 'FRÉQUENCE'               : 'FREQUENCY';
  String get frequencyTitle         => _fr ? 'Combien de jours par\nsemaine veux-tu t\'entraîner ?' : 'How many days per\nweek do you want to train?';
  String get frequencyHint          => _fr ? 'Fais glisser le curseur pour choisir' : 'Drag the slider to choose';
  String get frequencyNext          => _fr ? 'Suivant'                 : 'Next';
  String get frequencyDay2          => _fr ? '2 jours'                 : '2 days';
  String get frequencyDay3          => _fr ? '3 jours'                 : '3 days';
  String get frequencyDay4          => _fr ? '4 jours'                 : '4 days';
  String get frequencyDay5          => _fr ? '5 jours'                 : '5 days';
  String get frequencyDay6          => _fr ? '6 jours'                 : '6 days';

  /// Returns translated frequency label for dial display (index 0–4 = 2–6 days).
  String freqLabel(int index) {
    switch (index) {
      case 0: return frequencyDay2;
      case 1: return frequencyDay3;
      case 2: return frequencyDay4;
      case 3: return frequencyDay5;
      default: return frequencyDay6;
    }
  }

  // StepHealthProfile
  String get healthProfileTopBarTitle => _fr ? 'Profil santé'          : 'Health profile';
  String get healthProfileTitle     => _fr ? 'Taille, Poids & Âge'    : 'Height, Weight & Age';
  String get healthProfileSubtitle  => _fr ? 'Fais défiler pour entrer tes mesures' : 'Scroll to enter your measurements';
  String get healthProfileHeight    => _fr ? 'TAILLE'                  : 'HEIGHT';
  String get healthProfileWeight    => _fr ? 'POIDS'                   : 'WEIGHT';
  String get healthProfileAge       => _fr ? 'ÂGE'                    : 'AGE';
  String get healthProfileAgeUnit   => _fr ? 'ans'                     : 'yrs';
  String get healthProfileBmi       => _fr ? 'IMC'                     : 'BMI';
  String get healthProfileBmiThin   => _fr ? 'Mince'                   : 'Underweight';
  String get healthProfileBmiNormal => _fr ? 'Normale'                 : 'Normal';
  String get healthProfileBmiOver   => _fr ? 'Surpoids'                : 'Overweight';
  String get healthProfileBmiObese  => _fr ? 'Obésité'                 : 'Obese';
  String get healthProfileContinue  => _fr ? 'Continuer'               : 'Continue';

  // StepCycleAndPregnancy
  String get cycleStepTopBarTitle   => _fr ? 'Santé féminine'          : 'Women\'s health';
  String get cycleStepTitle         => _fr ? 'Santé féminine'          : 'Women\'s health';
  String get cycleStepSubtitle      => _fr ? 'Pour adapter ton plan à ta réalité du moment' : 'To adapt your plan to your current reality';
  String get cycleStatusRegular     => _fr ? 'Cycle\nrégulier'         : 'Regular\ncycle';
  String get cycleStatusRegularSub  => _fr ? 'Sync entraînement'       : 'Training sync';
  String get cycleStatusPregnant    => _fr ? 'Je suis\nenceinte'       : 'I am\npregnant';
  String get cycleStatusPregnantSub => _fr ? 'Programme prénatal'      : 'Prenatal program';
  String get cycleStatusPostpartum  => _fr ? 'Après\ngrossesse'        : 'After\npregnancy';
  String get cycleStatusPostpartumSub => _fr ? 'Post-partum'           : 'Postpartum';
  String get cycleSelectSituation   => _fr ? 'Sélectionne ta situation ci-dessus' : 'Select your situation above';
  String get cycleDurationLabel     => _fr ? 'Durée habituelle de ton cycle' : 'Usual cycle duration';
  String get cycleLastPeriod        => _fr ? 'Dernières règles'        : 'Last period';
  String get cycleAtAGlance         => _fr ? "Ton cycle en un coup d'œil" : 'Your cycle at a glance';
  String get cycleNextPeriodIn      => _fr ? 'Prochaines règles dans'  : 'Next period in';
  String get cycleNextPeriodDays    => _fr ? 'jours'                   : 'days';
  String get cycleNextPeriodToday   => _fr ? "Prochaines règles aujourd'hui" : 'Next period today';
  String get cycleNextPeriodExpected => _fr ? 'Période attendue'       : 'Expected period';
  String get cyclePregnancyWeeksLabel => _fr ? "SEMAINES D'AMÉNORRHÉE" : 'GESTATIONAL WEEKS';
  String get cycleTrimester1Label   => _fr ? '1er trimestre'           : '1st trimester';
  String get cycleTrimester2Label   => _fr ? '2ème trimestre'          : '2nd trimester';
  String get cycleTrimester3Label   => _fr ? '3ème trimestre'          : '3rd trimester';
  String get cycleAdviceT1          => _fr ? 'Marche douce & yoga prénatal. Évite les abdominaux et les efforts intenses.' : 'Gentle walking & prenatal yoga. Avoid abdominals and intense efforts.';
  String get cycleAdviceT2          => _fr ? "Natation & Pilates prénatal. Évite d'être allongée sur le dos après 16 SA." : 'Swimming & prenatal Pilates. Avoid lying on your back after 16 weeks.';
  String get cycleAdviceT3          => _fr ? 'Mobilité douce & respiration consciente. Intensité très modérée recommandée.' : 'Gentle mobility & mindful breathing. Very moderate intensity recommended.';
  String get ppWhenDidYouGiveBirth  => _fr ? 'Quand as-tu accouché ?'  : 'When did you give birth?';
  String get ppAutoCalculate        => _fr ? 'On calcule ta phase de récupération automatiquement' : 'We calculate your recovery phase automatically';
  String get ppSelectBirthDate      => _fr ? "Sélectionne la date d'accouchement" : 'Select your birth date';
  String get ppLessThanOneWeek      => _fr ? "Moins d'une semaine"     : 'Less than one week';
  String get ppWeeksSince           => _fr ? "depuis l'accouchement"   : 'since giving birth';
  String get ppProgramLabel         => _fr ? 'Programme'               : 'Program';
  String get ppPhaseLabel           => _fr ? 'Phase'                   : 'Phase';
  String get cycleCtaStart          => _fr ? 'Commencer FITEVA'        : 'Start FITEVA';
  String get ppPpProgDesc0_2        => _fr ? '0–2 sem. · récupération douce, périnée & repos absolu' : '0–2 wks · gentle recovery, perineum & absolute rest';
  String get ppPpProgDesc2_6        => _fr ? '2–6 sem. · mobilité progressive & renforcement léger' : '2–6 wks · progressive mobility & light strengthening';
  String get ppPpProgDesc6_12       => _fr ? '6–12 sem. · reprise légère & consolidation posturale' : '6–12 wks · light resumption & postural consolidation';
  String get ppPpProgDesc3_6m       => _fr ? "3–6 mois · renforcement progressif & retour à l'effort" : '3–6 months · progressive strengthening & return to effort';
  String get ppPpProgDesc6mPlus     => _fr ? '6+ mois · retour fitness actif & reconditionnement complet' : '6+ months · active fitness return & full reconditioning';

  // StepAvatar
  String get avatarTopBarTitle      => _fr ? 'TA MASCOTTE'             : 'YOUR MASCOT';
  String get avatarChooseTitle      => _fr ? 'Choisis ta mascotte !'   : 'Choose your mascot!';
  String get avatarSubtitle         => _fr ? 'Elle t\'accompagnera tout au long\nde ton aventure FitEva.' : 'It will accompany you throughout\nyour FitEva adventure.';
  String get avatarShapeLabel       => _fr ? 'FORME'                   : 'SHAPE';
  String get avatarMoodLabel        => _fr ? 'HUMEUR'                  : 'MOOD';
  String get avatarMoodHappy        => _fr ? 'Heureuse'                : 'Happy';
  String get avatarMoodExcited      => _fr ? 'Excitée'                 : 'Excited';
  String get avatarMoodProud        => _fr ? 'Fière'                   : 'Proud';
  String get avatarMoodCelebrating  => _fr ? 'En fête'                 : 'Celebrating';
  String get avatarMoodSleepy       => _fr ? 'Fatiguée'                : 'Tired';
  String get avatarCta              => _fr ? 'COMMENCER !'             : 'GET STARTED!';

  // Cycle phase names (used in cycle strip)
  String get cyclePhaseMenstruation => _fr ? 'Menstruation'            : 'Menstruation';
  String get cyclePhaseFollicular   => _fr ? 'Folliculaire'            : 'Follicular';
  String get cyclePhaseOvulation    => _fr ? 'Ovulation'               : 'Ovulation';
  String get cyclePhaseLuteal       => _fr ? 'Lutéale'                 : 'Luteal';

  // Cycle home screen
  String get cycleNextPeriod         => _fr ? 'Prochains règles'         : 'Next period';
  String get cycleMyCycle            => _fr ? 'Mon cycle'                : 'My cycle';
  String get cycleDuration           => _fr ? 'Durée'                   : 'Duration';
  String get cycleCurrentDay         => _fr ? 'Jour actuel'              : 'Current day';
  String get cycleDailyTips          => _fr ? 'Conseils du jour'         : 'Daily tips';
  String get cycleWorkout            => _fr ? 'Entraînement'             : 'Workout';
  String get cycleNutrition          => _fr ? 'Nutrition'                : 'Nutrition';
  String get cycleToday              => _fr ? "Aujourd'hui"              : 'Today';
  String get cyclePast               => _fr ? 'Passée'                   : 'Past';
  String cycleDaysLeft(int d)        => _fr ? 'Dans $d j'                : 'In $d d';
  String get cycleSymptomFlow        => _fr ? 'Flux'                     : 'Flow';
  String get cycleSymptomMood        => _fr ? 'Humeur'                   : 'Mood';
  String get cycleSymptomEnergy      => _fr ? 'Énergie'                  : 'Energy';
  String get cycleSymptomCramps      => _fr ? 'Crampes'                  : 'Cramps';
  String get cycleHowFeeling         => _fr ? 'Comment tu te sens ?'     : 'How are you feeling?';

  // Cycle phase descriptions
  String cyclePhaseDesc(String phase) {
    if (_fr) {
      switch (phase) {
        case 'Règles':       return 'Ton corps se nettoie. Repos, chaleur et douceur sont essentiels.';
        case 'Folliculaire': return "Énergie montante. C'est le moment d'explorer et commencer.";
        case 'Ovulation':    return 'Pic d\'énergie et de confiance. Performe et connecte-toi.';
        default:             return 'Phase introspective. Écoute tes besoins et ralentis.';
      }
    } else {
      switch (phase) {
        case 'Règles':       return 'Your body is cleansing. Rest, warmth and gentleness are key.';
        case 'Folliculaire': return 'Rising energy. Time to explore and start new things.';
        case 'Ovulation':    return 'Peak energy and confidence. Perform and connect.';
        default:             return 'Introspective phase. Listen to your needs and slow down.';
      }
    }
  }

  // Cycle phase tips
  ({String workout, String nutrition}) cyclePhaseTips(String phase) {
    if (_fr) {
      switch (phase) {
        case 'Règles':       return (workout: 'Yoga doux, marche légère — évite l\'intensité élevée.', nutrition: 'Favorise le fer (épinards, lentilles) et le magnésium.');
        case 'Folliculaire': return (workout: 'Cardio, HIIT et force — ton énergie est au top.',       nutrition: 'Protéines et glucides complexes pour alimenter l\'effort.');
        case 'Ovulation':    return (workout: 'Séances intenses, sports collectifs — performance maximale.', nutrition: 'Légumes crucifères et aliments anti-inflammatoires.');
        default:             return (workout: 'Pilates, natation, yoga — écoute ton corps.',            nutrition: 'Limite le sel et le sucre, privilégie les oméga-3.');
      }
    } else {
      switch (phase) {
        case 'Règles':       return (workout: 'Gentle yoga, light walking — avoid high intensity.',     nutrition: 'Prioritize iron (spinach, lentils) and magnesium.');
        case 'Folliculaire': return (workout: 'Cardio, HIIT and strength — your energy is at its peak.', nutrition: 'Proteins and complex carbs to fuel your effort.');
        case 'Ovulation':    return (workout: 'Intense sessions, team sports — peak performance.',      nutrition: 'Cruciferous vegetables and anti-inflammatory foods.');
        default:             return (workout: 'Pilates, swimming, yoga — listen to your body.',         nutrition: 'Limit salt and sugar, prioritize omega-3s.');
      }
    }
  }

  // ── Cycle Insights (dashboard avancé) ──────────────────────────────────────
  String get insightsMenuLabel      => _fr ? 'Insights'                       : 'Insights';
  String get insightsTitle          => _fr ? 'Tableau de bord'                : 'Dashboard';
  String get insightsSubtitle       => _fr ? 'Analyse de tes 3 derniers mois' : 'Analysis of your last 3 months';
  String get insightsSymptomsChart  => _fr ? 'Graphique des symptômes'        : 'Symptoms chart';
  String get insightsSymptomsSub    => _fr ? 'Fréquence sur la période'       : 'Frequency over the period';
  String get insightsMoodCorrelation => _fr ? 'Corrélation humeur / cycle'    : 'Mood / cycle correlation';
  String get insightsMoodSub        => _fr ? 'Humeur moyenne par phase'       : 'Average mood by phase';
  String get insightsMonthlyTrends  => _fr ? 'Tendances mensuelles'           : 'Monthly trends';
  String get insightsMonthlySub     => _fr ? 'Jours suivis par mois'          : 'Days tracked per month';
  String get insightsEmpty          => _fr
      ? 'Pas encore assez de données. Continue à suivre ton cycle pour voir tes tendances ici.'
      : 'Not enough data yet. Keep tracking your cycle to see your trends here.';
  String get insightsNoMoodData     => _fr ? 'Pas assez de données d\'humeur' : 'Not enough mood data';
  String get insightsDaysLogged     => _fr ? 'jours suivis'                   : 'days tracked';
  List<String> get insightsMoodLabels => _fr
      ? ['Super', 'Bien', 'Ok', 'Faible', 'Calme']
      : ['Great', 'Good', 'Okay', 'Low', 'Calm'];

  // ── Écran "règles en retard" ───────────────────────────────────────────────
  String get lateTitle           => _fr ? 'Règles en retard'                    : 'Period is late';
  String lateDelayDays(int d)    => _fr ? (d > 1 ? '$d jours de retard' : '$d jour de retard')
                                        : (d > 1 ? '$d days late' : '$d day late');
  String get lateStatDueDate     => _fr ? 'Date prévue'                         : 'Due date';
  String get lateStatDelay       => _fr ? 'Retard'                              : 'Delay';
  String get lateStatUsualCycle  => _fr ? 'Cycle habituel'                      : 'Usual cycle';
  String get lateStatCurrentCycle => _fr ? 'Cycle actuel'                       : 'Current cycle';
  String get lateStatLastPeriod  => _fr ? 'Dernières règles'                    : 'Last period';
  String get lateStatOvulation   => _fr ? 'Ovulation estimée'                   : 'Estimated ovulation';
  String get lateReassurance     => _fr
      ? 'Un léger retard est fréquent et souvent sans gravité. Le stress, la fatigue, '
        'un changement de routine, un voyage, des variations hormonales ou certains '
        'médicaments peuvent en être la cause.'
      : 'A slight delay is common and usually not a cause for concern. Stress, fatigue, '
        'a change in routine, travel, hormonal shifts or certain medications can all play a role.';
  String get lateConsultTitle    => _fr ? 'Quand consulter'                     : 'When to see a doctor';
  String get lateConsultText     => _fr
      ? 'Si le retard devient inhabituel pour vous, dure plusieurs semaines, ou '
        's\'accompagne de douleurs importantes ou de saignements anormaux, consultez '
        'un professionnel de santé.'
      : 'If the delay is unusual for you, lasts several weeks, or comes with significant '
        'pain or abnormal bleeding, please consult a healthcare professional.';
  String get latePregnancyTest   => _fr
      ? 'Si vous avez eu un rapport non protégé et que vos règles sont en retard, '
        'un test de grossesse peut être envisagé.'
      : 'If you\'ve had unprotected intercourse and your period is late, taking a '
        'pregnancy test may be worth considering.';
  String get lateBtnLog          => _fr ? 'Enregistrer mes règles'              : 'Log my period';
  String get lateBtnRemindTomorrow => _fr ? 'Me rappeler demain'                : 'Remind me tomorrow';
  String get lateBtnMore         => _fr ? 'En savoir plus'                     : 'Learn more';
  String get lateCausesTitle     => _fr ? 'Causes possibles d\'un retard'       : 'Possible causes of a delay';
  String get lateCauseStress     => _fr ? 'Stress'                              : 'Stress';
  String get lateCauseFatigue    => _fr ? 'Fatigue'                             : 'Fatigue';
  String get lateCauseRoutine    => _fr ? 'Changement de routine'               : 'Change in routine';
  String get lateCauseTravel     => _fr ? 'Voyage'                              : 'Travel';
  String get lateCauseHormonal   => _fr ? 'Variations hormonales'               : 'Hormonal changes';
  String get lateCauseMeds       => _fr ? 'Certains médicaments'                : 'Certain medications';

  // Date picker titles
  String get datePickerLastPeriodTitle   => _fr ? 'Dernieres regles'     : 'Last period';
  String get datePickerLastPeriodSub     => _fr ? 'Date du premier jour' : 'First day date';
  String get datePickerBirthTitle        => _fr ? "Date d'accouchement"  : 'Birth date';
  String get datePickerBirthSub         => _fr ? 'Quand est ne votre bebe ?' : 'When was your baby born?';

  // ── Programme detail screen ────────────────────────────────────────────────
  String get progAbout          => _fr ? 'À propos'         : 'About';
  String get progSessions       => _fr ? 'Les séances'      : 'Sessions';
  String get progWeeks          => _fr ? 'Semaines'         : 'Weeks';
  String get progDescription    => _fr ? 'Description'      : 'Description';
  String get progCoach          => _fr ? 'Ton coach'        : 'Your coach';
  String get progObjectives     => _fr ? 'Objectifs'        : 'Objectives';
  String get progPhases         => _fr ? 'Les phases'       : 'Phases';
  String get progCoachName      => _fr ? 'Sarah M.'         : 'Sarah M.';
  String get progCoachTitle     => _fr ? 'Coach certifiée'  : 'Certified coach';
  String get progCoachRating    => _fr ? '4.9 · Expert'     : '4.9 · Expert';
  String get progFollow         => _fr ? 'Suivre'           : 'Follow';
  String get progNextSession    => _fr ? 'Prochaine séance' : 'Next session';
  String get progSession        => _fr ? 'Séance'           : 'Session';
  String get progCompleted      => _fr ? '✓ TERMINÉ'        : '✓ DONE';
  String get progProgramme      => _fr ? 'PROGRAMME'        : 'PROGRAM';
  String get progSeances        => _fr ? 'séances'          : 'sessions';
  String get progCalPerSession  => _fr ? 'Cal/séance'       : 'Cal/session';
  String get progDone           => _fr ? 'Programme terminé ✓' : 'Program done ✓';
  String get progStart          => _fr ? 'Commencer le programme' : 'Start program';
  String get progCalUnit        => 'cal';
  String get progPtsUnit        => 'pts';

  // ── Santé screen ── (UI labels only, content data stays hardcoded) ─────────
  String get santeSanteEyebrow     => _fr ? 'SANTÉ & BIEN-ÊTRE'            : 'HEALTH & WELLNESS';
  String get santeMySpace          => _fr ? 'Mon Espace Santé'              : 'My Health Space';
  String get santeWatch            => _fr ? 'Regarder'                      : 'Watch';
  String get santeCall             => _fr ? 'Appeler'                       : 'Call';
  String get santeAppointment      => _fr ? 'Rendez-vous'                   : 'Appointment';
  String get santeLikeBtn          => _fr ? "J'aime"                        : 'Like';
  String get santeShareBtn         => _fr ? 'Partager'                      : 'Share';
  String get santeFollowBtn        => _fr ? 'Suivre'                        : 'Follow';
  String get santeInThisSeries     => _fr ? 'Dans cette série'              : 'In this series';
  String get santeEpisodeLabel     => _fr ? 'Épisode'                       : 'Episode';
  String get santeSendBtn          => _fr ? 'Envoyer'                       : 'Send';
  String get santeSeriesSection    => _fr ? 'Séries vidéo'                  : 'Video series';
  String get santeArticlesSection  => _fr ? 'Articles'                      : 'Articles';
  String get santeLexiqueSection   => _fr ? 'Lexique médical'               : 'Medical lexicon';
  String get santeLexiqueSubtitle  => _fr ? 'Termes & définitions'          : 'Terms & definitions';
  String get santeLexiqueHint      => _fr ? 'Rechercher un terme…'          : 'Search a term…';
  String get santeYourQuestion     => _fr ? 'Votre question'                : 'Your question';
  String get santeAnonPost         => _fr ? 'Publication anonyme'           : 'Anonymous post';
  String get santeAskDoctorHint    => _fr ? 'Poser une question à un médecin…' : 'Ask a doctor a question…';
  String santeSeriesCount(int n)       => _fr ? '$n séries · médecins experts' : '$n series · expert doctors';
  String santeArticlesCount(int n)     => _fr ? '$n articles scientifiques'    : '$n scientific articles';
  String santeSpecialistsCount(int n) => _fr ? 'Tunisie · $n spécialistes'  : 'Tunisia · $n specialists';
  String santeEpisodesCount(int n)    => _fr ? '$n épisodes'                : '$n episodes';
  String santeConsultationsCount(int n) => _fr ? '$n consultations'         : '$n consultations';

  // ── Community screens ──────────────────────────────────────────────────────
  String get communityTopPosts          => _fr ? 'Top Posts'                  : 'Top Posts';
  String get communityEventsLabel       => _fr ? 'Événements'                 : 'Events';
  String get communityFilters           => _fr ? 'Filtres'                    : 'Filters';
  String get communityNewPost           => _fr ? 'NOUVEAU POST'               : 'NEW POST';
  String get communityShareWith         => _fr ? 'Partage avec la communauté' : 'Share with the community';
  String get communityPublish           => _fr ? 'Publier'                    : 'Publish';
  String get communityPublished         => _fr ? 'Post publié !'              : 'Post published!';
  String get communityNewEvent          => _fr ? 'NOUVEL ÉVÉNEMENT'           : 'NEW EVENT';
  String get communityInvite            => _fr ? 'Invite la communauté'       : 'Invite the community';
  String get communityPublishEvent      => _fr ? "Publier l'événement"        : 'Publish event';
  String get communityOrganizeEvent     => _fr ? 'Organiser un événement'     : 'Organize an event';
  String get communityEventPublished    => _fr ? 'Événement publié !'         : 'Event published!';
  String get communityOrganizerLabel    => _fr ? 'ORGANISATEUR'               : 'ORGANIZER';
  String get communityOrganizerSub      => _fr ? 'Organisateur'               : 'Organizer';
  String get communityParticipantsLabel => _fr ? 'PARTICIPANTS'               : 'PARTICIPANTS';
  String get communityAboutLabel        => _fr ? 'À PROPOS'                   : 'ABOUT';
  String get communityMessageBtn        => _fr ? 'Message'                    : 'Message';
  String get communityComments          => _fr ? 'Commentaires'               : 'Comments';
  String get communityNoComments        => _fr ? 'Aucun commentaire pour l\'instant.\nSois la première ! 💬'
                                               : 'No comments yet.\nBe the first! 💬';
  String get communityAddComment        => _fr ? 'Ajouter un commentaire…'    : 'Add a comment…';
  String get communityPartnerLabel      => _fr ? 'PARTENAIRE'                 : 'PARTNER';
  String get communityDescribeProfile   => _fr ? 'Décris ton profil'          : 'Describe your profile';
  String get communityPublishProfile    => _fr ? 'Publier mon profil'         : 'Publish my profile';
  String get communityPublishProfileFull => _fr ? 'Publier mon profil partenaire' : 'Publish my partner profile';
  String get communityProfilePublished  => _fr ? 'Profil publié !'            : 'Profile published!';
  String get communityMessageSent       => _fr ? 'Message envoyé'             : 'Message sent';
  String get communitySendMessage       => _fr ? 'Envoyer un message'         : 'Send a message';
  String get communityJoinBtn           => _fr ? 'Rejoindre'                  : 'Join';
  String get communityJoinPending       => _fr ? 'En attente'                 : 'Pending';
  String get communityJoinAccepted      => _fr ? 'Accepté ! ' : 'Accepted! ';
  String get communityRequestsReceived  => _fr ? 'Demandes reçues'            : 'Requests received';
  String get communityNoRequests        => _fr ? 'Aucune demande en attente.' : 'No pending requests.';
  // ── Partner tab / formulaire / demandes ─────────────────────────────────────
  String get communityPartnerTitle        => _fr ? 'Partenaires'                  : 'Partners';
  String get communityPartnerSearching    => _fr ? 'Recherche…'                   : 'Searching…';
  String communityPartnerProfilesCount(int n) =>
      _fr ? '$n profil${n > 1 ? 's' : ''}' : '$n profile${n > 1 ? 's' : ''}';
  String get communityPartnerSearch       => _fr ? 'Rechercher'                   : 'Search';
  String get communityPartnerSearchHint   => _fr ? 'Nom, objectif, région…'       : 'Name, goal, region…';
  String get communityCancel              => _fr ? 'Annuler'                      : 'Cancel';
  String get communityClose               => _fr ? 'Fermer'                       : 'Close';
  String communityPartnerFiltersCount(int n) =>
      n > 0 ? '${_fr ? "Filtres" : "Filters"} ($n)' : (_fr ? 'Filtres' : 'Filters');
  String get communityPartnerEmptyTitle    => _fr ? 'Aucun partenaire pour l\'instant' : 'No partners yet';
  String get communityPartnerEmptySubtitle => _fr
      ? 'Sois la première à publier ton profil et\ntrouve ta partenaire d\'entraînement idéale.'
      : 'Be the first to publish your profile and\nfind your ideal workout partner.';
  String get communityPartnerNoResultsTitle    => _fr ? 'Aucun résultat' : 'No results';
  String get communityPartnerNoResultsSubtitle => _fr
      ? 'Essaie d\'élargir tes critères de\nrecherche ou de filtres.'
      : 'Try widening your search\nor filter criteria.';
  String get communityPartnerReset         => _fr ? 'Réinitialiser'               : 'Reset';
  String get communityPartnerApply         => _fr ? 'Appliquer'                   : 'Apply';
  String get communityPartnerYouSuffix     => _fr ? '· toi'                       : '· you';
  String get communityPartnerPublicListing => _fr ? 'Ton annonce publique'        : 'Your public listing';
  String get communityPartnerFilterTitle   => _fr ? 'Filtrer'                     : 'Filter';
  String get communityPartnerGoalLabel     => _fr ? 'Objectif'                    : 'Goal';
  String get communityPartnerRegionLabel   => _fr ? 'Région'                      : 'Region';
  String get communityPartnerFrequencyLabel => _fr ? 'Fréquence'                  : 'Frequency';
  String get communityPartnerInterestsSection => _fr ? 'CENTRES D\'INTÉRÊT'       : 'INTERESTS';
  String get communityPartnerContactSection   => _fr ? 'CONTACT'                  : 'CONTACT';
  String get communityPartnerNoContact     => _fr ? 'Aucune coordonnée renseignée.' : 'No contact info provided.';
  String get communityPartnerLinkError     => _fr ? 'Impossible d\'ouvrir ce lien.' : 'Could not open this link.';
  String get communityPartnerAboutOptional => _fr ? 'À propos de toi  (optionnel)' : 'About you  (optional)';
  String get communityPartnerContactPrompt => _fr
      ? 'Comment te contacter une fois accepté ? (optionnel)'
      : 'How to contact you once accepted? (optional)';
  String get communityPartnerDescHint      => _fr
      ? 'Je cherche une partenaire pour salle 3x/semaine à Sousse…'
      : 'Looking for a gym partner 3x/week in Sousse…';
  String get communityPartnerWhatsappHint  => _fr ? 'Numéro WhatsApp'             : 'WhatsApp number';
  String get communityPartnerInstagramHint => _fr ? '@ton_instagram'              : '@your_instagram';
  String get communityPartnerFacebookHint  => _fr ? 'Profil ou page Facebook'     : 'Facebook profile or page';
  String get communityPartnerPublishError  => _fr
      ? 'Erreur lors de la publication. Vérifiez votre connexion.'
      : 'Error publishing. Please check your connection.';
  String get communityPartnerAsWho         => _fr ? 'Publier en tant que'         : 'Publish as';
  String communityPartnerCharCount(int n)  => '$n/240';
  String get communityPartnerYouLabel      => _fr ? 'Toi'                         : 'You';

  // Options (identifiants stockés en français — seul l'affichage est traduit)
  String communityPartnerGoalOption(String v) {
    switch (v) {
      case 'Tous':           return _fr ? 'Tous'            : 'All';
      case 'Perdre du poids': return _fr ? 'Perdre du poids' : 'Lose weight';
      case 'Tonifier':       return _fr ? 'Tonifier'         : 'Tone up';
      case 'Prise de masse':
      case 'Masse':          return _fr ? 'Prise de masse'   : 'Build muscle';
      case 'Bien-être':      return _fr ? 'Bien-être'        : 'Wellbeing';
      default:                return v;
    }
  }

  String communityPartnerLevelOption(String v) {
    switch (v) {
      case 'Tous':           return _fr ? 'Tous'            : 'All';
      case 'Débutant':       return _fr ? 'Débutant'         : 'Beginner';
      case 'Intermédiaire':  return _fr ? 'Intermédiaire'    : 'Intermediate';
      case 'Avancé':         return _fr ? 'Avancé'           : 'Advanced';
      default:                return v;
    }
  }

  String communityPartnerFreqOption(String v) {
    if (!_fr) {
      final n = v.split('x').first;
      return '${n}x / week';
    }
    return v;
  }

  String get communityPartnerRegionAll => _fr ? 'Tous' : 'All';
  String get communityPartnerDecline => _fr ? 'Refuser'  : 'Decline';
  String get communityPartnerAccept  => _fr ? 'Accepter' : 'Accept';

  String get communityReport            => _fr ? 'Signaler ce profil'         : 'Report this profile';
  String get communityHidePosts         => _fr ? 'Masquer les publications'   : 'Hide posts';
  String get communityCannotLoad        => _fr ? 'Impossible de charger ce profil' : 'Cannot load this profile';
  String get communityTagsLabel         => 'TAGS';
  String get communityLevelLabel        => _fr ? 'Niveau'                     : 'Level';
  String get communityPublishCommunity  => _fr ? 'Publier sur la communauté'  : 'Post to the community';
  String communityXPToNext(int n)       => _fr ? '$n XP avant le prochain niveau' : '$n XP to next level';
  String communityPlaces(int n)         => _fr ? '$n places'                  : '$n spots';
  String communityParticipantsCount(int n) => '$n participant${n > 1 ? 's' : ''}';
  String communityHaveJoined(int n)     => _fr ? 'ont rejoint cet événement'  : 'have joined this event';
  String get communityAvailableSpots   => _fr ? 'Places disponibles'          : 'Available spots';

  // ── Badge selfie screen ────────────────────────────────────────────────────
  String get badgeSelfieTitle     => _fr ? 'BADGE SELFIE'                    : 'BADGE SELFIE';
  String get badgeProgCompleted   => _fr ? 'PROGRAMME COMPLÉTÉ'              : 'PROGRAM COMPLETED';
  String get badgeSelfieBtn       => 'SELFIE';
  String get badgeMoveHint        => _fr ? 'DÉPLACE · REDIMENSIONNE'         : 'MOVE · RESIZE';
  String get badgeHeadline1       => _fr ? 'TON TROPHÉE,'                   : 'YOUR TROPHY,';
  String get badgeHeadline2       => _fr ? "TU L'AS MÉRITÉ."                : 'YOU EARNED IT.';
  String get badgeSubtext         => _fr ? 'Prends un selfie et partage ta victoire.' : 'Take a selfie and share your victory.';
  String get badgeSavedGallery    => _fr ? 'Sauvegardé dans la galerie !'   : 'Saved to gallery!';
  String get badgeDownloaded      => _fr ? 'Téléchargé !'                   : 'Downloaded!';
  String get badgeMesTophees      => _fr ? 'MES TROPHÉES'                   : 'MY TROPHIES';
  String get badgeSelfieHint      => _fr ? 'Appuie sur un badge débloqué pour le selfie' : 'Tap an unlocked badge for a selfie';
  String get badgeFitEva          => 'FITEVA';
  String get badgeExportBtn      => _fr ? 'EXPORTER'                         : 'EXPORT';
  String get badgeSavedBtn       => _fr ? 'SAUVÉ !'                         : 'SAVED!';
  String get badgeGalleryBtn     => _fr ? 'GALERIE'                         : 'GALLERY';

// ── Home screen (additional keys) ─────────────────────────────────────────
  String get homeProgramme      => _fr ? 'PROGRAMME'              : 'PROGRAM';
  String get homeSerieActive    => _fr ? 'SÉRIE ACTIVE'           : 'ACTIVE SERIES';
  String get homeJours          => _fr ? 'JOURS'                  : 'DAYS';
  String get homeEnFeu          => _fr ? '🔥 EN FEU'              : '🔥 ON FIRE';
  String homeDoneCount(int done) => _fr ? '$done/7 FAITS'         : '$done/7 DONE';

// ── Referral card ──────────────────────────────────────────────────────────
  String get referralTitle       => _fr ? 'INVITE & GAGNE'                           : 'INVITE & EARN';
  String get referralHeadline    => _fr ? 'Scratch & Débloque\ntes récompenses 🎁'   : 'Scratch & Unlock\nyour rewards 🎁';
  String get referralHint        => _fr ? 'Gratte chaque carte pour révéler ta récompense' : 'Scratch each card to reveal your reward';
  String get referralScratch     => _fr ? 'Gratte !'                                 : 'Scratch!';
  String get referralAllUnlocked => _fr ? 'Toutes les récompenses débloquées !'     : 'All rewards unlocked!';
  String get referralCodeLabel   => _fr ? 'TON CODE DE PARRAINAGE'                  : 'YOUR REFERRAL CODE';
  String get referralShare       => _fr ? "Partager le lien d'invitation"            : 'Share invitation link';
  String get referralFriends     => _fr ? 'Amies inscrites via ton lien'             : 'Friends signed up via your link';
  String get referralRegistered  => _fr ? 'Inscrite ✔'                               : 'Registered ✔';
  String get referralPending     => _fr ? 'En attente…'                              : 'Pending…';
  String get referralShareTitle  => _fr ? 'Partage avec tes amies 🎁'               : 'Share with your friends 🎁';
  String get referralCopied      => _fr ? 'Message copié — colle-le dans WhatsApp ou Insta !' : 'Message copied — paste it in WhatsApp or Insta!';
  String get referralCopyMsg     => _fr ? 'Copier le message'                        : 'Copy message';
  String referralNeedMore(int n) => _fr ? 'Encore $n amie${n > 1 ? 's' : ''} pour ta prochaine récompense' : '$n more friend${n > 1 ? 's' : ''} for your next reward';
  String referralCodeCopied(String code) => _fr ? 'Code $code copié !' : 'Code $code copied!';

// ── Boutique screen ────────────────────────────────────────────────────────
  String get boutiqueALaUne       => _fr ? 'À LA UNE'               : 'FEATURED';
  String get boutiquePartner      => _fr ? 'Devenir partenaire'      : 'Become a partner';
  String get boutiquePartnerSub   => _fr ? 'Rejoignez notre réseau et bénéficiez de plus de visibilité.' : 'Join our network and gain more visibility.';
  String get boutiquePartenaires  => _fr ? 'PARTENAIRES'             : 'PARTNERS';
  String get boutiqueVoirPlus     => _fr ? 'Voir plus'               : 'See more';
  String get boutiqueAucunProduit => _fr ? 'Aucun produit trouvé'    : 'No products found';
  String get boutiqueAucunArticle => _fr ? 'Aucun article ne correspond\nà tes filtres actuels.' : 'No items match\nyour current filters.';
  String get boutiqueReset        => _fr ? 'Réinitialiser les filtres' : 'Reset filters';
  String get boutiqueTrier        => _fr ? 'Trier'                   : 'Sort';
  String get boutiqueEchange      => _fr ? 'Échangé'                 : 'Redeemed';

// ── Boutique detail screen ─────────────────────────────────────────────────
  String get detailOffreLimitee   => _fr ? 'OFFRE LIMITÉE'           : 'LIMITED OFFER';
  String get detailSurSite        => _fr ? 'sur le site'             : 'on the website';
  String get detailResume         => _fr ? "Résumé de l'offre"       : 'Offer summary';
  String get detailCout           => _fr ? "Coût de l'offre"         : 'Offer cost';
  String get detailEtoiles        => _fr ? 'étoiles'                 : 'stars';
  String get detailValable        => _fr ? "Valable jusqu'au"        : 'Valid until';
  String get detailNonPrecise     => _fr ? 'Non précisé'             : 'Not specified';
  String get detailExpireDemain   => _fr ? 'Expire demain !'         : 'Expires tomorrow!';
  String get detailMesEtoiles     => _fr ? 'Mes étoiles'             : 'My stars';
  String get detailDisponibles    => _fr ? 'disponibles'             : 'available';
  String get detailAPropos        => _fr ? "À propos de l'offre"     : 'About the offer';
  String get detailComment        => _fr ? 'Comment ça marche ?'     : 'How does it work?';
  String get detailStep1          => _fr ? 'Appuie sur "Échanger mes étoiles"' : 'Tap "Exchange my stars"';
  String get detailStep2          => _fr ? 'Reçois ton code promo et QR code' : 'Receive your promo code and QR code';
  String get detailStep3          => _fr ? 'Télécharge ta carte en PDF' : 'Download your card as PDF';
  String get detailStep4          => _fr ? 'Utilise-le lors de ta commande' : 'Use it when ordering';
  String get detailOffresSimilaires => _fr ? 'Offres similaires'     : 'Similar offers';
  String get detailDejaEchange    => _fr ? 'Offre déjà échangée — consulte ton code ci-dessus' : 'Offer already redeemed — see your code above';
  String get detailEtoilesInsuff  => _fr ? 'Étoiles insuffisantes'   : 'Insufficient stars';
  String get detailDejaEchangeBtn => _fr ? 'Offre déjà échangée'     : 'Offer already redeemed';
  String detailManque(int n)      => _fr ? 'Il te manque $n étoile${n > 1 ? 's' : ''} pour débloquer cette offre' : 'You need $n more star${n > 1 ? 's' : ''} to unlock this offer';
  String detailEchangerEtoiles(int n) => _fr ? 'Échanger $n étoiles' : 'Exchange $n stars';
  String detailCopierCode(String c)   => _fr ? 'Copier le code : $c' : 'Copy code: $c';

// ── All partenaires screen ─────────────────────────────────────────────────
  String get allPartBoutique     => _fr ? 'Boutique'                  : 'Shop';
  String get allPartPartenaires  => _fr ? 'Partenaires'               : 'Partners';
  String get allPartSearch       => _fr ? 'Rechercher un partenaire…' : 'Search a partner…';
  String get allPartAucun        => _fr ? 'Aucun partenaire trouvé'   : 'No partner found';
  String get allPartEssayer      => _fr ? 'Essayez un autre filtre ou mot-clé.' : 'Try another filter or keyword.';

// ── Partner form screen ────────────────────────────────────────────────────
  String get formDevenirPart     => _fr ? 'Devenir partenaire'        : 'Become a partner';
  String get formSubtitle        => _fr ? 'Rejoignez 150+ marques sur Fiteva et touchez\nune communauté de 12 000 mamans.' : 'Join 150+ brands on Fiteva and reach\na community of 12,000 moms.';
  String get formCoordonnees     => _fr ? 'Vos coordonnées'           : 'Your details';
  String get formNomComplet      => _fr ? 'Nom complet *'             : 'Full name *';
  String get formChampRequis     => _fr ? 'Champ requis'              : 'Required field';
  String get formEmail           => _fr ? 'Email *'                   : 'Email *';
  String get formEmailInvalid    => _fr ? 'Email invalide'            : 'Invalid email';
  String get formTelephone       => _fr ? 'Téléphone'                 : 'Phone';
  String get formVotreMarque     => _fr ? 'Votre marque'              : 'Your brand';
  String get formNomMarque       => _fr ? 'Nom de la marque *'        : 'Brand name *';
  String get formSiteWeb         => _fr ? 'Site web ou Instagram'     : 'Website or Instagram';
  String get formPresenter       => _fr ? 'Présentez votre marque'    : 'Introduce your brand';
  String get formProduits        => _fr ? 'Vos produits, vos valeurs…' : 'Your products, your values…';
  String get formCategorie       => _fr ? 'Catégorie'                 : 'Category';
  String get formSelectCat       => _fr ? 'Veuillez sélectionner une catégorie.' : 'Please select a category.';
  String get formAcceptCond      => _fr ? 'Veuillez accepter les conditions partenaires.' : 'Please accept the partner conditions.';
  String get formJAccepte        => _fr ? "J'accepte les "            : 'I accept the ';
  String get formConditions      => _fr ? 'conditions du programme partenaire' : 'partner program conditions';
  String get formDeFiteva        => _fr ? ' de Fiteva.'               : ' of Fiteva.';
  String get formEnvoyer         => _fr ? 'Envoyer ma candidature'    : 'Send my application';
  String get formSecurise        => _fr ? 'Données sécurisées — aucun partage tiers' : 'Secured data — no third-party sharing';
  String get formCandidature     => _fr ? 'Candidature envoyée !'     : 'Application sent!';
  String get formRecontact       => _fr ? 'Notre équipe vous recontactera sous 48h.' : 'Our team will contact you within 48h.';
  String get formVerif           => _fr ? 'Vérification du dossier'   : 'File review';
  String get formAppel           => _fr ? 'Appel de présentation Fiteva' : 'Fiteva presentation call';
  String get formMiseEnLigne     => _fr ? 'Mise en ligne de la boutique' : 'Shop goes live';
  String get formParfait         => _fr ? 'Parfait, merci !'          : 'Perfect, thank you!';

// ── Promo modal ────────────────────────────────────────────────────────────
  String get promoCodeTitle      => _fr ? 'Ton code promo'            : 'Your promo code';
  String get promoScanQR         => _fr ? 'Scanne le QR code'         : 'Scan the QR code';
  String get promoOuSaisis       => _fr ? 'ou saisis le code manuellement lors de ta commande en ligne.' : 'or enter the code manually when ordering online.';
  String get promoReserve        => _fr ? "Réservé aux abonnés TSE"   : 'For TSE subscribers only';
  String get promoPersonnel      => _fr ? 'Carte personnelle · Non cessible · Généré via l\'app TSE' : 'Personal card · Non-transferable · Generated via TSE app';
  String get promoReady          => _fr ? 'Ta récompense est prête !' : 'Your reward is ready!';
  String get promoUseCode        => _fr ? 'Utilise le code ou le QR code sur le site partenaire.' : 'Use the code or QR code on the partner site.';
  String get promoCodeLabel      => _fr ? 'Code promo'                : 'Promo code';
  String get promoCopied         => _fr ? 'Copié !'                   : 'Copied!';
  String get promoCopier         => _fr ? 'Copier'                    : 'Copy';
  String get promoOuManuel       => _fr ? 'Ou saisis le code manuellement lors de ta commande.' : 'Or enter the code manually when ordering.';
  String get promoTelecharger    => _fr ? 'Télécharger en PDF'        : 'Download as PDF';
  String get promoFermer         => _fr ? 'Fermer'                    : 'Close';

// ── UserProfileScreen ──────────────────────────────────────────────────────
  String get profileApercu       => _fr ? 'Aperçu'                    : 'Overview';
  String get profilePosts        => _fr ? 'Posts'                     : 'Posts';
  String get profileEvenements   => _fr ? 'Événements'               : 'Events';
  String get profileSuivi        => _fr ? 'Suivi'                     : 'Follow';
  String get profileSuivre       => _fr ? 'Suivre'                    : 'Follow';
  String get profileStats        => _fr ? 'STATISTIQUES'              : 'STATISTICS';
  String get profileSeances      => _fr ? 'Séances'                   : 'Sessions';
  String get profileSerie        => _fr ? 'Série en cours'            : 'Current streak';
  String get profileCalories     => _fr ? 'Calories brûlées'          : 'Calories burned';
  String get profileTemps        => _fr ? 'Temps total'               : 'Total time';
  String get profileRepartition  => _fr ? 'RÉPARTITION'               : 'BREAKDOWN';
  String get profileCompletes    => _fr ? 'Complétés'                 : 'Completed';
  String get profileProgrammes   => _fr ? 'Programmes'               : 'Programs';
  String get profileEnCours      => _fr ? 'En cours'                  : 'In progress';
  String get profileSignaler     => _fr ? 'Signaler ce profil'        : 'Report this profile';
  String get profileMasquer      => _fr ? 'Masquer les publications'  : 'Hide posts';
  String get profileAnnuler      => _fr ? 'Annuler'                   : 'Cancel';
  String get profileAucunPost    => _fr ? 'Aucun post publié'         : 'No posts yet';
  String get profileAucunEvt     => _fr ? 'Aucun événement créé'      : 'No events created';
  String get profileAVenir       => _fr ? 'À VENIR'                   : 'UPCOMING';
  String get profilePasses       => _fr ? 'PASSÉS'                    : 'PAST';
  String get profileProgEnCours  => _fr ? 'PROGRAMMES EN COURS'       : 'PROGRAMS IN PROGRESS';
  String get profileImpossible   => _fr ? 'Impossible de charger ce profil' : 'Cannot load this profile';
  String get profileDebutant     => _fr ? 'Débutant'                  : 'Beginner';
  String get profileInter        => _fr ? 'Intermédiaire'             : 'Intermediate';
  String get profileAvance       => _fr ? 'Avancé'                    : 'Advanced';
  String get profileExpert       => _fr ? 'Expert'                    : 'Expert';
  String profileNiveau(String lbl) => _fr ? 'Niveau $lbl'            : 'Level $lbl';
  String profileXPToNext(int n)    => _fr ? '$n XP avant le prochain niveau' : '$n XP to next level';
  String profileTimeAgoMin(int n)  => _fr ? 'il y a ${n} min'        : '${n}m ago';
  String profileTimeAgoH(int n)    => _fr ? 'il y a ${n}h'           : '${n}h ago';
  String profileTimeAgoD(int n)    => _fr ? 'il y a ${n}j'           : '${n}d ago';

  // ── Cycle home screen ──────────────────────────────────────────────────────
  String get cycleFlux          => _fr ? 'Flux'         : 'Flow';
  String get cycleHumeur        => _fr ? 'Humeur'       : 'Mood';
  String get cycleEnergie       => _fr ? 'Énergie'      : 'Energy';
  String get cycleCrampes       => _fr ? 'Crampes'      : 'Cramps';
  String get cycleRegles        => _fr ? 'Règles'       : 'Period';
  String get cycleFolliculaire  => _fr ? 'Folliculaire' : 'Follicular';
  String get cycleOvulationLabel => _fr ? 'Ovulation'   : 'Ovulation';
  String get cycleLuteale       => _fr ? 'Lutéale'      : 'Luteal';
  String get cycleJour          => _fr ? 'Jour'         : 'Day';
  String get cycleCeMois        => _fr ? 'Ce mois'      : 'This month';
  String get cycleAuj           => _fr ? 'auj.'         : 'today';

  // ── Cycle header ───────────────────────────────────────────────────────────
  String get cycleHeaderTitle    => _fr ? 'MON CYCLE'   : 'MY CYCLE';
  String get cycleHeaderRoue     => _fr ? 'Roue'        : 'Wheel';
  String get cycleHeaderCal      => _fr ? 'Calendrier'  : 'Calendar';
  String get cycleHeaderGrossesse=> _fr ? 'Grossesse'   : 'Pregnancy';

  // ── Calendar screen ────────────────────────────────────────────────────────
  String get calTitle            => _fr ? 'Calendrier du cycle'    : 'Cycle calendar';
  String get calRegles           => _fr ? 'Règles'                 : 'Period';
  String get calOvulation        => _fr ? 'Ovulation'              : 'Ovulation';
  String get calModifier         => _fr ? 'Modifier mes règles'    : 'Edit my period';
  String get calDateDebut        => _fr ? 'Date de début'          : 'Start date';
  String get calDuree            => _fr ? 'Durée des règles'       : 'Period duration';
  String get calDateFin          => _fr ? 'Date de fin (calculée automatiquement)' : 'End date (auto-calculated)';
  String get calChoisir          => _fr ? 'Choisir la date de debut' : 'Choose start date';
  String get calAnnuler          => _fr ? 'Annuler'                : 'Cancel';
  String get calSauvegarder      => _fr ? 'Sauvegarder'            : 'Save';

  // ── Onboarding steps ──────────────────────────────────────────────────────
  String get oboCycleTitle       => _fr ? 'Durée de ton cycle'     : 'Your cycle length';
  String get oboCycleSub         => _fr ? 'La moyenne est de 28 jours mais chaque femme est unique' : 'The average is 28 days but every woman is unique';
  String get oboCycleDuree       => _fr ? 'Durée habituelle'       : 'Usual duration';
  String get oboCycleLastPeriod  => _fr ? 'Début de tes dernières règles' : 'Start of your last period';
  String get oboCycleCommencer   => _fr ? 'Commencer FITEVA'       : 'Start FITEVA';
  String get oboPregnancyWeek   => _fr ? 'À quelle semaine es-tu ?' : 'What week are you at?';
  String get oboPregnancySA     => _fr ? 'SA'                      : 'WA';
  String get oboPregnancyTri1   => _fr ? '1er trimestre (S1–S13)'  : '1st trimester (W1–W13)';
  String get oboPregnancyTri2   => _fr ? '2e trimestre (S14–S27)'  : '2nd trimester (W14–W27)';
  String get oboPregnancyTri3   => _fr ? '3e trimestre (S28–S42)'  : '3rd trimester (W28–W42)';
  String get oboPregnancyNo     => _fr ? 'Non'                     : 'No';
  String get oboPregnancyNoSub  => _fr ? 'Je ne suis pas enceinte' : "I'm not pregnant";
  String get oboPregnancyYes    => _fr ? 'Oui'                     : 'Yes';
  String get oboPregnancyYesSub => _fr ? 'Je suis enceinte'        : "I'm pregnant";
  String get oboPregnancyContinue => _fr ? 'Continuer'             : 'Continue';
  String get oboHealthHeight    => _fr ? 'Height'                   : 'Height';
  String get oboHealthWeight    => _fr ? 'Weight'                   : 'Weight';
  String get oboHealthContinue  => _fr ? 'Continuer'                : 'Continue';

  // ── Pregnancy screens ──────────────────────────────────────────────────────
  String get pregTitle          => _fr ? 'GROSSESSE'                         : 'PREGNANCY';
  String get pregMonSuivi       => _fr ? 'Mon suivi'                         : 'My tracking';
  String get pregQuitter        => _fr ? 'Quitter le suivi grossesse ?'      : 'Exit pregnancy tracking?';
  String get pregQuitterSub     => _fr ? "L'app passera en mode Cycle. Vos données sont conservées." : 'The app will switch to Cycle mode. Your data is saved.';
  String get pregDateAccouch    => _fr ? "Date d'accouchement"               : 'Due date';
  String get pregQuandNe        => _fr ? 'Quand est né votre bébé ?'         : 'When was your baby born?';
  String get pregPostPartum     => _fr ? 'Passer en mode Post-partum ?'      : 'Switch to Post-partum mode?';
  String get pregAnnuler        => _fr ? 'Annuler'                           : 'Cancel';
  String get pregConfirmer      => _fr ? 'Confirmer'                         : 'Confirm';
  String get pregPostPartumBtn  => _fr ? 'Post-partum →'                     : 'Post-partum →';
  String get pregMonCycle       => _fr ? 'Mon cycle →'                       : 'My cycle →';
  String get pregCommentTuTeSens=> _fr ? 'Comment tu te sens ?'              : 'How are you feeling?';
  String get pregExplorer       => _fr ? 'Explorer'                          : 'Explore';
  String get pregBabyBorn       => _fr ? 'Mon bébé est né !'                 : 'My baby is born!';
  String get pregPasserSuivi    => _fr ? 'Passer au suivi post-partum'       : 'Switch to post-partum tracking';
  String get pregTrim1Short     => _fr ? '1er trim.'                         : '1st trim.';
  String get pregTrim2Short     => _fr ? '2e trim.'                          : '2nd trim.';
  String get pregTrim3Short     => _fr ? '3e trim.'                          : '3rd trim.';
  String get pregVotreBebe      => _fr ? 'Votre bébé'                        : 'Your baby';
  String get pregDeveloppement  => _fr ? 'Développement'                     : 'Development';
  String get pregVotreCorps     => _fr ? 'Votre corps'                       : 'Your body';
  String get pregEvolutions     => _fr ? 'Évolutions et changements'         : 'Changes and evolutions';
  String get pregMaChecklist    => _fr ? 'Ma checklist'                      : 'My checklist';
  String get pregPreparatifs    => _fr ? 'Préparatifs et rendez-vous'        : 'Preparations and appointments';
  String get pregSymptomes      => _fr ? 'Symptômes'                         : 'Symptoms';
  String get pregSuivreSymptomes=> _fr ? 'Suivre vos symptômes du jour'      : 'Track your symptoms today';
  String get pregJoursRestants  => _fr ? 'jours restants'                    : 'days remaining';
  String get pregSemaine        => _fr ? 'SEMAINE'                           : 'WEEK';
  String pregSemaineN(int w)    => _fr ? 'Semaine $w'                        : 'Week $w';
  String pregCommeFruit(String f) => _fr ? 'comme une $f'                   : 'like a $f';

  // ── Baby story screen ──────────────────────────────────────────────────────
  String get babyTitle          => _fr ? "L'HISTOIRE DE BÉBÉ"                : "BABY'S STORY";
  String get babyTrim1          => _fr ? '1er trimestre'                     : '1st trimester';
  String get babyTrim2          => _fr ? '2e trimestre'                      : '2nd trimester';
  String get babyTrim3          => _fr ? '3e trimestre'                      : '3rd trimester';
  String get babyBebeTRaconte   => _fr ? 'Bébé te raconte…'                  : 'Baby tells you…';
  String get babySaviezVous     => _fr ? 'Le saviez-vous ?'                  : 'Did you know?';
  String get babyDevSemaine     => _fr ? 'Développement cette semaine'       : 'Development this week';

  // ── Pregnancy body screen ──────────────────────────────────────────────────
  String get bodyTitle          => _fr ? 'VOTRE CORPS'                       : 'YOUR BODY';
  String get bodyTrim1          => _fr ? '1er trimestre'                     : '1st trimester';
  String get bodyTrim2          => _fr ? '2e trimestre'                      : '2nd trimester';
  String get bodyTrim3          => _fr ? '3e trimestre'                      : '3rd trimester';
  String get bodyVecuTitle      => _fr ? 'Ce que ton corps vit'              : 'What your body is going through';
  String get bodyConseils       => _fr ? 'CONSEILS POUR CETTE PÉRIODE'       : 'TIPS FOR THIS PERIOD';
  String get bodyPoids          => _fr ? 'Prise de poids recommandée'        : 'Recommended weight gain';

  // ── Pregnancy checklist ────────────────────────────────────────────────────
  String get checkTitle         => _fr ? 'MA CHECKLIST'                      : 'MY CHECKLIST';
  String get checkAucune        => _fr ? 'Aucune tâche cette semaine'        : 'No tasks this week';
  String get checkToutFait      => _fr ? 'Tout est fait — bravo !'           : 'All done — great job!';
  String get checkMedical       => _fr ? 'Médical'                           : 'Medical';
  String get checkBienEtre      => _fr ? 'Bien-être'                         : 'Well-being';
  String get checkPratique      => _fr ? 'Pratique'                          : 'Practical';
  String get checkAVenir        => _fr ? 'À venir'                           : 'Coming up';
  String get checkRien          => _fr ? 'Rien de prévu cette semaine'       : 'Nothing planned this week';
  String get checkCalme         => _fr ? 'Profite de ce moment de calme.\nLes prochaines tâches arrivent bientôt.' : 'Enjoy this quiet moment.\nMore tasks coming soon.';
  String checkTaches(int done, int total) => _fr ? '$done sur $total tâches complétées' : '$done of $total tasks completed';

  // ── Postpartum hub ─────────────────────────────────────────────────────────
  String get ppTitle            => _fr ? 'POST-PARTUM'                       : 'POST-PARTUM';
  String get ppTrim4            => _fr ? '4e trimestre'                      : '4th trimester';
  String get ppDateAccouch      => _fr ? "Date d'accouchement"               : 'Due date';
  String get ppQuandNe          => _fr ? 'Quand est né votre bébé ?'         : 'When was your baby born?';
  String get ppMesRegles        => _fr ? 'Mes règles'                        : 'My period';
  String get ppQuandRegles      => _fr ? 'Quand ont-elles commencé ?'        : 'When did they start?';
  String get ppPasserCycle      => _fr ? 'Passer au suivi de cycle ?'        : 'Switch to cycle tracking?';
  String get ppAnnuler          => _fr ? 'Annuler'                           : 'Cancel';
  String get ppConfirmer        => _fr ? 'Confirmer'                         : 'Confirm';
  String get ppModifier         => _fr ? 'Modifier'                          : 'Edit';
  String get ppCommentSentez    => _fr ? 'Comment vous sentez-vous ?'        : 'How are you feeling?';
  String get ppVotreBebe        => _fr ? 'Votre bébé'                        : 'Your baby';
  String get ppVotreCorps       => _fr ? 'Votre corps'                       : 'Your body';
  String get ppVotreMental      => _fr ? 'Votre mental'                      : 'Your mental health';
  String ppDaysNaissance(int d) => _fr ? '$d jours depuis la naissance'      : '$d days since birth';
  String ppSemainesRestantes(int n) => _fr ? '$n semaines restantes de suivi post-partum' : '$n weeks of post-partum tracking remaining';

  // ── Add symptom sheet ──────────────────────────────────────────────────────
  String get symptomTitle       => _fr ? 'Comment tu te sens ?'              : 'How are you feeling?';
  String get symptomChoisis     => _fr ? 'Choisis un symptôme'               : 'Choose a symptom';
  String get symptomNote        => _fr ? 'Note (optionnel)'                  : 'Note (optional)';
  String get symptomHint        => _fr ? 'Un détail à retenir…'              : 'A detail to remember…';
  String get symptomEnregistrer    => _fr ? 'Enregistrer'                    : 'Save';
  String get symptomIntensiteLabel => _fr ? 'Intensité'                      : 'Intensity';
  String get symptomLegere      => _fr ? 'Légère'                            : 'Mild';
  String get symptomModeree     => _fr ? 'Modérée'                           : 'Moderate';
  String get symptomForte       => _fr ? 'Forte'                             : 'Strong';
  String get symptomIntense     => _fr ? 'Intense'                           : 'Intense';

  // ── Symptoms home screen ───────────────────────────────────────────────────
  String get sympHomeTitle      => _fr ? 'MES SYMPTÔMES'                     : 'MY SYMPTOMS';
  String get sympHomeCetteSem   => _fr ? 'CETTE SEMAINE'                     : 'THIS WEEK';
  String get sympHomeRien       => _fr ? 'Rien de noté cette semaine'        : 'Nothing logged this week';
  String get sympHomeHint       => _fr ? 'Appuie sur le bouton ci-dessous\npour enregistrer comment tu te sens.' : 'Tap the button below\nto log how you feel.';
  String get sympHomeAjouter    => _fr ? 'Ajouter un symptôme'               : 'Add a symptom';
  String get sympHomeConseil    => _fr ? 'Conseil de la semaine'             : 'Tip of the week';
  String get sympHomeTendance   => _fr ? 'Tendance hebdomadaire'             : 'Weekly trend';
  String get sympHomeHier       => _fr ? 'Hier'                              : 'Yesterday';
  String get sympHomeAuj        => _fr ? "Auj'"                              : "Today";
  String sympHomeCount(int n)   => _fr ? '$n ce mois'                        : '$n this month';

  // ── Nutrition / recipes screens ────────────────────────────────────────────
  String get recettesEyebrow     => _fr ? 'RECETTES'                  : 'RECIPES';
  String get recettesPhotos      => _fr ? 'Photos & Étapes'           : 'Photos & Steps';
  String get recettesVideos      => _fr ? 'Vidéos'                    : 'Videos';
  String get recettesVideo       => _fr ? 'Vidéo'                     : 'Video';
  String get recettesAucune      => _fr ? 'Aucune recette'            : 'No recipes';
  String get recettesEssaie      => _fr ? 'Essaie un autre terme'     : 'Try another term';
  String get recettesExplorer    => _fr ? 'Explorer'                  : 'Explore';
  String get recettesEnVedette   => _fr ? 'En vedette'                : 'Featured';
  String get recettesKcal        => _fr ? 'kcal'                      : 'kcal';
  String recettesCount(int n)    => _fr ? '$n recettes'               : '$n recipes';
  String recettesResults(int n)  => _fr ? '$n résultat${n > 1 ? "s" : ""}' : '$n result${n > 1 ? "s" : ""}';

  String get detailCaloriesPortion => _fr ? 'Calories par portion'   : 'Calories per serving';
  String get detailObjectif        => _fr ? 'Objectif journalier'     : 'Daily goal';

  String get videoTotalEstime    => _fr ? 'Total estimé'              : 'Estimated total';
  String videoPourquoiPhase(String p) => _fr ? 'Pourquoi en phase $p ?' : 'Why in $p phase?';

  // ── Health nutrition widgets ───────────────────────────────────────────────
  String get healthBilanJour     => _fr ? 'BILAN DU JOUR'             : "TODAY'S SUMMARY";
  String get healthAujourdhui    => _fr ? "Aujourd'hui"               : 'Today';
  String get healthEnregistrer   => _fr ? 'Enregistrer mon signal'    : 'Log my signal';
  String get healthSignalEnreg   => _fr ? 'Signal enregistré !'       : 'Signal logged!';
  String get healthVerres        => _fr ? 'verres'                    : 'glasses';
  String get healthAPrivilegier  => _fr ? 'À privilégier'             : 'To favor';
  String get healthAEviter       => _fr ? 'À éviter'                  : 'To avoid';
  String get healthExperts       => _fr ? 'EXPERTS'                   : 'EXPERTS';
  String get healthConseils      => _fr ? 'Conseils personnalisés'    : 'Personalized tips';

  // ── Workout screens ────────────────────────────────────────────────────────
  String get weeklyMaSemaine     => _fr ? 'Ma semaine'             : 'My week';
  String get weeklyCetteSemaine  => _fr ? 'Cette semaine'          : 'This week';
  String get weeklyProgSemaine   => _fr ? 'PROGRAMME SEMAINE'      : 'WEEK PROGRAM';
  String get weeklyAucuneSeance  => _fr ? 'Aucune séance prévue'   : 'No sessions planned';
  String get weeklyDeplacer      => _fr ? 'Déplacer vers…'         : 'Move to…';
  String get weeklyVide          => _fr ? 'Vide'                   : 'Empty';

  // ── Avatar customization screen ────────────────────────────────────────────
  String get avatarTitle         => _fr ? 'Mon avatar'             : 'My avatar';
  String get avatarEnregistrer   => _fr ? 'Enregistrer'            : 'Save';
  String get avatarAleatoire     => _fr ? 'Aléatoire avec le bouton shuffle' : 'Random with the shuffle button';
  String get avatarStyle         => _fr ? 'Style'                  : 'Style';
  String get avatarCouleur       => _fr ? 'Couleur de fond'        : 'Background color';
  String get avatarUtiliser      => _fr ? 'Utiliser cet avatar'    : 'Use this avatar';

  // ── CorpsZone player screen ────────────────────────────────────────────────
  String corpszonePoints(int earned, int total) => _fr ? '+$earned pts ! Total : $total pts' : '+$earned pts! Total: $total pts';

  // ── Workout widgets ────────────────────────────────────────────────────────
  String get hcardDemarrer      => _fr ? 'Démarrer'    : 'Start';
  String get progcardCommencer  => _fr ? 'Commencer'   : 'Start';
  String get progcardProgramme  => _fr ? 'PROGRAMME'   : 'PROGRAM';
  String get sectionVoirTout    => _fr ? 'Voir tout'   : 'See all';

  // ── Nutrition widgets ──────────────────────────────────────────────────────
  String get mealMange          => _fr ? 'Mangé 😊'    : 'Eaten 😊';
  String get recipeIngredients  => _fr ? 'Ingrédients' : 'Ingredients';
  String get mealsRecommandations => _fr ? 'RECOMMANDATIONS' : 'RECOMMENDATIONS';
  String get mealsRepasJour     => _fr ? 'Repas du jour' : "Today's meals";

  // ── Chatbot sheet ──────────────────────────────────────────────────────────
  String get chatAssistante     => _fr ? 'Assistante personnelle'           : 'Personal assistant';
  String get chatChoisir        => _fr ? 'Choisis une catégorie pour commencer' : 'Choose a category to start';
  String get chatComment        => _fr ? 'Comment puis-je t\'aider ?'      : 'How can I help you?';
  String get chatFitEvaAI       => _fr ? 'FitEva AI'                        : 'FitEva AI';
  String get chatSelectionner   => _fr ? 'Sélectionne une question'         : 'Select a question';

  // ── Misc widgets ───────────────────────────────────────────────────────────
  String get datePickerConfirmer => _fr ? 'Confirmer'      : 'Confirm';
  String get stepPtsAjoutes      => _fr ? '+50 points ajoutés' : '+50 points added';
  String get stepPts             => _fr ? '+50 pts'            : '+50 pts';
  String get stepObjectifAtteint => _fr ? 'Objectif atteint !' : 'Goal reached!';


  // ── Profile screen ──────────────────────────────────────────────────────────
  String get profileTitle          => _fr ? 'Profil'                      : 'Profile';
  String get profileEditBtn        => _fr ? 'Modifier le profil'          : 'Edit profile';
  String get profileUser           => _fr ? 'Utilisateur'                 : 'User';
  String get profileXpProgress     => _fr ? 'Progression XP'              : 'XP Progress';
  String get profileMaxLevel       => _fr ? '🏆 Niveau maximum atteint !' : '🏆 Max level reached!';
  String profileXpToNext(int xp)   => _fr ? '$xp XP avant le prochain niveau' : '$xp XP to next level';
  String get profileWeeklyGoal     => _fr ? 'Objectif hebdomadaire'       : 'Weekly goal';
  String profileWeeklyDays(int d)  => _fr ? '$d jours complétés cette semaine' : '$d days completed this week';
  String get profileBadges         => _fr ? 'Badges'                      : 'Badges';
  String get profileHide           => _fr ? 'Masquer'                     : 'Hide';
  String get profileSeeAll         => _fr ? 'Voir tout'                   : 'See all';
  String get profileChallenges     => _fr ? 'Défis'                       : 'Challenges';
  String get profileCompleted      => _fr ? '✅ Complété !'               : '✅ Completed!';
  String profileDays(int d, int t) => _fr ? '$d / $t jours'              : '$d / $t days';
  String get profileAiAssistant    => _fr ? 'Assistant IA'                : 'AI Assistant';
  String get profileEnabled        => _fr ? 'Activé'                      : 'On';
  String get profileDisabled       => _fr ? 'Désactivé'                   : 'Off';
  String get profileStreak         => _fr ? 'Streak'                      : 'Streak';
  String get profileSessions       => _fr ? 'Séances'                     : 'Sessions';
  // ── Edit profile sheet ────────────────────────────────────────────────────
  String get editProfileTitle      => _fr ? 'Modifier le profil'          : 'Edit profile';
  String get editProfileSubtitle   => _fr ? 'Vos informations personnelles' : 'Your personal info';
  String get editUsername          => _fr ? 'Nom d\'utilisateur'          : 'Username';
  String get editPhysicalData      => _fr ? 'Données physiques'           : 'Physical data';
  String get editHeight            => _fr ? 'Taille (cm)'                 : 'Height (cm)';
  String get editWeight            => _fr ? 'Poids (kg)'                  : 'Weight (kg)';
  String get editAge               => _fr ? 'Âge'                         : 'Age';
  String get editAdvanced          => _fr ? 'Édition avancée'             : 'Advanced edit';
  String get editSave              => _fr ? 'Enregistrer'                 : 'Save';

  // ── Santé screen remaining strings ──────────────────────────────────────────
  String get santeAnonyme           => _fr ? 'Anonyme'                  : 'Anonymous';
  String santeEpisodes(int n)       => _fr ? '$n épisodes'              : '$n episodes';
  String santeEpisode(int n)        => _fr ? 'Épisode $n'               : 'Episode $n';
  String santeEpShort(int n)        => _fr ? 'Ep. $n'                   : 'Ep. $n';
  String get santeLike              => _fr ? 'J\'aime'                  : 'Like';
  String get santeShare             => _fr ? 'Partager'                 : 'Share';
  String get santeFollow            => _fr ? 'Suivre'                   : 'Follow';
  String get santeDansCetteSerie    => _fr ? 'Dans cette série'         : 'In this series';
  String get santeMedecin           => _fr ? 'Médecin'                  : 'Physician';
}
