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

  // ── Nutrition screen ───────────────────────────────────────────────────────
  String get nutritionMyDiet        => _fr ? 'Mon alimentation'      : 'My diet';
  String get nutritionAdd           => _fr ? 'Ajouter'               : 'Add';
  String get nutritionNewRecipes    => _fr ? 'Nouvelles recettes'     : 'New recipes';
  String get nutritionKcalOver      => _fr ? 'kcal dépassés'         : 'kcal over';
  String get nutritionKcalLeft      => _fr ? 'kcal restantes'        : 'kcal left';

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
}
