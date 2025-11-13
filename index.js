/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';
import * as z from 'zod';

export const ai = genkit({
  plugins: [
    vertexAI({
      projectId: 'mamma-ai-fsi',
      location: 'us-central1', // You can change this to 'europe-west1' if preferred
    }),
  ],
  model: vertexAI.model('gemini-2.5-flash', {
    temperature: 1,
  }),
  // Placeholder for flow state and observability, will be discussed later
  flowStateStore: 'firebase', 
  logLevel: 'debug',
  enableTracingAndMetrics: true,
});

export const mammaSaysHello = ai.defineFlow(
  {
    name: 'mammaSaysHello',
    inputSchema: z.string().describe("The name of the person Mamma is greeting"),
    outputSchema: z.string().describe("Mamma's greeting message"),
  },
  async (name) => {
    const response = await ai.generate({
      model: 'vertexai/gemini-2.5-flash',
      prompt: `You are Mamma, a caring but firm Italian mother. Say hello to ${name} and tell them you are ready to give financial advice.`,
      config: {
        temperature: 1
      },
    });

    return response.text;
  }
);