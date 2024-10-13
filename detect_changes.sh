#!/bin/bash

# Get the base and head SHAs
BASE_SHA=$(git rev-parse origin/main)
HEAD_SHA=$(git rev-parse HEAD)

# Initialize an empty array to store unique directories
declare -A CHANGED_DIRS

echo "Checking for changes in terragrunt.hcl files..."
# Check for changes in terragrunt.hcl files
CHANGED_TG_FILES=$(git diff --name-only $BASE_SHA $HEAD_SHA | grep 'terragrunt.hcl$')
for file in $CHANGED_TG_FILES; do
    dir=$(dirname "$file")
    CHANGED_DIRS[$dir]=1
    echo "Changed terragrunt.hcl file detected: $file"
done

# Function to extract environment name from a line
get_env_name() {
    echo "$1" | sed -n 's/^[[:space:]]*- name:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p'
}

echo "Checking for changes in vars.yaml files..."
# Check for changes in any vars.yaml file
CHANGED_VARS_FILES=$(git diff --name-only $BASE_SHA $HEAD_SHA | grep 'vars.yaml$')
for vars_file in $CHANGED_VARS_FILES; do
    echo "Processing changes in $vars_file"
    vars_dir=$(dirname "$vars_file")
    
    # Get the diff of the vars.yaml file
    VARS_DIFF=$(git diff $BASE_SHA $HEAD_SHA -- "$vars_file")
    
    # Flag to track if we're in the Environments section
    IN_ENVIRONMENTS=false
    CURRENT_ENV=""

    # Process each line of the diff
    while IFS= read -r line; do
        if [[ $line == "@@ "* ]]; then
            # Reset environment tracking at each diff chunk
            IN_ENVIRONMENTS=false
            CURRENT_ENV=""
        elif [[ $line == *"Environments:"* ]]; then
            IN_ENVIRONMENTS=true
            echo "  Entered Environments section"
        elif $IN_ENVIRONMENTS; then
            ENV_NAME=$(get_env_name "$line")
            if [[ -n $ENV_NAME ]]; then
                CURRENT_ENV=$ENV_NAME
                echo "  Processing environment: $CURRENT_ENV"
            elif [[ $line == -* || $line == +* ]] && [[ -n $CURRENT_ENV ]]; then
                # This is a change within an environment, find the corresponding terragrunt.hcl
                TG_FILE=$(find "$vars_dir" -path "*/$CURRENT_ENV/terragrunt.hcl")
                if [[ -n $TG_FILE ]]; then
                    dir=$(dirname "$TG_FILE")
                    CHANGED_DIRS[$dir]=1
                    echo "  Change detected in environment $CURRENT_ENV. Affected terragrunt.hcl: $TG_FILE"
                fi
            fi
        elif [[ $line == -* || $line == +* ]]; then
            echo "  Change detected outside Environments section. Affecting all terragrunt.hcl files in $vars_dir"
            # This is a change outside the Environments section, affect all terragrunt.hcl files in this directory and subdirectories
            while IFS= read -r -d '' tg_file
            do
                dir=$(dirname "$tg_file")
                CHANGED_DIRS[$dir]=1
                echo "    Affected terragrunt.hcl: $tg_file"
            done < <(find "$vars_dir" -name "terragrunt.hcl" -print0)
            break  # No need to continue checking after this
        fi
    done <<< "$VARS_DIFF"
done

echo "Generating final output..."
# Output the changed directories as a JSON array
echo -n '['
first=true
for dir in "${!CHANGED_DIRS[@]}"; do
    if [ "$first" = true ] ; then
        first=false
    else
        echo -n ','
    fi
    echo -n "\"$dir\""
done
echo ']'