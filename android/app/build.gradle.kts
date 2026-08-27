import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
  implementation(platform("com.google.firebase:firebase-bom:34.18.0"))
  implementation("com.google.firebase:firebase-analytics")
}


android {
    namespace = "com.OneDestiny.customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.OneDestiny.customer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyPropFile = rootProject.file("key.properties")
            if (keyPropFile.exists()) {
                val keyProps = Properties()
                keyProps.load(FileInputStream(keyPropFile))
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
                val storeFilePath = keyProps.getProperty("storeFile")
                storeFile = if (file(storeFilePath).exists()) {
                    file(storeFilePath)
                } else if (file("../$storeFilePath").exists()) {
                    file("../$storeFilePath")
                } else {
                    rootProject.file(storeFilePath)
                }
                storePassword = keyProps.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            val keyPropFile = rootProject.file("key.properties")
            signingConfig = if (keyPropFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
