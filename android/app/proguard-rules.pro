# ================== META/DEPURAÇÃO ==================
# Mantenha informações úteis pra stacktrace e reflexão
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod,SourceFile,LineNumberTable

# Enums (evita R8 ser agressivo demais)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable (precisamos do CREATOR)
-keep class ** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ================== AVISOS GENÉRICOS/GRADLE ==================
-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
-dontwarn org.bouncycastle.jce.provider.BouncyCastleProvider
-dontwarn org.bouncycastle.pqc.jcajce.provider.BouncyCastlePQCProvider
-keep class org.xmlpull.v1.** { *; }

# ================== FLUTTER ==================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ================== GOOGLE PLAY SERVICES / MAPS / LOCATION ==================
# Maps SDK (Android)
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.**

# Location (FusedLocationProvider etc.)
-keep class com.google.android.gms.location.** { *; }

# Google Maps Android Utilities (se usar clustering, heatmaps etc.)
-keep class com.google.maps.android.** { *; }
-dontwarn com.google.maps.android.**

# Places SDK (se usar Autocomplete/Places)
-keep class com.google.android.libraries.places.** { *; }
-dontwarn com.google.android.libraries.places.**

# ================== FIREBASE (Auth/Firestore/Storage/Performance) ==================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Protobuf (usado por Firestore)
-dontwarn com.google.protobuf.**

# ================== BRAINTREE / CARD.IO ==================
-keep class com.braintreepayments.** { *; }
-dontwarn com.braintreepayments.**
-keep class io.card.** { *; }
-dontwarn io.card.**

# ================== OKHTTP/OKIO (muitas libs usam indiretamente) ==================
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# ================== ANDROIDX / LIFECYCLE / COROUTINES ==================
-dontwarn androidx.lifecycle.**
-dontwarn kotlinx.coroutines.**

# ================== GLIDE (caso alguma dependência utilize) ==================
# Os módulos do Glide às vezes são removidos sem isso
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep class com.bumptech.glide.GeneratedAppGlideModuleImpl { *; }
-keep class com.bumptech.glide.GeneratedRequestManagerFactory { *; }
-dontwarn com.bumptech.glide.**

# ================== GSON (se houver serialização por reflexão) ==================
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# ================== PLAY BILLING / WALLET (caso use Google Pay) ==================
-keep class com.google.android.gms.wallet.** { *; }
-dontwarn com.google.android.gms.wallet.**

# ================== EXTRA: REFLEXÃO EM KOTLIN/ANOTAÇÕES ==================
# Ajuda quando plugins usam reflexão em classes anotadas
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
