#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓ Found: $1${NC}"
        return 0
    else
        echo -e "${RED}✗ Missing: $1${NC}"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓ Found directory: $1${NC}"
        return 0
    else
        echo -e "${RED}✗ Missing directory: $1${NC}"
        return 1
    fi
}

create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}Created directory: $1${NC}"
    else
        echo -e "${YELLOW}Directory already exists: $1${NC}"
    fi
}

create_file() {
    if [ ! -f "$1" ]; then
        touch "$1"
        echo -e "${GREEN}Created file: $1${NC}"
    else
        echo -e "${YELLOW}File already exists: $1${NC}"
    fi
}

check_env_status() {
    local env_name="$1"
    local dir_path="$2"
    local required_files=("${@:3}")
    
    if [ -d "$dir_path" ]; then
        local missing_files=()
        for file in "${required_files[@]}"; do
            if [ ! -e "$dir_path/$file" ]; then
                missing_files+=("$file")
            fi
        done
        
        if [ ${#missing_files[@]} -eq 0 ]; then
            echo -e "${GREEN}✓ $env_name environment is properly configured${NC}"
            return 0
        else
            echo -e "${YELLOW}! $env_name environment exists but missing: ${missing_files[*]}${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ $env_name environment not found${NC}"
        return 2
    fi
}

check_python_env() {
    echo -e "\n${YELLOW}Checking Python project environment...${NC}"
    local status=0
    
    check_file "python/requirements.txt" || status=1
    check_file "python/setup.py" || check_file "python/pyproject.toml" || status=1
    check_dir "python/venv" || check_dir "python/.venv" || status=1
    check_file "python/.gitignore" || status=1
    check_file "python/README.md" || status=1
    check_dir "python/tests" || status=1
    
    return $status
}

check_node_env() {
    echo -e "\n${YELLOW}Checking Node.js/TypeScript project environment...${NC}"
    local status=0
    
    check_file "typescript/package.json" || status=1
    check_file "typescript/package-lock.json" || check_file "typescript/yarn.lock" || status=1
    check_dir "typescript/node_modules" || status=1
    check_file "typescript/.gitignore" || status=1
    check_file "typescript/README.md" || status=1
    check_file "typescript/tsconfig.json" || status=1
    
    return $status
}

check_java_env() {
    echo -e "\n${YELLOW}Checking Java project environment...${NC}"
    local status=0
    
    check_file "java/pom.xml" || check_file "java/build.gradle" || status=1
    check_dir "java/src/main/java" || status=1
    check_dir "java/src/test/java" || status=1
    check_file "java/.gitignore" || status=1
    check_file "java/README.md" || status=1
    
    return $status
}

check_cpp_env() {
    echo -e "\n${YELLOW}Checking C++ project environment...${NC}"
    local status=0
    
    check_file "cpp/CMakeLists.txt" || check_file "cpp/Makefile" || status=1
    check_dir "cpp/src" || status=1
    check_dir "cpp/include" || status=1
    check_file "cpp/.gitignore" || status=1
    check_file "cpp/README.md" || status=1
    
    return $status
}

check_php_env() {
    echo -e "\n${YELLOW}Checking PHP project environment...${NC}"
    local status=0
    
    check_file "php/composer.json" || status=1
    check_dir "php/src" || status=1
    check_dir "php/tests" || status=1
    check_file "php/.gitignore" || status=1
    check_file "php/README.md" || status=1
    
    return $status
}

check_dotnet_env() {
    echo -e "\n${YELLOW}Checking .NET project environment...${NC}"
    local status=0
    
    check_file "csharp/DSA.sln" || status=1
    check_dir "csharp/DSA.Core" || status=1
    check_dir "csharp/DSA.Tests" || status=1
    check_file "csharp/.gitignore" || status=1
    check_file "csharp/README.md" || status=1
    
    return $status
}

check_go_env() {
    echo -e "\n${YELLOW}Checking Go project environment...${NC}"
    local status=0
    
    check_file "go/go.mod" || status=1
    check_dir "go/cmd" || status=1
    check_dir "go/pkg" || status=1
    check_dir "go/internal" || status=1
    check_file "go/.gitignore" || status=1
    check_file "go/README.md" || status=1
    
    return $status
}

check_rust_env() {
    echo -e "\n${YELLOW}Checking Rust project environment...${NC}"
    local status=0
    
    cd rust || return
    
    if [ ! -f "Cargo.toml" ]; then
        cargo init
        cat >> Cargo.toml << EOL

[dependencies]
itertools = "0.10"
num = "0.4"
rand = "0.8"

[dev-dependencies]
criterion = "0.4"
EOL
        status=1
    fi
    
    [ ! -f ".gitignore" ] && touch .gitignore && status=1
    [ ! -f "README.md" ] && touch README.md && status=1
    [ ! -d "src" ] && mkdir -p src && status=1
    
    cd ..
    return $status
}

check_ruby_env() {
    echo -e "\n${YELLOW}Checking Ruby project environment...${NC}"
    local status=0
    
    cd ruby || return
    
    if [ ! -f "Gemfile" ]; then
        cat > Gemfile << EOL
source 'https://rubygems.org'

gem 'rspec'
gem 'rubocop'
EOL
        status=1
    fi
    
    [ ! -f ".gitignore" ] && touch .gitignore && status=1
    [ ! -f "README.md" ] && touch README.md && status=1
    [ ! -d "lib" ] && mkdir -p lib && status=1
    [ ! -d "spec" ] && mkdir -p spec && status=1
    
    if [ ! -f ".rspec" ]; then
        cat > .rspec << EOL
--require spec_helper
--format documentation
EOL
        status=1
    fi
    
    cd ..
    return $status
}

check_swift_env() {
    echo -e "\n${YELLOW}Checking Swift project environment...${NC}"
    local status=0
    
    cd swift || return
    
    if [ ! -f "Package.swift" ]; then
        swift package init --type library
        cat > Package.swift << EOL
// swift-tools-version:5.5
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
)
EOL
        status=1
    fi
    
    [ ! -f ".gitignore" ] && touch .gitignore && status=1
    [ ! -f "README.md" ] && touch README.md && status=1
    [ ! -d "Sources" ] && mkdir -p Sources && status=1
    [ ! -d "Tests" ] && mkdir -p Tests && status=1
    
    cd ..
    return $status
}

check_kotlin_env() {
    echo -e "\n${YELLOW}Checking Kotlin project environment...${NC}"
    local status=0
    
    cd kotlin || return
    
    if [ ! -f "build.gradle.kts" ]; then
        cat > build.gradle.kts << EOL
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
EOL
        status=1
    fi
    
    [ ! -f ".gitignore" ] && touch .gitignore && status=1
    [ ! -f "README.md" ] && touch README.md && status=1
    [ ! -d "src/main/kotlin" ] && mkdir -p src/main/kotlin && status=1
    [ ! -d "src/test/kotlin" ] && mkdir -p src/test/kotlin && status=1
    
    cd ..
    return $status
}

check_c_env() {
    echo -e "\n${YELLOW}Checking C project environment...${NC}"
    local status=0
    
    cd c || return
    
    [ ! -f "CMakeLists.txt" ] && status=1
    [ ! -d "src" ] && mkdir -p src && status=1
    [ ! -d "include" ] && mkdir -p include && status=1
    [ ! -d "tests" ] && mkdir -p tests && status=1
    [ ! -f ".gitignore" ] && touch .gitignore && status=1
    [ ! -f "README.md" ] && touch README.md && status=1
    
    if [ ! -d "build" ]; then
        mkdir -p build
        echo -e "${GREEN}Created directory: build${NC}"
        status=1
    fi
    
    cd ..
    return $status
}

check_javascript_env() {
    echo -e "\n${YELLOW}Checking JavaScript project environment...${NC}"
    local status=0
    
    check_file "javascript/package.json" || status=1
    check_file "javascript/.babelrc" || status=1
    check_file "javascript/.eslintrc.json" || status=1
    check_file "javascript/jest.config.js" || status=1
    check_dir "javascript/node_modules" || status=1
    check_dir "javascript/src" || status=1
    check_dir "javascript/tests" || status=1
    check_file "javascript/.gitignore" || status=1
    check_file "javascript/README.md" || status=1
    
    check_file "javascript/package-lock.json" || check_file "javascript/yarn.lock" || true
    
    return $status
}

setup_python_env() {
    echo -e "\n${YELLOW}Checking Python environment...${NC}"
    
    local pyenv_status=0
    if command_exists pyenv; then
        check_env_status "Pyenv" "$HOME/.pyenv" "versions" "plugins"
        pyenv_status=$?
    fi
    
    local pip_status=0
    if command_exists pip; then
        check_env_status "Pip" "$HOME/.pip" "pip.conf"
        pip_status=$?
    fi
    
    local venv_status=0
    check_env_status "Virtualenv" "$HOME/.virtualenvs"
    venv_status=$?
    
    if [ $pyenv_status -eq 0 ] && [ $pip_status -eq 0 ] && [ $venv_status -eq 0 ]; then
        echo -e "${GREEN}Python environment is fully configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Setting up missing Python components...${NC}"
    
    [ $venv_status -ne 0 ] && create_dir "$HOME/.virtualenvs"
    
    [ $pip_status -ne 0 ] && {
        create_dir "$HOME/.pip"
        create_file "$HOME/.pip/pip.conf"
    }
    
    [ $pyenv_status -ne 0 ] && command_exists pyenv && {
        create_dir "$HOME/.pyenv/versions"
        create_dir "$HOME/.pyenv/plugins"
    }
}

setup_node_env() {
    echo -e "\n${YELLOW}Checking Node.js environment...${NC}"
    
    local npm_status=0
    if command_exists npm; then
        check_env_status "NPM" "$HOME/.npm"
        npm_status=$?
    fi
    
    local nvm_status=0
    if command_exists nvm; then
        check_env_status "NVM" "$HOME/.nvm"
        nvm_status=$?
    fi
    
    local node_modules_status=0
    check_env_status "Node modules" "$HOME/.node_modules"
    node_modules_status=$?
    
    if [ $npm_status -eq 0 ] && [ $nvm_status -eq 0 ] && [ $node_modules_status -eq 0 ]; then
        echo -e "${GREEN}Node.js environment is fully configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Setting up missing Node.js components...${NC}"
    
    [ $npm_status -ne 0 ] && create_dir "$HOME/.npm"
    
    [ $nvm_status -ne 0 ] && create_dir "$HOME/.nvm"
    
    [ $node_modules_status -ne 0 ] && create_dir "$HOME/.node_modules"
    
    if [ ! -f "$HOME/package.json" ]; then
        create_file "$HOME/package.json"
        [ ! -s "$HOME/package.json" ] && echo '{"private": true}' > "$HOME/package.json"
    fi
}

setup_java_env() {
    echo -e "\n${YELLOW}Checking Java environment...${NC}"
    
    local maven_status=0
    if command_exists mvn; then
        check_env_status "Maven" "$HOME/.m2" "settings.xml"
        maven_status=$?
    fi
    
    local gradle_status=0
    if command_exists gradle; then
        check_env_status "Gradle" "$HOME/.gradle"
        gradle_status=$?
    fi
    
    if [ $maven_status -eq 0 ] && [ $gradle_status -eq 0 ]; then
        echo -e "${GREEN}Java environment is fully configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Setting up missing Java components...${NC}"
    
    [ $maven_status -ne 0 ] && {
        create_dir "$HOME/.m2"
        create_file "$HOME/.m2/settings.xml"
    }
    
    [ $gradle_status -ne 0 ] && create_dir "$HOME/.gradle"
}

setup_cpp_env() {
    echo -e "\n${YELLOW}Setting up C/C++ environment...${NC}"
    
    create_dir "$HOME/.local/lib"
    
    create_dir "$HOME/.local/include"
    
    create_dir "$HOME/build"
}

setup_php_env() {
    echo -e "\n${YELLOW}Setting up PHP environment...${NC}"
    
    create_dir "$HOME/.composer"
    
    create_dir "$HOME/.php"
    
    create_file "$HOME/.composer/composer.json"
    [ ! -s "$HOME/.composer/composer.json" ] && echo '{}' > "$HOME/.composer/composer.json"
}

setup_dotnet_env() {
    echo -e "\n${YELLOW}Setting up .NET environment...${NC}"
    
    create_dir "$HOME/.dotnet"
    create_dir "$HOME/.dotnet/tools"
    
    create_dir "$HOME/.nuget/packages"
}

setup_go_env() {
    echo -e "\n${YELLOW}Setting up Go environment...${NC}"
    
    create_dir "$HOME/go"
    create_dir "$HOME/go/src"
    create_dir "$HOME/go/pkg"
    create_dir "$HOME/go/bin"
}

setup_rust_env() {
    echo -e "\n${YELLOW}Setting up Rust environment...${NC}"
    
    create_dir "$HOME/.cargo"
    
    create_dir "$HOME/.rustup"
    
    create_file "$HOME/.cargo/config"
}

setup_ruby_env() {
    echo -e "\n${YELLOW}Setting up Ruby environment...${NC}"
    
    create_dir "$HOME/.gem"
    
    create_dir "$HOME/.bundle"
    
    create_dir "$HOME/.rvm"
}

setup_swift_env() {
    echo -e "\n${YELLOW}Setting up Swift environment...${NC}"
    
    create_dir "$HOME/.swift"
    create_dir "$HOME/.swiftpm"
    
    create_dir "$HOME/.build"
}

setup_kotlin_env() {
    echo -e "\n${YELLOW}Setting up Kotlin environment...${NC}"
    
    create_dir "$HOME/.kotlin"
    
    create_dir "$HOME/.gradle"
    
    create_dir "$HOME/.kotlin-script"
}

fix_path() {
    echo -e "\n${YELLOW}Fixing PATH in .bashrc...${NC}"
    local bashrc="$HOME/.bashrc"
    local backup="$HOME/.bashrc.backup"

    cp "$bashrc" "$backup"
    echo -e "${GREEN}Created backup: $backup${NC}"

    sed -i 's/*i*\\)/\*i\*)/g' "$bashrc"
    sed -i 's/*\\)/\*)/g' "$bashrc"
    sed -i 's/xterm*|rxvt*\\)/xterm\*|rxvt\*)/g' "$bashrc"

    sed -i 's/Program Files (x86)/Program\ Files\ \(x86\)/g' "$bashrc"
    sed -i 's/Program Files/Program\ Files/g' "$bashrc"
    sed -i 's/ (/\ \(/g' "$bashrc"
    sed -i 's/) /\)\ /g' "$bashrc"
    
    sed -i 's/""/"/g' "$bashrc"
    
    sed -i '/^export PATH=/ {
        # Remove duplicate quotes
        s/""\([^"]*\)""/"\1"/g
        # Add quotes if missing
        s/^export PATH=\([^"]\)/export PATH="\1/
        s/\([^"]\)$/\1"/
        # Add continuation character for readability
        s/:/:\\\/g
        # Fix any remaining unescaped spaces
        s/\([^\\]\) /\1\\ /g
    }' "$bashrc"
    
    awk '!seen[$0]++' "$bashrc" > "$bashrc.tmp" && mv "$bashrc.tmp" "$bashrc"
    
    sed -i 's/\\(/(/g' "$bashrc"
    sed -i 's/\\)/)/g' "$bashrc"
    sed -i '/^export PATH=/! s/\\\\(/\\(/g' "$bashrc"
    sed -i '/^export PATH=/! s/\\\\)/\\)/g' "$bashrc"
    
    echo -e "${GREEN}Fixed PATH in .bashrc${NC}"
    echo -e "${YELLOW}Changes made:${NC}"
    echo "1. Fixed case statement syntax"
    echo "2. Escaped spaces and parentheses in PATH"
    echo "3. Removed duplicate PATH exports"
    echo "4. Added proper line continuations"
    echo -e "${YELLOW}Please run 'source ~/.bashrc' to apply changes${NC}"
}

setup() {
    echo -e "${YELLOW}Starting environment setup...${NC}"
    
    create_dir "$HOME/Development"
    create_dir "$HOME/.local/bin"
    
    for lang in "$@"; do
        case "$lang" in
            python) setup_python_env ;;
            node|typescript|javascript) setup_node_env ;;
            java) setup_java_env ;;
            cpp|c) setup_cpp_env ;;
            php) setup_php_env ;;
            csharp|dotnet) setup_dotnet_env ;;
            go) setup_go_env ;;
            rust) setup_rust_env ;;
            ruby) setup_ruby_env ;;
            swift) setup_swift_env ;;
            kotlin) setup_kotlin_env ;;
            all)
                setup_python_env
                setup_node_env
                setup_java_env
                setup_cpp_env
                setup_php_env
                setup_dotnet_env
                setup_go_env
                setup_rust_env
                setup_ruby_env
                setup_swift_env
                setup_kotlin_env
                ;;
            *)
                echo -e "${RED}Unsupported language: $lang${NC}"
                ;;
        esac
    done
    
    echo -e "\n${GREEN}Environment setup complete!${NC}"
    echo -e "${YELLOW}Note: You may need to restart your terminal or source your shell configuration file.${NC}"
}

