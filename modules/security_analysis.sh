# Function to run Bandit for security analysis
run_bandit() {
    if [ -n "$file_path" ] || [ -n "$dir_path" ]; then
        if [ -n "$file_path" ]; then
            if [ -f "$file_path" ]; then
                run_command "Running bandit on $file_path:" "bandit -c configs/config.yaml -r $(dirname $file_path)"
            else
                echo "Invalid file. Skipping bandit."
            fi
        elif [ -n "$dir_path" ]; then
            if [ -d "$dir_path" ]; then
                run_command "\nRunning bandit $(pwd):" "bandit -c ./configs/config.yaml -r $dir_path "
            else
                echo "Invalid directory. Skipping bandit."
            fi
        else
            echo "Invalid file or directory. Skipping bandit."
        fi
    else
        echo "No file or directory specified for Bandit."
    fi
}
