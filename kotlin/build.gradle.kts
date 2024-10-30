plugins {
	kotlin("jvm") version "1.8.0"
}

repositories {
	mavenCentral()
}

dependencies {
	implementation(kotlin("stdlib"))
	testImplementation(kotlin("test"))
	testImplementation("org.junit.jupiter:junit-jupiter:5.8.2")
}

tasks.test {
	useJUnitPlatform()
}
