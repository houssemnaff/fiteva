# flutter_stripe — le SDK référence les classes optionnelles de
# « push provisioning » (ajout de cartes à Google Pay) sans les embarquer.
# R8 échoue en release sans ces règles. Fix officiel :
# https://github.com/flutter-stripe/flutter_stripe#android
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
