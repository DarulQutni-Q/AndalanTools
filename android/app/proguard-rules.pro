# Flutter Wrapper
-dontwarn io.flutter.**

# Google ML Kit
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
-keep class com.google.mlkit.** { *; }

# uCrop (Yalantis)
-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }

# OkHttp and Okio (used by uCrop)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
