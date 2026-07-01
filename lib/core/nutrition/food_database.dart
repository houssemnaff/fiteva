import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import '../../services/supabase_config.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  FOOD DATABASE  — ~140 aliments avec valeurs réelles (pour 100 g)
//  Sources : ANSES / Ciqual 2020
// ══════════════════════════════════════════════════════════════════════════════
class FoodDatabase {
  FoodDatabase._();

  static final List<FoodItem> all = [
    // ── 🥩 Viandes & Volailles ────────────────────────────────────────────────
    const FoodItem(id: 'chicken_breast', name: 'Poulet (filet)', category: FoodCategory.viandes,
      kcal: 165, protein: 31.0, carbs: 0.0, fat: 3.6, fiber: 0,
      defaultGrams: 150, portionLabel: '1 filet'),
    const FoodItem(id: 'chicken_thigh', name: 'Cuisse de poulet', category: FoodCategory.viandes,
      kcal: 209, protein: 24.0, carbs: 0.0, fat: 12.0, fiber: 0,
      defaultGrams: 120, portionLabel: '1 cuisse'),
    const FoodItem(id: 'turkey_breast', name: 'Dinde (filet)', category: FoodCategory.viandes,
      kcal: 157, protein: 30.0, carbs: 0.0, fat: 3.5, fiber: 0,
      defaultGrams: 150, portionLabel: '1 filet'),
    const FoodItem(id: 'beef_lean', name: 'Bœuf haché 5%', category: FoodCategory.viandes,
      kcal: 137, protein: 20.5, carbs: 0.0, fat: 6.0, fiber: 0,
      defaultGrams: 100, portionLabel: '1 steak (100 g)'),
    const FoodItem(id: 'beef_steak', name: 'Steak de bœuf', category: FoodCategory.viandes,
      kcal: 172, protein: 26.0, carbs: 0.0, fat: 7.2, fiber: 0,
      defaultGrams: 130, portionLabel: '1 steak'),
    const FoodItem(id: 'pork_tenderloin', name: 'Filet de porc', category: FoodCategory.viandes,
      kcal: 143, protein: 22.0, carbs: 0.0, fat: 5.9, fiber: 0,
      defaultGrams: 130, portionLabel: '1 portion'),
    const FoodItem(id: 'lamb_leg', name: 'Agneau (gigot)', category: FoodCategory.viandes,
      kcal: 192, protein: 23.0, carbs: 0.0, fat: 11.0, fiber: 0,
      defaultGrams: 130, portionLabel: '1 tranche'),
    const FoodItem(id: 'ham_cooked', name: 'Jambon cuit (blanc)', category: FoodCategory.viandes,
      kcal: 107, protein: 17.0, carbs: 1.2, fat: 3.6, fiber: 0,
      defaultGrams: 45, portionLabel: '2 tranches'),
    const FoodItem(id: 'chorizo', name: 'Chorizo', category: FoodCategory.viandes,
      kcal: 379, protein: 19.0, carbs: 2.0, fat: 33.0, fiber: 0,
      defaultGrams: 30, portionLabel: '6 rondelles'),

    // ── 🐟 Poissons & Fruits de mer ───────────────────────────────────────────
    const FoodItem(id: 'salmon', name: 'Saumon (filet)', category: FoodCategory.poissons,
      kcal: 208, protein: 20.0, carbs: 0.0, fat: 13.0, fiber: 0,
      defaultGrams: 150, portionLabel: '1 filet'),
    const FoodItem(id: 'tuna_canned', name: 'Thon en boîte (naturel)', category: FoodCategory.poissons,
      kcal: 116, protein: 26.0, carbs: 0.0, fat: 1.0, fiber: 0,
      defaultGrams: 120, portionLabel: '1 boîte'),
    const FoodItem(id: 'cod', name: 'Cabillaud', category: FoodCategory.poissons,
      kcal: 82, protein: 18.0, carbs: 0.0, fat: 0.7, fiber: 0,
      defaultGrams: 150, portionLabel: '1 filet'),
    const FoodItem(id: 'trout', name: 'Truite', category: FoodCategory.poissons,
      kcal: 148, protein: 20.0, carbs: 0.0, fat: 7.2, fiber: 0,
      defaultGrams: 150, portionLabel: '1 filet'),
    const FoodItem(id: 'sardines', name: 'Sardines à l\'huile', category: FoodCategory.poissons,
      kcal: 208, protein: 24.0, carbs: 0.0, fat: 12.0, fiber: 0,
      defaultGrams: 85, portionLabel: '1 boîte'),
    const FoodItem(id: 'shrimp', name: 'Crevettes décortiquées', category: FoodCategory.poissons,
      kcal: 99, protein: 21.0, carbs: 0.9, fat: 1.1, fiber: 0,
      defaultGrams: 100, portionLabel: '100 g'),
    const FoodItem(id: 'mussels', name: 'Moules', category: FoodCategory.poissons,
      kcal: 86, protein: 12.0, carbs: 3.7, fat: 2.2, fiber: 0,
      defaultGrams: 200, portionLabel: '200 g'),
    const FoodItem(id: 'mackerel', name: 'Maquereau', category: FoodCategory.poissons,
      kcal: 205, protein: 19.0, carbs: 0.0, fat: 14.0, fiber: 0,
      defaultGrams: 120, portionLabel: '1 filet'),

    // ── 🥚 Œufs & Laitiers ───────────────────────────────────────────────────
    const FoodItem(id: 'egg_whole', name: 'Œuf entier', category: FoodCategory.oeufslaitiers,
      kcal: 155, protein: 13.0, carbs: 1.1, fat: 11.0, fiber: 0,
      defaultGrams: 60, portionLabel: '1 œuf'),
    const FoodItem(id: 'egg_white', name: 'Blanc d\'œuf', category: FoodCategory.oeufslaitiers,
      kcal: 52, protein: 11.0, carbs: 0.7, fat: 0.2, fiber: 0,
      defaultGrams: 35, portionLabel: '1 blanc'),
    const FoodItem(id: 'greek_yogurt', name: 'Yaourt grec (0%)', category: FoodCategory.oeufslaitiers,
      kcal: 59, protein: 10.0, carbs: 3.6, fat: 0.4, fiber: 0,
      defaultGrams: 150, portionLabel: '1 pot'),
    const FoodItem(id: 'yogurt_nature', name: 'Yaourt nature', category: FoodCategory.oeufslaitiers,
      kcal: 61, protein: 3.8, carbs: 4.7, fat: 3.2, fiber: 0,
      defaultGrams: 125, portionLabel: '1 pot'),
    const FoodItem(id: 'cottage_cheese', name: 'Fromage blanc (0%)', category: FoodCategory.oeufslaitiers,
      kcal: 45, protein: 7.8, carbs: 3.2, fat: 0.3, fiber: 0,
      defaultGrams: 150, portionLabel: '1 pot'),
    const FoodItem(id: 'milk_skimmed', name: 'Lait écrémé', category: FoodCategory.oeufslaitiers,
      kcal: 34, protein: 3.4, carbs: 4.9, fat: 0.1, fiber: 0,
      defaultGrams: 200, portionLabel: '1 verre'),
    const FoodItem(id: 'milk_whole', name: 'Lait entier', category: FoodCategory.oeufslaitiers,
      kcal: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0,
      defaultGrams: 200, portionLabel: '1 verre'),
    const FoodItem(id: 'cheddar', name: 'Cheddar', category: FoodCategory.oeufslaitiers,
      kcal: 403, protein: 25.0, carbs: 1.3, fat: 33.0, fiber: 0,
      defaultGrams: 30, portionLabel: '1 tranche'),
    const FoodItem(id: 'mozzarella', name: 'Mozzarella', category: FoodCategory.oeufslaitiers,
      kcal: 280, protein: 17.0, carbs: 3.1, fat: 22.0, fiber: 0,
      defaultGrams: 60, portionLabel: '½ boule'),
    const FoodItem(id: 'parmesan', name: 'Parmesan râpé', category: FoodCategory.oeufslaitiers,
      kcal: 431, protein: 38.0, carbs: 3.2, fat: 29.0, fiber: 0,
      defaultGrams: 20, portionLabel: '2 c.à.s'),
    const FoodItem(id: 'feta', name: 'Feta', category: FoodCategory.oeufslaitiers,
      kcal: 264, protein: 14.0, carbs: 4.1, fat: 21.0, fiber: 0,
      defaultGrams: 50, portionLabel: '1 portion'),

    // ── 🌾 Céréales & Féculents ───────────────────────────────────────────────
    const FoodItem(id: 'rice_white', name: 'Riz blanc (cuit)', category: FoodCategory.cereales,
      kcal: 130, protein: 2.7, carbs: 28.0, fat: 0.3, fiber: 0.4,
      defaultGrams: 150, portionLabel: '1 portion cuite'),
    const FoodItem(id: 'rice_brown', name: 'Riz complet (cuit)', category: FoodCategory.cereales,
      kcal: 112, protein: 2.6, carbs: 23.0, fat: 0.9, fiber: 1.8,
      defaultGrams: 150, portionLabel: '1 portion cuite'),
    const FoodItem(id: 'quinoa', name: 'Quinoa (cuit)', category: FoodCategory.cereales,
      kcal: 120, protein: 4.4, carbs: 21.0, fat: 1.9, fiber: 2.8,
      defaultGrams: 150, portionLabel: '1 portion cuite'),
    const FoodItem(id: 'pasta_cooked', name: 'Pâtes (cuites)', category: FoodCategory.cereales,
      kcal: 131, protein: 5.0, carbs: 25.0, fat: 1.1, fiber: 1.8,
      defaultGrams: 180, portionLabel: '1 portion cuite'),
    const FoodItem(id: 'pasta_ww', name: 'Pâtes complètes (cuites)', category: FoodCategory.cereales,
      kcal: 124, protein: 5.3, carbs: 23.0, fat: 1.0, fiber: 3.2,
      defaultGrams: 180, portionLabel: '1 portion cuite'),
    const FoodItem(id: 'oats', name: 'Flocons d\'avoine', category: FoodCategory.cereales,
      kcal: 389, protein: 17.0, carbs: 66.0, fat: 7.0, fiber: 10.6,
      defaultGrams: 60, portionLabel: '6 c.à.s'),
    const FoodItem(id: 'bread_whole', name: 'Pain complet', category: FoodCategory.cereales,
      kcal: 247, protein: 9.0, carbs: 41.0, fat: 3.4, fiber: 6.5,
      defaultGrams: 40, portionLabel: '2 tranches'),
    const FoodItem(id: 'bread_white', name: 'Pain blanc (baguette)', category: FoodCategory.cereales,
      kcal: 272, protein: 8.5, carbs: 53.0, fat: 1.6, fiber: 2.4,
      defaultGrams: 50, portionLabel: '2 tranches'),
    const FoodItem(id: 'sweet_potato', name: 'Patate douce (cuite)', category: FoodCategory.cereales,
      kcal: 86, protein: 1.6, carbs: 20.0, fat: 0.1, fiber: 3.0,
      defaultGrams: 150, portionLabel: '1 petite'),
    const FoodItem(id: 'potato', name: 'Pomme de terre (cuite)', category: FoodCategory.cereales,
      kcal: 77, protein: 2.0, carbs: 17.0, fat: 0.1, fiber: 1.8,
      defaultGrams: 150, portionLabel: '1 moyenne'),
    const FoodItem(id: 'couscous', name: 'Couscous (cuit)', category: FoodCategory.cereales,
      kcal: 112, protein: 3.8, carbs: 23.0, fat: 0.2, fiber: 1.4,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'corn', name: 'Maïs doux', category: FoodCategory.cereales,
      kcal: 86, protein: 3.2, carbs: 19.0, fat: 1.2, fiber: 2.7,
      defaultGrams: 100, portionLabel: '100 g'),
    const FoodItem(id: 'granola', name: 'Granola nature', category: FoodCategory.cereales,
      kcal: 471, protein: 10.0, carbs: 64.0, fat: 20.0, fiber: 6.0,
      defaultGrams: 50, portionLabel: '1 bol'),

    // ── 🫘 Légumineuses ───────────────────────────────────────────────────────
    const FoodItem(id: 'lentils', name: 'Lentilles (cuites)', category: FoodCategory.legumineuses,
      kcal: 116, protein: 9.0, carbs: 20.0, fat: 0.4, fiber: 7.9,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'chickpeas', name: 'Pois chiches (cuits)', category: FoodCategory.legumineuses,
      kcal: 164, protein: 8.9, carbs: 27.0, fat: 2.6, fiber: 7.6,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'black_beans', name: 'Haricots noirs (cuits)', category: FoodCategory.legumineuses,
      kcal: 132, protein: 8.9, carbs: 24.0, fat: 0.5, fiber: 8.7,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'white_beans', name: 'Haricots blancs (cuits)', category: FoodCategory.legumineuses,
      kcal: 139, protein: 9.7, carbs: 25.0, fat: 0.5, fiber: 10.5,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'edamame', name: 'Edamame', category: FoodCategory.legumineuses,
      kcal: 121, protein: 11.0, carbs: 8.9, fat: 5.2, fiber: 5.2,
      defaultGrams: 100, portionLabel: '100 g'),
    const FoodItem(id: 'tofu', name: 'Tofu ferme', category: FoodCategory.legumineuses,
      kcal: 144, protein: 17.0, carbs: 2.8, fat: 8.7, fiber: 0.3,
      defaultGrams: 100, portionLabel: '100 g'),
    const FoodItem(id: 'hummus', name: 'Houmous', category: FoodCategory.legumineuses,
      kcal: 166, protein: 7.9, carbs: 14.0, fat: 9.6, fiber: 6.0,
      defaultGrams: 60, portionLabel: '3 c.à.s'),

    // ── 🥦 Légumes ────────────────────────────────────────────────────────────
    const FoodItem(id: 'spinach', name: 'Épinards', category: FoodCategory.legumes,
      kcal: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2,
      defaultGrams: 100, portionLabel: '1 grosse poignée'),
    const FoodItem(id: 'broccoli', name: 'Brocoli', category: FoodCategory.legumes,
      kcal: 34, protein: 2.8, carbs: 7.0, fat: 0.4, fiber: 2.6,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'carrots', name: 'Carottes', category: FoodCategory.legumes,
      kcal: 41, protein: 0.9, carbs: 10.0, fat: 0.2, fiber: 2.8,
      defaultGrams: 100, portionLabel: '2 carottes'),
    const FoodItem(id: 'tomato', name: 'Tomate', category: FoodCategory.legumes,
      kcal: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2,
      defaultGrams: 120, portionLabel: '1 moyenne'),
    const FoodItem(id: 'cucumber', name: 'Concombre', category: FoodCategory.legumes,
      kcal: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5,
      defaultGrams: 150, portionLabel: '½ concombre'),
    const FoodItem(id: 'bell_pepper', name: 'Poivron rouge', category: FoodCategory.legumes,
      kcal: 31, protein: 1.0, carbs: 6.0, fat: 0.3, fiber: 2.1,
      defaultGrams: 100, portionLabel: '1 moyen'),
    const FoodItem(id: 'zucchini', name: 'Courgette', category: FoodCategory.legumes,
      kcal: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1.0,
      defaultGrams: 150, portionLabel: '1 petite'),
    const FoodItem(id: 'eggplant', name: 'Aubergine', category: FoodCategory.legumes,
      kcal: 25, protein: 1.0, carbs: 5.9, fat: 0.2, fiber: 3.0,
      defaultGrams: 150, portionLabel: '½ aubergine'),
    const FoodItem(id: 'onion', name: 'Oignon', category: FoodCategory.legumes,
      kcal: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7,
      defaultGrams: 80, portionLabel: '1 moyen'),
    const FoodItem(id: 'garlic', name: 'Ail', category: FoodCategory.legumes,
      kcal: 149, protein: 6.4, carbs: 33.0, fat: 0.5, fiber: 2.1,
      defaultGrams: 5, portionLabel: '1 gousse'),
    const FoodItem(id: 'mushroom', name: 'Champignons de Paris', category: FoodCategory.legumes,
      kcal: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1.0,
      defaultGrams: 100, portionLabel: '100 g'),
    const FoodItem(id: 'lettuce', name: 'Salade verte', category: FoodCategory.legumes,
      kcal: 15, protein: 1.4, carbs: 2.9, fat: 0.2, fiber: 1.3,
      defaultGrams: 80, portionLabel: '1 bol'),
    const FoodItem(id: 'cauliflower', name: 'Chou-fleur', category: FoodCategory.legumes,
      kcal: 25, protein: 1.9, carbs: 5.0, fat: 0.3, fiber: 2.0,
      defaultGrams: 150, portionLabel: '1 portion'),
    const FoodItem(id: 'green_beans', name: 'Haricots verts', category: FoodCategory.legumes,
      kcal: 31, protein: 1.8, carbs: 7.1, fat: 0.1, fiber: 3.4,
      defaultGrams: 150, portionLabel: '1 portion'),

    // ── 🍎 Fruits ─────────────────────────────────────────────────────────────
    const FoodItem(id: 'apple', name: 'Pomme', category: FoodCategory.fruits,
      kcal: 52, protein: 0.3, carbs: 14.0, fat: 0.2, fiber: 2.4,
      defaultGrams: 150, portionLabel: '1 moyenne'),
    const FoodItem(id: 'banana', name: 'Banane', category: FoodCategory.fruits,
      kcal: 89, protein: 1.1, carbs: 23.0, fat: 0.3, fiber: 2.6,
      defaultGrams: 120, portionLabel: '1 moyenne'),
    const FoodItem(id: 'orange', name: 'Orange', category: FoodCategory.fruits,
      kcal: 47, protein: 0.9, carbs: 12.0, fat: 0.1, fiber: 2.4,
      defaultGrams: 150, portionLabel: '1 moyenne'),
    const FoodItem(id: 'avocado', name: 'Avocat (½)', category: FoodCategory.fruits,
      kcal: 160, protein: 2.0, carbs: 9.0, fat: 15.0, fiber: 6.7,
      defaultGrams: 80, portionLabel: '½ avocat'),
    const FoodItem(id: 'strawberry', name: 'Fraises', category: FoodCategory.fruits,
      kcal: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2.0,
      defaultGrams: 150, portionLabel: '1 bol'),
    const FoodItem(id: 'blueberry', name: 'Myrtilles', category: FoodCategory.fruits,
      kcal: 57, protein: 0.7, carbs: 14.0, fat: 0.3, fiber: 2.4,
      defaultGrams: 100, portionLabel: '1 petite poignée'),
    const FoodItem(id: 'mango', name: 'Mangue', category: FoodCategory.fruits,
      kcal: 60, protein: 0.8, carbs: 15.0, fat: 0.4, fiber: 1.6,
      defaultGrams: 150, portionLabel: '½ mangue'),
    const FoodItem(id: 'pineapple', name: 'Ananas', category: FoodCategory.fruits,
      kcal: 50, protein: 0.5, carbs: 13.0, fat: 0.1, fiber: 1.4,
      defaultGrams: 150, portionLabel: '2 tranches'),
    const FoodItem(id: 'grapes', name: 'Raisins', category: FoodCategory.fruits,
      kcal: 69, protein: 0.7, carbs: 18.0, fat: 0.2, fiber: 0.9,
      defaultGrams: 100, portionLabel: '1 grappe'),
    const FoodItem(id: 'kiwi', name: 'Kiwi', category: FoodCategory.fruits,
      kcal: 61, protein: 1.1, carbs: 15.0, fat: 0.5, fiber: 3.0,
      defaultGrams: 80, portionLabel: '1 kiwi'),
    const FoodItem(id: 'watermelon', name: 'Pastèque', category: FoodCategory.fruits,
      kcal: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4,
      defaultGrams: 200, portionLabel: '1 tranche'),
    const FoodItem(id: 'dates', name: 'Dattes', category: FoodCategory.fruits,
      kcal: 277, protein: 1.8, carbs: 75.0, fat: 0.2, fiber: 6.7,
      defaultGrams: 30, portionLabel: '3 dattes'),

    // ── 🥜 Oléagineux & Graines ───────────────────────────────────────────────
    const FoodItem(id: 'almonds', name: 'Amandes', category: FoodCategory.oleagineux,
      kcal: 579, protein: 21.0, carbs: 22.0, fat: 50.0, fiber: 12.5,
      defaultGrams: 30, portionLabel: '1 petite poignée'),
    const FoodItem(id: 'walnuts', name: 'Noix', category: FoodCategory.oleagineux,
      kcal: 654, protein: 15.0, carbs: 14.0, fat: 65.0, fiber: 6.7,
      defaultGrams: 30, portionLabel: '5 cerneaux'),
    const FoodItem(id: 'cashews', name: 'Noix de cajou', category: FoodCategory.oleagineux,
      kcal: 553, protein: 18.0, carbs: 30.0, fat: 44.0, fiber: 3.3,
      defaultGrams: 30, portionLabel: '1 petite poignée'),
    const FoodItem(id: 'peanuts', name: 'Cacahuètes', category: FoodCategory.oleagineux,
      kcal: 567, protein: 26.0, carbs: 16.0, fat: 49.0, fiber: 8.5,
      defaultGrams: 30, portionLabel: '1 petite poignée'),
    const FoodItem(id: 'peanut_butter', name: 'Beurre de cacahuète', category: FoodCategory.oleagineux,
      kcal: 588, protein: 25.0, carbs: 20.0, fat: 50.0, fiber: 6.0,
      defaultGrams: 30, portionLabel: '2 c.à.s'),
    const FoodItem(id: 'almond_butter', name: 'Beurre d\'amande', category: FoodCategory.oleagineux,
      kcal: 614, protein: 21.0, carbs: 19.0, fat: 56.0, fiber: 10.3,
      defaultGrams: 30, portionLabel: '2 c.à.s'),
    const FoodItem(id: 'chia_seeds', name: 'Graines de chia', category: FoodCategory.oleagineux,
      kcal: 486, protein: 17.0, carbs: 42.0, fat: 31.0, fiber: 34.4,
      defaultGrams: 20, portionLabel: '2 c.à.s'),
    const FoodItem(id: 'flaxseeds', name: 'Graines de lin', category: FoodCategory.oleagineux,
      kcal: 534, protein: 18.0, carbs: 29.0, fat: 42.0, fiber: 27.3,
      defaultGrams: 15, portionLabel: '1 c.à.s'),
    const FoodItem(id: 'pumpkin_seeds', name: 'Graines de courge', category: FoodCategory.oleagineux,
      kcal: 559, protein: 30.0, carbs: 11.0, fat: 49.0, fiber: 6.0,
      defaultGrams: 30, portionLabel: '2 c.à.s'),

    // ── 🧈 Corps gras ─────────────────────────────────────────────────────────
    const FoodItem(id: 'olive_oil', name: 'Huile d\'olive', category: FoodCategory.corpsGras,
      kcal: 884, protein: 0.0, carbs: 0.0, fat: 100.0, fiber: 0,
      defaultGrams: 10, portionLabel: '1 c.à.s'),
    const FoodItem(id: 'butter', name: 'Beurre', category: FoodCategory.corpsGras,
      kcal: 717, protein: 0.9, carbs: 0.1, fat: 81.0, fiber: 0,
      defaultGrams: 10, portionLabel: '1 noisette'),
    const FoodItem(id: 'coconut_oil', name: 'Huile de coco', category: FoodCategory.corpsGras,
      kcal: 862, protein: 0.0, carbs: 0.0, fat: 99.0, fiber: 0,
      defaultGrams: 10, portionLabel: '1 c.à.s'),
    const FoodItem(id: 'avocado_oil', name: 'Huile d\'avocat', category: FoodCategory.corpsGras,
      kcal: 884, protein: 0.0, carbs: 0.0, fat: 100.0, fiber: 0,
      defaultGrams: 10, portionLabel: '1 c.à.s'),

    // ── 🥗 Plats composés ─────────────────────────────────────────────────────
    const FoodItem(id: 'caesar_salad', name: 'Salade César (poulet)', category: FoodCategory.platCompose,
      kcal: 180, protein: 15.0, carbs: 9.0, fat: 10.0, fiber: 2.0,
      defaultGrams: 250, portionLabel: '1 portion'),
    const FoodItem(id: 'chicken_rice_bowl', name: 'Bowl poulet riz', category: FoodCategory.platCompose,
      kcal: 410, protein: 38.0, carbs: 42.0, fat: 8.0, fiber: 3.5,
      defaultGrams: 400, portionLabel: '1 bowl'),
    const FoodItem(id: 'protein_smoothie', name: 'Smoothie protéiné', category: FoodCategory.platCompose,
      kcal: 280, protein: 25.0, carbs: 30.0, fat: 6.0, fiber: 3.0,
      defaultGrams: 350, portionLabel: '1 verre'),
    const FoodItem(id: 'overnight_oats', name: 'Overnight oats', category: FoodCategory.platCompose,
      kcal: 320, protein: 14.0, carbs: 48.0, fat: 8.0, fiber: 6.0,
      defaultGrams: 300, portionLabel: '1 bol'),
    const FoodItem(id: 'veggie_wrap', name: 'Wrap légumes & houmous', category: FoodCategory.platCompose,
      kcal: 340, protein: 12.0, carbs: 45.0, fat: 13.0, fiber: 7.0,
      defaultGrams: 200, portionLabel: '1 wrap'),
    const FoodItem(id: 'pasta_bolognese', name: 'Pâtes bolognaise', category: FoodCategory.platCompose,
      kcal: 380, protein: 22.0, carbs: 48.0, fat: 10.0, fiber: 4.0,
      defaultGrams: 350, portionLabel: '1 assiette'),
    const FoodItem(id: 'vegetable_soup', name: 'Soupe de légumes', category: FoodCategory.platCompose,
      kcal: 75, protein: 3.0, carbs: 14.0, fat: 1.0, fiber: 4.0,
      defaultGrams: 300, portionLabel: '1 bol'),

    // ── 🧃 Boissons ───────────────────────────────────────────────────────────
    const FoodItem(id: 'water', name: 'Eau', category: FoodCategory.boissons,
      kcal: 0, protein: 0.0, carbs: 0.0, fat: 0.0, fiber: 0,
      defaultGrams: 250, portionLabel: '1 verre'),
    const FoodItem(id: 'coffee_black', name: 'Café noir', category: FoodCategory.boissons,
      kcal: 2, protein: 0.3, carbs: 0.0, fat: 0.0, fiber: 0,
      defaultGrams: 200, portionLabel: '1 tasse'),
    const FoodItem(id: 'orange_juice', name: 'Jus d\'orange (pressé)', category: FoodCategory.boissons,
      kcal: 45, protein: 0.7, carbs: 10.0, fat: 0.2, fiber: 0.2,
      defaultGrams: 200, portionLabel: '1 verre'),
    const FoodItem(id: 'almond_milk', name: 'Boisson amande', category: FoodCategory.boissons,
      kcal: 24, protein: 0.9, carbs: 3.2, fat: 1.1, fiber: 0.3,
      defaultGrams: 200, portionLabel: '1 verre'),
    const FoodItem(id: 'oat_milk', name: 'Boisson avoine', category: FoodCategory.boissons,
      kcal: 47, protein: 1.0, carbs: 9.0, fat: 1.5, fiber: 0.8,
      defaultGrams: 200, portionLabel: '1 verre'),
    const FoodItem(id: 'green_tea', name: 'Thé vert', category: FoodCategory.boissons,
      kcal: 1, protein: 0.2, carbs: 0.0, fat: 0.0, fiber: 0,
      defaultGrams: 250, portionLabel: '1 tasse'),

    // ── 🍰 Desserts & Sucreries ───────────────────────────────────────────────
    const FoodItem(id: 'dark_chocolate', name: 'Chocolat noir 85%', category: FoodCategory.desserts,
      kcal: 598, protein: 12.0, carbs: 24.0, fat: 52.0, fiber: 10.9,
      defaultGrams: 30, portionLabel: '3 carrés'),
    const FoodItem(id: 'honey', name: 'Miel', category: FoodCategory.desserts,
      kcal: 304, protein: 0.3, carbs: 82.0, fat: 0.0, fiber: 0.2,
      defaultGrams: 15, portionLabel: '1 c.à.s'),
    const FoodItem(id: 'rice_cake', name: 'Galette de riz', category: FoodCategory.desserts,
      kcal: 387, protein: 7.8, carbs: 85.0, fat: 2.8, fiber: 1.6,
      defaultGrams: 20, portionLabel: '2 galettes'),
    const FoodItem(id: 'protein_bar', name: 'Barre protéinée', category: FoodCategory.desserts,
      kcal: 380, protein: 22.0, carbs: 37.0, fat: 12.0, fiber: 3.5,
      defaultGrams: 60, portionLabel: '1 barre'),
    const FoodItem(id: 'whey_protein', name: 'Whey protéine (vanille)', category: FoodCategory.desserts,
      kcal: 370, protein: 74.0, carbs: 8.0, fat: 6.0, fiber: 0.5,
      defaultGrams: 30, portionLabel: '1 dose'),
  ];

