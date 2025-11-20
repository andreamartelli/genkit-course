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

/**
 * Singleton class that wraps the mcpClient for convenience
 */
class YahooFinanceMCP {

  /**
   * @private
   * BUG: due to a bug in Genkit it is not possible to cache tools.
   * See: https://github.com/firebase/genkit/pull/3828
   */
  _tools = null;

  /**
   * @private
   */
  _client = null;

  constructor() {
    // Init the MCP connection
    this._client = createMcpClient({
      name: 'yahooFinanceClient',
      mcpServer: {
        command: 'uvx',
        args: ['mcp-yahoo-finance']
      }
    });
    console.log('Yahoo Finance MCP Client created.');
  }

  /**
   * Returns the MCP client (it's a Genkit plugin)
   * @returns GenkitPlugin
   */
  async getClient() {
    return await this._client.ready();
  }

  async getTools() {
    await this.getClient();
    const tools = await this._client.getActiveTools(ai);
    console.log('\n* Enumerating available tools...');
    for(const t of tools) {
      console.log(' - ', t.__action.name);
    }
    console.log('\n');
    return tools;
  }
}

const instance = new YahooFinanceMCP();
Object.freeze(instance);

export default instance;
