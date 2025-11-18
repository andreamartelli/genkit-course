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

import { mcp } from '@genkit-ai/mcp';

// Create and export a single, configured MCP plugin instance.
// The key 'yfmcp' becomes the prefix for all tools from this server.
export const yahooFinancePlugin = mcp({
  yfmcp: {
    command: 'uvx',
    args: ['mcp-yahoo-finance'],
  },
});