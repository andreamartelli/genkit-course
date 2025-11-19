# Genkit Course Presenter Guide: ConsigliAI di Mamma

## Introduction

Welcome, presenter! This guide is your step-by-step companion for delivering the "ConsigliAI di Mamma" Genkit course. It includes talking points, code demonstration instructions, and key concepts for each module.

**Course Goal:** To provide Google Cloud CEs with a practical, hands-on introduction to building production-ready AI applications using Genkit and Vertex AI.

**Core Strategy:** We will build a fun, FSI-relevant application, "ConsigliAI di Mamma," step-by-step. Each step corresponds to a Git tag, allowing you to easily navigate the code during the presentation.

---

## Pre-Course Setup for Participants

**Objective:** Ensure all participants have a working environment before the course begins.

**Action:**
1.  Direct participants to the `README.md` file in the repository.
2.  Instruct them to run the `setup.sh` script: `./setup.sh`.
3.  Emphasize that they must follow the on-screen prompts, especially for the Google Cloud SDK installation and providing their Project ID.
4.  Ensure everyone has successfully run `npm start` and can see the `getMammaAdvice` flow in the Genkit Developer UI at `http://localhost:4000`.

---

## Module 1: Parliamo di Genkit (Introduction)

**Objective:** Set the stage. Introduce Genkit and its value proposition.

