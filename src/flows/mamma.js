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

import { int } from 'zod/v4';
import { ai } from '../genkit.js';
import { InputQuestionSchema } from '../schemas.js';
import { getExchangeRate } from '../tools/exchange.js';

// Load prompts
const routerPrompt = ai.prompt('router');
const advicePrompt = ai.prompt('mammaAdvice');
const searchPrompt = ai.prompt('mammaSearch');

export const getMammaAdvice = ai.defineFlow(
  {
    name: 'getMammaAdvice',
    inputSchema: InputQuestionSchema,
  },
  async (input) => {
    // 1. Route to the correct prompt based on intent.
    const route = await routerPrompt(input);
    const intent = route.output.intent;
    
    console.log('[Routing] You asked for: %s', intent);

    // 2. Execute the appropriate prompt with the correct tools.
    if (intent === 'general_advice') {
      const response = await advicePrompt(input, {
        tools: [getExchangeRate]
      });
      return response.output;
    } else if (intent === 'market_news') {
      const response = await searchPrompt(input, {
        config: {
          tools: [{ // native Gemini API parameters - config passthrough
            googleSearch: {}
          }]
        }
      });
      return response.output;
    } else {
      // intent not recognized 
      return {
        response: 'Mamma doesn\'t know :-( ...',
        mammaApprovalRating: '0'
      }
    }
  }
);
