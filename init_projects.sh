#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}Created directory: $1${NC}"
    fi
}

check_directory_empty() {
    local dir=$1
    if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
        return 1
    fi
    return 0
}

prompt_reinit() {
    local lang=$1
    read -p "Directory for $lang already exists. Reinitialize? (y/N) " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

backup_directory() {
    local dir=$1
    local backup_dir="${dir}_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$dir" "$backup_dir"
    echo "Backed up existing directory to: $backup_dir"
}

create_config_if_missing() {
    local file=$1
    local content=$2
    
    if [ ! -f "$file" ]; then
        echo "Creating $file..."
        echo "$content" > "$file"
    else
        echo -e "${GREEN}$file already exists${NC}"
    fi
}

init_php_project() {
    echo -e "\n${YELLOW}Initializing PHP project...${NC}"
    ensure_dir "php"
    cd php || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "PHP"; then
            cd ..
            return 0
        fi
        backup_directory "vendor"
    fi
    
    rm -rf vendor composer.lock
    
    cat > composer.json << EOL
{
    "name": "dsa/php",
    "description": "Data Structures and Algorithms in PHP",
    "type": "project",
    "require": {
        "php": ">=7.4"
    },
    "require-dev": {
        "phpunit/phpunit": "^9.5"
    },
    "autoload": {
        "psr-4": {
            "DSA\\\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "DSA\\\\Tests\\\\": "tests/"
        }
    }
}
EOL

    if command_exists composer; then
        COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction
    fi
    
    cd ..
    return 0
}

init_javascript_project() {
    echo -e "\n${YELLOW}Initializing JavaScript project...${NC}"
    ensure_dir "javascript"
    cd javascript || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "JavaScript"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Initialize with npm
    echo "Initializing new npm project..."
    npm init -y
    
    # Install minimal dependencies for testing
    echo "Installing dependencies..."
    npm install --save-dev jest@latest
    
    # Update package.json scripts
    if [ -f "package.json" ]; then
        local tmp_file=$(mktemp)
        jq '.scripts = {
            "test": "jest"
        }' package.json > "$tmp_file" && mv "$tmp_file" package.json
    fi
    
    # Create .gitignore
    create_config_if_missing ".gitignore" "node_modules/
coverage/
.env
*.log
dist/"
    
    ensure_dir "src"
    ensure_dir "tests"
    
    cd ..
    return 0
}

init_typescript_project() {
    echo -e "\n${YELLOW}Initializing TypeScript project...${NC}"
    ensure_dir "typescript"
    cd typescript || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "TypeScript"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Initialize with npm
    echo "Initializing new npm project..."
    npm init -y
    
    # Install minimal dependencies
    echo "Installing dependencies..."
    npm install --save-dev typescript@latest @types/node@latest ts-jest@latest @types/jest@latest
    
    create_config_if_missing "tsconfig.json" '{
    "compilerOptions": {
        "target": "ES2022",
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "strict": true,
        "outDir": "dist",
        "sourceMap": true,
        "rootDir": "src"
    },
    "include": ["src/**/*"],
    "exclude": ["node_modules", "dist", "tests"]
}'

    # Create jest.config.js for TypeScript
    create_config_if_missing "jest.config.js" 'module.exports = {
    preset: "ts-jest",
    testEnvironment: "node",
    testMatch: ["**/tests/**/*.test.ts"]
};'
    
    # Update package.json scripts
    if [ -f "package.json" ]; then
        local tmp_file=$(mktemp)
        jq '.scripts = {
            "build": "tsc",
            "test": "jest",
            "watch": "tsc -w"
        }' package.json > "$tmp_file" && mv "$tmp_file" package.json
    fi
    
    # Create .gitignore
    create_config_if_missing ".gitignore" "node_modules/
dist/
coverage/
.env
*.log"
    
    ensure_dir "src"
    ensure_dir "tests"
    
    cd ..
    return 0
}

init_python_project() {
    echo -e "\n${YELLOW}Initializing Python project...${NC}"
    ensure_dir "python"
    cd python || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Python"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    python -m venv venv
    
    create_config_if_missing "setup.py" 'from setuptools import setup, find_packages

setup(
    name="dsa",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-cov>=4.0.0",
        ],
    },
)'

    create_config_if_missing "requirements.txt" 'pytest>=7.0.0
pytest-cov>=4.0.0'

    ensure_dir "src"
    ensure_dir "tests"
    
    create_config_if_missing ".gitignore" "venv/
__pycache__/
*.pyc
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/"

    cd ..
    return 0
}

init_java_project() {
    echo -e "\n${YELLOW}Initializing Java project...${NC}"
    ensure_dir "java"
    cd java || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Java"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    create_config_if_missing "pom.xml" '<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.dsa</groupId>
    <artifactId>algorithms</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <junit.version>5.9.2</junit.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.0.0</version>
            </plugin>
        </plugins>
    </build>
</project>'

    ensure_dir "src/main/java/com/dsa"
    ensure_dir "src/test/java/com/dsa"
    
    create_config_if_missing ".gitignore" "target/
.idea/
*.iml
.settings/
.project
.classpath"

    cd ..
    return 0
}

