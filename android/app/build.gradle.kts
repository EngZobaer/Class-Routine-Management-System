plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin অবশ্যই Android + Kotlin এর পর apply হবে
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Firebase এর জন্য Google Services Plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.dcr_1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.dcr_1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase BoM ব্যবহার করলে সব লাইব্রেরি ভার্সন ম্যানেজ হবে
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // ✅ Firebase লাইব্রেরিগুলো (যেটা লাগবে সেটাই add করবেন)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}
