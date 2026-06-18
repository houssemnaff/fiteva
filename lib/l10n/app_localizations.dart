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
  String get homeStartProgram       => _fr ? 'START PROGRAM'         : 'START PROGRAM';
  String get homeProgrammeLabel     => _fr ? 'PROGRAMME'             : 'PROGRAM';
  String get homeWeekPlan           => _fr ? 'WEEK PLAN'             : 'WEEK PLAN';
  String get homePlanYourWeek       => _fr ? 'Plan Your\nWeek'       : 'Plan Your\nWeek';
  String get homeDone               => _fr ? 'DONE'                  : 'DONE';
  String get homeInProgress         => _fr ? 'PROGRAMMES EN COURS'   : 'IN PROGRESS';
  String get homeContinueSection    => _fr ? 'Continuer'             : 'Continue';
  String get homeVoirTout           => _fr ? 'voir tout'             : 'see all';
  String get homePickWorkout        => _fr ? 'Pick a workout'        : 'Pick a workout';
  String get homeStart              => _fr ? 'START'                 : 'START';
  String get homeReview             => _fr ? 'REVIEW'                : 'REVIEW';
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
  String get nutritionDailyTotal    => _fr ? 'total journée'                                         : 'daily total';
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

  // StepGoals
  String get goalsTopBarTitle       => _fr ? 'OBJECTIFS'               : 'GOALS';
  String get goalsTitle             => _fr ? 'Quel est ton objectif\nprincipal en ce moment ?' : 'What is your main\ngoal right now?';
  String get goalsHint              => _fr ? 'Touche un cercle pour choisir' : 'Tap a circle to choose';
  String get goal1                  => _fr ? 'Prendre de la force\net me sentir plus forte'   : 'Build strength\nand feel stronger';
  String get goal2                  => _fr ? 'Tonifier et sculpter\ntout mon corps'            : 'Tone and sculpt\nmy whole body';
  String get goal3                  => _fr ? 'Améliorer\nma souplesse\net mobilité'            : 'Improve\nmy flexibility\nand mobility';
  String get goal4                  => _fr ? 'Réduire le stress\net me sentir plus\néquilibrée' : 'Reduce stress\nand feel more\nbalanced';
  String get goal5                  => _fr ? 'Reprendre\nune routine'                          : 'Get back\nto a routine';

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

  // Date picker titles
  String get datePickerLastPeriodTitle   => _fr ? 'Dernieres regles'     : 'Last period';
  String get datePickerLastPeriodSub     => _fr ? 'Date du premier jour' : 'First day date';
  String get datePickerBirthTitle        => _fr ? "Date d'accouchement"  : 'Birth date';
  String get datePickerBirthSub         => _fr ? 'Quand est ne votre bebe ?' : 'When was your baby born?';
}
