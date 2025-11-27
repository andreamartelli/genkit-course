#!/bin/bash

# This script updates all 'step/*' branches to include the latest versions
# of the course documentation files from the 'main' branch.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Helper Functions for Logging ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

# --- Files to Update ---
DOC_FILES=("COURSE_PLAN.md" "USER_GUIDE.md" "PRESENTER_GUIDE.md")

# --- Script Logic ---
info "Fetching latest updates from remote..."
git fetch origin

# Get the current branch name so we can return to it later
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get all step branches
ALL_BRANCHES=($(git branch --list "step/*" | sed 's/..//'))

info "The following documentation files will be added to each step branch:"
for file in "${DOC_FILES[@]}"; do
    echo "  - $file"
done

for branch in "${ALL_BRANCHES[@]}"; do
    info "Updating branch: $branch..."
    
    # Checkout the step branch
    git checkout "$branch"
    
    # Grab the documentation files from the main branch
    git checkout main -- "${DOC_FILES[@]}"
    
    # Commit the files
    # The '--amend' flag is used to avoid creating a new commit if the only
    # change is adding these docs. If other changes are present, it will
    # create a new commit.
    git add "${DOC_FILES[@]}"
    git commit -m "docs: Add final course documentation"

    success "Branch '$branch' updated."
done

info "Returning to original branch: $ORIGINAL_BRANCH..."
git checkout "$ORIGINAL_BRANCH"

success "All step branches have been updated with the latest documentation."
info "You can now push the changes with: git push origin --all"
