# ===== Avisos genéricos sugeridos pelo Gradle (os que você recebeu) =====
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn org.bouncycastle.jce.provider.BouncyCastleProvider
-dontwarn org.bouncycastle.pqc.jcajce.provider.BouncyCastlePQCProvider
-keep class org.xmlpull.v1.** { *; }

# ===== Google Play Services / Maps / Places =====
# (Evita que o R8 remova/refatore classes usadas pelo Maps)
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.**

# Se usar as libs utilitárias do Google Maps (clustering, proj., etc.)
-keep class com.google.maps.android.** { *; }
-dontwarn com.google.maps.android.**

# Places SDK (se você usa Places/Autocomplete)
-keep class com.google.android.libraries.places.** { *; }
-dontwarn com.google.android.libraries.places.**

# ===== Flutter e plugins =====
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase (se estiver usando)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# (Opcional) Coroutines / Lifecycle, comuns em plugins
-dontwarn kotlinx.coroutines.**
-dontwarn androidx.lifecycle.**
