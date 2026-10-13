# Flutter embedding and plugins. R8 minify/shrink is enabled on release.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core is optional (deferred components). Silence missing-class warnings.
-dontwarn com.google.android.play.core.**
