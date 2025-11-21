#!/bin/bash

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
echo "This may include: Homebrew (on macOS), Node.js, Python, Git, Google Cloud SDK, and Python tools."
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
fi

# Git
if ! command -v git &> /dev/null; then
    info "Git not found. Installing Git..."
    $PKG_MANAGER git
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
fi

# Python
if ! command -v python3 &> /dev/null; then
    info "Python 3 not found. Installing Python 3..."
    $PKG_MANAGER python3 python3-pip
fi

# pipx
if ! command -v pipx &> /dev/null; then
    info "pipx not found. Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    export PATH="$PATH:$HOME/.local/bin" # Add pipx to path for the current session
fi

# uv
if ! command -v uv &> /dev/null; then
    info "uv/uvx not found. Installing uv..."
    pipx install uv
fi

# Google Cloud SDK
if ! command -v gcloud &> /dev/null; then
    info "Google Cloud SDK not found. Starting interactive installer..."
    warn "Please follow the on-screen instructions from the official Google Cloud SDK installer."
    warn "After installation, you MUST open a new terminal and re-run this script to continue."
    curl https://sdk.cloud.google.com | bash
    error "Google Cloud SDK installation initiated. Please open a NEW terminal and re-run this script."
fi

success "All prerequisites are installed and up to date."

# --- The rest of the script is the same as before ---

# --- Google Cloud Configuration ---
info "Configuring Google Cloud..."

read -p "Please enter your desired Google Cloud Project ID: " GCLOUD_PROJECT_ID
if [ -z "$GCLOUD_PROJECT_ID" ]; then
    error "Google Cloud Project ID cannot be empty."
fi

info "Checking if project '$GCLOUD_PROJECT_ID' exists..."
if gcloud projects describe "$GCLOUD_PROJECT_ID" &> /dev/null; then
    success "Project '$GCLOUD_PROJECT_ID' already exists."
else
    info "Project '$GCLOUD_PROJECT_ID' not found. Creating it now..."
    gcloud projects create "$GCLOUD_PROJECT_ID"
    success "Project creation command issued."

    info "Waiting for project to be fully created... (This may take a minute or two)"
    TIMEOUT=300 # 5 minutes timeout
    SECONDS=0
    while ! gcloud projects describe "$GCLOUD_PROJECT_ID" &> /dev/null; do
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

info "Enabling the Vertex AI API (aiplatform.googleapis.com)..."
gcloud services enable aiplatform.googleapis.com --project="$GCLOUD_PROJECT_ID"

info "Enabling the Compute Engine API (compute.googleapis.com) to ensure default service account exists..."
gcloud services enable compute.googleapis.com --project="$GCLOUD_PROJECT_ID"

success "Required APIs enabled."

info "Granting 'Vertex AI User' role to the default Compute Engine service account..."
PROJECT_NUMBER=$(gcloud projects describe "$GCLOUD_PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/aiplatform.user" \
    --condition=None \
    --quiet
success "IAM role granted to $SERVICE_ACCOUNT."

info "Granting 'Storage Object Viewer' role to the default Compute Engine service account..."
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectViewer" \
    --condition=None \
    --quiet
success "IAM role granted to $SERVICE_ACCOUNT."

info "Granting 'Logging Log Writer' role to the default Compute Engine service account..."
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/logging.logWriter" \
    --condition=None \
    --quiet
success "IAM role granted to $SERVICE_ACCOUNT."

info "Granting 'Artifact Registry Reader' role to the Cloud Build service account..."
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" \
    --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" \
    --role="roles/artifactregistry.reader" \
    --condition=None \
    --quiet
success "IAM role granted to $CLOUD_BUILD_SERVICE_ACCOUNT."

info "Granting 'Artifact Registry Writer' role to the Cloud Build service account..."
gcloud projects add-iam-policy-binding "$GCLOUD_PROJECT_ID" \
    --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" \
    --role="roles/artifactregistry.writer" \
    --condition=None \
    --quiet
success "IAM role granted to $CLOUD_BUILD_SERVICE_ACCOUNT."

# --- Code Checkout ---
REPO_URL="https://github.com/your-org/consigliai-di-mamma.git" # Placeholder URL
REPO_DIR="consigliai-di-mamma"

if [ -d "$REPO_DIR" ]; then
    info "Directory '$REPO_DIR' already exists. Skipping git clone."
else
    info "Cloning the course repository..."
    git clone "$REPO_URL"
fi

cd "$REPO_DIR"
info "Changed directory to '$REPO_DIR'."

# --- Installation ---
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
