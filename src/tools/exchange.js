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

export const getExchangeRate = ai.defineTool(
  {
    name: 'getExchangeRate',
    description: 'Retrieves the current exchange rate between two currencies.',
    inputSchema: z.object({
      fromCurrency: z.string().describe('The currency to convert from (e.g., "USD").'),
      toCurrency: z.string().describe('The currency to convert to (e.g., "EUR").'),
    }),
    outputSchema: z.object({
      rate: z.number().describe('The exchange rate.'),
    }),
  },
  async ({ fromCurrency, toCurrency }) => {
    try {
      // invoke external exchange API
      const response = await fetch(`https://api.frankfurter.app/latest?from=${fromCurrency}&to=${toCurrency}`);
      if (!response.ok) {
        throw new Error(`Failed to fetch exchange rate: ${response.statusText}`);
      }
      const data = await response.json();
      console.log('\n[getExchangeRate] Exchanged rate from external API:\n %s\n', JSON.stringify(data, null, 2));
      
      // parse API response and return tool result
      const rate = data.rates?.[toCurrency];
      if (rate === undefined) {
        throw new Error(`Rate for ${toCurrency} not found in response.`);
      }

      return { rate };
    } catch (error) {
      console.error('Error fetching exchange rate:', error);
      throw new Error('Could not retrieve the exchange rate.');
    }
  }
);
