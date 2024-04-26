
# Function to print a separator line
print_separator() {
    # printf %"$COLUMNS"s |tr " " "-"
    printf '\033[0;33m%*s\n\033[0m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Function to run a command and display a message
run_command() {
    echo "${bold_blue}$1${reset}"
    $2
    print_separator
}


# Function to check if a command is available
is_command_available() {
    local command="$1"
    if ! command -v "$command" &> /dev/null; then
        return 1  # Command not available
    fi
    return 0  # Command available
}