#!/bin/bash

# Get the base and head SHAs
BASE_SHA=$(git rev-parse origin/main)
HEAD_SHA=$(git rev-parse HEAD)

# Get the list of changed files
CHANGED_FILES=$(git diff --name-only $BASE_SHA $HEAD_SHA)

# Initialize an empty array to store unique directories
declare -A CHANGED_DIRS

# Loop through changed files and extract unique directories
for file in $CHANGED_FILES; do
    if [[ $file == *"terragrunt.hcl" ]]; then
        dir=$(dirname "$file")
        CHANGED_DIRS[$dir]=1
    elif [[ $file == "aws/vars.yaml" ]]; then
        # If aws/vars.yaml changed, we need to process all directories with terragrunt.hcl
        while IFS= read -r -d '' tg_file
        do
            dir=$(dirname "$tg_file")
            CHANGED_DIRS[$dir]=1
        done < <(find . -name "terragrunt.hcl" -print0)
    fi
done

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