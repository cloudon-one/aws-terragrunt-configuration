#!/bin/bash

# Get the base and head SHAs
BASE_SHA=$(git rev-parse origin/main)
HEAD_SHA=$(git rev-parse HEAD)

# Initialize an empty array to store unique directories
declare -A CHANGED_DIRS

# Check for changes in terragrunt.hcl files
CHANGED_TG_FILES=$(git diff --name-only $BASE_SHA $HEAD_SHA | grep 'terragrunt.hcl$')
for file in $CHANGED_TG_FILES; do
    dir=$(dirname "$file")
    CHANGED_DIRS[$dir]=1
done

# Function to extract environment name from a line
get_env_name() {
    echo "$1" | sed -n 's/^[[:space:]]*- name:[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p'
}

# Check for changes in aws/vars.yaml
if git diff --name-only $BASE_SHA $HEAD_SHA | grep -q 'aws/vars.yaml$'; then
    # Get the diff of aws/vars.yaml
    VARS_DIFF=$(git diff $BASE_SHA $HEAD_SHA -- aws/vars.yaml)
    
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
        elif $IN_ENVIRONMENTS; then
            ENV_NAME=$(get_env_name "$line")
            if [[ -n $ENV_NAME ]]; then
                CURRENT_ENV=$ENV_NAME
            elif [[ $line == -* || $line == +* ]] && [[ -n $CURRENT_ENV ]]; then
                # This is a change within an environment, find the corresponding terragrunt.hcl
                TG_FILE=$(find . -path "*/$CURRENT_ENV/terragrunt.hcl")
                if [[ -n $TG_FILE ]]; then
                    dir=$(dirname "$TG_FILE")
                    CHANGED_DIRS[$dir]=1
                fi
            fi
        elif [[ $line == -* || $line == +* ]]; then
            # This is a change outside the Environments section, affect all terragrunt.hcl files
            while IFS= read -r -d '' tg_file
            do
                dir=$(dirname "$tg_file")
                CHANGED_DIRS[$dir]=1
            done < <(find . -name "terragrunt.hcl" -print0)
            break  # No need to continue checking after this
        fi
    done <<< "$VARS_DIFF"
fi

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