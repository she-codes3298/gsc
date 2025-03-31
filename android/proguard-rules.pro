# Keep all class members of your app package to prevent accidental removal
-keep class com.example.** { *; }

# Keep Firebase-related classes
-keep class com.google.firebase.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }

# Ignore warnings related to missing AndroidX classes
-dontwarn android.support.**
