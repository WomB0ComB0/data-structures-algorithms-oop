#!/bin/bash

# Define color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if a script exists and is executable
check_script() {
    local script="$1"
    if [ ! -f "$script" ]; then
        echo -e "${RED}Error: $script not found${NC}"
        return 1
    elif [ ! -x "$script" ]; then
        echo -e "${YELLOW}Making $script executable...${NC}"
        chmod +x "$script"
    fi
    return 0
}

# Function to run a script with arguments
run_script() {
    local script="$1"
    shift
    echo -e "\n${YELLOW}Running $script...${NC}"
    ./"$script" "$@"
    local status=$?
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✓ $script completed successfully${NC}"
    else
        echo -e "${RED}✗ $script failed with status $status${NC}"
        exit $status
    fi
}

# Print usage information
usage() {
    echo "Usage: $0 [language1] [language2] ..."
    echo "Available languages: python, typescript, javascript, java, cpp, c, dart, php, csharp, go, rust, ruby, swift, kotlin, all"
    exit 1
}

# Main execution
main() {
    # Check if any arguments are provided
    if [ $# -eq 0 ]; then
        usage
    fi

    # Check if all required scripts exist
    local required_scripts=("install.sh" "setup.sh" "dev_setup.sh" "init_projects.sh")
    for script in "${required_scripts[@]}"; do
        check_script "$script" || exit 1
    done

    echo -e "${YELLOW}Starting complete development environment setup...${NC}"
    
    # Step 1: Install language support
    run_script "install.sh" "$@"
    
    # Step 2: Create directory structure
    run_script "setup.sh"
    
    # Step 3: Initialize project files and install packages
    run_script "init_projects.sh"
    
    # Step 4: Verify setup
    run_script "dev_setup.sh" "check" "$@"
    
    echo -e "\n${GREEN}Complete setup finished successfully!${NC}"
    echo -e "${YELLOW}Note: You may need to restart your terminal or run 'source ~/.bashrc' to apply PATH changes${NC}"
}

# Execute main function with all provided arguments
main "$@" 