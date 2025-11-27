#!/bin/bash

# This script automates the process of rebasing all subsequent course branches
# after a change has been made to an earlier step.

set -e # Exit immediately if a command fails.

# --- Helper Functions for Logging ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

# --- Script Logic ---
if [ -z "$1" ]; then
    error "Usage: ./rebase_course.sh <branch-that-was-fixed>"
    echo "Example: ./rebase_course.sh step/m4-s7"
fi

START_BRANCH=$1

# Get all step branches and sort them using a version sort (-V)
# This is crucial for correctly ordering names like 's9' and 's10'.
ALL_BRANCHES=($(git branch --list "step/*" | sed 's/..//' | sort -V))

# Find the index of the starting branch in the sorted list
START_INDEX=-1
for i in "${!ALL_BRANCHES[@]}"; do
   if [[ "${ALL_BRANCHES[$i]}" = "$START_BRANCH" ]]; then
       START_INDEX=$i
       break
   fi
done

if [ $START_INDEX -eq -1 ]; then
    error "Branch '$START_BRANCH' not found in the list of step branches."
fi

info "Starting rebase process from branch after '$START_BRANCH'..."

# Loop from the branch AFTER the one that was fixed
for (( i=$START_INDEX + 1; i<${#ALL_BRANCHES[@]}; i++ )); do
    PREVIOUS_BRANCH=${ALL_BRANCHES[$i-1]}
    CURRENT_BRANCH=${ALL_BRANCHES[$i]}

    info "Rebasing '$CURRENT_BRANCH' on top of '$PREVIOUS_BRANCH'..."

    # Execute the commands
    git checkout "$CURRENT_BRANCH"
    git rebase "$PREVIOUS_BRANCH"

    success "'$CURRENT_BRANCH' successfully rebased."
done

# --- Final Instructions ---
echo
success "All subsequent branches have been rebased locally!"
warn "IMPORTANT: This script does not handle merge conflicts."
warn "If the script stopped, resolve the conflicts, run 'git rebase --continue',"
warn "and then re-run this script with the branch you were on as the argument to continue."
echo
info "To push these changes to the remote repository, you must use --force."
info "You can push all updated branches by running: git push origin --all --force"
