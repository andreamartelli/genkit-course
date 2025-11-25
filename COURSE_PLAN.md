# Participant Quickstart Guide

This guide provides the steps to set up your local environment to run the course project and follow along.

### Prerequisites

Make sure you have the following software installed on your workstation:

- **Node.js** (v20.x or later)
- **Python** (v3.8 or later)
- **Google Cloud SDK** (`gcloud` CLI)
- **Git**
- **pipx** (Python package installer for applications)

### Step 1: Google Cloud Project Setup

1.  **Create a new Google Cloud Project** or select an existing one.
2.  The `setup.sh` script will automatically enable the necessary APIs (Vertex AI, Compute Engine) and grant the required IAM roles for the default Compute Engine service account.

### Step 2: Authenticate the gcloud CLI

In your terminal, run the following commands to log in and set your active project. Replace `[YOUR_PROJECT_ID]` with your actual Google Cloud project ID.

```bash
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
```

### Step 3: Install `uvx` for MCP Server Execution

To run the external tools provided via the Model-Context Protocol (MCP), you need to install `uvx`. `uvx` will automatically manage the Python MCP server package.

First, ensure `pipx` is installed (if not already):
```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```
Then, install `uvx`:
```bash
pipx install uv
```

### Step 4: Get the Course Code

Clone the repository from our shared location. (Note: The URL is a placeholder).

```bash
git clone https://github.com/your-org/consigliai-di-mamma.git
cd consigliai-di-mamma
```

### Step 5: Install Dependencies & Run the Project

Once you are inside the project directory, install the Node.js dependencies and start the Genkit Developer UI.

```bash
npm install
npm start
```

### Step 6: Verify Your Setup

1.  The `npm start` command should open the Genkit Developer UI in your browser at `http://localhost:4000`.
2.  In the UI, find the `getMammaAdvice` flow.
3.  Run the flow with a simple question in the input field, like: `{"question": "Should I save more money?"}`.
4.  If the setup is correct, you should see a successful run and a JSON output containing Mamma's advice.

---

# Genkit Course: "ConsigliAI di Mamma" - Masterplan

This document outlines the full plan for the interactive Genkit course.

## The Use Case: "ConsigliAI di Mamma"

A GenAI-powered financial advisor with the persona of a caring, wise, and slightly stereotypical Italian mother.

## High-Level Course Structure

1.  **Module 1: "Parliamo di Genkit"** (Introduction)
2.  **Module 2: "Il Primo Consiglio di Mamma"** (The First Step)
3.  **Module 3: "Mamma Vuole Chiarezza"** (Structuring the Conversation & Prompts)
4.  **Module 4: "Mamma si Informa"** (Making Mamma Smart with Tools)
5.  **Module 5: "La Saggezza Avanzata di Mamma"** (Advanced Patterns)
6.  **Module 6: "Dalla Cucina al Cloud"** (Serving, Deploying, and Observing)

## Git Tagging Strategy

We will use tags in the format `mX-sY` to mark the state of the code at each step.
- `mX`: Module X
- `sY`: Code Sample Y

---

## Detailed Slide & Code Sample Breakdown

### **Module 1: Parliamo di Genkit**
*   **Slide 1: Title Slide** - Genkit: Build Production-Ready AI Systems with Node.js & Google Cloud
*   **Slide 2: Who are we?** - Intro to the presenter and the audience (Google Cloud CEs FSI).
*   **Slide 3: The Challenge:** Moving from GenAI "Magic" (PoCs) to Production Systems.
*   **Slide 4: Introducing Genkit:** An open-source framework to build, deploy, and monitor robust AI features.
*   **Slide 5: Core Philosophy:** Declarative, Composable, Observable, Portable.
*   **Slide 6: The Genkit Ecosystem:** Supported Models (Gemini on Vertex AI!), Plugins, and Tools.
*   **Slide 7: Our Goal Today:** Build "ConsigliAI di Mamma", a wise financial advisor bot.

### **Module 2: Il Primo Consiglio di Mamma**
*   **Slide 8: Setup & "Hello, Mamma!"** - Your first Genkit flow.
    *   **Tag: `m2-s1`**
    *   **Code Sample 1:**
        *   `package.json`: Dependencies (`genkit`, `@genkit-ai/vertexai`, `express`, `zod`).
        *   `index.js`: Initialize Genkit with Vertex AI (`configureGenkit`). Define a basic flow `mammaSaysHello`.

### **Module 3: Mamma Vuole Chiarezza**
*   **Slide 9: The Power of Prompts: Giving Mamma a Personality & Making it Reusable.**
    *   **Tag: `m3-s2`**
    *   **Code Sample 2:**
        *   Create `prompts/mammaAdvice.prompt` with a `name`, persona, and Handlebars templating (`{{question}}`).
        *   Modify the flow to call the prompt by its name (`ai.prompt('mammaAdvice', ...)`).
