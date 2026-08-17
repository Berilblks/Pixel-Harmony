import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePropertiesFile = rootProject.file("key.properties")
val releaseKeystoreProperties = Properties()
val requiredSigningProperties = listOf(
    "storePassword",
    "keyPassword",
    "keyAlias",
    "storeFile",
)

if (releaseKeystorePropertiesFile.exists()) {
    releaseKeystorePropertiesFile.inputStream().use(releaseKeystoreProperties::load)
}

val hasCompleteReleaseSigning =
    releaseKeystorePropertiesFile.exists() &&
        requiredSigningProperties.all { key ->
            releaseKeystoreProperties.getProperty(key)?.isNotBlank() == true
        } &&
        rootProject.file(releaseKeystoreProperties.getProperty("storeFile", "")).exists()

android {
    namespace = "com.berilblks.pixelharmony"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.berilblks.pixelharmony"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasCompleteReleaseSigning) {
            create("release") {
                keyAlias = releaseKeystoreProperties.getProperty("keyAlias")
                keyPassword = releaseKeystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(releaseKeystoreProperties.getProperty("storeFile"))
                storePassword = releaseKeystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            isDebuggable = false
            isMinifyEnabled = false
            isShrinkResources = false
            if (hasCompleteReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val requestsReleaseArtifact = allTasks.any { task ->
        task.path.startsWith(":app:") && task.name.contains("Release", ignoreCase = true)
    }
    if (requestsReleaseArtifact && !hasCompleteReleaseSigning) {
        throw GradleException(
            "Release signing is not configured. Create android/key.properties with " +
                "storePassword, keyPassword, keyAlias, and storeFile values. " +
                "Keep that file and the upload keystore outside Git.",
        )
    }
}

flutter {
    source = "../.."
}
