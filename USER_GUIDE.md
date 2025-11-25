## **Genkit Course: Preparation Guide**

Hello everyone,

To ensure we can dive straight into building our AI application, please complete these setup steps on your workstation **before** our session. This should take about 15-20 minutes.

If you encounter any issues, please don't hesitate to reach out.

---

### **Step 1: Install Prerequisite Tools**

You will need `git`, `node.js` (version 20 or higher), and the `gcloud` CLI. Open your terminal and run the following commands.

**On macOS (using Homebrew):**
```bash
# If you don't have Homebrew, install it first:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git
brew install node@20
brew install --cask google-cloud-sdk
```

**On Linux (Debian/Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install -y git

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Google Cloud SDK
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
sudo apt-get update && sudo apt-get install -y google-cloud-cli
```
**After installing `gcloud`**, you must initialize it. Run this command and follow the on-screen instructions to log in with your Google account:
```bash
gcloud init
```

---

### **Step 2: Download the Course Repository**

Clone the project code from GitHub:
```bash
git clone https://github.com/andreamartelli/genkit-course.git
```

---

### **Step 3: Configure Your Google Cloud Project**

1.  **Navigate into the project directory:**
    ```bash
    cd genkit-course
    ```

2.  **Set Your Project ID:**
    Decide on a unique Project ID (e.g., `mamma-ai-your-name`). We will set this as an environment variable.
    ```bash
    # Replace 'your-unique-project-id' with your choice
    export PROJECT_ID="your-unique-project-id"
    ```

3.  **Create and Configure the Project:**
    ```bash
    # Create the project
    gcloud projects create $PROJECT_ID

    # Set gcloud to use your new project
    gcloud config set project $PROJECT_ID
    ```

4.  **Link a Billing Account (Manual Step):**
    A billing account is required to enable APIs.
    *   Go to the [Google Cloud Billing Console](https://console.cloud.google.com/billing).
    *   Select your new project (`your-unique-project-id`).
    *   Follow the prompts to link an existing billing account or create a new one. **This step is mandatory.**

5.  **Enable the Vertex AI API:**
    ```bash
    gcloud services enable aiplatform.googleapis.com
    ```

---

### **Step 4: Install Dependencies & Verify**

1.  **Install the Node.js packages:**
    ```bash
    npm install
    ```

2.  **Run the project!**
    ```bash
    npm start
    ```

You should see output indicating that the Genkit server has started.

3.  **Final Check:** Open your web browser and navigate to **http://localhost:4000**. You should see the Genkit Developer UI.

If you see the Dev UI, your setup is complete! You are all set for the course.

See you soon,
Andrea