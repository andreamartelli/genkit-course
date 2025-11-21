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

// Reference: https://github.com/leoncuhk/mcp-yahoo-finance

import { ai } from '../genkit.js';
import { createMcpClient } from '@genkit-ai/mcp';
import * as z from 'zod';

// Define a dummy tool to be used as a fallback on Cloud Run
const dummyGetStockPrice = ai.defineTool(
  {
    name: 'dummy_getStockPrice',
    description: 'A dummy tool that returns a fake stock price.',
    inputSchema: z.object({ ticker: z.string() }),
    outputSchema: z.object({ price: z.number() }),
  },
  async ({ ticker }) => {
    console.log(`Dummy tool called for ticker: ${ticker}`);
    return { price: 123.45 };
  }
);

/**
 * Singleton class that wraps the mcpClient for convenience
 */
class YahooFinanceMCP {

  /**
   * @private
   */
  _client = null;

  constructor() {
    console.log('Yahoo Finance MCP Client singleton created.');
  }

  /**
   * Returns the MCP client (it's a Genkit plugin)
   * @returns GenkitPlugin
   */
  async getClient() {
    if (!this._client) {
      console.log('Initializing Yahoo Finance MCP Client...');
      this._client = createMcpClient({
        name: 'yahooFinanceClient',
        mcpServer: {
          command: 'uvx',
          args: ['mcp-yahoo-finance']
        }
      });
      console.log('Yahoo Finance MCP Client initialized.');
    }
    console.log('\n* Waiting for MCP client to be ready...');
    await this._client.ready();
    console.log('* MCP client ready!');
    return this._client;
  }

  async getTools() {
    // Check if running in a Cloud Run environment
    if (process.env.K_SERVICE) {
      console.log('\n* Cloud Run environment detected. Using dummy tool instead of MCP server.');
      return [dummyGetStockPrice];
    }

    // Proceed with real MCP client for local environment
    const client = await this.getClient();
    const tools = await client.getActiveTools(ai);
    console.log('\n* Enumerating available tools...');
    for(const t of tools) {
      console.log(' - ', t.__action.name);
    }
    console.log('\n');
    return tools;
  }
}

const instance = new YahooFinanceMCP();

export default instance;
