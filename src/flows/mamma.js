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

import { ai } from '../genkit.js';
import * as z from 'zod';

// Load prompt
const advicePrompt = ai.prompt('mammaAdvice');

export const getMammaAdvice = ai.defineFlow(
  {
    name: 'getMammaAdvice',
    inputSchema: z.object({
      question: z.string().describe("The user's financial question or topic"),
    }),
    outputSchema: z.string().describe("Mamma's financial advice"),
  },
  async (input) => {

    const response = await advicePrompt(input);

    return response.text;
  }
);
