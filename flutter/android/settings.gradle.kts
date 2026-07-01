pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://mirrors.tencent.com/nexus/repository/maven-public/") }
        // 集成华为推送时取消注释下一行：
        // maven { url = uri("https://developer.huawei.com/repo/") }
        // 集成荣耀推送时取消注释下一行：
        // maven { url = uri("https://developer.hihonor.com/repo") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

dependencyResolutionManagement {
    versionCatalogs {
        create("libs") {
            plugin("android-application", "com.android.application").version("8.7.0")
        }
    }
}

include(":app")
