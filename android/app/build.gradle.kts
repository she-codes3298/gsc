plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Keep this at the bottom
}

android {
    namespace = "com.example.gsc"
    compileSdk = 35 // Ensure this matches your Flutter compile SDK version

    ndkVersion = "27.0.12077973" // Updated NDK version as per the error message

    defaultConfig {
        applicationId = "com.example.gsc"
        minSdk = 23  // Set minimum SDK to 23
        targetSdk = 35 // Ensure this matches your Flutter target SDK version
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            isMinifyEnabled = true // ✅ Enable code shrinking
            isShrinkResources = true // ✅ Enable resource shrinking

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), // ✅ Default ProGuard rules
                "proguard-rules.pro" // ✅ Use the newly created ProGuard file
            )
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ Updated
}