  // ── Search ────────────────────────────────────────────────────────────────
  static List<FoodItem> search(String query, {int limit = 20}) {
    if (query.isEmpty) return all.take(limit).toList();
    final q = _normalize(query);
    final results = all.where((f) => _normalize(f.name).contains(q)).toList();
    results.sort((a, b) {
      final aStart = _normalize(a.name).startsWith(q) ? 0 : 1;
      final bStart = _normalize(b.name).startsWith(q) ? 0 : 1;
      return aStart.compareTo(bStart);
    });
    return results.take(limit).toList();
  }

  static List<FoodItem> byCategory(FoodCategory cat) =>
      all.where((f) => f.category == cat).toList();

  static FoodItem? byId(String id) {
    try { return all.firstWhere((f) => f.id == id); }
    catch (_) { return null; }
  }

  // Popular / recent suggestions
  static List<FoodItem> get popular => [
    all.firstWhere((f) => f.id == 'chicken_breast'),
    all.firstWhere((f) => f.id == 'oats'),
    all.firstWhere((f) => f.id == 'egg_whole'),
    all.firstWhere((f) => f.id == 'greek_yogurt'),
    all.firstWhere((f) => f.id == 'banana'),
    all.firstWhere((f) => f.id == 'rice_white'),
    all.firstWhere((f) => f.id == 'salmon'),
    all.firstWhere((f) => f.id == 'avocado'),
  ];