check() {
    echo -e "${YELLOW}Checking project structure...${NC}"
    local status=0
    
    for dir in python typescript javascript java cpp c php csharp go rust ruby swift kotlin; do
        if [ ! -f "$dir/.gitignore" ]; then
            touch "$dir/.gitignore"
            echo -e "${GREEN}Created .gitignore in $dir${NC}"
        fi
        if [ ! -f "$dir/README.md" ]; then
            touch "$dir/README.md"
            echo -e "${GREEN}Created README.md in $dir${NC}"
        fi
    done
    
    for lang in "$@"; do
        case "$lang" in
            python) 
                check_python_env
                check_dsa_structure "python" "py"
                ;;
            node|typescript) 
                check_node_env
                check_dsa_structure "typescript" "ts"
                ;;
            javascript)
                check_javascript_env
                check_dsa_structure "javascript" "js"
                ;;
            java) check_java_env ;;
            cpp) check_cpp_env ;;
            c) check_c_env ;;
            php) check_php_env ;;
            csharp|dotnet) check_dotnet_env ;;
            go) check_go_env ;;
            rust) check_rust_env ;;
            ruby) check_ruby_env ;;
            swift) check_swift_env ;;
            kotlin) check_kotlin_env ;;
            all)
                check_python_env
                check_node_env
                check_javascript_env
                check_java_env
                check_cpp_env
                check_c_env
                check_php_env
                check_dotnet_env
                check_go_env
                check_rust_env
                check_ruby_env
                check_swift_env
                check_kotlin_env
                ;;
            *)
                echo -e "${RED}Unsupported language: $lang${NC}"
                status=1
                ;;
        esac
    done
    
    return $status
}