init_cpp_project() {
    echo -e "\n${YELLOW}Initializing C++ project...${NC}"
    ensure_dir "cpp"
    cd cpp || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "C++"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    create_config_if_missing "CMakeLists.txt" 'cmake_minimum_required(VERSION 3.10)
project(DSA VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable testing
enable_testing()

# Add Google Test
include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip
)
FetchContent_MakeAvailable(googletest)

# Add source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE TEST_SOURCES "tests/*.cpp")

# Create library
add_library(dsa_lib ${SOURCES})
target_include_directories(dsa_lib PUBLIC include)

# Create test executable
add_executable(dsa_tests ${TEST_SOURCES})
target_link_libraries(dsa_tests PRIVATE dsa_lib gtest_main)

# Register tests
include(GoogleTest)
gtest_discover_tests(dsa_tests)'

    ensure_dir "src"
    ensure_dir "include"
    ensure_dir "tests"
    
    create_config_if_missing ".gitignore" "build/
.vscode/
.idea/
cmake-build-*/
*.o
*.exe"

    cd ..
    return 0
}

init_dart_project() {
    echo -e "\n${YELLOW}Initializing Dart project...${NC}"
    ensure_dir "dart"
    cd dart || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Dart"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    dart create --template=package .
    
    create_config_if_missing "pubspec.yaml" 'name: dsa
description: Data Structures and Algorithms implementation in Dart.
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dev_dependencies:
  test: ^1.24.0
  lints: ^3.0.0'
    
    ensure_dir "lib"
    ensure_dir "test"
    
    create_config_if_missing ".gitignore" ".dart_tool/
.packages
build/
pubspec.lock"
    
    dart pub get
    
    cd ..
    return 0
}

init_ruby_project() {
    echo -e "\n${YELLOW}Initializing Ruby project...${NC}"
    ensure_dir "ruby"
    cd ruby || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Ruby"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    create_config_if_missing "Gemfile" 'source "https://rubygems.org"

gem "rspec", "~> 3.12"
gem "rake", "~> 13.0"'
    
    create_config_if_missing "Rakefile" 'require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec'
    
    ensure_dir "lib"
    ensure_dir "spec"
    
    create_config_if_missing ".gitignore" "*.gem
*.rbc
/.config
/coverage/
/pkg/
/spec/reports/
/tmp/
.rspec_status"
    
    if command_exists bundle; then
        bundle install
    fi
    
    cd ..
    return 0
}

init_c_project() {
    echo -e "\n${YELLOW}Initializing C project...${NC}"
    ensure_dir "c"
    cd c || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "C"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    create_config_if_missing "CMakeLists.txt" 'cmake_minimum_required(VERSION 3.10)
project(DSA C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Enable testing
enable_testing()

# Add Google Test
include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip
)
FetchContent_MakeAvailable(googletest)

# Add source files
file(GLOB_RECURSE SOURCES "src/*.c")
file(GLOB_RECURSE TEST_SOURCES "tests/*.c")

# Create library
add_library(dsa_lib ${SOURCES})
target_include_directories(dsa_lib PUBLIC include)

# Create test executable
add_executable(dsa_tests ${TEST_SOURCES})
target_link_libraries(dsa_tests PRIVATE dsa_lib gtest_main)

# Register tests
include(GoogleTest)
gtest_discover_tests(dsa_tests)'

    ensure_dir "src"
    ensure_dir "include"
    ensure_dir "tests"
    
    create_config_if_missing ".gitignore" "build/
.vscode/
.idea/
cmake-build-*/
*.o
*.exe"

    cd ..
    return 0
}

init_kotlin_project() {
    echo -e "\n${YELLOW}Initializing Kotlin project...${NC}"
    ensure_dir "kotlin"
    cd kotlin || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Kotlin"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Create build.gradle.kts
    create_config_if_missing "build.gradle.kts" 'plugins {
    kotlin("jvm") version "1.9.0"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
}

tasks.test {
    useJUnitPlatform()
}'

    # Create settings.gradle.kts
    create_config_if_missing "settings.gradle.kts" 'rootProject.name = "dsa-kotlin"'
    
    # Create directory structure
    ensure_dir "src/main/kotlin"
    ensure_dir "src/test/kotlin"
    
    # Create .gitignore
    create_config_if_missing ".gitignore" ".gradle/
build/
.idea/
*.iml
.DS_Store"
    
    cd ..
    return 0
}

