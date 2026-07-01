buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://mirrors.tencent.com/nexus/repository/maven-public/") }
        // 集成华为推送时取消注释下一行：
        // maven { url = uri("https://developer.huawei.com/repo/") }
        // 集成荣耀推送时取消注释下一行：
        // maven { url = uri("https://developer.hihonor.com/repo") }
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        // 集成 FCM 推送时取消注释下一行：
        // classpath("com.google.gms:google-services:4.3.15")
        // 集成华为推送时取消注释下一行：
        // classpath("com.huawei.agconnect:agcp:1.9.4.300")
        // 集成荣耀推送时取消注释下一行：
        // classpath("com.hihonor.mcs:asplugin:2.0.1.300")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://mirrors.tencent.com/nexus/repository/maven-public/") }
        // 集成华为推送时取消注释下一行：
        // maven { url = uri("https://developer.huawei.com/repo/") }
        // 集成荣耀推送时取消注释下一行：
        // maven { url = uri("https://developer.hihonor.com/repo") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