*   **Slides 1-7:**
    *   **Talking Points:**
        *   (Slide 3) Discuss the difficulty of moving from a cool GenAI demo (like a Python notebook) to a production-grade, scalable, and observable application. Highlight challenges like model switching, structured I/O, observability, and deployment.
        *   (Slide 4) Introduce Genkit as the open-source framework designed to solve these problems.
        *   (Slide 5) Use the analogy "Firebase for GenAI" to explain the philosophy. Emphasize the four pillars: **Declarative, Composable, Observable, Portable**.
        *   (Slide 6) Briefly showcase the ecosystem: it supports many models (we'll use Gemini on Vertex AI), has various plugins, and is framework-agnostic.
        *   (Slide 7) Introduce the fun use case: "ConsigliAI di Mamma," our AI-powered Italian mother financial advisor.

---

## Module 2: Il Primo Consiglio di Mamma

**Objective:** Create and run the very first, simplest Genkit flow.

*   **Slide 8: Setup & "Hello, Mamma!"**
    *   **Code Demo (Tag: `m2-s1`):**
        1.  **Action:** `git checkout m2-s1`
        2.  **Show `package.json`:** Point out the key dependencies: `genkit`, `@genkit-ai/vertexai`, `express`, `zod`.
        3.  **Show `index.js`:** This is the core of our first step.
            *   Explain `configureGenkit` and the `plugins` array. Highlight the `vertexAI` plugin and how it's configured.
            *   Walk through the `defineFlow` function for `mammaSaysHello`. Explain the `name`, `inputSchema` (a simple string), and `outputSchema`.
            *   Explain the `generate` call: it takes a model, a prompt, and returns a response.
        4.  **Demonstrate:**
            *   Run `npm start` in the terminal.
            *   Open the Dev UI (`http://localhost:4000`).
            *   Find `mammaSaysHello`, enter a name (e.g., "Antonio"), and run it. Show the generated text output.

---

## Module 3: Mamma Vuole Chiarezza

**Objective:** Introduce prompts, structured I/O, and best practices for organizing code.

*   **Slide 9: The Power of Prompts & Making it Reusable**
    *   **Code Demo (Tag: `m3-s2`):**
        1.  **Action:** `git checkout m3-s2`
        2.  **Show `prompts/mammaAdvice.prompt`:**
            *   Explain the `.prompt` file format. This is where we define Mamma's persona.
            *   Highlight the YAML front matter (`---`). Explain the `name: mammaAdvice` makes it a callable prompt.
            *   Point out the Handlebars templating: `{{question}}`. This is how we inject dynamic data.
        3.  **Show `src/flows/mamma.js`:**
            *   Explain that the flow logic has been moved here for better organization.
            *   Show the new `inputSchema`: `z.object({ question: z.string() })`.
            *   Highlight the new prompt call: `const advicePrompt = ai.prompt('mammaAdvice');` and `await advicePrompt(input);`. Explain that this is cleaner and more declarative than embedding the prompt text in the code.
        4.  **Demonstrate:** Run `getMammaAdvice` in the Dev UI with a JSON input like `{"question": "Is it a good time to buy a house?"}`. Show the structured input field.

*   **Slide 10: Flow-level & Referenced Schemas**
    *   **Code Demo (Tag: `m3-s3`):**
        1.  **Action:** `git checkout m3-s3`
        2.  **Show `src/schemas.js`:** Explain that centralizing schemas is a best practice for reusability and clean code. Show the `MammaAdviceSchema` definition.
        3.  **Show `src/flows/mamma.js`:**
            *   Point out the `import { MammaAdviceSchema } from '../schemas.js';`.
            *   Show that the `outputSchema` in `defineFlow` is now set to `MammaAdviceSchema`.
        4.  **Show `prompts/mammaAdvice.prompt`:** Explain that the prompt now has `output: { format: json }` and instructs the model to respond in JSON.
        5.  **Demonstrate:** Run the flow. Show that the output is now a structured JSON object with `advice` and `mammaApprovalRating` fields.

*   **Slide 11: Prompt Composition with Partials**
    *   **Code Demo (Tag: `m3-s4`):**
        1.  **Action:** `git checkout m3-s4`
        2.  **Show `prompts/mammaPersona.prompt`:** Explain this is a "partial" prompt. It contains only the core persona.
        3.  **Show `prompts/mammaAdvice.prompt`:** Point out the `{{> mammaPersona}}` syntax. Explain that this is how Genkit composes prompts, injecting the content of the partial. This is great for reusing prompt components.
        4.  **Demonstrate:** Run the flow. The behavior is the same, but the code is now more modular.

*   **Slides 12 & 13: Prompt-level Schemas**
    *   **Code Demos (Tags: `m3-s5` & `m3-s6`):**
        1.  **Action:** `git checkout m3-s5`
        2.  **Show `prompts/mammaAdvice.prompt`:** Explain that you can define the schema *directly* in the prompt using JSON Schema. This makes the prompt self-contained.
        3.  **Show `src/flows/mamma.js`:** Point out that the `outputSchema` has been removed from the flow definition, as it's now inferred from the prompt.
        4.  **Action:** `git checkout m3-s6`
        5.  **Show `prompts/mammaAdvice.prompt`:** Explain the best-of-both-worlds approach. The prompt references the schema by its registered name (`schema: MammaAdviceSchema`). This keeps the prompt self-contained without duplicating the schema definition.

---

## Module 4: Mamma si Informa

**Objective:** Give Mamma "superpowers" by connecting her to external tools.

*   **Slide 14: Custom Exchange Rate Tool**
    *   **Code Demo (Tag: `m4-s7`):**
        1.  **Action:** `git checkout m4-s7`
        2.  **Show `src/tools/exchange.js`:**
            *   Walk through the `defineTool` function. Explain the `name`, `description` (critical for the model to know when to use it), `inputSchema`, and `outputSchema`.
            *   Show the implementation logic that calls the `fetch` API to get real-world data.
        3.  **Show `src/flows/mamma.js`:** Show how the `getExchangeRate` tool is imported and passed into the `tools` array of the prompt call.
        4.  **Demonstrate:** Run the flow with a question like `{"question": "How many US dollars is 100 Euros?"}`. Open the trace and show the `tool_code` step where the model called our custom tool.

*   **Slide 15: Agentic Patterns - Conditional Routing**
    *   **Code Demo (Tag: `m4-s8`):**
        1.  **Action:** `git checkout m4-s8`
        2.  **Explain the "Why":** We want to add Google Search, but the model has limitations with mixing different tool types. Our solution is to build a router.
        3.  **Show `prompts/router.prompt`:** Explain its only job is to classify the user's intent.
        4.  **Show `prompts/mammaSearch.prompt`:** This is a new prompt specifically for handling search queries.
        5.  **Show `src/flows/mamma.js`:** This is the key part. Walk through the new logic:
            *   The flow first calls the `routerPrompt`.
            *   An `if/else` block checks the `intent`.
            *   It then calls the appropriate prompt (`advicePrompt` or `searchPrompt`) with the correct tools for that specific task.
        6.  **Demonstrate:** Run two queries: one for exchange rates and one for `{"question": "What is the latest news on Apple stock?"}`. Show the different paths taken in the traces.

---

## Module 5: La Saggezza Avanzata di Mamma

**Objective:** Explore advanced agentic patterns and multimodality.

*   **Slide 16: Multimodality**
    *   **Code Demo (Tag: `m5-s9`):**
        1.  **Action:** `git checkout m5-s9`
        2.  **Explain the Goal:** Mamma will now provide a "financial care package" image along with her advice.
        3.  **Show `src/schemas.js`:** Point out the new optional `imageData` field.
        4.  **Show `src/flows/mamma.js`:** In the `general_advice` branch, show the second `ai.generate` call. Explain that this call uses a multimodal model to generate an image. Highlight the `config` object where we specify `responseMimeType` and `aspectRatio`.
        5.  **Demonstrate:** Run a `general_advice` query. Show the output JSON now contains a long `imageData` string. Explain that this is the base64-encoded image data that a frontend could render.

*   **Slide 17: Iterative Refinement**
    *   **Code Demo (Tag: `m5-s10`):**
        1.  **Action:** `git checkout m5-s10`
        2.  **Explain the Story:** "Mamma took a personal finance course." We are modeling her ability to critique and improve her own advice.
        3.  **Show `prompts/critique.prompt`:** Explain its role as Mamma's "inner financial advisor."
        4.  **Show `src/flows/mamma.js`:** Walk through the `for` loop in the `general_advice` branch. Explain the draft -> critique -> refine cycle. Show how the critique from one iteration is passed to the next.
        5.  **Demonstrate:** Run a query like `{"question": "Should I invest in crypto?"}`. In the terminal, point out the `[Refinement Loop]` log messages, showing the agent is "thinking."

*   **Slide 18: Advanced Tooling with MCP (Conceptual)**
    *   **Code Demo (Tag: `m5-s11`):**
        1.  **Action:** `git checkout m5-s11`
        2.  **Explain the Concept:** "So far, all our tools have been defined in our own codebase. What if another team provides a set of tools as a separate service? That's what MCP is for."
        3.  **Show `src/tools/yahooFinanceMcp.js`:** Explain that this class sets up a *client* to connect to an external tool server.
        4.  **Show the commented-out code in `src/flows/mamma.js`:** Explain that this is where we would use the client to discover and use the external tools. Acknowledge the implementation complexity and state that for this course, it remains a conceptual demonstration of Genkit's powerful extensibility.

*   **Slide 19: Interactive Chats (Conceptual)**
    *   **Talking Points:**
        *   Explain that everything we've built has been a single-shot flow.
        *   To build a true chatbot, you need to manage conversation history.
        *   Introduce `ai.chat()` as the high-level, easy way to do this. It's a specialized flow builder that handles state and history automatically. Show a conceptual code snippet on the slide.

---

## Module 6: Dalla Cucina al Cloud

**Objective:** Show how to debug, deploy, and observe a Genkit application.

*   **Slide 19: The Local Dev Experience**
    *   **Demonstrate:** Go back to the Dev UI. Open a complex trace (like one from the refinement loop). Click through each step: the router, the advice drafts, the critiques, the tool calls, the final image generation. Emphasize how invaluable this is for debugging complex AI chains.

*   **Slide 20: Exposing Flows as Services**
    *   **Demonstrate:**
        *   Point out that `npm start` also starts an Express server.
        *   Open a new terminal and use `curl` to call the flow's endpoint directly:
            ```bash
            curl -X POST -H "Content-Type: application/json" -d '{"input": {"question": "Ciao Mamma!"}}' http://localhost:3400/getMammaAdvice
            ```
        *   Explain that because flows are just functions, you could build any custom API (Express, Fastify, etc.) and call your flow logic from within it.

*   **Slide 21: Deploying to Cloud Run**
    *   **Demonstrate:**
        *   Show the `Dockerfile` in the project (if you choose to have one, or explain that `genkit deploy` can use a standard one).
        *   Run the `gcloud auth configure-docker` command if needed.
        *   Run `genkit deploy`. Explain what it's doing (building a container, pushing it to Artifact Registry, deploying to Cloud Run).
        *   Show the deployed service in the Google Cloud Console.

*   **Slide 22: Observability in Google Cloud**
    *   **Demonstrate:**
        *   Call the deployed Cloud Run endpoint.
        *   Go to the Cloud Trace dashboard in the Google Cloud Console.
        *   Find and open the trace from the production call. Show that it's the *exact same* rich trace we had in the local Dev UI. This is the killer feature for production monitoring.

*   **Slides 23 & 24: Recap & Q&A**
    *   **Talking Points:** Briefly recap the journey: started with a simple flow, added structured I/O, composed prompts, added tools, built agentic patterns, and deployed to production with full observability. Open the floor for questions.
