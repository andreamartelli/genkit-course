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

import { createMcpClient } from '@genkit-ai/mcp';

export class YahooFinanceMCP {
  constructor() {
    // Init the MCP connection
    this.client = createMcpClient({
      name: 'mcpYahooFinance',
      mcpServer: {
        command: 'uvx',
        args: ['mcp-yahoo-finance']
      }
    });
    console.log('Yahoo Finance MCP Client created.');
  }

  async getClient() {
    console.log('Waiting for MCP client to be ready...');
    await this.client.ready();
    console.log('MCP client ready!');
    return this.client;
  }
}