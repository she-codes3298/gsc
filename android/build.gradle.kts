allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false // ✅ Ensure consistent version
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false    // ✅ Upgrade Kotlin to 2.1.0
}

// ✅ Fix for build directory issues
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