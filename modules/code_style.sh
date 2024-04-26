
# Function to run code style checks (Flake8 or Ruff)
run_code_checks() {
    printf "\n${bold_blue}First, let's check your Code Style${reset}\n"
    sleep 1
    code_path=$1
    read -p "Do you want to check code style with Flake8 (f) or Ruff (r) or both (b). (default: both)" code_choice
    code_choice="${code_choice:-b}"
    case "$code_choice" in
    f | F)
        run_command "Using Flake8:" "python -m flake8 --exclude=venv,.venv $code_path"
        ;;
    r | R)
        run_command "Checking the code with Ruff:" "python -m ruff check $code_path"
        run_command "Fixing the code with Ruff:" "python -m ruff check $code_path --fix"
        run_command "Removing Ruff cache :" "python -m ruff clean"  
        ;;
    b | B)
        run_command "Using Flake8:" "python -m flake8 --exclude=venv,.venv  $code_path"
        run_command "Checking the code with Ruff:" "python -m ruff check $code_path"
        run_command "Fixing the code with Ruff:" "python -m ruff check $code_path --fix"
        ;;
    *)
        echo "Invalid choice. Skipping code style check."
        ;;
    esac
}