init_swift_project() {
    echo -e "\n${YELLOW}Initializing Swift project...${NC}"
    ensure_dir "swift"
    cd swift || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Swift"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Initialize Swift package
    swift package init --type library
    
    # Update Package.swift
    create_config_if_missing "Package.swift" '// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "DSA",
    products: [
        .library(name: "DSA", targets: ["DSA"]),
    ],
    targets: [
        .target(name: "DSA", dependencies: []),
        .testTarget(name: "DSATests", dependencies: ["DSA"]),
    ]
)'
    
    # Create .gitignore
    create_config_if_missing ".gitignore" ".DS_Store
/.build
/Packages
/*.xcodeproj
xcuserdata/
DerivedData/
.swiftpm/"
    
    cd ..
    return 0
}

init_go_project() {
    echo -e "\n${YELLOW}Initializing Go project...${NC}"
    ensure_dir "go"
    cd go || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Go"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Initialize Go module
    go mod init dsa
    
    # Create directory structure
    ensure_dir "cmd"
    ensure_dir "internal"
    ensure_dir "pkg"
    
    # Create main.go
    create_config_if_missing "cmd/main.go" 'package main

func main() {
    // Entry point for the application
}'
    
    # Create .gitignore
    create_config_if_missing ".gitignore" "# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out

# Dependency directories
/vendor/"
    
    cd ..
    return 0
}

init_rust_project() {
    echo -e "\n${YELLOW}Initializing Rust project...${NC}"
    ensure_dir "rust"
    cd rust || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "Rust"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Initialize new Rust project
    cargo init --name dsa
    
    # Update Cargo.toml
    create_config_if_missing "Cargo.toml" '[package]
name = "dsa"
version = "0.1.0"
edition = "2021"

[dependencies]

[dev-dependencies]
criterion = "0.5"

[[bench]]
name = "benchmarks"
harness = false'
    
    # Create directory structure
    ensure_dir "src"
    ensure_dir "tests"
    ensure_dir "benches"
    
    # Create basic benchmark file
    create_config_if_missing "benches/benchmarks.rs" 'use criterion::{criterion_group, criterion_main, Criterion};

fn benchmark(c: &mut Criterion) {
    // Add benchmarks here
}

criterion_group!(benches, benchmark);
criterion_main!(benches);'
    
    cd ..
    return 0
}

init_csharp_project() {
    echo -e "\n${YELLOW}Initializing C# project...${NC}"
    ensure_dir "csharp"
    cd csharp || return 1
    
    if ! check_directory_empty "."; then
        if ! prompt_reinit "C#"; then
            cd ..
            return 0
        fi
        backup_directory "."
    fi
    
    # Create solution
    dotnet new sln --name DSA
    
    # Create class library project
    dotnet new classlib -n DSA.Core
    dotnet sln add DSA.Core/DSA.Core.csproj
    
    # Create test project
    dotnet new xunit -n DSA.Tests
    dotnet sln add DSA.Tests/DSA.Tests.csproj
    dotnet add DSA.Tests/DSA.Tests.csproj reference DSA.Core/DSA.Core.csproj
    
    # Create .gitignore
    create_config_if_missing ".gitignore" "## .NET Core
bin/
obj/
*.user
*.userosscache
*.suo
*.userprefs
.vs/
.vscode/
*.swp
*.*~
project.lock.json
.DS_Store
*.pyc
nupkg/

# Visual Studio Code
.vscode

# Rider
.idea/

# User-specific files
*.suo
*.user
*.userosscache
*.sln.docstates"
    
    cd ..
    return 0
}

init_all_projects() {
    echo -e "${YELLOW}Initializing project files for all languages...${NC}"
    
    declare -A project_inits=(
        ["php"]="init_php_project"
        ["csharp"]="init_csharp_project"
        ["go"]="init_go_project"
        ["cpp"]="init_cpp_project"
        ["c"]="init_c_project"
        ["java"]="init_java_project"
        ["python"]="init_python_project"
        ["rust"]="init_rust_project"
        ["ruby"]="init_ruby_project"
        ["swift"]="init_swift_project"
        ["kotlin"]="init_kotlin_project"
        ["javascript"]="init_javascript_project"
        ["typescript"]="init_typescript_project"
        ["dart"]="init_dart_project"
    )
    
    for project in "${!project_inits[@]}"; do
        init_func="${project_inits[$project]}"
        if declare -F "$init_func" > /dev/null; then
            if ! $init_func; then
                echo -e "${RED}Failed to initialize: $project${NC}"
            fi
        else
            echo -e "${RED}Initialization function not found: $init_func${NC}"
        fi
    done
}

add_gitkeep_files() {
    echo -e "\n${YELLOW}Adding .gitkeep files to empty directories...${NC}"
    find . -type d -empty -not -path "*/\.*" -exec touch {}/.gitkeep \;
}

main() {
    init_all_projects
    add_gitkeep_files
    echo -e "\n${GREEN}Project initialization complete!${NC}"
}

main