*   **Slide 10: Structured I/O (Method 1: Flow-level & Referenced Schemas).**
    *   **Tag: `m3-s3`**
    *   **Code Sample 3:**
        *   Add a Zod schema to the flow's `outputSchema`.
        *   Refactor immediately by creating `src/schemas.js` and moving the schema definition there.
        *   Update the flow to import and use the schema from `src/schemas.js`.
*   **Slide 11: Prompt Composition with Partials.**
    *   **Tag: `m3-s4`**
    *   **Code Sample 4:**
        *   Create `prompts/mammaPersona.prompt` to hold the core persona.
        *   Update `prompts/mammaAdvice.prompt` to include the persona using `{{> mammaPersona}}`.
*   **Slide 12: Structured I/O (Method 2: Inline Prompt Schemas).**
    *   **Tag: `m3-s5`**
    *   **Code Sample 5:**
        *   Modify `prompts/mammaAdvice.prompt`: Add an `output` block with an inline Zod schema.
        *   Remove the `outputSchema` from the flow definition in `src/flows/mamma.js`.
*   **Slide 13: Structured I/O (Method 3: Referenced Prompt Schemas).**
    *   **Tag: `m3-s6`**
    *   **Code Sample 6:**
        *   Modify `src/genkit.js`: Register the schema from `src/schemas.js` with `defineSchema('mammaAdvice', ...)`.
        *   Modify `prompts/mammaAdvice.prompt`: Reference the schema by its registered name: `schema: mammaAdvice`.

### **Module 4: Mamma si Informa**
*   **Slide 14: Giving Mamma Tools (Part 1): Custom Exchange Rate Tool.**
    *   **Tag: `m4-s7`**
    *   **Code Sample 7:**
        *   Create a custom tool `getExchangeRate` that calls a public API to fetch currency exchange rates.
        *   Add the tool to the `prompt` call.
*   **Slide 15: More Tools - Grounding and Agentic Patterns.**
    *   **Tag: `m4-s8`**
    *   **Code Sample 8:**
        *   Implement a router prompt to classify user intent.
        *   Refactor the main flow to first call the router.
        *   Use an if/else block to conditionally call different prompts with the appropriate tools (`getExchangeRate` or native `googleSearch`).

### **Module 5: La Saggezza Avanzata di Mamma**
*   **Slide 16: Multimodality: Mamma's "Financial Care Package".**
    *   **Tag: `m5-s9`**
    *   **Code Sample 9:**
        *   Update `MammaAdviceSchema` to include an optional `imageUrl` field.
        *   In the flow, after Mamma gives text advice, make a second `ai.generate` call using a multimodal model to generate an image based on the advice.
        *   Include the generated image URL in the flow's output.
*   **Slide 17: Agentic Patterns: Iterative Refinement.**
    *   **Tag: `m5-s10`**
    *   **Code Sample 10:**
        *   Create a `critique.prompt` to evaluate the quality of Mamma's advice.
        *   Implement a refinement loop in the main flow that calls the advice prompt, then the critique prompt, and feeds the critique back into the advice prompt to improve the response.
*   **Slide 18: Advanced Tooling with MCP.**
    *   **Tag: `m5-s11`**
    *   **Code Sample 11:**
        *   Implement an environment-aware MCP client that uses the real `mcp-yahoo-finance` server locally, but provides a hardcoded dummy tool when running in Cloud Run.
*   **Slide 19: Interactive Chats (Conceptual).**
    *   **Code Sample 12 (Conceptual/Slide-only):**
        *   This step is conceptual. The slide will explain how to build stateful, interactive chats easily using the `ai.chat()` method in Genkit.

### **Module 6: Dalla Cucina al Cloud**

*   **Slide 20: The Local Dev Experience & Express Integration.**
    *   **Tag: `m6-s12`**
    *   **Code Sample 12:**
        *   Create `src/server.js` to explicitly start the Express server.
        *   Update `index.js` to run the server.
*   **Slide 21: Prepare for Cloud Run Deployment.**
    *   **Tag: `m6-s13`**
    *   **Code Sample 13:**
        *   Modify `package.json` to use `node index.js` for the `start` script.
*   **Slide 22: Deploying to Cloud Run (Live Demo).**
    *   **Action:** Run `gcloud run deploy`.
*   **Slide 23: Production Observability with Firebase.**
    *   **Tag: `m6-s14`**
    *   **Code Sample 14:**
        *   Add the `@genkit-ai/firebase` dependency to `package.json`.
        *   Add `enableFirebaseTelemetry()` to `src/genkit.js` to automatically configure production-grade tracing.
*   **Slide 24: Recap & Thank You.**
*   **Slide 25: Q&A.
