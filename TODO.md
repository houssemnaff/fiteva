# TODO - Home “Voir tout” bottom sheets

- [ ] Read `lib/screens/home/home_screen.dart` and locate the existing `voir tout` actions for:
  - [ ] My Programs (“voir tout”) → showModalBottomSheet with programs + progress + button to continue program + button “Voir tout”
  - [ ] Favorites / Shop (“voir tout”) → showModalBottomSheet with favorite programs OR products from shop
  - [ ] Nutrition (“voir tout”) → showModalBottomSheet listing nutrition items/products
- [ ] Implement reusable bottom sheet widget(s) (program list card rows + CTA buttons).
- [ ] Wire buttons to existing navigation routes (program detail / current route / shop route / nutrition route).
- [ ] Ensure bottom sheets use existing app routing (Navigator / GoRouter) without route-name mismatches.
- [ ] Run `flutter analyze` / `flutter run` to confirm no layout overflow/regressions.

