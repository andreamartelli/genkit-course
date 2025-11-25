#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script is designed to be run on macOS or Debian/Red Hat-based Linux.
# It will attempt to install missing prerequisites, which may require sudo privileges.

# --- Helper Functions for Logging ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

# --- Initial Warning and Confirmation ---
echo "This script will check for and install missing prerequisites for the Genkit course."
echo "This may include: Homebrew (on macOS), Node.js, Python, Git, and Google Cloud SDK."
echo "Sudo privileges will be required for system-wide installations."
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# --- Sudo and OS Detection ---
info "Requesting sudo privileges upfront..."
sudo -v # Ask for sudo password at the beginning

OS=""
PKG_MANAGER=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        OS="debian"
        PKG_MANAGER="sudo apt-get install -y"
    elif command -v yum &> /dev/null; then
        OS="redhat"
        PKG_MANAGER="sudo yum install -y"
    else
        error "Unsupported Linux distribution. Please install prerequisites manually."
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    PKG_MANAGER="brew install"
else
    error "Unsupported operating system. This script runs on macOS or Linux."
fi
info "Detected OS: $OS"

# --- Prerequisite Installation ---
info "Checking and installing prerequisites..."

# Homebrew (for macOS)
if [[ "$OS" == "macos" ]] && ! command -v brew &> /dev/null; then
    info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed."
fi

# Git
if ! command -v git &> /dev/null; then
    info "Git not found. Installing Git..."
    $PKG_MANAGER git
    success "Git installed."
fi

# Node.js
if ! command -v node &> /dev/null; then
    info "Node.js not found. Installing Node.js..."
    if [[ "$OS" == "macos" ]]; then
        $PKG_MANAGER node
    else
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    success "Node.js installed."
fi

# Python & pip
if ! command -v python3 &> /dev/null; then
    info "Python 3 not found. Installing Python 3..."
    if [[ "$OS" == "macos" ]]; then
        $PKG_MANAGER python3
    else
        $PKG_MANAGER python3 python3-pip python3-venv
    fi
    success "Python 3 installed."
fi

if ! python3 -m pip --version &> /dev/null; then
    info "pip for python3 not found. Installing python3-pip..."
    if [[ "$OS" == "debian" ]]; then
        sudo apt-get install -y python3-pip python3-venv
    elif [[ "$OS" == "redhat" ]]; then
        sudo yum install -y python3-pip python3-venv
    fi
    success "pip for python3 installed."
fi

# Google Cloud SDK
if ! command -v gcloud &> /dev/null; then
    info "Google Cloud SDK not found. Starting interactive installer..."
    warn "Please follow the on-screen instructions from the official Google Cloud SDK installer."
    warn "After installation, you MUST open a new terminal and re-run this script to continue."
    curl https://sdk.cloud.google.com | bash
    error "Google Cloud SDK installation initiated. Please open a NEW terminal and re-run this script."
fi

success "All command-line prerequisites are installed."

# --- Google Cloud Configuration ---
info "Configuring Google Cloud..."

read -p "Please enter your desired Google Cloud Project ID: " GCLOUD_PROJECT_ID
if [ -z "$GCLOUD_PROJECT_ID" ]; then
    error "Google Cloud Project ID cannot be empty."
fi

info "Checking if project '$GCLOUD_PROJECT_ID' exists..."
if ! gcloud projects describe "$GCLOUD_PROJECT_ID" --quiet &> /dev/null; then
    info "Project '$GCLOUD_PROJECT_ID' not found. Creating it now..."
    gcloud projects create "$GCLOUD_PROJECT_ID"
    success "Project creation command issued."

    info "Waiting for project to be fully created... (This may take a minute or two)"
    TIMEOUT=300 # 5 minutes timeout
    SECONDS=0
    while ! gcloud projects describe "$GCLOUD_PROJECT_ID" --quiet &> /dev/null; do
        sleep 5
        SECONDS=$((SECONDS + 5))
        if [ $SECONDS -ge $TIMEOUT ]; then
            error "Timed out waiting for project '$GCLOUD_PROJECT_ID' to be created. Please check the Google Cloud Console."
        fi
        echo -n "."
    done
    echo
    success "Project '$GCLOUD_PROJECT_ID' is now active."
fi

info "Setting gcloud project to '$GCLOUD_PROJECT_ID'..."
gcloud config set project "$GCLOUD_PROJECT_ID"

# --- Billing Check ---
info "Checking if billing is enabled for project '$GCLOUD_PROJECT_ID'..."
if ! gcloud beta billing projects describe "$GCLOUD_PROJECT_ID" --format="value(billingEnabled)" | grep -q "True"; then
    error "Billing is not enabled for project '$GCLOUD_PROJECT_ID'. Please visit the Google Cloud Console to enable billing, then re-run this script."
fi
success "Billing is enabled."

# --- API and IAM Configuration ---
info "Enabling required Google Cloud APIs..."
gcloud services enable cloudresourcemanager.googleapis.com compute.googleapis.com aiplatform.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project="$GCLOUD_PROJECT_ID"
success "Required APIs enabled."

info "Granting necessary IAM roles..."
PROJECT_NUMBER=$(gcloud projects describe "$GCLOUD_PROJECT_ID" --format="value(projectNumber)")

# Grant roles to Default Compute Service Account
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
info "Granting roles to Default Compute Service Account ($SERVICE_ACCOUNT)..."
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/aiplatform.user" --condition=None --quiet
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/storage.objectViewer" --condition=None --quiet
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" --member="serviceAccount:${SERVICE_ACCOUNT}" --role="roles/logging.logWriter" --condition=None --quiet

# Grant roles to Cloud Build Service Account
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
info "Granting roles to Cloud Build Service Account ($CLOUD_BUILD_SERVICE_ACCOUNT)..."
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" --role="roles/artifactregistry.reader" --condition=None --quiet
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" --role="roles/artifactregistry.writer" --condition=None --quiet

success "All necessary IAM roles have been granted."

# --- Code Checkout ---
REPO_URL="https://github.com/andreamartelli/genkit-course.git"
REPO_DIR="genkit-course"

if [ -d "$REPO_DIR" ]; then
    info "Directory '$REPO_DIR' already exists. Skipping git clone."
else
    info "Cloning the course repository..."
    git clone "$REPO_URL"
fi

cd "$REPO_DIR"
info "Changed directory to '$REPO_DIR'."

# Add the repository to Git's safe.directory list
git config --global --add safe.directory "$(pwd)"
success "Repository added to Git's safe directories."

# --- Python Virtual Environment and Tool Installation ---
info "Creating Python virtual environment in ./.venv ..."
python3 -m venv .venv

info "Activating virtual environment..."
source .venv/bin/activate

info "Installing 'uv' into the virtual environment..."
python3 -m pip install uv
success "'uv' is now installed in the virtual environment."

# --- Node.js Installation ---
info "Installing Node.js dependencies..."
npm install
success "Dependencies installed."

# --- Final Instructions ---
echo
success "Setup complete!"
info "You can now start the Genkit application by running the following command:"
echo
echo "    npm start"
echo