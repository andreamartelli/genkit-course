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

import { expressHandler } from '@genkit-ai/express';
import { getMammaAdvice } from './flows/mamma.js';

import express from 'express';

const app = express();
app.use(express.json());

// can be called with:
// curl -X POST -H "Content-Type: application/json" -d '{"data": {"question": "Mamma, should I invest in gold or real estate?"}}'  http://localhost:8080/getMammaAdvice
app.post('/getMammaAdvice', expressHandler(getMammaAdvice));

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Express server listening on port ${port}`);
});