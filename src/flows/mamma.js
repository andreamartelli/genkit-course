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
import parseDataURL from 'data-urls';
import { ai } from '../genkit.js';
import { InputQuestionSchema } from '../schemas.js';
import { getExchangeRate } from '../tools/exchange.js';

// Load prompts
const routerPrompt = ai.prompt('router');
const advicePrompt = ai.prompt('mammaAdvice');
const searchPrompt = ai.prompt('mammaSearch');
const imagePrompt = ai.prompt('mammaImage');
const critiquePrompt = ai.prompt('critique');

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

      // Generate the general advice using an iterative refinement loop (critique pattern)
      let adviceOutput;
      let currentAdvice = '';
      let critique = '';
      const MAX_REFINEMENTS = 2; // Draft + 1 refinement

      for (let i = 0; i < MAX_REFINEMENTS; i++) {
        console.log(`[Refinement Loop] Iteration ${i + 1}`);
        console.log(`[${i + 1}] Generating draft advice...`);
        
        const textResponse = await advicePrompt({
          question: input.question,
          critique: critique, // Pass previous critique (if any)
          draft: currentAdvice, // Pass previous draft (if any)
        }, {
          tools: [getExchangeRate]
        });

        adviceOutput = textResponse.output;
        currentAdvice = adviceOutput.advice;

        // Critique the advice
        console.log(`[${i + 1}] Criticizing the draft advice...`);
        const critiqueResponse = await critiquePrompt({ advice: currentAdvice });
        const critiqueResult = critiqueResponse.output;

        if (critiqueResult.requiresRevision) {
          critique = critiqueResult.critique;
        } else {
          // Advice is good enough, break the loop
          break;
        }
      }
      // End of the critique loop

      // Generate an image for the FINAL refined advice
      const imageResponse = await imagePrompt(
        { advice: adviceOutput.advice },
        {
          config: {
            imageConfig: {
              aspectRatio: '16:9'
            }
          }
        }
      );

      const parsed = parseDataURL(imageResponse.media.url);
      if (parsed) {
        console.log('Advice fully generated.');
      }

      return { ...adviceOutput, imageData: imageResponse.media.url };
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
