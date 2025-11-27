#!/bin/bash

# This script converts the repository from a tag-based structure
# to a branch-per-step structure, locally.
# No changes will be pushed to the remote repository.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Helper Functions for Logging ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

info "Creating new step branches locally..."

git branch step/m2-s1 m2-s1
git branch step/m3-s2 m3-s2
git branch step/m3-s3 m3-s3
git branch step/m3-s4 m3-s4
git branch step/m3-s5 m3-s5
git branch step/m3-s6 m3-s6
git branch step/m4-s7 m4-s7
git branch step/m4-s8 m4-s8
git branch step/m5-s9 m5-s9
git branch step/m5-s10 m5-s10
git branch step/m5-s11 m5-s11
git branch step/m6-s12 m6-s12
git branch step/m6-s13 m6-s13
git branch step/m6-s14 m6-s14

success "All local step branches created."

info "Deleting old tags locally..."

git tag -d m2-s1 m3-s2 m3-s3 m3-s4 m3-s5 m3-s6 m4-s7 m4-s8 m5-s9 m5-s10 m5-s11 m6-s12 m6-s13 m6-s14

success "Old local tags deleted."

echo
info "Local conversion complete!"
info "Run 'git branch' to see the new branches."
info "When you are ready, push the changes to the remote repository."
