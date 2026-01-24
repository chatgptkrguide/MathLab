# Flutter ProGuard Rules
# Keep Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Keep Flutter plugin classes
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore
-keep class com.google.cloud.** { *; }
-dontwarn com.google.cloud.**

# Google Sign In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Kakao SDK
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**

# Riverpod / Provider
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <init>(...);
}

# Keep model classes (adjust package names as needed)
-keep class com.gomath.mathlab.models.** { *; }

# Keep serialization classes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
