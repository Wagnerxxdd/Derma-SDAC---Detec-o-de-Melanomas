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

// Safer fix for plugins with missing namespace
subprojects {
    if (project.name == "tflite_flutter" || project.name == "tflite_flutter_plus") {
        afterEvaluate {
            val androidExtension = extensions.findByName("android")
            if (androidExtension != null) {
                val method = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                val targetNamespace = if (project.name == "tflite_flutter") 
                    "com.tfliteflutter.tflite_flutter" 
                else 
                    "com.a5starcompany.com.ng.tflite_flutter_plus"
                method.invoke(androidExtension, targetNamespace)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
