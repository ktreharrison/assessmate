
#!/usr/bin/env sh

# Source the module files
source modules/utilities.sh
source modules/code_style.sh
source modules/code_formatting.sh
source modules/security_analysis.sh

# Define colors for better readability
bold="\033[1;1m"
bold_magenta="\033[1;35m"
bold_blue="\033[1;34m"
bold_green="\033[1;32m"
bold_red="\033[1;31m"
light_yellow="\033[1;33m"
reset="\033[0m"

# Global variables for file_path and dir_path
file_path=""
dir_path="$(pwd)"

# Check for the existence of any virtual environment directory
# Function to activate virtual environment
activate_virtualenv() {
    local venv_dirs=("venv" ".venv" "env" ".env")
    local venv_found=false

    # Check if any of the virtual environment directories exist
    for dir in "${venv_dirs[@]}"; do
        if [ -d "$dir" ]; then
            source "$dir/bin/activate"
            venv_found=true
            break
        fi
    done

# If virtual environment not found, prompt user to set up
    if [ "$venv_found" = false ]; then
        echo "Virtual environment not found. Please run the setup script first."
        read -p "Do you want to run the setup script now? (y/n) " choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            configs/setup.sh
            for dir in "${venv_dirs[@]}"; do
                if [ -d "$dir" ]; then
                    source "$dir/bin/activate"
                    break
                fi
            done
        elif [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
            # Run the script without activating the virtual environment
            echo "Continuing without activating the virtual environment..."
        else
            echo "Invalid choice. Exiting..."
            exit 1
        fi
    fi
}

# Call the function to activate virtual environment
activate_virtualenv


# Function to select a file or directory for analysis
select_file_or_directory() {
    read -p "Do you want to analyze an individual file (f) or an entire directory (d) (default: directory)? " choice
    choice="${choice:-d}"  # Set the default choice to 'd'
    case "$choice" in
    f | F)
        file_path=""
        read -p "Enter the path to the Python file for analysis: " file_path
        if [ -f "$file_path" ]; then
            run_sourcery "$file_path"
            run_pylint "$file_path"
            run_black "$file_path"
            run_pytype_and_merge_pyi "$file_path"
            add_docstring_with_pyment "$file_path"
            run_code_checks "$file_path"


        else
            echo "File not found. Exiting."
        fi
        ;;
    d | D)
    read -p "Enter the path to the directory for analysis (default: current working directory): " dir_input
    dir_path=$(realpath "$dir_input")  # Resolve the path to handle dot notation
    if [ -z "$dir_path" ]; then
        dir_path=$(pwd)
    fi

    if [ -d "$dir_path" ]; then
        run_pylint "$dir_path"
        run_black
        run_sourcery "$dir_input"
        run_pytype_and_merge_pyi "$dir_path"
        add_docstring_with_pyment "$dir_path"
        run_code_checks "$dir_path"

    else
        read -p "Directory not found. Do you want to create it? (y/n): " create_dir_choice
        if [ "$create_dir_choice" = "y" ] || [ "$create_dir_choice" = "Y" ]; then
            mkdir -p "$dir_path"
            if [ $? -eq 0 ]; then
                run_pytype_and_merge_pyi "$dir_path"
                add_docstring_with_pyment "$dir_path"
                run_code_checks "$dir_path"
                run_black
                run_pylint "$dir_path"
                run_sourcery "$dir_path"
            else
                echo "Failed to create directory. Exiting."
            fi
        else
            echo "Exiting."
        fi
    fi
    ;;
    *)
    echo "Invalid choice. Exiting."
    ;;
    esac
}


# Function to add docstring using pyment
add_docstring_with_pyment() {
    code_path=$1
    if [ -n "$code_path" ]; then
        if [ -f "$code_path" ]; then
            run_command "Adding docstring with Pyment:" "pyment -w $code_path"
        elif [ -d "$code_path" ]; then
            run_command "\n${bold_magenta}Adding docstrings with Pyment to all .py files in $(pwd): ${reset}" "pyment -w $code_path"
        fi
    else
        echo "No file or directory specified for adding docstring."
    fi
}

# Function to run Pylint for code analysis
run_pylint() {
    code_path=$1
    if [ -n "$code_path" ]; then
        if [ -f "$code_path" ]; then
            run_command "\nRunning pylint:" "python -m pylint $code_path"
        elif [ -d "$code_path" ]; then
            run_command "\nRunning pylint:" "python -m pylint $code_path/*.py"
        else
            echo "Invalid file or directory. Skipping pylint."
        fi
    else
        echo "No file or directory specified for pylint."
    fi
}

# Function to run pytype and merge .pyi files
run_pytype_and_merge_pyi() {
    code_path=$1

    if [ -n "$code_path" ]; then
        if [ -f "$code_path" ]; then
            # Run pytype on the individual file
            run_command "Running pytype on $code_path:" "pytype $code_path --output "

            # Determine the .pyi file path
            file_name=$(basename "$code_path" .py)
            pyi_file=".pytype/pyi/${file_name}.pyi"

            # Check if the .pyi file exists and merge it
            if [ -f "$pyi_file" ]; then
                run_command "Merging .pyi file for $code_path:" "merge-pyi -i $code_path $pyi_file"
            else
                echo "No .pyi file found for $code_path. Skipping merge-pyi."
            fi
        elif [ -d "$code_path" ]; then
            # Run pytype on all .py files in the directory
            run_command "Running pytype on all .py files in $code_path:" "pytype $code_path/*.py --output"

            # Loop through .py files and merge their corresponding .pyi files
            for py_file in "$code_path"/*.py; do
                file_name=$(basename "$py_file" .py)
                pyi_file=".pytype/pyi/${file_name}.pyi"
                if [ -f "$pyi_file" ]; then
                    run_command "Merging .pyi file for $py_file:" "merge-pyi -i $py_file $pyi_file"
                fi
            done
        else
            echo "Invalid file or directory. Skipping pytype and merge-pyi."
        fi
    else
        echo "No file or directory specified for pytype and merge-pyi."
    fi
}

# Function to clean cache and temporary files
clean_cache_and_temp_files() {

    read -p "Do you want to delete all cache and temporary files (y/n)? (default: yes)"  clean_choice
    clean_choice="${clean_choice:-y}"
    if [ "$clean_choice" = "y" ] || [ "$clean_choice" = "Y" ]; then
        echo "Cleaning cache and temporary files..."
        cleanpy $(pwd) --exclude-envs --all
        ruff clean
        echo "${bold_red}Cache and temporary files cleaned.${reset}"
    else
        echo "${bold}Skipping cache and temporary file cleanup.${reset}"
    fi
}


echo "${bold_magenta}\nWe are going to analyze your Python code${reset}"
sleep 1
print_separator

# Move file or directory selection to the beginning of the script
select_file_or_directory

print_separator
printf "\n${bold_blue}Lastly, let's do a Security Analysis of Your Python Code${reset}\n"
run_bandit "Running bandit:"
# Alternative command: python -m bandit -r . -x ./venv
run_command "\nChecking import dependencies with pyright:" "python -m pyright $file_path --stats"
run_command "\nListing import dependencies with pyright:" "python -m pyright $file_path --dependencies"
run_command "\nCache and temp files removal with cleanpy:" "clean_cache_and_temp_files"

echo "\n\n${bold_green}All done your code have been checked and optimized. Happy Coding 🐍💻🤖${reset}"
