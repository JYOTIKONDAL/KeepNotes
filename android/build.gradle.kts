import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// AGP 8+ requires namespace on all Android library modules. Older plugins
// (e.g. isar_flutter_libs 3.1.0) omit it; derive from Gradle project group.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace.isNullOrEmpty()) {
                namespace = project.group.toString()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