  // Normalize for search: lowercase + remove accents
  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[àáâã]'), 'a')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôõ]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll(RegExp('[ç]'), 'c')
      .replaceAll('\'', ' ');

  // ── Search helpers that work on an arbitrary list ─────────────────────────
  static List<FoodItem> searchIn(List<FoodItem> items, String query, {int limit = 20}) {
    if (query.isEmpty) return items.take(limit).toList();
    final q = _normalize(query);
    final results = items.where((f) => _normalize(f.name).contains(q)).toList();
    results.sort((a, b) {
      final aStart = _normalize(a.name).startsWith(q) ? 0 : 1;
      final bStart = _normalize(b.name).startsWith(q) ? 0 : 1;
      return aStart.compareTo(bStart);
    });
    return results.take(limit).toList();
  }

  static List<FoodItem> byCategoryIn(List<FoodItem> items, FoodCategory cat) =>
      items.where((f) => f.category == cat).toList();

  static List<FoodItem> popularIn(List<FoodItem> items) {
    const ids = [
      'chicken_breast', 'oats', 'egg_whole', 'greek_yogurt',
      'banana', 'rice_white', 'salmon', 'avocado',
    ];
    return ids
        .map((id) => items.where((f) => f.id == id).firstOrNull)
        .whereType<FoodItem>()
        .toList();
  }
}

// ── Supabase provider with offline fallback ───────────────────────────────────
final foodItemsProvider = FutureProvider<List<FoodItem>>((ref) async {
  try {
    final rows = await SupabaseConfig.table('foods')
        .select()
        .order('name') as List;
    if (rows.isEmpty) return FoodDatabase.all;
    return rows.cast<Map<String, dynamic>>().map((r) => FoodItem(
      id:           r['id'] as String,
      name:         r['name'] as String,
      category:     FoodCategory.values.firstWhere(
        (c) => c.name == (r['category'] as String? ?? ''),
        orElse: () => FoodCategory.platCompose,
      ),
      kcal:         (r['kcal'] as num).toDouble(),
      protein:      (r['protein'] as num).toDouble(),
      carbs:        (r['carbs'] as num).toDouble(),
      fat:          (r['fat'] as num).toDouble(),
      fiber:        (r['fiber'] as num? ?? 0).toDouble(),
      defaultGrams: (r['default_grams'] as num? ?? 100).toDouble(),
      portionLabel: r['portion_label'] as String? ?? '100 g',
    )).toList();
  } catch (_) {
    return FoodDatabase.all;
  }
});
