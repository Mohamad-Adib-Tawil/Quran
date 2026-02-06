# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ✅ Audio Service (MediaBrowserService) - Critical for background playback
-keep class androidx.media.** { *; }
-keep interface androidx.media.** { *; }
-keep class * extends androidx.media.MediaBrowserServiceCompat { *; }
-keep class com.ryanheise.audioservice.** { *; }

# ✅ Just Audio (ExoPlayer + Reflection) - Prevents playback crashes
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
-keepclassmembers class com.google.android.exoplayer2.** {
    <init>(...);
}

# ✅ Dio - Network requests
-keep class io.grpc.** { *; }
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ✅ Shared Preferences
-keep class androidx.preference.** { *; }

# ✅ Background Downloader (WorkManager)
-keep class com.bbflight.background_downloader.** { *; }
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.CoroutineWorker
-dontwarn androidx.work.**

# ✅ SQLite / Path Provider (Android 10+ Scoped Storage)
-keep class androidx.sqlite.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# ✅ Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ✅ Keep generic signatures for reflection (Gson/JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ✅ Keep Parcelables (Android IPC)
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ✅ Keep Serializables
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ✅ Remove logging in release (performance + security)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
}

# ✅ Preserve line numbers for crash reports (essential for debugging)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ✅ Crashlytics / Firebase (if added later)
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ✅ Google Play Core (Deferred Components - Optional Feature)
# These classes are only used if deferred components are enabled
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# ✅ Flutter Play Store Split Application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
