#!/bin/bash

# Function to run Black code formatting
run_black() {
    local file_path="$1"
    local dir_path="$2"

    printf "\n${bold_blue}Second, we are going to do a code analysis beyond styles${reset}\n"
    sleep 2

    if [ -n "$file_path" ]; then
        format_with_black "$file_path"
    elif [ -n "$dir_path" ]; then
        format_with_black "$dir_path"
    else
        echo "No file or directory specified for Black formatting."
    fi
}

format_with_black() {
    local code_path="$1"

    read -p "Do you want to format the code with Black (y/n)? (default: yes) " black_choice
    black_choice="${black_choice:-y}"

    if [ "$black_choice" = "y" ] || [ "$black_choice" = "Y" ]; then
        run_command "Formatting the code with Black:" "python -m black $code_path"
    fi
}

# Function to run Sourcery
run_sourcery() {
    local file_path="$1"
    local dir_path="$2"

    if [ -n "$file_path" ]; then
        handle_sourcery_for_file "$file_path"
    elif [ -n "$dir_path" ]; then
        handle_sourcery_for_directory "$dir_path"
    else
        echo "No file or directory specified for Sourcery review."
    fi
}

handle_sourcery_for_file() {
    local file_path="$1"

    if command -v sourcery &> /dev/null; then
        echo "\n${bold_magenta}Sourcery is installed. Running Sourcery review on: $(pwd)"
        echo "${bold_green}Running Sourcery review:${reset}"
        sourcery review --check $file_path
        if [ $? -eq 0 ]; then
            echo "\n${bold_green}No issues found. Skipping code fix with Sourcery.${reset}"
        else
            run_command "\nFixing code with Sourcery review:" "sourcery review --fix $file_path"
        fi
    else
        install_sourcery "$file_path"
    fi
}

handle_sourcery_for_directory() {
    local dir_path="$1"

    if command -v sourcery &> /dev/null; then
        echo "${bold_magenta}\nSourcery is installed.\nRunning Sourcery review on: $(pwd) ${reset}"
        echo "Running Sourcery review:"
        sourcery review --check "../$dir_path"  # Using dot notation for the directory path
        if [ $? -eq 0 ]; then
            echo "\n${bold_green}No issues found. Skipping code fix with Sourcery.${reset}"
        else
            run_command "\nFixing code with Sourcery review:" "sourcery review --fix ../$(printf "%q" "$dir_path")"  # Using dot notation and quoting for directory path
        fi
    else
        install_sourcery "$dir_path"
    fi
}

install_sourcery() {
    local code_path="$1"

    read -p "Sourcery is not installed. Do you want to install Sourcery (y/n)? " install_sourcery
    if [ "$install_sourcery" = "y" ] || [ "$install_sourcery" = "Y" ]; then
        case "$OSTYPE" in
        darwin*) # macOS
            echo "Installing Sourcery on macOS..."
            pip3 install sourcery
            ;;
        linux*) # Linux
            echo "Installing Sourcery on Linux..."
            pip3 install sourcery
            ;;
        cygwin*) # Windows
            echo "Installing Sourcery on Windows..."
            pip3 install sourcery
            ;;
        *) # Unsupported OS
            echo "Sourcery installation not supported on this OS."
            return
            ;;
        esac

        echo "\n${bold_magenta}Sourcery is installed. You may need to log in if your repository is not open source. See 'sourcery login' for details.${reset}"
        echo "Running Sourcery review on: $(pwd)"

        if [ -n "$code_path" ]; then
            handle_sourcery_review "$code_path"
        else
            echo "No file or directory specified for Sourcery review."
        fi
    else
        echo "Skipping Sourcery review."
    fi
}

handle_sourcery_review() {
    local code_path="$1"

    echo "Running Sourcery review:"
    sourcery review --check "$code_path"
    if [ $? -eq 0 ]; then
        echo "\n${bold_green}No issues found. Skipping code fix with Sourcery.${reset}"
    else
        run_command "\nFixing code with Sourcery review:" "sourcery review --fix $code_path"
    fi
}