plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fertilizercalc.app"
    compileSdk = 36  // ← MANUALLY SET!
    ndkVersion = "27.0.12077973"  // ← MANUALLY SET!

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.fertilizercalc.app"
        minSdk = 21  // ← MANUALLY SET!
        targetSdk = 36  // ← MANUALLY SET!
        versionCode = 1
        versionName = "1.0.0"
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
