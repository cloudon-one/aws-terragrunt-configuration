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

# Check for changes in aws/vars.yaml
if git diff --name-only $BASE_SHA $HEAD_SHA | grep -q 'aws/vars.yaml$'; then
    # Check if the content of aws/vars.yaml has changed
    if ! git diff --exit-code $BASE_SHA $HEAD_SHA -- aws/vars.yaml > /dev/null; then
        # Content has changed, so we need to process all directories with terragrunt.hcl
        while IFS= read -r -d '' tg_file
        do
            dir=$(dirname "$tg_file")
            CHANGED_DIRS[$dir]=1
        done < <(find . -name "terragrunt.hcl" -print0)
    fi
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