usage() {
    echo "Usage: $0 [command] [language1] [language2] ..."
    echo "Commands:"
    echo "  setup   - Setup development environments"
    echo "  check   - Check project structure"
    echo "  fix-path - Fix PATH in .bashrc"
    echo "Available languages: python, node, typescript, javascript, java, cpp, c, php, csharp, dotnet, go, rust, ruby, swift, kotlin, all"
    exit 1
}

check_dsa_structure() {
    local dir="$1"
    local ext="$2"
    local status=0
    
    echo -e "\n${YELLOW}Checking DSA structure for $dir...${NC}"
    
    check_dir "$dir/dsa" || status=1
    check_file "$dir/README.md" || status=1
    check_file "$dir/dsa/README.md" || status=1
    
    if [ -n "$ext" ]; then
        check_dir "$dir/dsa/algorithms/greedy-algorithms" || status=1
        check_dir "$dir/dsa/algorithms/searching-sorting-algorithms" || status=1
        check_dir "$dir/dsa/data-structure/graph-based" || status=1
        check_dir "$dir/dsa/data-structure/misc" || status=1
        check_dir "$dir/dsa/data-structure/tree-based" || status=1
        check_dir "$dir/oop" || status=1
    fi
    
    return $status
}

if [ $# -lt 2 ]; then
    usage
fi

command="$1"
shift

case "$command" in
    setup)
        setup "$@"
        ;;
    check)
        check "$@"
        ;;
    fix-path)
        fix_path
        ;;
    *)
        usage
        ;;
esac 