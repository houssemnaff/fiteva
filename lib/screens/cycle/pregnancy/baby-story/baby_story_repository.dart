import 'baby_story.dart';

class BabyStoryRepository {
  static final List<BabyStory> stories = [

    BabyStory(
      week: 6,
      title: "Un petit cœur commence à battre",
      story:
          "Salut maman… mon petit cœur vient de commencer à battre. Il est encore fragile, mais il apprend déjà son rythme.",
      fact: "Le cœur commence à battre autour de la 5e à 6e semaine.",
    ),

    BabyStory(
      week: 12,
      title: "Je forme mes petits doigts",
      story:
          "Je peux maintenant bouger mes doigts et m’étirer dans mon petit cocon chaud. Tout est nouveau pour moi.",
      fact: "Les doigts et les réflexes se développent fortement au 1er trimestre.",
    ),

    BabyStory(
      week: 20,
      title: "Je commence à te sentir",
      story:
          "J’entends des sons étouffés… ta voix est celle que je préfère. Je me sens en sécurité quand tu me parles.",
      fact: "L’ouïe commence à se développer vers 18–20 semaines.",
    ),

    BabyStory(
      week: 24,
      title: "Je reconnais ta voix",
      story:
          "Ta voix devient plus claire pour moi… je commence à la reconnaître. Elle ressemble à la maison.",
      fact: "Le bébé peut réagir aux sons extérieurs à ce stade.",
    ),

    BabyStory(
      week: 30,
      title: "Je deviens plus fort",
      story:
          "Je bouge beaucoup maintenant. Je m’étire, je donne des coups… je prépare mon arrivée dans le monde.",
      fact: "Le cerveau et les muscles se développent rapidement au 3e trimestre.",
    ),

    BabyStory(
      week: 36,
      title: "Je suis presque prêt",
      story:
          "C’est plus serré ici… mais je suis bientôt prêt. J’ai appris tout ce dont j’ai besoin grâce à toi.",
      fact: "Le bébé prend surtout du poids en fin de grossesse.",
    ),

    BabyStory(
      week: 40,
      title: "Il est temps de te rencontrer",
      story:
          "Maman… je suis prêt. Je t’entends. Je te connais. Allons enfin nous rencontrer.",
      fact: "Grossesse à terme.",
    ),
  ];

  static BabyStory forWeek(int week) {
    return stories.lastWhere(
      (s) => week >= s.week,
      orElse: () => stories.first,
    );
  }
   static String getStory(int week) {
    const stories = {
      1: "Je commence mon voyage… tout est encore invisible mais je suis déjà là.",
      2: "Je me divise, je grandis doucement vers mon futur chez moi.",
      3: "Je trouve ma place dans ton ventre.",
      4: "Mon petit corps commence à se dessiner.",
      5: "Mon cœur commence à se former… peut-être même à battre.",
      6: "Je commence à ressembler à quelque chose de vivant 💛",
      10: "Mes doigts apparaissent doucement.",
      14: "Je commence à réagir à la lumière.",
      20: "Je bouge, même si tu ne comprends pas encore.",
      24: "Je t’entends… ta voix me calme.",
      30: "Je rêve déjà dans ton ventre.",
      36: "Je me prépare à te rencontrer.",
      40: "Je suis prêt(e). On se voit bientôt ❤️",
    };

    return stories[week] ??
        "Je grandis doucement jour après jour… je suis ton bébé 💛";
  }
}