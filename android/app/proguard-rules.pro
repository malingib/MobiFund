# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Supabase & related libraries
-keep class com.supabase.** { *; }
-keep class io.gotev.** { *; }
-dontwarn com.supabase.**
-dontwarn io.gotev.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# HTTP clients
-keep class okhttp3.** { *; }
-keep class com.squareup.okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn com.squareup.okhttp3.**

# Retrofit
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Native crypto
-keep class javax.crypto.** { *; }
-dontwarn javax.crypto.**

# Keep app-specific code
-keep class com.mobiwave.mobifund.** { *; }

# Crypto and security libraries
-keep class java.security.** { *; }
-keep class javax.security.** { *; }

# Remove verbose logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
