#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print the status of a command
# Arguments:
#   $1 - The message to print
#   $2 - The exit status of the command (0 for success, non-zero for failure)
print_status() {
    if [ $2 -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
    fi
}

# Function to check if a command exists
# Arguments:
#   $1 - The command to check
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_python_version() {
    if command_exists python3; then
        local version=$(python3 --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}Python ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_node_version() {
    if command_exists node; then
        local version=$(node --version 2>&1 | cut -d'v' -f2)
        echo -e "${GREEN}Node.js ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_java_version() {
    if command_exists java; then
        local version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        echo -e "${GREEN}Java ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_cpp_version() {
    if command_exists g++; then
        local version=$(g++ --version 2>&1 | head -n 1 | cut -d' ' -f4)
        echo -e "${GREEN}G++ ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_dart_version() {
    if command_exists dart; then
        local version=$(dart --version 2>&1 | cut -d' ' -f4)
        echo -e "${GREEN}Dart ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_php_version() {
    if command_exists php; then
        local version=$(php -v 2>&1 | head -n 1 | cut -d' ' -f2)
        echo -e "${GREEN}PHP ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_dotnet_version() {
    if command_exists dotnet; then
        local version=$(dotnet --version 2>&1)
        echo -e "${GREEN}.NET SDK ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to check the installed version of Go
check_go_version() {
    if command_exists go; then
        local version=$(go version 2>&1 | cut -d' ' -f3 | sed 's/go//')
        echo -e "${GREEN}Go ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to check the installed version of Rust
check_rust_version() {
    if command_exists rustc; then
        local version=$(rustc --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}Rust ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to check the installed version of Ruby
check_ruby_version() {
    if command_exists ruby; then
        local version=$(ruby --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}Ruby ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to check the installed version of Swift
check_swift_version() {
    if command_exists swift; then
        local version=$(swift --version 2>&1 | head -n 1 | cut -d'(' -f1 | cut -d' ' -f4)
        echo -e "${GREEN}Swift ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to check the installed version of Kotlin
check_kotlin_version() {
    if command_exists kotlin; then
        local version=$(kotlin -version 2>&1 | cut -d' ' -f3)
        echo -e "${GREEN}Kotlin ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

# Function to safely update PATH in .bashrc
# Arguments:
#   $1 - The new path to add to PATH
update_path() {
    local new_path="$1"
    local bashrc="$HOME/.bashrc"
    
    # Remove any existing PATH export with the same component
    sed -i "\#export PATH=.*${new_path}.*#d" "$bashrc"
    
    # Add the new PATH export, properly escaped
    echo "export PATH=\"${new_path}:\$PATH\"" >> "$bashrc"
}

# Function to install Python and its dependencies
install_python() {
    echo -e "\n${YELLOW}Setting up Python environment...${NC}"
    
    # Install pyenv if not present
    if ! check_pyenv; then
        install_if_missing "pyenv" \
            "curl https://pyenv.run | bash && \
             echo 'export PYENV_ROOT=\"\$HOME/.pyenv\"' >> ~/.bashrc && \
             echo 'command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\"' >> ~/.bashrc && \
             echo 'eval \"\$(pyenv init -)\"' >> ~/.bashrc" \
            "pyenv"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install pyenv${NC}"
            return 1
        fi
        source ~/.bashrc
    fi
    
    if ! command_exists python3; then
        echo "Installing Python..."
        pyenv install 3.12.0
        pyenv global 3.12.0
    else
        echo -e "${GREEN}Python $(python3 --version) is already installed${NC}"
    fi
    
    if ! command_exists pip; then
        echo "Installing pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py
        rm get-pip.py
    else
        echo -e "${GREEN}pip $(pip --version) is already installed${NC}"
    fi
    
    print_status "Python setup complete" $?
}

check_npm() {
    check_version_manager "npm" "npm --version" "npm"
}

install_node() {
    echo -e "\n${YELLOW}Setting up Node.js environment...${NC}"
    
    # Install nvm if not present
    if ! check_nvm; then
        echo "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install nvm${NC}"
            return 1
        fi
        source ~/.bashrc
    fi
    
    # Install Node.js using nvm
    if ! command_exists node; then
        echo "Installing Node.js..."
        nvm install --lts
        nvm use --lts
    else
        echo -e "${GREEN}Node.js $(node --version) is already installed${NC}"
    fi
    
    # Install global packages with timeouts
    echo "Installing global packages..."
    if ! command_exists tsc; then
        timeout 30 npm install -g typescript || {
            echo -e "${RED}Failed to install TypeScript${NC}"
            return 1
        }
    else
        echo -e "${GREEN}TypeScript is already installed${NC}"
    fi
    
    if ! command_exists ts-node; then
        timeout 30 npm install -g ts-node || {
            echo -e "${RED}Failed to install ts-node${NC}"
            return 1
        }
    else
        echo -e "${GREEN}ts-node is already installed${NC}"
    fi
    
    print_status "Node.js setup complete" $?
}

install_java() {
    echo -e "\n${YELLOW}Setting up Java environment...${NC}"
    
    if ! check_sdkman; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
    
    # Install Java using SDKMAN!
    if command_exists sdk; then
        sdk install java
        sdk install gradle
        sdk install maven
        sdk install kotlin
    else
        install_java_fallback
    fi
    
    print_status "Java setup complete" $?
}

install_cpp() {
    echo -e "\n${YELLOW}Setting up C/C++ environment...${NC}"
    
    if check_cpp_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt update && sudo apt install -y build-essential cmake
        elif command_exists brew; then
            brew install gcc cmake
        fi
    fi
    
    print_status "C/C++ setup complete" $?
}

install_dart() {
    echo -e "\n${YELLOW}Setting up Dart environment...${NC}"
    
    if check_dart_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt-get update && sudo apt-get install apt-transport-https
            sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
            sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
            sudo apt-get update && sudo apt-get install dart
        elif command_exists brew; then
            brew tap dart-lang/dart
            brew install dart
        fi
    fi
    
    print_status "Dart setup complete" $?
}

install_php() {
    echo -e "\n${YELLOW}Setting up PHP environment...${NC}"
    
    # Add PHP repository if not already added
    if ! grep -q "^deb .*ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        sudo add-apt-repository ppa:ondrej/php -y
    fi
    
    # Update package list
    sudo apt-get update
    
    # Install PHP and required extensions
    sudo apt-get install -y \
        php8.3 \
        php8.3-cli \
        php8.3-common \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-xml \
        php8.3-zip \
        php8.3-bz2 \
        php8.3-dom \
        php8.3-intl \
        php-xdebug \
        git-core \
        unzip
    
    # Skip postfix configuration
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
    
    # Install Composer if not present
    if ! command_exists composer; then
        echo "Installing Composer..."
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
        
        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            echo -e "${RED}Composer installer corrupt${NC}"
            rm composer-setup.php
            return 1
        fi
        
        php composer-setup.php --quiet
        rm composer-setup.php
        sudo mv composer.phar /usr/local/bin/composer
    else
        echo -e "${GREEN}Composer is already installed${NC}"
    fi
    
    print_status "PHP setup complete" $?
}

install_csharp() {
    echo -e "\n${YELLOW}Setting up C# environment...${NC}"
    
    if check_dotnet_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            
            sudo apt-get update
            sudo apt-get install -y dotnet-sdk-8.0
        elif command_exists brew; then
            brew install --cask dotnet-sdk
        fi
    fi
    
    init_project "C#" init_csharp_project
    print_status "C# setup complete" $?
}

install_go() {
    echo -e "\n${YELLOW}Setting up Go environment...${NC}"
    
    if ! check_goenv; then
        if command_exists apt; then
            git clone https://github.com/syndbg/goenv.git ~/.goenv
            echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc
            echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(goenv init -)"' >> ~/.bashrc
            
            source ~/.bashrc
        elif command_exists brew; then
            brew install goenv
        fi
    fi
    
    init_project "Go" init_go_project
    print_status "Go setup complete" $?
}

install_rust() {
    echo -e "\n${YELLOW}Setting up Rust environment...${NC}"
    
    if check_rust_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
    fi
    
    init_project "Rust" init_rust_project
    print_status "Rust setup complete" $?
}

install_ruby() {
    echo -e "\n${YELLOW}Setting up Ruby environment...${NC}"
    
    if ! check_rbenv; then
        if command_exists apt; then
            sudo apt update
            sudo apt install -y rbenv ruby-build
            echo 'eval "$(rbenv init -)"' >> ~/.bashrc
            
            source ~/.bashrc
        elif command_exists brew; then
            brew install rbenv ruby-build
        fi
    fi
    
    init_project "Ruby" init_ruby_project
    print_status "Ruby setup complete" $?
}

install_swift() {
    echo -e "\n${YELLOW}Setting up Swift environment...${NC}"
    
    if check_swift_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt update
            sudo apt install -y \
                binutils \
                git \
                gnupg2 \
                libc6-dev \
                libcurl4-openssl-dev \
                libedit2 \
                libgcc-9-dev \
                python3 \
                libsqlite3-0 \
                libstdc++-9-dev \
                libxml2-dev \
                libz3-dev \
                pkg-config \
                tzdata \
                zlib1g-dev
            
            wget https://download.swift.org/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
            sudo tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz -C /usr/local/
            
            update_path "/usr/local/swift-5.9-RELEASE-ubuntu22.04/usr/bin"
            
            rm swift-5.9-RELEASE-ubuntu22.04.tar.gz
            
            source "$HOME/.bashrc"
        elif command_exists brew; then
            brew install swift
        fi
    fi
    
    init_project "Swift" init_swift_project
    print_status "Swift setup complete" $?
}

install_kotlin() {
    echo -e "\n${YELLOW}Setting up Kotlin environment...${NC}"
    
    if check_kotlin_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt update && sudo apt install -y kotlin
        elif command_exists brew; then
            brew install kotlin
        fi
    fi
    
    init_project "Kotlin" init_kotlin_project
    print_status "Kotlin setup complete" $?
}

fix_mongodb_gpg() {
    if command_exists apt; then
        echo -e "\n${YELLOW}Fixing MongoDB GPG key...${NC}"
        sudo rm -f /etc/apt/sources.list.d/mongodb*.list
        sudo apt-key del 9ECBEC467F0CEB10 2>/dev/null || true
        sudo apt update
    fi
}

setup_dsa_structure() {
    echo -e "\n${YELLOW}Setting up DSA directory structure...${NC}"
    
    if [ -f "./setup.sh" ] && [ -x "./setup.sh" ]; then
        ./setup.sh
    else
        echo -e "${RED}Error: setup.sh not found or not executable${NC}"
        return 1
    fi
}

check_pyenv() {
    check_version_manager "pyenv" "pyenv --version" "pyenv"
}

check_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        local version=$(nvm --version 2>&1)
        echo -e "${GREEN}nvm ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_sdkman() {
    if [ -d "$HOME/.sdkman" ]; then
        echo -e "${GREEN}SDKMAN! is already installed${NC}"
        return 0
    fi
    return 1
}

check_phpenv() {
    if command_exists phpenv; then
        local version=$(phpenv --version 2>&1 | head -n 1 | cut -d' ' -f2)
        echo -e "${GREEN}phpenv ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_goenv() {
    if command_exists goenv; then
        local version=$(goenv --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}goenv ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_rbenv() {
    if command_exists rbenv; then
        local version=$(rbenv --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}rbenv ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_swiftenv() {
    if command_exists swiftenv; then
        local version=$(swiftenv --version 2>&1)
        echo -e "${GREEN}swiftenv ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_rustup() {
    if command_exists rustup; then
        local version=$(rustup --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}rustup ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

check_asdf() {
    if [ -d "$HOME/.asdf" ]; then
        local version=$(asdf --version 2>&1)
        echo -e "${GREEN}asdf ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

install_version_managers() {
    echo -e "\n${YELLOW}Installing language version managers...${NC}"
    
    if ! check_pyenv; then
        curl https://pyenv.run | bash
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    fi
    
    if ! check_nvm; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    if ! check_rbenv; then
        if command_exists apt; then
            sudo apt update
            sudo apt install -y rbenv ruby-build
        elif command_exists brew; then
            brew install rbenv ruby-build
        fi
        echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    fi
    
    if ! check_sdkman; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
    
    if ! check_phpenv; then
        git clone https://github.com/phpenv/phpenv.git ~/.phpenv
        echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(phpenv init -)"' >> ~/.bashrc
    fi
    
    if ! check_goenv; then
        git clone https://github.com/syndbg/goenv.git ~/.goenv
        echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc
        echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(goenv init -)"' >> ~/.bashrc
    fi
    
    if ! check_rustup; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    if ! check_swiftenv; then
        git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
        echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bashrc
        echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bashrc
        echo 'eval "$(swiftenv init -)"' >> ~/.bashrc
    fi

    if ! check_asdf; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
        source "$HOME/.asdf/asdf.sh"
        asdf plugin add dart
    fi
    
    source ~/.bashrc
}

check_directory_empty() {
    local dir=$1
    if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
        return 1
    fi
    return 0
}

backup_directory() {
    local dir=$1
    local backup_dir="${dir}_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in $backup_dir"
    mv "$dir" "$backup_dir"
}

prompt_reinit() {
    local lang=$1
    echo -e "${YELLOW}${lang} project directory already exists and is not empty${NC}"
    read -p "Do you want to reinitialize it? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

create_config_if_missing() {
    local file=$1
    local content=$2
    
    if [ ! -f "$file" ]; then
        echo "Creating $file..."
        echo "$content" > "$file"
        return 0
    else
        echo -e "${GREEN}$file already exists${NC}"
        return 1
    fi
}

ensure_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
        return 0
    else
        echo -e "${GREEN}Directory already exists: $dir${NC}"
        return 1
    fi
}

check_version_manager() {
    local cmd=$1
    local version_cmd=$2
    local name=$3
    
    if command_exists "$cmd"; then
        local version=$($version_cmd 2>&1)
        echo -e "${GREEN}${name} ${version} is already installed${NC}"
        return 0
    fi
    return 1
}

install_if_missing() {
    local cmd=$1
    local install_cmd=$2
    local name=$3
    
    if ! command_exists "$cmd"; then
        echo "Installing $name..."
        eval "$install_cmd"
        return $?
    else
        echo -e "${GREEN}$name is already installed${NC}"
        return 0
    fi
}

# Add these functions after the existing installation functions

init_project() {
    local lang=$1
    local init_func=$2
    
    echo -e "\n${YELLOW}Initializing $lang project...${NC}"
    
    if declare -f "$init_func" > /dev/null; then
        if $init_func; then
            echo -e "${GREEN}✓ $lang project initialized${NC}"
            return 0
        else
            echo -e "${RED}✗ Failed to initialize $lang project${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Initialization function not found: $init_func${NC}"
        return 1
    fi
}

# Modify the installation functions to include project initialization

install_kotlin() {
    echo -e "\n${YELLOW}Setting up Kotlin environment...${NC}"
    
    if check_kotlin_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt update && sudo apt install -y kotlin
        elif command_exists brew; then
            brew install kotlin
        fi
    fi
    
    init_project "Kotlin" init_kotlin_project
    print_status "Kotlin setup complete" $?
}

install_swift() {
    echo -e "\n${YELLOW}Setting up Swift environment...${NC}"
    
    if check_swift_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            sudo apt update
            sudo apt install -y \
                binutils \
                git \
                gnupg2 \
                libc6-dev \
                libcurl4-openssl-dev \
                libedit2 \
                libgcc-9-dev \
                python3 \
                libsqlite3-0 \
                libstdc++-9-dev \
                libxml2-dev \
                libz3-dev \
                pkg-config \
                tzdata \
                zlib1g-dev
            
            wget https://download.swift.org/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
            sudo tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz -C /usr/local/
            
            update_path "/usr/local/swift-5.9-RELEASE-ubuntu22.04/usr/bin"
            
            rm swift-5.9-RELEASE-ubuntu22.04.tar.gz
            
            source "$HOME/.bashrc"
        elif command_exists brew; then
            brew install swift
        fi
    fi
    
    init_project "Swift" init_swift_project
    print_status "Swift setup complete" $?
}

install_go() {
    echo -e "\n${YELLOW}Setting up Go environment...${NC}"
    
    if ! check_goenv; then
        if command_exists apt; then
            git clone https://github.com/syndbg/goenv.git ~/.goenv
            echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc
            echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(goenv init -)"' >> ~/.bashrc
            
            source ~/.bashrc
        elif command_exists brew; then
            brew install goenv
        fi
    fi
    
    init_project "Go" init_go_project
    print_status "Go setup complete" $?
}

install_rust() {
    echo -e "\n${YELLOW}Setting up Rust environment...${NC}"
    
    if check_rust_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
    fi
    
    init_project "Rust" init_rust_project
    print_status "Rust setup complete" $?
}

install_csharp() {
    echo -e "\n${YELLOW}Setting up C# environment...${NC}"
    
    if check_dotnet_version; then
        echo -e "${YELLOW}Checking for updates...${NC}"
    else
        if command_exists apt; then
            wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            
            sudo apt-get update
            sudo apt-get install -y dotnet-sdk-8.0
        elif command_exists brew; then
            brew install --cask dotnet-sdk
        fi
    fi
    
    init_project "C#" init_csharp_project
    print_status "C# setup complete" $?
}

# Add the initialization functions you provided
# (Add all the init_*_project functions here)

main() {
    echo -e "${YELLOW}Starting development environment setup...${NC}"
    
    fix_mongodb_gpg
    
    if ! command_exists apt && ! command_exists brew; then
        echo -e "${RED}Error: Neither apt nor brew package managers found.${NC}"
        echo "Please install either apt (Linux) or brew (macOS) first."
        exit 1
    fi
    
    # Install version managers first
    install_version_managers
    
    for lang in "$@"; do
        case "$lang" in
            python) 
                install_python
                init_project "Python" init_python_project
                ;;
            typescript|javascript) 
                install_node
                init_project "TypeScript" init_typescript_project
                ;;
            java) 
                install_java
                init_project "Java" init_java_project
                ;;
            cpp|c) 
                install_cpp
                init_project "C++" init_cpp_project
                ;;
            dart) 
                install_dart
                init_project "Dart" init_dart_project
                ;;
            php) 
                install_php
                init_project "PHP" init_php_project
                ;;
            csharp) 
                install_csharp
                init_project "C#" init_csharp_project
                ;;
            go) 
                install_go
                init_project "Go" init_go_project
                ;;
            rust) 
                install_rust
                init_project "Rust" init_rust_project
                ;;
            ruby) 
                install_ruby
                init_project "Ruby" init_ruby_project
                ;;
            swift) 
                install_swift
                init_project "Swift" init_swift_project
                ;;
            kotlin) 
                install_kotlin
                init_project "Kotlin" init_kotlin_project
                ;;
            all)
                # ... existing all case ...
                ;;
            *)
                echo -e "${RED}Unsupported language: $lang${NC}"
                ;;
        esac
    done
    
    setup_dsa_structure
    
    echo -e "\n${GREEN}Setup complete!${NC}"
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 [language1] [language2] ..."
    echo "Available languages: python, typescript, javascript, java, cpp, c, dart, php, csharp, go, rust, ruby, swift, kotlin, all"
    exit 1
fi

main "$@"