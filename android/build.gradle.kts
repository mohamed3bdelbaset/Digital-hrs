
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(
    rootProject.layout.projectDirectory.dir("../build")
)

subprojects {
    layout.buildDirectory.set(
        rootProject.layout.buildDirectory.dir(name)
    )
    
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
