#!/bin/bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is designed to be run in Google Cloud Shell.
# It assumes gcloud, git, node, and python are already installed.

set -e # Exit immediately if a command exits with a non-zero status.

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

# --- Initial Login Check ---
info "Ensuring you are authenticated with gcloud..."
gcloud auth login
gcloud config list

# --- Project Configuration ---
info "Starting Google Cloud project setup..."
read -p "Please enter your Google Cloud Project ID: " PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
    error "Project ID cannot be empty."
fi

gcloud config set project "$PROJECT_ID"

info "Checking if project '$PROJECT_ID' exists..."
if ! gcloud projects describe "$PROJECT_ID" --quiet &> /dev/null; then
    info "Project '$PROJECT_ID' not found. Creating it now..."
    gcloud projects create "$PROJECT_ID"
    success "Project '$PROJECT_ID' created."
fi

info "Checking if billing is enabled..."
if ! gcloud beta billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" | grep -q "True"; then
    error "Billing is not enabled for project '$PROJECT_ID'. Please visit the Google Cloud Console to enable billing, then re-run this script."
fi
success "Billing is enabled."

# --- API & IAM Configuration ---
info "Enabling required Google Cloud APIs..."
gcloud services enable aiplatform.googleapis.com \
    cloudresourcemanager.googleapis.com \
    compute.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    --project="$PROJECT_ID"
success "APIs enabled."

info "Granting necessary IAM roles..."
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/aiplatform.user" --condition=None --quiet
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/storage.objectViewer" --condition=None --quiet
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/logging.logWriter" --condition=None --quiet
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" --role="roles/artifactregistry.reader" --condition=None --quiet
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" --role="roles/artifactregistry.writer" --condition=None --quiet
success "IAM roles granted."

# --- Tool & Code Installation ---
info "Installing Genkit CLI globally..."
npm install -g genkit-cli

info "Installing uv..."
pip install uv

info "Cloning course repository..."
git clone https://github.com/andreamartelli/genkit-course.git
cd genkit-course

info "Installing Node.js dependencies..."
npm install
cd genkit-course

# --- Final Instructions ---
success "Setup complete!"
info "You are in the project directory. You can now start the application by running:"
echo "    npm start"
