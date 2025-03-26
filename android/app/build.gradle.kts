plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))

    // Add the dependencies for Firebase products
    implementation("com.google.firebase:firebase-analytics")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

android {
    namespace = "com.example.gsc"
    compileSdk = 34

    // ✅ Fix: Set the required NDK version explicitly
    ndkVersion = "27.0.12077973"  // Updated NDK version as per the error message

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.gsc"
        minSdk = 26  // ✅ Increased from 21 to 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // 🔴 **FIX**: Remove this line if `signingConfigs` is not defined
            // signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true  // ✅ Correct syntax

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )  // ✅ Corrected closing parenthesis
        }
    }
}

flutter {
    source = "../.."
}
