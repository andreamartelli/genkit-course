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